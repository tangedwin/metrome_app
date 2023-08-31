//
//  TripCollectionView.m
//  MetroMap
//
//  Created by edwin on 2019/10/9.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "AddressCollectsView.h"

@interface AddressCollectsView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, retain) UICollectionViewFlowLayout *fallLayout;
@property (nonatomic, retain) NSMutableArray *addressCollects;
@property (nonatomic, retain) StationCollectsHelper *stationCollectsHelper;

@property (nonatomic, assign) double locLat;
@property (nonatomic, assign) double locLon;
@property (nonatomic, assign) BOOL withAddress;

@end

static NSString * const address_collection_id = @"address_collection";
static NSString * const address_collection_header_id = @"address_collection_header";
@implementation AddressCollectsView

-(instancetype)initWithFrame:(CGRect)frame withCommenAddress:(BOOL)withAddress{
    // 创建布局
    _fallLayout = [[UICollectionViewFlowLayout alloc]init];
    _fallLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self = [super initWithFrame:frame collectionViewLayout:_fallLayout];
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:address_collection_id];
    [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:address_collection_header_id];
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
    self.withAddress = withAddress;
//    if(withAddress) [self loadCommenAddress];
//    [self loadCollectStations];
    [[NSUserDefaults standardUserDefaults] objectForKey:LOCATION_LOC_KEY];
    
    NSString *location = [[NSUserDefaults standardUserDefaults] objectForKey:LOCATION_LOC_KEY];
    if(location) {
        NSArray *array = [location componentsSeparatedByString:@","];
        _locLon = [array[0] doubleValue];
        _locLat = [array[1] doubleValue];
    }
    
    [self setupRefresh];
    [self.mj_header beginRefreshing];
    return self;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:address_collection_header_id forIndexPath:indexPath];
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        if(reusableView.subviews) for(UIView *sview in reusableView.subviews) [sview removeFromSuperview];
        if(indexPath.section==0 && _withAddress) return reusableView;
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(view_margin, 0, SCREEN_WIDTH-view_margin*2, 25)];
        label.font = main_font_big;
        label.textColor = dynamic_color_black;
        label.text = @"收藏站点";
        [reusableView addSubview:label];
        
        UIImageView *collectsIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"collects_icon"]];
        collectsIcon.frame = CGRectMake(view_margin, 31, 24, 24);
        [reusableView addSubview:collectsIcon];
        
        UILabel *sublabel = [[UILabel alloc] initWithFrame:CGRectMake(view_margin+27, 33, SCREEN_WIDTH-view_margin*2-27, 20)];
        sublabel.font = main_font_small;
        sublabel.textColor = dynamic_color_gray;
        sublabel.text = [NSString stringWithFormat:@"%lld 个站点", _stationCollectsHelper.dataCount];
        [reusableView addSubview:sublabel];
        
        reusableView.backgroundColor = dynamic_color_white;
    }
    //如果是头视图
    return reusableView;
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //根据注册标记查找cell
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:address_collection_id forIndexPath:indexPath];
    if(cell.contentView.subviews) for(UIView *sview in cell.contentView.subviews) [sview removeFromSuperview];
    if(indexPath.section == 1 || !_withAddress){
        StationModel *station = _stationCollectsHelper.stationList[indexPath.item];
        [self createCellTable:station cell:cell indexPath:indexPath];
    }else{
        AddressModel *home = nil;
        AddressModel *company = nil;
        if(_addressCollects) for(AddressModel *address in _addressCollects){
            if([home_type isEqualToString:address.type]) home = address;
            if([company_type isEqualToString:address.type]) company = address;
        }
        [self createCommonAddress: home company:company cell:cell indexPath:indexPath];
    }
    return cell;
}


-(void)createCommonAddress:(AddressModel*)addressHome company:(AddressModel*)addressCompany cell:(UICollectionViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    UIView *viewHome = [[UIView alloc] initWithFrame:CGRectMake(view_margin, 0, (SCREEN_WIDTH-view_margin*2-6)/2, fitFloat(105))];
    UIImageView *homeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_big"]];
    homeIcon.frame = CGRectMake(view_margin, 12, 24, 24);
    [viewHome addSubview:homeIcon];
    UILabel *homeLabel = [[UILabel alloc] initWithFrame:CGRectMake(view_margin, 42, fitFloat(40), 14)];
    homeLabel.font = sub_font_small;
    homeLabel.textColor = dynamic_color_gray;
    homeLabel.text = @"家庭住址";
    [viewHome addSubview:homeLabel];
    UILabel *homeName = [[UILabel alloc] initWithFrame:CGRectMake(view_margin, 56, viewHome.width-view_margin*2, fitFloat(20))];
    if(addressHome){
        homeName.font = main_font_middle_small;
        homeName.textColor = dynamic_color_black;
        homeName.text = addressHome.addressName;
    }else{
        homeName.font = main_font_middle_small;
        homeName.textColor = dynamic_color_gray;
        homeName.text = @"添加家庭地址";
    }
    [viewHome addSubview:homeName];
    
    if(addressHome){
        UILabel *homeAddress = [[UILabel alloc] initWithFrame:CGRectMake(view_margin, 56+fitFloat(20), viewHome.width-view_margin*2, fitFloat(17))];
        homeAddress.font = sub_font_middle;
        homeAddress.textColor = dynamic_color_gray;
        homeAddress.text = addressHome.address;
        [viewHome addSubview:homeAddress];
    }
    
    UITapGestureRecognizer *tap1 = nil;
    if(!addressHome) tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editCommenAddress:)];
    else tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedAddress:)];
    [viewHome addGestureRecognizer:tap1];
    viewHome.tag = 0;
    viewHome.userInteractionEnabled = YES;
    
    viewHome.backgroundColor = dynamic_color_lightwhite;
//    viewHome.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    viewHome.layer.cornerRadius = 12;
    viewHome.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05].CGColor;
    viewHome.layer.shadowOffset = CGSizeMake(0,3);
    viewHome.layer.shadowOpacity = 1;
    viewHome.layer.shadowRadius = 6;
    
    
    UIView *viewCompany = [[UIView alloc] initWithFrame:CGRectMake(view_margin+viewHome.width+6, 0, (SCREEN_WIDTH-view_margin*2-6)/2, fitFloat(105))];
    UIImageView *companyIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"company_big"]];
    companyIcon.frame = CGRectMake(view_margin, 12, 24, 24);
    [viewCompany addSubview:companyIcon];
    UILabel *companyLabel = [[UILabel alloc] initWithFrame:CGRectMake(view_margin, 42, fitFloat(40), 14)];
    companyLabel.font = sub_font_small;
    companyLabel.textColor = dynamic_color_gray;
    companyLabel.text = @"公司地址";
    [viewCompany addSubview:companyLabel];
    UILabel *companyName = [[UILabel alloc] initWithFrame:CGRectMake(view_margin, 56, viewCompany.width-view_margin*2, fitFloat(20))];
    if(addressCompany){
        companyName.font = main_font_middle_small;
        companyName.textColor = dynamic_color_black;
        companyName.text = addressCompany.addressName;
    }else{
        companyName.font = main_font_middle_small;
        companyName.textColor = dynamic_color_gray;
        companyName.text = @"添加公司地址";
    }
    [viewCompany addSubview:companyName];
    
    if(addressCompany){
        UILabel *companyAddress= [[UILabel alloc] initWithFrame:CGRectMake(view_margin, 56+fitFloat(20), viewCompany.width-view_margin*2, fitFloat(17))];
        companyAddress.font = sub_font_middle;
        companyAddress.textColor = dynamic_color_gray;
        companyAddress.text = addressCompany.address;
        [viewCompany addSubview:companyAddress];
    }
    UITapGestureRecognizer *tap2 = nil;
    if(!addressCompany) tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editCommenAddress:)];
    else tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedAddress:)];
    [viewCompany addGestureRecognizer:tap2];
    viewCompany.tag = 1;
    viewCompany.userInteractionEnabled = YES;
    
    viewCompany.backgroundColor = dynamic_color_lightwhite;
//    viewCompany.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
    viewCompany.layer.cornerRadius = 12;
    viewCompany.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05].CGColor;
    viewCompany.layer.shadowOffset = CGSizeMake(0,3);
    viewCompany.layer.shadowOpacity = 1;
    viewCompany.layer.shadowRadius = 6;
    
    [cell.contentView addSubview:viewHome];
    [cell.contentView addSubview:viewCompany];
}

//编辑地址
-(void)editCommenAddress:(UITapGestureRecognizer*)tap{
    if(self.editCommenAddress) self.editCommenAddress(_addressCollects);
}
//选中地址
-(void)selectedAddress:(UITapGestureRecognizer*)tap{
    __weak typeof(self) wkSelf = self;
    if(self.selectedStation) {
        if(tap.view.tag==0) for(AddressModel *address in _addressCollects){
            if([home_type isEqualToString:address.type]) {
                [LocationHelper queryStationByAddress:address success:^(StationModel *station) {
                    if(station && wkSelf.selectedStation) {
                        NSString *curCityId = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_CITY_ID_KEY];
                        if(!curCityId || [curCityId integerValue]!=address.cityId){
                            [[AlertUtils new] showTipsView:@"该地址非当前选择城市" seconds:2.f];
                        }else{
                            wkSelf.selectedStation(station);
                        }
                    }
                    else if(!station) {
                        [MBProgressHUD showInfo:@"未找到附近地铁站" detail:nil image:nil inView:nil];
                    }
                }];
            }
        }
        if(tap.view.tag==1) for(AddressModel *address in _addressCollects){
            if([company_type isEqualToString:address.type]) {
                [LocationHelper queryStationByAddress:address success:^(StationModel *station) {
                    if(station && wkSelf.selectedStation) {
                        NSString *curCityId = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_CITY_ID_KEY];
                        if(!curCityId || [curCityId integerValue]!=address.cityId){
                            [[AlertUtils new] showTipsView:@"该地址非当前城市" seconds:2.f];
                        }else{
                            wkSelf.selectedStation(station);
                        }
                    }
                    else if(!station) {
                        [MBProgressHUD showInfo:@"未找到附近地铁站" detail:nil image:nil inView:nil];
                    }
                }];
            }
        }
    }
}
-(void)selectStation:(UITapGestureRecognizer*)tap{
    if(tap.view.tag<_stationCollectsHelper.stationList.count){
        StationModel *station = _stationCollectsHelper.stationList[tap.view.tag];
        if(station && self.selectedStation) self.selectedStation(station);
    }
}

-(void)createCellTable:(StationModel*)station cell:(UICollectionViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(view_margin, 0, SCREEN_WIDTH-view_margin, 52)];
    
    NSString *titleStr = station.nameCn;

    NSString *curCityId = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_CITY_ID_KEY];
    if((curCityId && station.city.identifyCode!=[curCityId integerValue]) || !_withAddress){
        //不是当前城市不显示公里数而显示城市
    } else if(_locLon>0 && _locLat>0 && station.latitude>0 && station.longitude>0){
        double distance = [LocationHelper getDistanceBetweenLat1:_locLat lon1:_locLon lat2:station.latitude lon2:station.longitude];
        if(distance>0 && distance<1000) titleStr = [NSString stringWithFormat:@"%@ · %.0f 米", titleStr, distance];
        else if(distance>=1000 && distance<2000) titleStr = [NSString stringWithFormat:@"%@ · 约 %.2f 公里", titleStr, distance/1000];
        else if(distance>=2000 && distance<100000) titleStr = [NSString stringWithFormat:@"%@ · %.0f 公里",titleStr,  distance/1000];
    }
    
    UILabel *titleName = [[UILabel alloc] init];
    CGSize titleSize = [titleStr sizeWithAttributes:@{NSFontAttributeName:main_font_small}];
    titleName.frame = CGRectMake(0, 16, titleSize.width, 20);
    titleName.font = main_font_small;
    titleName.textColor = dynamic_color_black;
    titleName.text = titleStr;
    [view addSubview:titleName];
    if((curCityId && station.city.identifyCode!=[curCityId integerValue]) || !_withAddress){
        CGSize cityNameSize = [station.city.nameCn sizeWithAttributes:@{NSFontAttributeName:main_font_small}];
        UILabel *cityName = [[UILabel alloc] initWithFrame:CGRectMake(titleName.x+titleName.width+24, 16, cityNameSize.width, 20)];
        cityName.font = main_font_small;
        cityName.textColor = main_color_blue;
        cityName.text = station.city.nameCn;
        [view addSubview:cityName];
    }
        
    NSMutableArray *array = station.lineModels;
    for(int i=0; i<array.count; i++){
        LineModel *line = array[i];
        UILabel *llabel = [[UILabel alloc] initWithFrame:CGRectMake(view.width-((array.count-i)*26+view_margin), 16, 20, 20)];
        llabel.backgroundColor = [ColorUtils colorWithHexString:line.color];
        if(!llabel.backgroundColor) llabel.backgroundColor = dynamic_color_gray;
        llabel.textColor = dynamic_color_white;
        llabel.text = line.code;
        llabel.textAlignment = NSTextAlignmentCenter;
        if(llabel.text.length<2) llabel.font = [UIFont fontWithName:@"DIN-Black" size:14];
        else if(llabel.text.length<3) llabel.font = [UIFont fontWithName:@"DIN-Black" size:10];
        else llabel.font = [UIFont fontWithName:@"DIN-Black" size:7];
        llabel.layer.cornerRadius = 10;
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



-(void)reloadAddressData{
    if(_withAddress) [self loadCommenAddress];
    [self reloadData];
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if(section==0 && _withAddress) return CGSizeZero;
    else return CGSizeMake(SCREEN_WIDTH, 57);
}

//设置cell的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0 && _withAddress) return CGSizeMake(SCREEN_WIDTH, 86+fitFloat(37));
    else return CGSizeMake(SCREEN_WIDTH, 52);
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
    if(_withAddress) return 2;
    else return 1;
}

//返回列表每个分组section拥有cell行数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(section==0 && _withAddress) return 1;
    else return _stationCollectsHelper.stationList.count;
}


#pragma mark --MJRefresh
//设置页头页尾和更新数据的方法
- (void)setupRefresh{
//    self.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNews)];
    MJChiBaoZiHeader *header = [MJChiBaoZiHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    self.mj_header = header;
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    self.mj_header.backgroundColor = [UIColor clearColor];
    self.mj_footer.hidden = NO;
    
    self.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(moreCollectStations)];
    self.mj_footer.backgroundColor = [UIColor clearColor];
    self.mj_footer.hidden = YES;
}

-(void)loadNewData{
    if(_withAddress) [self loadCommenAddress];
    [self loadCollectStations];
}


-(void)loadCommenAddress{
    __weak typeof(self) wkSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary new];
    [[HttpHelper new] findList:request_commen_address_collect params:params page:0 progress:^(NSProgress *progress) {
    } success:^(NSMutableDictionary *responseDic) {
        NSMutableArray *resultArray = (NSMutableArray *)[responseDic mutableArrayValueForKey:@"list"];
        if(!resultArray) return;
        wkSelf.addressCollects = [NSMutableArray new];
        for(int i=0; i<resultArray.count; i++){
            [wkSelf.addressCollects addObject:[AddressModel yy_modelWithJSON:resultArray[i]]];
        }
        [wkSelf reloadData];
    } failure:^(NSString *errorInfo) {
    }];
}

-(void)loadCollectStations{
    if(!_stationCollectsHelper){
        _stationCollectsHelper = [StationCollectsHelper new];
        _stationCollectsHelper.uri = request_station_collect_list;
    }
    __weak typeof(self) wkSelf = self;
    [_stationCollectsHelper loadStations:^(NSInteger count) {
        [wkSelf reloadData];
        [wkSelf.mj_header endRefreshing];
        if(count>9) wkSelf.mj_footer.hidden = NO;
    } failure:^(NSString *errorInfo) {
        [wkSelf.mj_header endRefreshing];
    }];
}
-(void)moreCollectStations{
    __weak typeof(self) wkSelf = self;
    [_stationCollectsHelper moreStations:^(NSInteger count) {
        [wkSelf reloadData];
        if(count>0) [wkSelf.mj_footer endRefreshing];
        else {
            [wkSelf.mj_footer endRefreshingWithNoMoreData];
            [wkSelf performSelector:@selector(endRefreshing) withObject:nil afterDelay:2.f];
        }
    } failure:^(NSString *errorInfo) {
        [wkSelf.mj_footer endRefreshing];
    }];
}

-(void)endRefreshing{
    [self.mj_footer setHidden:YES];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    __weak typeof(self) wkSelf = self;
    // trait发生了改变
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            MJChiBaoZiHeader *header = [MJChiBaoZiHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
            self.mj_header = header;
            header.lastUpdatedTimeLabel.hidden = YES;
            header.stateLabel.hidden = YES;
            self.mj_header.backgroundColor = [UIColor clearColor];
            self.mj_footer.hidden = NO;
        }
    } else {
    }
}
@end
