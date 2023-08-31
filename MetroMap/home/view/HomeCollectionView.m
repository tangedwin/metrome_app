//
//  HomeCollectionView.m
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "HomeCollectionView.h"
#import "GDTNativeExpressAd.h"
#import "GDTNativeExpressAdView.h"
#import "AdScrollView.h"

@interface HomeCollectionView()<UICollectionViewDelegate, UICollectionViewDataSource, GDTNativeExpressAdDelegete>
//布局
@property (nonatomic, retain) UICollectionViewFlowLayout *fallLayout;
@property (nonatomic, retain) NSMutableArray *dataStationLines;

@property (nonatomic, assign) NSInteger cityId;
@property (nonatomic, retain) StationModel *nearbyStation;
@property (nonatomic, assign) NSInteger distance;
@property (nonatomic, retain) NSString *loc;
@property (nonatomic, assign) BOOL locationed;

@property (nonatomic, strong) NSArray *expressAdViews;
@property (nonatomic, strong) GDTNativeExpressAd *nativeExpressAd;
@property (nonatomic, strong) AdScrollView *adScrollView;
@property (nonatomic, strong) RecommendArticleCollectionView *articleCollectionView;

@property(nonatomic, retain) StationNearByView *stationNearbyView;
@property(nonatomic, retain) HotCityListView *hotCityListView;
@property(nonatomic, retain) NSMutableArray *dataNewsList;

@end

static NSString * const home_collection_id = @"home_collection";
static NSString * const home_collection_header_id = @"home_collection_header";
@implementation HomeCollectionView

-(instancetype)initWithFrame:(CGRect)frame{
    // 创建布局
    _fallLayout = [[UICollectionViewFlowLayout alloc]init];
    _fallLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _fallLayout.sectionHeadersPinToVisibleBounds = YES;
    self = [super initWithFrame:frame collectionViewLayout:_fallLayout];
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:home_collection_id];
    [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:home_collection_header_id];
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
    self.showsVerticalScrollIndicator = NO;
    [self loadScrollImageInfo:YES];
    [self setupRefresh];
    return self;
}

- (void)setupRefresh{
//    self.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNews)];
    MJChiBaoZiHeader *header = [MJChiBaoZiHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadPage)];
    self.mj_header = header;
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    self.mj_header.backgroundColor = [UIColor clearColor];
}

-(void)reloadPage{
//    [self reloadData];
    [self reloadNearByStation];
    [self reloadNews];
    [self loadScrollImageInfo:!(_expressAdViews && _expressAdViews.count>0)];
    [self.mj_header endRefreshing];
}


-(void)adPrepare:(NSInteger)count{
    // 支持视频广告的 PlacementId 会混出视频与图片广告
    CGFloat width = SCREEN_WIDTH-view_margin*2;
    CGFloat height = width/1280*720;
    self.nativeExpressAd = [[GDTNativeExpressAd alloc] initWithAppId:GDT_APP_ID placementId:GDT_NATIVE_AD_ID adSize:CGSizeMake(width, height)];
    self.nativeExpressAd.delegate = self;
    [self.nativeExpressAd loadAd:count];
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //根据注册标记查找cell
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:home_collection_id forIndexPath:indexPath];
    if(cell.contentView.subviews) for(UIView *sview in cell.contentView.subviews) [sview removeFromSuperview];
    
    if(indexPath.section==0) {
        if(indexPath.item==0) [self createHotCityListViewInCell:cell atIndex:indexPath];
        else [self createBannerViewInCell:cell atIndex:indexPath];
    }
    else if(indexPath.section==1 && _nearbyStation && _distance) [self createNearByStationViewInCell:cell atIndex:indexPath];
    else [self createDescoverViewInCell:cell atIndex:indexPath];
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:home_collection_header_id forIndexPath:indexPath];
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        if(reusableView.subviews) for(UIView *sview in reusableView.subviews) [sview removeFromSuperview];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(view_margin, 5, SCREEN_WIDTH-view_margin*2, fitFloat(25))];
        label.font = main_font_big;
        label.textColor = dynamic_color_black;
        [reusableView addSubview:label];
        if(indexPath.section==0) {
            label.text = @"热门城市";
            UIView *hotView = [[UIView alloc] initWithFrame:CGRectMake(view_margin+fitFloat(38)+fitFloat(37), 2, fitFloat(37), 15)];
            CAGradientLayer *gl = [CAGradientLayer layer];
            gl.frame = CGRectMake(0, 0, fitFloat(37), 15);
            gl.startPoint = CGPointMake(0, 0);
            gl.endPoint = CGPointMake(1, 1);
            gl.colors = gradual_color_pink;
            gl.locations = @[@(0), @(1.0f)];
            [hotView.layer addSublayer:gl];
            
            UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: hotView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(6,6)];
            //创建 layer
            CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
            maskLayer.frame = hotView.bounds;
            //赋值
            maskLayer.path = maskPath.CGPath;
            hotView.layer.mask = maskLayer;
            
            UILabel *hotLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, fitFloat(37), 15)];
            hotLabel.font = sub_font_small;
            hotLabel.textColor = dynamic_color_white;
            hotLabel.text = @"HOT";
            hotLabel.textAlignment = NSTextAlignmentCenter;
            [hotView addSubview:hotLabel];
            [reusableView addSubview:hotView];
        }
        else if(indexPath.section==1 && _nearbyStation && _distance) label.text = @"附近站点";
        else label.text = @"地铁新闻";
        reusableView.backgroundColor = dynamic_color_white;
    }
    //如果是头视图
    return reusableView;
}


-(void)createBannerViewInCell:(UICollectionViewCell*)cell atIndex:(NSIndexPath*)indexPath{
    CGFloat width = SCREEN_WIDTH-view_margin*2;
    CGFloat height = width/1280*720;
    GDTNativeExpressAdView *nativeExpressAd = (_expressAdViews && _expressAdViews.count>0)?_expressAdViews[0]:nil;
    width = nativeExpressAd?nativeExpressAd.bounds.size.width:width;
    height = nativeExpressAd?nativeExpressAd.bounds.size.height:height;
    
    NSMutableArray *viewList = [[NSMutableArray alloc] init];
    if(_dataNewsList){
        for(int i=0; i<_dataNewsList.count; i++){
            NewsModel *newsInfo = _dataNewsList[i];
            if(newsInfo.innerUrls && newsInfo.innerUrls.count>0){
                UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
                [imgView setImage:[UIImage imageNamed:@"default_news"]];
                imgView.contentMode = UIViewContentModeScaleAspectFill;
                [imgView yy_setImageWithURL:[NSURL URLWithString:newsInfo.innerUrls[0]] placeholder:nil options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                    if(!image) [imgView setImage:[UIImage imageNamed:@"default_news"]];
                }];
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNewsDetail:)];
                imgView.tag = i;
                imgView.userInteractionEnabled = YES;
                [imgView addGestureRecognizer:tap];
                [viewList addObject:imgView];
            }
        }
    }
    if(_expressAdViews && _expressAdViews.count>0){
        for(int i=0; i<_expressAdViews.count; i++){
            GDTNativeExpressAdView *adView = _expressAdViews[i];
            if(viewList.count > 2*i+1) [viewList insertObject:adView atIndex:2*i+1];
            else [viewList addObject:adView];
        }
    }
    
    _adScrollView = [[AdScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, height) viewArray:viewList];
    _adScrollView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05].CGColor;
    _adScrollView.layer.shadowOffset = CGSizeMake(0,3);
    _adScrollView.layer.shadowOpacity = 1;
    _adScrollView.layer.shadowRadius = 6;
    _adScrollView.layer.cornerRadius = 6;
    _adScrollView.layer.masksToBounds = NO;
    [cell.contentView addSubview:_adScrollView];
    [cell.contentView addSubview:_adScrollView.pageControl];
}

-(void)createHotCityListViewInCell:(UICollectionViewCell*)cell atIndex:(NSIndexPath*)indexPath{
    if(_hotCityListView) [_hotCityListView removeFromSuperview];
    _hotCityListView = [[HotCityListView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, fitFloat(88)+12+fitFloat(20))];
    __weak typeof(self) wkSelf = self;
    [_hotCityListView setReloadCityData:^{
        if(wkSelf.reloadCityData) wkSelf.reloadCityData();
    }];
    [cell.contentView addSubview:_hotCityListView];
}
-(void)createNearByStationViewInCell:(UICollectionViewCell*)cell atIndex:(NSIndexPath*)indexPath{
    if(_stationNearbyView) [_stationNearbyView removeFromSuperview];
    _stationNearbyView = [[StationNearByView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, fitFloat(154)) nearbyStation:_nearbyStation distance:_distance];
    [cell.contentView addSubview:_stationNearbyView];
    __weak typeof(self) wkSelf = self;
    [_stationNearbyView setShowExit:^(StationModel *station) {
        if(wkSelf.showExit) wkSelf.showExit(station);
    }];
    [_stationNearbyView setShowTimetable:^(StationModel *station) {
        if(wkSelf.showTimetable) wkSelf.showTimetable(station);
    }];
    [_stationNearbyView setShowStationInfo:^(StationModel *station) {
        if(wkSelf.showStationInfo) wkSelf.showStationInfo(station);
    }];
}
-(void)createDescoverViewInCell:(UICollectionViewCell*)cell atIndex:(NSIndexPath*)indexPath{
    _articleCollectionView = [[RecommendArticleCollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, cell.height)];
    __weak typeof(self) wkSelf = self;
    [_articleCollectionView setShowNewsDetail:^(NewsModel *newsInfo) {
        if(wkSelf.showNewsDetail) wkSelf.showNewsDetail(newsInfo);
    }];
    [cell.contentView addSubview:_articleCollectionView];
}


-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(SCREEN_WIDTH, fitFloat(31));
}
//设置cell的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0) {
        if(_expressAdViews && _expressAdViews.count>0 && indexPath.item==1) {
            UIView *view = [self.expressAdViews objectAtIndex:0];
            return CGSizeMake(SCREEN_WIDTH, view.bounds.size.height+view_margin);
        }else if(_dataNewsList && _dataNewsList.count>0 && indexPath.item==1){
            CGFloat width = SCREEN_WIDTH-view_margin*2;
            CGFloat height = width/1280*720;
            return CGSizeMake(SCREEN_WIDTH, height+view_margin);
        }
        else return CGSizeMake(SCREEN_WIDTH, fitFloat(88)+12+fitFloat(20)+view_margin);
    }
    else if(indexPath.section==1 && _nearbyStation && _distance) return CGSizeMake(SCREEN_WIDTH, fitFloat(154));
    return CGSizeMake(SCREEN_WIDTH, fitFloat(129)*4+12);
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
    if(_nearbyStation && _distance){
        _locationed = YES;
        return 3;
    }
    else return 2;
}

//返回列表每个分组section拥有cell行数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(_expressAdViews && _expressAdViews.count>0 && section==0) return 2;
    else if(_dataNewsList && _dataNewsList.count>0 && section==0) return 2;
    else return 1;
}


- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd*)nativeExpressAd views:(NSArray<__kindof GDTNativeExpressAdView *> *)views{
   self.expressAdViews = [NSArray arrayWithArray:views];
   if (self.expressAdViews.count) {
       [self.expressAdViews enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           GDTNativeExpressAdView *expressView = (GDTNativeExpressAdView *)obj;
           expressView.controller = [BaseUtils viewController:self];
           [expressView render];
       }];
   }
   // 广告位 render 后刷新 tableView
   [self reloadSections:[NSIndexSet indexSetWithIndex:0]];
}



-(void)reloadNearByStation{
    [self loadNearByStation];
//    [self reloadData];
//    if(_articleCollectionView) [_articleCollectionView loadRecommendNews];
}

-(void)reloadNews{
    NSString * cityIdStr = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_CITY_ID_KEY];
    NSInteger cityIdInt = 0;
    if(cityIdStr) cityIdInt = [cityIdStr integerValue];
    if(_cityId != cityIdInt){
        _cityId = cityIdInt;
//        NSIndexSet *reloadSet = [NSIndexSet indexSetWithIndex:1];
//        if(_locationed) reloadSet = [NSIndexSet indexSetWithIndex:2];
        [self reloadData];
    }
}


-(void) loadNearByStation{
    __weak typeof(self) wkSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSString *location = [[NSUserDefaults standardUserDefaults] objectForKey:LOCATION_LOC_KEY];
    if(location) {
        if([location isEqualToString: _loc]) return;
        NSArray *array = [location componentsSeparatedByString:@","];
        if(array.count<2) return;
        [params setObject:array[0] forKey:@"longitude"];
        [params setObject:array[1] forKey:@"latitude"];
    }else{
        BOOL reload = !(_nearbyStation==nil);
        _nearbyStation =  nil;
        _locationed =  NO;
        if(reload) [self reloadData];
        return;
    }
    [params setObject:@(3000) forKey:@"radius"];
    
    [[HttpHelper new] findList:request_station_nearby params:params page:1 progress:nil success:^(NSMutableDictionary *responseDic) {
        NSMutableArray *resultArray = (NSMutableArray *)[responseDic mutableArrayValueForKey:@"list"];
        if(!resultArray) return;
        for(int i=0; i<resultArray.count; i++){
            NSDictionary *sdict = resultArray[i][@"station"];
            NSString *dist = resultArray[i][@"distance"];
            if(sdict && dist) {
                wkSelf.nearbyStation = [StationModel yy_modelWithJSON:sdict];
                wkSelf.distance = [dist integerValue];
                if(!wkSelf.locationed) [wkSelf reloadData];
                else [wkSelf reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:1]]];
                break;
            }
        }
    } failure:^(NSString *errorInfo) {
        
    }];
}

-(void) showNewsDetail:(UITapGestureRecognizer*)tap{
    if(tap.view.tag < _dataNewsList.count){
        NewsModel *newsInfo = _dataNewsList[tap.view.tag];
        if(self.showNewsDetail) self.showNewsDetail(newsInfo);
    }
}


//banner页面
-(void)loadScrollImageInfo:(BOOL)withAd{
    __weak typeof(self) wkSelf = self;
    _dataNewsList = nil;
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSString *cityId = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_CITY_ID_KEY];
    if(cityId) [params setObject:cityId forKey:@"cityId"];
    [[HttpHelper new] findList:request_banner params:params page:0 progress:^(NSProgress *progress) {
    } success:^(NSMutableDictionary *responseDic) {
        NSMutableArray *newsArray = (NSMutableArray *)[responseDic mutableArrayValueForKey:@"list"];
        if(newsArray && newsArray.count>0) {
            if(!wkSelf.dataNewsList) wkSelf.dataNewsList = [NSMutableArray new];
            for(NSDictionary *dict in newsArray){
                NewsModel *news = [NewsModel yy_modelWithJSON:dict];
                [wkSelf.dataNewsList addObject:news];
            }
            if(wkSelf.dataNewsList.count>0) [self reloadSections:[NSIndexSet indexSetWithIndex:0]];
            if(wkSelf.dataNewsList.count>2 && withAd) [wkSelf adPrepare:wkSelf.dataNewsList.count-1];
            else if(withAd) [wkSelf adPrepare:3];
        }else if(withAd) [wkSelf adPrepare:3];
    } failure:^(NSString *errorInfo) {
        if(withAd) [wkSelf adPrepare:3];
    }];
}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    __weak typeof(self) wkSelf = self;
    // trait发生了改变
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            if(self.stationNearbyView) [self.stationNearbyView updateCGColors];
            if(_hotCityListView){
                [_hotCityListView reloadData];
            }
            MJChiBaoZiHeader *header = [MJChiBaoZiHeader headerWithRefreshingTarget:self refreshingAction:@selector(reloadPage)];
            self.mj_header = header;
            header.lastUpdatedTimeLabel.hidden = YES;
            header.stateLabel.hidden = YES;
            self.mj_header.backgroundColor = [UIColor clearColor];
        }
    } else {
    }
}
@end
