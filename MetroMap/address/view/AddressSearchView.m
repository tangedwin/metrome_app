//
//  AddressSearchView.m
//  MetroMap
//
//  Created by edwin on 2019/10/22.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "AddressSearchView.h"

@interface AddressSearchView()<UICollectionViewDelegate, UICollectionViewDataSource, AMapSearchDelegate>

@property (nonatomic, retain) UICollectionViewFlowLayout *fallLayout;
@property (nonatomic, retain) NSMutableArray *dataStations;
@property (nonatomic, retain) NSMutableArray *dataAddresses;

@property (nonatomic, retain) AMapSearchAPI *mapSearch;
@property (nonatomic, retain) CityModel *city;

@property (nonatomic, assign) BOOL forStation;
@property (nonatomic, assign) BOOL localAddress;

@end

static NSString * const address_search_collection_id = @"address_search_collection";
@implementation AddressSearchView

-(instancetype)initWithFrame:(CGRect)frame{
    // 创建布局
    _fallLayout = [[UICollectionViewFlowLayout alloc]init];
    _fallLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self = [super initWithFrame:frame collectionViewLayout:_fallLayout];
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:address_search_collection_id];
    self.dataSource = self;
    self.delegate = self;
    self.allowsSelection = NO;
    self.alwaysBounceVertical = YES;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    self.backgroundColor = dynamic_color_white;
    self.showsVerticalScrollIndicator = YES;
    [self loadCollects];
    
    self.mapSearch = [[AMapSearchAPI alloc] init];
    self.mapSearch.delegate = self;
    return self;
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //根据注册标记查找cell
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:address_search_collection_id forIndexPath:indexPath];
    if(cell.contentView.subviews) for(UIView *sview in cell.contentView.subviews) [sview removeFromSuperview];
    if(indexPath.item<_dataStations.count){
        StationModel *station = _dataStations[indexPath.item];
        [self createCellTable:station cell:cell indexPath:indexPath];
    }else if(indexPath.item-_dataStations.count<_dataAddresses.count){
        AddressModel *address = _dataAddresses[indexPath.item-_dataStations.count];
        [self createAddressCellTable:address cell:cell indexPath:indexPath];
    }
    return cell;
}


-(void)createAddressCellTable:(AddressModel*)address cell:(UICollectionViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(view_margin, 0, SCREEN_WIDTH-view_margin, 52)];
    
    UILabel *titleName = [[UILabel alloc] initWithFrame:CGRectMake(0, 8, view.width-view_margin, 20)];
    titleName.font = main_font_small;
    titleName.textColor = dynamic_color_black;
    if(_localAddress) titleName.text = @"当前位置";
    else titleName.text = address.addressName;
    [view addSubview:titleName];
    
    UILabel *addressName = [[UILabel alloc] initWithFrame:CGRectMake(0, view.height-7-17, view.width-view_margin, 17)];
    addressName.font = sub_font_middle;
    addressName.textColor = dynamic_color_gray;
    addressName.text = address.address;
    [view addSubview:addressName];
        
    CALayer *viewBorder = [CALayer layer];
    viewBorder.frame = CGRectMake(0, view.height, view.width, 1);
    viewBorder.backgroundColor = dynamic_color_lightgray.CGColor;
    [view.layer addSublayer:viewBorder];
    [cell.contentView addSubview:view];
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectAddress:)];
    view.tag = indexPath.item-(_dataStations?_dataStations.count:0);
    view.userInteractionEnabled = YES;
    [view addGestureRecognizer:tap];
}

-(void)createCellTable:(StationModel*)station cell:(UICollectionViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(view_margin, 0, SCREEN_WIDTH-view_margin, 52)];
    
    UIView *typeView = [[UIView alloc] initWithFrame:CGRectMake(0, 16, 36, 20)];
    UILabel *typeName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 36, 20)];
    typeName.font = sub_font_middle;
    typeName.textColor = main_color_white;
    typeName.text = @"站点";
    typeName.textAlignment = NSTextAlignmentCenter;
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = CGRectMake(0, 0, 36, 20);
    gl.startPoint = CGPointMake(0, 0.5);
    gl.endPoint = CGPointMake(1, 0.5);
    gl.colors = gradual_color_pink;
    gl.locations = @[@(0), @(1.0f)];
    [typeView.layer addSublayer:gl];
    typeView.layer.cornerRadius = 3;
    typeView.layer.masksToBounds = YES;
    [typeView addSubview:typeName];
    [view addSubview:typeView];
    
    UILabel *titleName = [[UILabel alloc] init];
    NSString *titleStr = station.nameCn;
    CGSize titleSize = [titleStr sizeWithAttributes:@{NSFontAttributeName:main_font_small}];
    titleName.frame = CGRectMake(typeView.width+view_margin, 16, titleSize.width, 20);
    titleName.font = main_font_small;
    titleName.textColor = dynamic_color_black;
    titleName.text = titleStr;
    [view addSubview:titleName];
    
    NSMutableArray *array = [NSMutableArray new];
    for(NSNumber *lid in station.lines) {
        LineModel *line = _city.lineDicts[[lid stringValue]];
        if(line) [array addObject:line];
    }
    
//    NSMutableArray *array = station.lineModels;
    CGFloat x = view_margin;
    for(int i=0; i<array.count; i++){
        LineModel *line = array[i];
        CGSize lineSize = [line.nameSimple sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"DIN-Black" size:14]}];
        CGFloat lineWidth = lineSize.width<fitFloat(20)?fitFloat(20):(lineSize.width+10);
        x = x+lineWidth+6;
        UILabel *llabel = [[UILabel alloc] initWithFrame:CGRectMake(view.width-x, (52-fitFloat(20))/2, lineWidth, fitFloat(20))];
        llabel.backgroundColor = [ColorUtils colorWithHexString:line.color];
        if(!llabel.backgroundColor) llabel.backgroundColor = dynamic_color_gray;
        llabel.textColor = main_color_white;
        llabel.text = line.nameSimple;
        llabel.textAlignment = NSTextAlignmentCenter;
        llabel.font = [UIFont fontWithName:@"DIN-Black" size:14];
//        if(llabel.text.length<2) llabel.font = [UIFont fontWithName:@"DIN-Black" size:14];
//        else if(llabel.text.length<3) llabel.font = [UIFont fontWithName:@"DIN-Black" size:10];
//        else llabel.font = [UIFont fontWithName:@"DIN-Black" size:7];
        llabel.layer.cornerRadius = fitFloat(20)/2;
        llabel.layer.masksToBounds = YES;
        [view addSubview:llabel];
    }
        
    CALayer *viewBorder = [CALayer layer];
    viewBorder.frame = CGRectMake(0, view.height, view.width, 1);
    viewBorder.backgroundColor = dynamic_color_lightgray.CGColor;
    [view.layer addSublayer:viewBorder];
    [cell.contentView addSubview:view];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectStation:)];
    view.tag = indexPath.item;
    view.userInteractionEnabled = YES;
    [view addGestureRecognizer:tap];
}


-(void)selectAddress:(UITapGestureRecognizer*)tap{
    if(_dataAddresses.count>tap.view.tag){
        if(!_forStation && self.selectedAddress){
            self.selectedAddress(_dataAddresses[tap.view.tag], self.city);
        }else{
            //查询附近站点
            [LocationHelper queryStationByAddress:_dataAddresses[tap.view.tag] success:^(StationModel *station) {
                if(station && self.selectedStation) self.selectedStation(station, self.city);
                else if(!station){
                    [MBProgressHUD showInfo:@"未找到附近地铁站" detail:nil image:nil inView:nil];
                }
            }];
        }
    }
}

-(void)selectStation:(UITapGestureRecognizer*)tap{
    if(_forStation && _dataStations.count>tap.view.tag){
        NSString *curCityId = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_CITY_ID_KEY];
        StationModel *station = _dataStations[tap.view.tag];
        if(!curCityId || [curCityId integerValue]!=station.city.identifyCode){
            [[AlertUtils new] showTipsView:@"该站点非当前城市" seconds:2.f];
        }else{
            if(self.selectedStation) self.selectedStation(_dataStations[tap.view.tag], _city);
        }
    }
}

//设置cell的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(SCREEN_WIDTH, 52);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

//设置section间隔
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    //分别为上、左、下、右
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

//返回列表分组数，默认为1
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

//返回列表每个分组section拥有cell行数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _dataAddresses.count + _dataStations.count;
}


-(void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    if(response.pois.count>0){
        self.dataAddresses = [NSMutableArray new];
        for(AMapPOI *poi in response.pois){
            AddressModel *address = [AddressModel new];
            address.addressName = poi.name;
            address.address = poi.address;
            address.latitude = poi.location.latitude;
            address.longitude = poi.location.longitude;
            address.cityName = poi.city;
            [self.dataAddresses addObject:address];
        }
        [self reloadData];
    }
}

-(void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response{
    NSString *location = [[NSUserDefaults standardUserDefaults] objectForKey:LOCATION_LOC_KEY];
    NSString *cityId = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_CITY_ID_KEY];
    NSString *cityName = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_CITY_NAME_KEY];
    if(location) {
        NSArray *array = [location componentsSeparatedByString:@","];
        AMapAddressComponent *addressComp = response.regeocode.addressComponent;
        AddressModel *localAddress = [[AddressModel alloc] init];
        localAddress.address = response.regeocode.formattedAddress;
        if(addressComp.building && addressComp.building.length>0) localAddress.addressName = addressComp.building;
        else localAddress.addressName = @"未知地名";
        localAddress.latitude = [array[1] floatValue];
        localAddress.longitude = [array[0] floatValue];
        if(cityId) localAddress.cityId = [cityId integerValue];
        localAddress.cityName = cityName;
        _dataAddresses = [NSMutableArray new];
        [_dataAddresses addObject:localAddress];
    }
    [self reloadData];
}

-(void)searchMap:(NSString*)keywords forStation:(BOOL)forStation{
    NSInteger cityId = [[[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_CITY_ID_KEY] integerValue];
    if(!cityId) cityId = 1;
    _city = [CityZipUtils parseFileToCityModel:cityId];
    if(!_city) return;

    if(keywords && keywords.length>0){
        _localAddress = NO;
        AMapPOIKeywordsSearchRequest *request = [[AMapPOIKeywordsSearchRequest alloc] init];
        request.keywords = keywords;
        request.city = _city.nameCn;
        request.cityLimit = YES;
        [self.mapSearch AMapPOIKeywordsSearch:request];
        
        if(forStation){
            self.dataStations = [NSMutableArray new];
            for(StationModel *station in _city.stations){
                if([station.nameCn containsString:keywords] && self.dataStations.count<6){
                    station.city = self.city;
                    [self.dataStations addObject:station];
                }
            }
            _forStation = YES;
            [self reloadData];
        }
    }else{
        if(!forStation){
            _localAddress = YES;
            NSString *location = [[NSUserDefaults standardUserDefaults] objectForKey:LOCATION_LOC_KEY];
            if(location) {
                NSArray *array = [location componentsSeparatedByString:@","];
                AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
                regeo.location = [AMapGeoPoint locationWithLatitude:[array[1] floatValue] longitude:[array[0] floatValue]];
        //      regeo.location = [AMapGeoPoint locationWithLatitude:31.2090503 longitude:121.4591430];
                [self.mapSearch AMapReGoecodeSearch:regeo];
            }
        }
    }
}
//图片
- (void)loadCollects{
    _dataAddresses = [NSMutableArray new];
    _dataStations = [NSMutableArray new];
}


@end
