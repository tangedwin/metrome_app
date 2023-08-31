//
//  StationDetailViewController.m
//  MetroMap
//
//  Created by edwin on 2019/10/23.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "StationInfoViewController.h"
#import "SegmentWithTabView.h"
#import "TabTitleView.h"
#import "StationDetailView.h"

@interface StationInfoViewController ()<UIScrollViewDelegate>

@property(nonatomic, retain) CityModel *city;
@property(nonatomic, retain) StationModel *station;
@property(nonatomic, retain) LineModel *selectedLine;
@property(nonatomic, retain) NSMutableArray *lines;
@property(nonatomic, retain) StationTimetableView *stationTimetableView;
@property(nonatomic, retain) LineNameCollectionView *lineNameCollectionView;
@property (nonatomic, retain) SegmentWithTabView *segmentWithTabView;
@property(nonatomic, retain) TabTitleView *tabTitleView;
@property(nonatomic, retain) UIView *mapView;


@property(nonatomic, retain) UIScrollView *detailScrollView;
@property(nonatomic, retain) NSMutableArray *segmentViewList;
@property(nonatomic, retain) NSMutableArray<NSString*> *segmentTitleList;

@property(nonatomic, retain) UIImageView *beCollected;
@property(nonatomic, retain) UIImageView *toBeCollected;
@property(nonatomic, assign) BOOL loadPlanPic;
@property(nonatomic, retain) UIScrollView *planPicView;

@property(nonatomic, retain) MAMapView *maMapView;


@property(nonatomic, retain) NSMutableArray *layers;
@end


@implementation StationInfoViewController

-(instancetype)initWithCity:(CityModel*)city lines:(NSMutableArray*)lines selectedLine:(LineModel*)line station:(StationModel*)station{
    self = [super init];
    _city = city;
    _station = station;
    _lines = lines;
    _selectedLine = line;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    if(!_station) return;
    
    [self.view addSubview:self.naviMask];
    [self.naviMask addSubview:self.backButton];
    [self.view setBackgroundColor:dynamic_color_white];
    
    NSString *text = _station.nameCn;
    CGSize titleSize = [text sizeWithAttributes:@{NSFontAttributeName:main_font_big}];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(48, STATUS_BAR_HEIGHT+(NAVIGATION_BAR_HEIGHT-ceil(titleSize.height))/2, SCREEN_WIDTH-48*2, ceil(titleSize.height))];
    title.textColor = dynamic_color_black;
    title.font = main_font_big;
    title.textAlignment = NSTextAlignmentCenter;
    title.text = text;
    [self.naviMask addSubview:title];
    
    _toBeCollected = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-view_margin-24, STATUS_BAR_HEIGHT+(NAVIGATION_BAR_HEIGHT-24)/2, 24, 24)];
    [_toBeCollected setImage:[UIImage imageNamed:@"station_collect"]];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(collected:)];
    _toBeCollected.userInteractionEnabled = YES;
    [_toBeCollected addGestureRecognizer:tap1];
    [self.naviMask addSubview:_toBeCollected];
    
    UIImageView *feedbackButton = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-view_margin-24-12-24, STATUS_BAR_HEIGHT+(NAVIGATION_BAR_HEIGHT-24)/2, 24, 24)];
    [feedbackButton setImage:[UIImage imageNamed:@"feedback_icon_instation"]];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(feedback:)];
    feedbackButton.userInteractionEnabled = YES;
    [feedbackButton addGestureRecognizer:tap2];
    [self.naviMask addSubview:feedbackButton];
    
    [self checkStationCollects:_station];
    
    NSMutableArray *stations = [NSMutableArray new];
    if(!_lines){
        _lines = [NSMutableArray new];
        stations = [self loadLinesByStation:_lines];
    }else{
        
    }
    
    [self loadTimetableView:_lines stations:stations];
    CGFloat y = 52*2;
    [self loadStationDetailView];
    [self resetStationDetailViewFrame:y];
}

-(void)loadStationDetailView{
    _detailScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT-49-[self mTabbarHeight])];
    
    _mapView = [self createMapView:CGRectMake(0, 0, SCREEN_WIDTH, fitFloat(150)+35)];
    if(_mapView) [_detailScrollView addSubview:_mapView];
    [self createSegmentsView:CGRectMake(0, _mapView?_mapView.height:0, SCREEN_WIDTH, _detailScrollView.height)];
    if(_tabTitleView) [_detailScrollView addSubview:_tabTitleView];
    if(_segmentWithTabView) [_detailScrollView addSubview:_segmentWithTabView];
    [self.view addSubview:_detailScrollView];
    _detailScrollView.delegate = self;
    _detailScrollView.showsVerticalScrollIndicator = NO;
    _detailScrollView.directionalLockEnabled = YES;
    _detailScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, (_mapView?_mapView.height:0)+_detailScrollView.height);
    
    UIView *bottomView = [self createBottomView:CGRectMake(0, SCREEN_HEIGHT-[self mTabbarHeight], SCREEN_WIDTH, [self mTabbarHeight])];
    [self.view addSubview:bottomView];
}
-(void)resetStationDetailViewFrame:(CGFloat)y{
    CGFloat height = SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT-49-[self mTabbarHeight]*2-y;
    y = NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT+49+y;
    __weak typeof(self) wkSelf = self;
    [UIView animateWithDuration:.5f animations:^{
        wkSelf.detailScrollView.frame = CGRectMake(wkSelf.detailScrollView.frame.origin.x, y, SCREEN_WIDTH, height);
        wkSelf.segmentWithTabView.frame = CGRectMake(wkSelf.segmentWithTabView.frame.origin.x, wkSelf.segmentWithTabView.frame.origin.y, SCREEN_WIDTH, height-44);
        for(UIScrollView *view in wkSelf.segmentViewList){
            view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, SCREEN_WIDTH, height-44);
        }
    }];
}


-(void)loadTimetableView:(NSMutableArray*)lines stations:(NSMutableArray*)stations{
    _lineNameCollectionView = [[LineNameCollectionView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT, SCREEN_WIDTH, 49) lines:lines];
    [self.view addSubview:_lineNameCollectionView];
    _lineNameCollectionView.selectedLine = _selectedLine;
    
    _stationTimetableView= [[StationTimetableView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT+49, SCREEN_WIDTH, 52*2) station:_station lines:lines city:_city];
    [self.view addSubview:_stationTimetableView];
    _stationTimetableView.selectedLine = _selectedLine;
    [_stationTimetableView reloadData];
    
    __weak typeof(self) wkSelf = self;
    [_lineNameCollectionView setSelectLine:^(NSInteger index) {
        [wkSelf.stationTimetableView selectLine:index];
    }];
    [_stationTimetableView setSelectLine:^(NSInteger index) {
        [wkSelf.lineNameCollectionView selectLine:index];
    }];
    [_stationTimetableView setResetTimetableHeight:^(CGFloat height) {
        [wkSelf resetStationDetailViewFrame:height];
    }];
}

-(UIView*)createBottomView:(CGRect)frame{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.backgroundColor = dynamic_color_white;
    view.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1].CGColor;
    view.layer.shadowOffset = CGSizeMake(0,-3);
    view.layer.shadowOpacity = 1;
    view.layer.shadowRadius = 12;
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.strokeColor = dynamic_color_lightgray.CGColor;
    lineLayer.fillColor = [UIColor clearColor].CGColor;
    lineLayer.lineWidth = 1;
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(SCREEN_WIDTH/3, 14)];
    [linePath addLineToPoint:CGPointMake(SCREEN_WIDTH/3, 37)];
    [linePath moveToPoint:CGPointMake(SCREEN_WIDTH*2/3, 14)];
    [linePath addLineToPoint:CGPointMake(SCREEN_WIDTH*2/3, 37)];
    lineLayer.path = linePath.CGPath;
    [view.layer addSublayer:lineLayer];
    if(!_layers) _layers = [NSMutableArray new];
    [_layers addObject:lineLayer];
    
    
    UILabel *showInMap = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH/3-(21+fitFloat(70)))/2+21, 14, fitFloat(70), 20)];
    showInMap.font = main_font_small;
    showInMap.textColor = dynamic_color_black;
    showInMap.textAlignment = NSTextAlignmentLeft;
    showInMap.text = @"显示地铁图";
    [view addSubview:showInMap];
    UIImageView *showInMapIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"show_inmap"]];
    showInMapIcon.frame = CGRectMake((SCREEN_WIDTH/3-(21+fitFloat(70)))/2, 17, 15, 15);
    [view addSubview:showInMapIcon];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInMap:)];
    [showInMap addGestureRecognizer:tap1];
    showInMap.userInteractionEnabled = YES;
    
    
    UILabel *startName = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH/3-(18+fitFloat(56)))/2+SCREEN_WIDTH/3+18, 14, fitFloat(56), 20)];
    startName.font = main_font_small;
    startName.textColor = dynamic_color_black;
    startName.textAlignment = NSTextAlignmentLeft;
    startName.text = @"设为起点";
    [view addSubview:startName];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setStartStation:)];
    [startName addGestureRecognizer:tap2];
    startName.userInteractionEnabled = YES;
    
    UILabel *endName = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH/3-(18+fitFloat(56)))/2+SCREEN_WIDTH*2/3+18, 14, fitFloat(56), 20)];
    endName.font = main_font_small;
    endName.textColor = dynamic_color_black;
    endName.textAlignment = NSTextAlignmentLeft;
    endName.text = @"设为终点";
    [view addSubview:endName];
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setEndStation:)];
    [endName addGestureRecognizer:tap3];
    endName.userInteractionEnabled = YES;
    
    UIView *subStartIcon = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH/3-(18+fitFloat(56)))/2+SCREEN_WIDTH/3, 21, 6, 6)];
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = CGRectMake(0,0,6,6);
    gl.startPoint = CGPointMake(0, 0);
    gl.endPoint = CGPointMake(1, 1);
    gl.colors = gradual_color_blue;
    gl.locations = @[@(0), @(1.0f)];
    [subStartIcon.layer addSublayer:gl];
    subStartIcon.layer.cornerRadius = 3;
    subStartIcon.layer.masksToBounds = YES;
    [view addSubview:subStartIcon];
    
    UIView *subEndIcon = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH/3-(18+fitFloat(56)))/2+SCREEN_WIDTH*2/3, 21, 6, 6)];
    CAGradientLayer *gl1 = [CAGradientLayer layer];
    gl1.frame = CGRectMake(0,0,6,6);
    gl1.startPoint = CGPointMake(0, 0);
    gl1.endPoint = CGPointMake(1, 1);
    gl1.colors = gradual_color_pink;
    gl1.locations = @[@(0), @(1.0f)];
    [subEndIcon.layer addSublayer:gl1];
    subEndIcon.layer.cornerRadius = 3;
    subEndIcon.layer.masksToBounds = YES;
    [view addSubview:subEndIcon];
    return view;
}

-(void)checkCityWithBlock:(void(^)(void))success{
    NSString *cityId = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_CITY_ID_KEY];
    if(cityId && _city.identifyCode == [cityId integerValue]){
        success();
    }else{
        MetroMapHelper *metroHelper = [MetroMapHelper new];
        [metroHelper loadMetroMap:_city success:^{
            success();
        }];
    }
}

-(void)showInMap:(UITapGestureRecognizer*)tap{
    __weak typeof(self) wkSelf = self;
    _station.city = _city;
    [self checkCityWithBlock:^{
        BaseCitySearchViewController *bcsVC = wkSelf.tabBarController.viewControllers[1].childViewControllers[0];
        [bcsVC setDefaultStation:wkSelf.station forStart:NO forEnd:NO];
        [wkSelf.navigationController popToRootViewControllerAnimated:YES];
        [wkSelf.tabBarController setSelectedIndex:1];
    }];
}

-(void)setStartStation:(UITapGestureRecognizer*)tap{
    __weak typeof(self) wkSelf = self;
    _station.city = _city;
    [self checkCityWithBlock:^{
        BaseCitySearchViewController *bcsVC = wkSelf.tabBarController.viewControllers[1].childViewControllers[0];
        [bcsVC setDefaultStation:wkSelf.station forStart:YES forEnd:NO];
        [wkSelf.navigationController popToRootViewControllerAnimated:YES];
        [wkSelf.tabBarController setSelectedIndex:1];
    }];
}

-(void)setEndStation:(UITapGestureRecognizer*)tap{
    __weak typeof(self) wkSelf = self;
    _station.city = _city;
    [self checkCityWithBlock:^{
        BaseCitySearchViewController *bcsVC = wkSelf.tabBarController.viewControllers[1].childViewControllers[0];
        [bcsVC setDefaultStation:wkSelf.station forStart:NO forEnd:YES];
        [wkSelf.navigationController popToRootViewControllerAnimated:YES];
        [wkSelf.tabBarController setSelectedIndex:1];
    }];
}


-(UIView*)createMapView:(CGRect)frame{
    if(_station && _station.longitude>0 && _station.latitude>0){
        UIView *view = [[UIView alloc] initWithFrame:frame];
//        UIView *subview = [[UIView alloc] initWithFrame:CGRectMake(view_margin, view_margin, SCREEN_WIDTH-view_margin*2, 150)];
        
        [AMapServices sharedServices].enableHTTPS = YES;
        _maMapView = [[MAMapView alloc] initWithFrame:CGRectMake(view_margin, view_margin, SCREEN_WIDTH-view_margin*2, fitFloat(150))];
        _maMapView.layer.backgroundColor = [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor;
        _maMapView.layer.cornerRadius = 12;
        _maMapView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05].CGColor;
        _maMapView.layer.shadowOffset = CGSizeMake(0,3);
        _maMapView.layer.shadowOpacity = 1;
        _maMapView.layer.shadowRadius = 6;
        [_maMapView setZoomLevel:17];
        [_maMapView setShowsScale:NO];
        [_maMapView setShowsCompass:NO];
        [_maMapView setCenterCoordinate:CLLocationCoordinate2DMake(_station.latitude, _station.longitude)];
        [_maMapView setAllowsBackgroundLocationUpdates:NO];
        [_maMapView setRotateEnabled:NO];
        [_maMapView setRotateCameraEnabled:NO];
        [_maMapView setZoomEnabled:NO];
        [_maMapView setScrollEnabled:NO];
        
        NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"gaode_map_light_style" ofType:@"data"];
        if (@available(iOS 13.0, *)) {
            if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
                urlStr = [[NSBundle mainBundle] pathForResource:@"gaode_map_dark_style" ofType:@"data"];
            }
        }
        NSData *data = [NSData dataWithContentsOfFile:urlStr];
        [_maMapView setCustomMapStyleEnabled:YES];
        MAMapCustomStyleOptions *options = [[MAMapCustomStyleOptions alloc] init];
        options.styleData = data;
        [_maMapView setCustomMapStyleOptions:options];
        [view addSubview:_maMapView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMap:)];
        _maMapView.userInteractionEnabled = YES;
        [_maMapView addGestureRecognizer:tap];
        
        return view;
    }
    return nil;
}

-(void)showMap:(UITapGestureRecognizer*)tap{
    GaodeMapViewController *gaodeMap = [[GaodeMapViewController alloc] initWithStation:_station];
    [gaodeMap setHidesBottomBarWhenPushed:YES];
    [self.navigationController pushViewController:gaodeMap animated:YES];
}

-(void)createSegmentsView:(CGRect)frame{
    __weak typeof(self) wkSelf = self;
    //tab页面
    _segmentWithTabView = [[SegmentWithTabView alloc] initWithFrame:CGRectMake(0, frame.origin.y+44, SCREEN_WIDTH, frame.size.height-44)];
    [_segmentWithTabView setMoveTabToIndex:^(NSInteger toIndex, NSInteger fromIndex) {
        if(wkSelf.tabTitleView) [wkSelf.tabTitleView selected:toIndex from:fromIndex];
        
        if([@"站层图" isEqualToString: wkSelf.segmentTitleList[toIndex]] && !wkSelf.loadPlanPic && wkSelf.planPicView) {
            MBProgressHUD *hud = [MBProgressHUD showWaitingWithText:@"加载中……" image:nil inView:nil];
            wkSelf.loadPlanPic = YES;
            StationDetailModel *detailInfo = wkSelf.station.detailInfo;
//            CGFloat y = view_margin;
            for(NSInteger i=0; i<detailInfo.planMap_uri.count; i++){
                NSString *uri = detailInfo.planMap_uri[i];
                NSString *url = [NSString stringWithFormat:@"%@%@%@",Base_URL,request_image,uri];
                url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
                url = [url stringByReplacingOccurrencesOfString:@"%5C" withString:@""];
                UIImageView *imgView = [[UIImageView alloc] init];
                imgView.contentMode = UIViewContentModeScaleAspectFit;
                imgView.layer.cornerRadius = 6;
                imgView.layer.masksToBounds = YES;
                [wkSelf.planPicView addSubview:imgView];
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:wkSelf action:@selector(showImage:)];
                imgView.tag = i;
                [imgView addGestureRecognizer:tap];
                imgView.userInteractionEnabled = YES;
                
//                CGSize size = [UIImage getImageSizeWithURL:url];
//                if(size.height<=0 || size.width<=0) continue;
//                CGFloat height = (SCREEN_WIDTH-view_margin*2)/size.width*size.height;
//                imgView.frame = CGRectMake(view_margin, y, SCREEN_WIDTH-view_margin*2, height);
//                [imgView yy_setImageWithURL:[NSURL URLWithString:url] options:YYWebImageOptionProgressive];
                
                [imgView yy_setImageWithURL:[NSURL URLWithString:url]
                   placeholder:nil
                    options:YYWebImageOptionIgnorePlaceHolder | YYWebImageOptionShowNetworkActivity
                   progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                   }
                   transform:^UIImage *(UIImage *image, NSURL *url) {
//                        CGFloat width = SCREEN_WIDTH-view_margin*2;
//                        CGFloat height = width/image.size.width*image.size.height;
                    
//                        image = [image yy_imageByResizeToSize:CGSizeMake(width, height) contentMode:UIViewContentModeScaleAspectFit];
//                        image = [image yy_imageByRoundCornerRadius:6];
                        return image;
                   }
                   completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
                       if (from == YYWebImageFromDiskCache) {
                           NSLog(@"load from disk cache");
                       }
                       if(!NSThread.currentThread.isMainThread){
                           dispatch_async(dispatch_get_main_queue(), ^{
                               [wkSelf reloadPlanPicsView];
                           });
                       }else{
                           [wkSelf reloadPlanPicsView];
                       }
                   }];
                
//                y = y + imageHeight + view_margin;
            }
//            wkSelf.planPicView.contentSize = CGSizeMake(SCREEN_WIDTH, y);
            [hud hideAnimated:YES];
        }
    }];
    
    _segmentViewList = [NSMutableArray new];
    _segmentTitleList = [NSMutableArray new];
    [self createDetailInfoView:CGRectMake(0, 0, _segmentWithTabView.width, _segmentWithTabView.height)];
    if(_segmentViewList && _segmentViewList.count>0) [_segmentWithTabView setSubViewArray:_segmentViewList];
    else _segmentWithTabView = nil;
    
    if(_segmentTitleList && _segmentTitleList.count>0){
        //tab标签
        _tabTitleView = [[TabTitleView alloc] initWithFrame:CGRectMake(0, frame.origin.y, SCREEN_WIDTH, 44) titles:_segmentTitleList type:SegmentTabTypeByAverage];
        _tabTitleView.withoutCursor = YES;
        _tabTitleView.textColor = dynamic_color_gray;
        _tabTitleView.textFont = main_font_small;
        _tabTitleView.textSelectedColor = main_color_pink;
        _tabTitleView.textSelectedFont = main_font_middle;
        
        CALayer *viewBorder = [CALayer layer];
        viewBorder.frame = CGRectMake(0, _tabTitleView.height-1, _tabTitleView.width, 1);
        viewBorder.backgroundColor = dynamic_color_lightgray.CGColor;
        [_tabTitleView.layer addSublayer:viewBorder];
        if(!_layers) _layers = [NSMutableArray new];
        [_layers addObject:viewBorder];
        
        [_tabTitleView setScrollToIndex:^(NSInteger toIndex) {
            if(wkSelf.segmentWithTabView) [wkSelf.segmentWithTabView scrollToIndex:toIndex];
        }];
    }
}

-(void)reloadPlanPicsView{
    __block CGFloat y = view_margin;
    if(_planPicView && _planPicView.subviews) for(UIView *sview in _planPicView.subviews){
        if([sview isKindOfClass:UIImageView.class]){
            UIImageView *imageView = (UIImageView*)sview;
            if(imageView.image && imageView.image.size.height>0){
                CGFloat width = SCREEN_WIDTH-view_margin*2;
                CGFloat height = width/imageView.image.size.width*imageView.image.size.height;
                imageView.frame = CGRectMake(view_margin, y, width, height);
                y = y + imageView.height + view_margin;
            }
        }
    }
    [UIView animateWithDuration:.5f animations:^{
        self.planPicView.contentSize = CGSizeMake(SCREEN_WIDTH, y);
    }];
}
-(void)showImage:(UITapGestureRecognizer*)tap{
    StationDetailModel *detailInfo = self.station.detailInfo;
    [[ImageBrowserHelper shared] browseImageWithType:ImageSourceTypeUrl imageArr:detailInfo.planMap_uri selectIndex:tap.view.tag pushByController:self.navigationController];
}

-(void)createDetailInfoView:(CGRect)frame{
    StationDetailModel *detailInfo = _station.detailInfo;
    
    if(detailInfo.exits && detailInfo.exits.count>0) {
        UIScrollView *view = [self createDetailNormlView:detailInfo.exits frame:frame];
        [_segmentViewList addObject:view];
        [_segmentTitleList addObject:@"出入口"];
    }
    if(detailInfo.toilets && detailInfo.toilets.count>0) {
        UIScrollView *view = [self createDetailNormlView:detailInfo.toilets frame:frame];
        [_segmentViewList addObject:view];
        [_segmentTitleList addObject:@"卫生间"];
    }
    if(detailInfo.planMap_uri && detailInfo.planMap_uri.count>0){
        StationDetailView *planPicView = [[StationDetailView alloc] initWithFrame:frame];
        planPicView.parentView = self;
        _planPicView = planPicView;
        [_segmentViewList addObject:_planPicView];
        [_segmentTitleList addObject:@"站层图"];
    }
}

-(StationDetailView*)createDetailNormlView:(NSMutableArray*)detail frame:(CGRect)frame{
    CGFloat y = 0;
    StationDetailView *view = [[StationDetailView alloc] initWithFrame:frame];
    view.parentView = self;
    for(int j=0; j<detail.count; j++){
        NSString *str = detail[j];
        if([str hasPrefix:@"#"]){
            NSArray *array = [[str substringFromIndex:1] componentsSeparatedByString:@":"];
            NSString *content = @"";
            if(array.count>1) {
                for(int i=0; i<array.count; i++){
                    if(i==0) {
                        y = y + view_margin;
                        UILabel *titleLabel = [self createTitleLabel:array[i] frame:CGRectMake(view_margin, y, SCREEN_WIDTH-view_margin*2, 23)];
                        if(titleLabel){
                            [view addSubview:titleLabel];
                            y = y + titleLabel.height + 3;
                        }
                    }else if(i==array.count-1){
                        content = [content stringByAppendingString:array[i]];
                    }else{
                        content = [content stringByAppendingFormat:@"%@, ",array[i]];
                    }
                }
                UILabel *contentLabel = [self createContentLabel:content frame:CGRectMake(view_margin, y, SCREEN_WIDTH-view_margin*2, 20)];
                if(contentLabel) {
                    [view addSubview:contentLabel];
                    y = y + contentLabel.height + view_margin;
                }
            }else{
                y = y + view_margin;
                UILabel *titleLabel = [self createTitleLabel:str frame:CGRectMake(view_margin, y, SCREEN_WIDTH-view_margin*2, 23)];
                if(titleLabel) {
                    [view addSubview:titleLabel];
                    y = y + titleLabel.height + 3;
                }
            }
        }else{
            if(j==0) y = y + view_margin;
            UILabel *contentLabel = [self createContentLabel:str frame:CGRectMake(view_margin, y, SCREEN_WIDTH-view_margin*2, 20)];
            if(contentLabel) {
                [view addSubview:contentLabel];
                y = y + contentLabel.height + view_margin;
            }
        }
    }
    view.contentSize = CGSizeMake(SCREEN_WIDTH, y);
    return view;
}

-(UILabel*) createTitleLabel:(NSString*)title frame:(CGRect)frame{
    if([title isEqualToString:@"\n"]) return nil;
    if([title hasPrefix:@"\n"]) title = [title substringFromIndex:2];
    NSDictionary *attribute = @{NSFontAttributeName: main_font_middle};
//    CGSize labelSize = [title boundingRectWithSize:CGSizeMake(frame.size.width, frame.size.height) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    CGFloat height = [BaseUtils heightOfString:title withConstrainSize:CGSizeMake(frame.size.width, frame.size.height) withAttributes:attribute];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, ceil(height))];
    label.text = title;
    label.font = main_font_middle;
    label.textColor = dynamic_color_black;
    label.textAlignment = NSTextAlignmentLeft;
    label.numberOfLines = 0;
    return label;
}
-(UILabel*) createContentLabel:(NSString*)content frame:(CGRect)frame{
    if([content isEqualToString:@"\n"]) return nil;
    if([content hasPrefix:@"\n"]) content = [content substringFromIndex:2];
    NSDictionary *attribute = @{NSFontAttributeName: main_font_small};
//    CGSize labelSize = [content boundingRectWithSize:CGSizeMake(frame.size.width, frame.size.height) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    CGFloat height = [BaseUtils heightOfString:content withConstrainSize:CGSizeMake(frame.size.width, MAXFLOAT) withAttributes:attribute];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, ceil(height))];
    label.text = content;
    label.font = main_font_small;
    label.textColor = dynamic_color_gray;
    label.textAlignment = NSTextAlignmentLeft;
    label.numberOfLines = 0;
    return label;
}

- (void)viewWillAppear:(BOOL)animated{
    if(_hideTabbar){
        [UIView animateWithDuration:.2f animations:^{
            self.tabBarController.tabBar.hidden = YES;
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    if(_hideTabbar){
        [UIView animateWithDuration:.2f animations:^{
            self.tabBarController.tabBar.hidden = NO;
        }];
    }
}

-(NSMutableArray*)loadLinesByStation:(NSMutableArray*)lines{
    NSMutableArray *stations = [NSMutableArray new];
    if(_city && _station){
        for(NSString *lid in _station.lines){
            LineModel *line = _city.lineDicts[[NSString stringWithFormat:@"%@", lid]];
            if(line) {
                [lines addObject:line];
                [stations addObject:[self loadStationsByLine:line]];
            }
        }
    }
    return stations;
}

- (NSMutableArray*)loadStationsByLine:(LineModel*)line{
    NSMutableArray *stations = [NSMutableArray new];
    if(_city && line){
        for(NSString *sid in line.stations){
            StationModel *station = _city.stationDicts[[NSString stringWithFormat:@"%@", sid]];
            if(station) [stations addObject:station];
        }
    }
    return stations;
}

-(void)uncollected:(UITapGestureRecognizer*)tap{
    if(!_station || !_station.identifyCode) return;
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:@(_station.identifyCode) forKey:@"stationId"];
    
    __weak typeof(self) wkSelf = self;
    [[HttpHelper new] submit:request_station_collect_delete params:params progress:^(NSProgress *progress) {
    } success:^(NSMutableDictionary *responseDic) {
        [wkSelf checkStationCollects:wkSelf.station];
    } failure:^(NSString *errorInfo) {
    }];
}

-(void)collected:(UITapGestureRecognizer*)tap{
    if(!_station || !_station.identifyCode) return;
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:@(_station.identifyCode) forKey:@"stationId"];
    
    __weak typeof(self) wkSelf = self;
    [[HttpHelper new] submit:request_station_collect params:params progress:^(NSProgress *progress) {
    } success:^(NSMutableDictionary *responseDic) {
        [wkSelf checkStationCollects:wkSelf.station];
    } failure:^(NSString *errorInfo) {
    }];
}

-(void)checkStationCollects:(StationModel*)station{
    if(!station || !station.identifyCode) return;
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:@(station.identifyCode) forKey:@"stationId"];

    if(_beCollected){
        [_beCollected removeFromSuperview];
        _beCollected = nil;
    }
    if(_toBeCollected){
        [_toBeCollected removeFromSuperview];
        _toBeCollected = nil;
    }
    __weak typeof(self) wkSelf = self;
    [[HttpHelper new] findDetail:request_station_collect_check params:params progress:^(NSProgress *progress) {
    } success:^(NSMutableDictionary *responseDic) {
        NSNumber *collectedNum = (NSNumber*)responseDic;
        BOOL collected = collectedNum?[collectedNum boolValue]:NO;
        if(collected){
            wkSelf.beCollected = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-view_margin-24, STATUS_BAR_HEIGHT+(NAVIGATION_BAR_HEIGHT-24)/2, 24, 24)];
            [wkSelf.beCollected setImage:[UIImage imageNamed:@"station_collected"]];
            [wkSelf.naviMask addSubview:wkSelf.beCollected];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:wkSelf action:@selector(uncollected:)];
            wkSelf.beCollected.userInteractionEnabled = YES;
            [wkSelf.beCollected addGestureRecognizer:tap];
        }else{
            wkSelf.toBeCollected = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-view_margin-24, STATUS_BAR_HEIGHT+(NAVIGATION_BAR_HEIGHT-24)/2, 24, 24)];
            [wkSelf.toBeCollected setImage:[UIImage imageNamed:@"station_collect"]];
            [wkSelf.naviMask addSubview:wkSelf.toBeCollected];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:wkSelf action:@selector(collected:)];
            wkSelf.toBeCollected.userInteractionEnabled = YES;
            [wkSelf.toBeCollected addGestureRecognizer:tap];
        }
    } failure:^(NSString *errorInfo) {
    }];
}


-(void)loadStationDetail{
    if(!_station) return;
    __weak typeof(self) wkSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:@(_station.identifyCode) forKey:@"stationId"];
    [[HttpHelper new] findDetail:request_station_detail params:params progress:^(NSProgress *progress) {
        
    } success:^(NSMutableDictionary *responseDic) {
//        [wkSelf loadTimetableView];
    } failure:^(NSString *errorInfo) {
        
    }];
}

-(void)feedback:(UITapGestureRecognizer*)tap{
    FeedbackModel *feedback = [FeedbackModel new];
    feedback.type = 2;
    feedback.objectType = 2;
    feedback.titles = [[NSMutableArray alloc] initWithObjects:@"时刻表错误",@"站点信息错误", nil];
    feedback.dataDetailStr = [_station yy_modelToJSONString];

    FeedbackViewController *feedbackVC = [[FeedbackViewController alloc] initWithFeedback:feedback];
    feedbackVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:feedbackVC animated:YES];
}



- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if(!_segmentWithTabView){
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, 0);
        return;
    }
    
    if (scrollView.contentOffset.y >= (_mapView?_mapView.height:0)+0.5) {
        self.offsetType = OffsetTypeMax;
    } else if (scrollView.contentOffset.y <= 0) {
        self.offsetType = OffsetTypeMin;
    } else {
        self.offsetType = OffsetTypeCenter;
    }
    if ([_segmentWithTabView getSubviewOffset] == OffsetTypeCenter) {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, (_mapView?_mapView.height:0)+0.5);
    }else if (scrollView.contentOffset.y >= (_mapView?_mapView.height:0)+0.5) {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, (_mapView?_mapView.height:0)+0.5);
    }
}



- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    __weak typeof(self) wkSelf = self;
    // trait发生了改变
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            if(wkSelf.stationTimetableView) [wkSelf.stationTimetableView reloadData];
            // 执行操作
            if(wkSelf.layers) for(CALayer *layer in wkSelf.layers){
                if([layer isKindOfClass:CAShapeLayer.class]){
                    CAShapeLayer *clayer = (CAShapeLayer*)layer;
                    clayer.strokeColor = dynamic_color_lightgray.CGColor;
                }else{
                    layer.backgroundColor = dynamic_color_lightgray.CGColor;
                }
            }

            if(wkSelf.maMapView){
                NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"gaode_map_light_style" ofType:@"data"];
                if (@available(iOS 13.0, *)) {
                    if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
                        urlStr = [[NSBundle mainBundle] pathForResource:@"gaode_map_dark_style" ofType:@"data"];
                    }
                }
                NSData *data = [NSData dataWithContentsOfFile:urlStr];
                [wkSelf.maMapView setCustomMapStyleEnabled:YES];
                MAMapCustomStyleOptions *options = [[MAMapCustomStyleOptions alloc] init];
                options.styleData = data;
                [wkSelf.maMapView setCustomMapStyleOptions:options];
            }
        }
    } else {
    }
}
@end
