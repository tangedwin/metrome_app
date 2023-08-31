//
//  CitySearchView.m
//  MetroMap
//
//  Created by edwin on 2019/10/8.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "CitySearchView.h"

@interface CitySearchView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, retain) UICollectionViewFlowLayout *fallLayout;

//@property (nonatomic, retain) NSMutableArray<NSDictionary*> *dataResult;
@property (nonatomic, retain) NSMutableArray *stations;
@property (nonatomic, retain) NSString *keywords;
@property (nonatomic, assign) NSInteger curPage;


@property (nonatomic, retain) UIView *noDataView;

@property (nonatomic, retain) MetroMapHelper *metroMapHelper;

@property(nonatomic, retain) NSMutableArray *layers;

@end

static NSString * const city_search_collection_id = @"city_search_collection";
@implementation CitySearchView


-(instancetype)initWithFrame:(CGRect)frame{
    // 创建布局
    _fallLayout = [[UICollectionViewFlowLayout alloc]init];
    _fallLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self = [super initWithFrame:frame collectionViewLayout:_fallLayout];
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:city_search_collection_id];
    self.dataSource = self;
    self.delegate = self;
    self.showsVerticalScrollIndicator = YES;
    self.showsHorizontalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    self.backgroundColor = dynamic_color_white;
    _metroMapHelper = [MetroMapHelper new];
    [self setupRefresh];
    return self;
}
#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //根据注册标记查找cell
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:city_search_collection_id forIndexPath:indexPath];
    if(cell.contentView.subviews) for(UIView *view in cell.contentView.subviews) [view removeFromSuperview];
    if(_stations.count>indexPath.section){
        StationModel *station = _stations[indexPath.section];
        [self createCell:station cell:cell index:indexPath];
    }
    return cell;
}

-(void)createCell:(StationModel*)station cell:(UICollectionViewCell*)cell index:(NSIndexPath*)indexPath{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(view_margin, 0, SCREEN_WIDTH-view_margin, 52)];
    
    NSString *name = station.nameCn?station.nameCn:station.city.nameCn;
    NSString *type = [@"站点" isEqualToString:station.type]?@"站点":@"城市";
    
    
    UIView *typeView = [[UIView alloc] initWithFrame:CGRectMake(0, 16, 36, 20)];
    UILabel *typeName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 36, 20)];
    typeName.font = sub_font_middle;
    typeName.textColor = main_color_white;
    typeName.text = type;
    typeName.textAlignment = NSTextAlignmentCenter;
    
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = CGRectMake(0, 0, 36, 20);
    gl.startPoint = CGPointMake(0, 0.5);
    gl.endPoint = CGPointMake(1, 0.5);
    gl.colors = [@"城市" isEqualToString:type] ? gradual_color_blue : gradual_color_pink;
    gl.locations = @[@(0), @(1.0f)];
    [typeView.layer addSublayer:gl];
    typeView.layer.cornerRadius = 3;
    typeView.layer.masksToBounds = YES;
    
    [typeView addSubview:typeName];
    [view addSubview:typeView];
    
    UILabel *titleName = [[UILabel alloc] init];
    CGSize titleSize = [name sizeWithAttributes:@{NSFontAttributeName:main_font_small}];
    titleName.frame = CGRectMake(48, 16, titleSize.width, 20);
    titleName.font = main_font_small;
    titleName.textColor = dynamic_color_black;
    titleName.text = name;
    [view addSubview:titleName];
    
    if([@"站点" isEqualToString:station.type] && station.city.nameCn){
        CGSize cityNameSize = [station.city.nameCn sizeWithAttributes:@{NSFontAttributeName:main_font_small}];
        UILabel *cityName = [[UILabel alloc] initWithFrame:CGRectMake(titleName.x+titleName.width+24, 16, cityNameSize.width, 20)];
        cityName.font = main_font_small;
        cityName.textColor = main_color_blue;
        cityName.text = station.city.nameCn;
        [view addSubview:cityName];
    }
    if(station.lineModels){
        CGFloat x = view_margin;
        for(int i=0; i<station.lineModels.count; i++){
            LineModel *line = station.lineModels[i];
            CGSize lineSize = [line.nameSimple sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"DIN-Black" size:14]}];
            CGFloat lineWidth = lineSize.width<fitFloat(20)?fitFloat(20):(lineSize.width+10);
            x = x+lineWidth+6;
            UILabel *llabel = [[UILabel alloc] initWithFrame:CGRectMake(view.width-x, (52-fitFloat(20))/2, lineWidth, fitFloat(20))];
            llabel.backgroundColor = [ColorUtils colorWithHexString:line.color];
            llabel.textColor = main_color_white;
            llabel.text = line.nameSimple;
            llabel.textAlignment = NSTextAlignmentCenter;
            llabel.font = [UIFont fontWithName:@"DIN-Black" size:14];
//            if(llabel.text.length<2) llabel.font = [UIFont fontWithName:@"DIN-Black" size:14];
//            else if(llabel.text.length<3) llabel.font = [UIFont fontWithName:@"DIN-Black" size:10];
//            else llabel.font = [UIFont fontWithName:@"DIN-Black" size:7];
llabel.layer.cornerRadius = fitFloat(20)/2;
            llabel.layer.masksToBounds = YES;
            [view addSubview:llabel];
        }
    }
    
    CALayer *viewBorder = [CALayer layer];
    viewBorder.frame = CGRectMake(0, view.height, view.width, 1);
    viewBorder.backgroundColor = dynamic_color_lightgray.CGColor;
    [view.layer addSublayer:viewBorder];
    [cell.contentView addSubview:view];
    if(!_layers) _layers = [NSMutableArray new];
    [_layers addObject:viewBorder];
    
    
    if([@"站点" isEqualToString:station.type] && station.city.identifyCode){
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadStationInCity:)];
        view.tag = indexPath.section;
        view.userInteractionEnabled = YES;
        [view addGestureRecognizer:tap];
    }else if([@"城市" isEqualToString:station.type] && station.city.identifyCode){
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadCity:)];
        view.tag = indexPath.section;
        view.userInteractionEnabled = YES;
        [view addGestureRecognizer:tap];
    }
}

-(void)loadStationInCity:(UITapGestureRecognizer*)tap{
    if(tap.view.tag<_stations.count){
        StationModel *station = _stations[tap.view.tag];
        CityModel *city = station.city;
        __weak typeof(self) wkSelf = self;
        [_metroMapHelper loadMetroMap:city success:^{
            if(wkSelf.reloadCityData) wkSelf.reloadCityDataWithStation(station);
        }];
    }
}

-(void)loadCity:(UITapGestureRecognizer*)tap{
    if(tap.view.tag<_stations.count){
        StationModel *station = _stations[tap.view.tag];
        CityModel *city = station.city;
        __weak typeof(self) wkSelf = self;
        [_metroMapHelper loadMetroMap:city success:^{
            if(wkSelf.reloadCityData) wkSelf.reloadCityData();
        }];
    }
}

//返回collection的section数量
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return _stations.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

// 设置UIcollectionView整体的内边距（这样item不贴边显示）
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // 上 左 下 右
    return UIEdgeInsetsMake(2,view_margin,6,0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(SCREEN_WIDTH, 53);
}


- (void)setupRefresh{
    MJChiBaoZiHeader *header = [MJChiBaoZiHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadCityAndStations)];
    self.mj_header = header;
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    self.mj_header.backgroundColor = [UIColor clearColor];
    self.mj_footer.hidden = NO;
    
    self.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreCityAndStations)];
    self.mj_footer.backgroundColor = [UIColor clearColor];
    self.mj_footer.hidden = YES;
}



-(void)showNoDataView{
    if(_noDataView){
        [_noDataView removeFromSuperview];
        _noDataView = nil;
    }
    _stations = [NSMutableArray new];
    _noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 3, SCREEN_WIDTH, 17)];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 17)];
    label.font = sub_font_middle;
    label.textColor = dynamic_color_gray;
    label.text = @"抱歉，没有找到您搜索的内容";
    label.textAlignment = NSTextAlignmentCenter;
    [_noDataView addSubview:label];
    [self addSubview:_noDataView];
}

-(void)removeNoDataView{
    if(_noDataView){
        [_noDataView removeFromSuperview];
        _noDataView = nil;
    }
}

-(void)loadCityAndStations{
    [self searchCityAndStations:_keywords];
}
-(void) searchCityAndStations:(NSString*)keyword{
    if(!keyword || keyword.length<=0) return;
    _keywords = keyword;
    __weak typeof(self) wkSelf = self;
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:keyword forKey:@"keywords"];
    [params setObject:@(20) forKey:@"pageSize"];
    _curPage = 0;
    [[HttpHelper new] findList:request_city_search params:params page:_curPage progress:^(NSProgress *progress) {
    } success:^(NSMutableDictionary *responseDic) {
        NSMutableArray *stationArray = (NSMutableArray *)[responseDic mutableArrayValueForKey:@"list"];
        if(stationArray && stationArray.count>0){
            NSMutableArray *stations = [NSMutableArray new];
            for(NSDictionary *sd in stationArray){
                StationModel *station = [StationModel yy_modelWithJSON:sd];
                if(sd[@"stationId"]) [station setIdentifyCode:[sd[@"stationId"] integerValue]];
                if(sd[@"name"]) [station setNameCn:sd[@"name"]];
                [stations addObject:station];
            }
            [wkSelf removeNoDataView];
            wkSelf.curPage = wkSelf.curPage+1;
            wkSelf.stations = stations;
            [wkSelf.mj_header endRefreshing];
            if(stations.count>11) wkSelf.mj_footer.hidden = NO;
            [wkSelf reloadData];
        }else{
            wkSelf.stations = [NSMutableArray new];
            [wkSelf reloadData];
            [wkSelf showNoDataView];
            [wkSelf.mj_header endRefreshing];
        }
    } failure:^(NSString *errorInfo) {
        wkSelf.stations = [NSMutableArray new];
        [wkSelf showNoDataView];
        [wkSelf.mj_header endRefreshing];
    }];
}

-(void) loadMoreCityAndStations{
    if(_keywords.length<=0) return;
    __weak typeof(self) wkSelf = self;
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:_keywords forKey:@"keywords"];
    [params setObject:@(20) forKey:@"pageSize"];
    [[HttpHelper new] findList:request_city_search params:params page:_curPage progress:^(NSProgress *progress) {
    } success:^(NSMutableDictionary *responseDic) {
        NSMutableArray *stationArray = (NSMutableArray *)[responseDic mutableArrayValueForKey:@"list"];
        if(stationArray && stationArray.count>0){
            NSMutableArray *stations = [NSMutableArray new];
            for(NSDictionary *sd in stationArray){
                StationModel *station = [StationModel yy_modelWithJSON:sd];
                if(sd[@"stationId"]) [station setIdentifyCode:[sd[@"stationId"] integerValue]];
                if(sd[@"name"]) [station setNameCn:sd[@"name"]];
                [stations addObject:station];
            }
            [wkSelf removeNoDataView];
            wkSelf.curPage = wkSelf.curPage+1;
            [wkSelf.stations addObjectsFromArray:stations];
            [wkSelf reloadData];
            if(stations.count>0) [wkSelf.mj_footer endRefreshing];
            else {
                [wkSelf.mj_footer endRefreshingWithNoMoreData];
                [wkSelf performSelector:@selector(endRefreshing) withObject:nil afterDelay:2.f];
            }
        }else {
            [wkSelf.mj_footer endRefreshingWithNoMoreData];
            [wkSelf performSelector:@selector(endRefreshing) withObject:nil afterDelay:2.f];
        }
    } failure:^(NSString *errorInfo) {
        [wkSelf.mj_footer endRefreshing];
        [wkSelf removeNoDataView];
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
            if(self.layers) for(CALayer *layer in self.layers){
                layer.backgroundColor = dynamic_color_lightgray.CGColor;
            }
            MJChiBaoZiHeader *header = [MJChiBaoZiHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadCityAndStations)];
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
