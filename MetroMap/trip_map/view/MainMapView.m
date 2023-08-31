//
//  MainMapView.m
//  MetroMap
//
//  Created by edwin on 2019/10/9.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "MainMapView.h"
#import "MetroMapHelper.h"

@interface MainMapView()<WKNavigationDelegate, UIScrollViewDelegate, WKUIDelegate, WKScriptMessageHandler>
    
@property(nonatomic, assign) CGFloat initZoomScale;

//显示线路后退回到原位置
@property(nonatomic, assign) CGFloat prevScale;
@property(nonatomic, assign) CGPoint prevOffset;

//显示经过某站点的线路(此时展示线路并且不隐藏站点弹框)
@property(nonatomic, assign) BOOL showStationLine;
@property(nonatomic, assign) BOOL showLine;

@property(nonatomic, assign) BOOL routeViewShowing;
@property(nonatomic, assign) BOOL toLocate;
@property(nonatomic, assign) BOOL showDefaultStation;

@property(nonatomic, assign) CGPoint startStationPoint;
@property(nonatomic, assign) CGPoint endStationPoint;
@property(nonatomic, assign) CGPoint locateStationPoint;
@property(nonatomic, retain) UIView *startStationSign;
@property(nonatomic, retain) UIView *endStationSign;
@property(nonatomic, retain) UIView *locateStationSign;
@property(nonatomic, retain) StationInfoAlert *stationInfoAlert;
    

@property(nonatomic, retain) StationModel *selectedStation;
@property(nonatomic, retain) StationModel *startStation;
@property(nonatomic, retain) StationModel *endStation;
@property(nonatomic, retain) CityModel *city;
@property(nonatomic, retain) RouteHelpManager *routeHelper;

@property (nonatomic, retain) StationModel *nearbyStation;
@property (nonatomic, assign) NSInteger distance;

@property (nonatomic, retain) LocationHelper *locationHelper;
@property (nonatomic, retain) MetroMapHelper *metroHelper;

@property (nonatomic, retain) MBProgressHUD *hud;

@property (nonatomic, assign) CGFloat routeRectMinX;
@property (nonatomic, assign) CGFloat routeRectMinY;
@property (nonatomic, assign) CGFloat routeRectMaxX;
@property (nonatomic, assign) CGFloat routeRectMaxY;

@end

@implementation MainMapView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    _locationHelper = [LocationHelper new];
    _metroHelper = [MetroMapHelper new];
    self.backgroundColor = dynamic_color_white;
    return self;
}
    
- (void)beforeViewAppear {
    [self beforeViewDisappear];
    if(!_scriptAdded){
        [_webView.configuration.userContentController addScriptMessageHandler:self name:@"showStation"];
    //    [_webView.configuration.userContentController addScriptMessageHandler:self name:@"showLocateStation"];
        [_webView.configuration.userContentController addScriptMessageHandler:self name:@"showLine"];
        [_webView.configuration.userContentController addScriptMessageHandler:self name:@"console"];
        [_webView.configuration.userContentController addScriptMessageHandler:self name:@"removeStation"];
//        [_webView.configuration.userContentController addScriptMessageHandler:self name:@"scrollToCenter"];
        [_webView.configuration.userContentController addScriptMessageHandler:self name:@"showAllLines"];
        _scriptAdded = YES;
    }
}

- (void)beforeViewDisappear {
    [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"showStation"];
//    [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"showLocateStation"];
    [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"showLine"];
    [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"console"];
    [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"removeStation"];
//    [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"scrollToCenter"];
    [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"showAllLines"];
    _scriptAdded = NO;
}

-(void)dealloc{
    
}

-(void)loadMapView{
    _hud = [MBProgressHUD showWaitingWithText:@"正在加载" image:nil inView:nil];
    NSInteger cityId = [[[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_CITY_ID_KEY] integerValue];
    NSString *urlStr = nil;
    if(!cityId){
        [_hud showCustomView:@"数据加载异常" detail:@"请在城市列表选择城市" image:nil];
        _hud = nil;
        return;
    }

    _city = [CityZipUtils parseFileToCityModel:cityId];
    if(!_city){
        [_hud showCustomView:@"数据加载异常" detail:@"请在城市列表选择城市" image:nil];
        _hud = nil;
        return;
    }else{
        urlStr = [CityZipUtils getMapPath:cityId darkMode:NO];
    }

    //    NSURL *url = [NSURL fileURLWithPath:path];
    
//    [[NSFileManager defaultManager] setAttributes:@{NSFileProtectionKey: NSFileProtectionNone} ofItemAtPath:urlStr error:nil];
    urlStr = [NSString stringWithFormat:@"file://%@",urlStr];
    urlStr = [urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    NSURL *url = [[NSURL alloc] initWithString:urlStr];
    
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    NSString *snapSvg = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"snap.svg-min" withExtension:@"js"] encoding:NSUTF8StringEncoding error:nil];
    WKUserScript *wkSnapSvg = [[WKUserScript alloc] initWithSource:snapSvg injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    NSString *svgClick = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"svg-click" withExtension:@"js"] encoding:NSUTF8StringEncoding error:nil];
    WKUserScript *wkSvgClick = [[WKUserScript alloc] initWithSource:svgClick injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [config.userContentController addUserScript:wkSnapSvg];
    [config.userContentController addUserScript:wkSvgClick];
    
    if(_webView){
        [_webView removeFromSuperview];
        _webView = nil;
    }
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height) configuration:config];
    _webView.navigationDelegate = self;
    _webView.scrollView.delegate = self;
    _webView.UIDelegate = self;
    _webView.scrollView.showsVerticalScrollIndicator = NO;
    _webView.scrollView.showsHorizontalScrollIndicator = NO;
    _webView.scrollView.directionalLockEnabled = NO;
//    _webView.scrollView.bounces = NO;
//    [_webView.scrollView setBouncesZoom: NO];
    [_webView sizeToFit];
    [_webView setOpaque:NO];
    if (@available(iOS 11.0, *)) {
        [_webView.scrollView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }
    _webView.backgroundColor = dynamic_color_white;
//    _webView.scrollView.backgroundColor = dynamic_color_white;

    
//    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(switchMapSize:)];
//    [doubleTap setNumberOfTapsRequired:2];
//    _webView.scrollView.userInteractionEnabled = YES;
//    [_webView.scrollView addGestureRecognizer:doubleTap];
    
    _toLocate = NO;
    if(!_showDefaultStation){
        _defaultStation = nil;
    }
    
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    [_webView loadRequest:request];
    [_webView loadFileURL:url allowingReadAccessToURL:url];
    [self addSubview:_webView];
    [self beforeViewAppear];
}

-(void)updateLocation{
    __weak typeof(self) wkSelf = self;
    [_locationHelper queryLocation:^(NSMutableDictionary *dict) {
        NSString *cityNameCn = [dict[key_city] stringByReplacingOccurrencesOfString:@"市" withString:@""];
        [[NSUserDefaults standardUserDefaults] setObject:dict[key_loc] forKey:LOCATION_LOC_KEY];
        if(![wkSelf.city.nameCn isEqualToString:cityNameCn]){
            if ([NSThread isMainThread]) {
                [[AlertUtils new] alertWithConfirm:@"切换城市" content:[NSString stringWithFormat: @"您的当前位置不在 %@, 是否切换到 %@",wkSelf.city.nameCn,cityNameCn] withBlock:^{
                    [wkSelf checkCityWithBlock:^{
                        if(wkSelf.switchCityData) wkSelf.switchCityData();
                        [wkSelf loadMapView];
                    }];
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[AlertUtils new] alertWithConfirm:@"切换城市" content:[NSString stringWithFormat: @"您的当前位置不在 %@, 是否切换到 %@",wkSelf.city.nameCn,cityNameCn] withBlock:^{
                        [wkSelf checkCityWithBlock:^{
                            if(wkSelf.switchCityData) wkSelf.switchCityData();
                            [wkSelf loadMapView];
                        }];
                    }];
                });
            }
        }else{
            [wkSelf queryNearByStation];
        }
    } failure:^(NSString *info) {
        if ([NSThread isMainThread]) {
            [[AlertUtils new] showTipsView:[NSString stringWithFormat:@"定位失败:%@",info] seconds:2.f];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[AlertUtils new] showTipsView:[NSString stringWithFormat:@"定位失败:%@",info] seconds:2.f];
            });
        }
    } showAlert:YES];
}


-(void)checkCityWithBlock:(void(^)(void))success{
    [_metroHelper updateLocation:^{
        if(success) success();
    } loadData:YES showAlert:YES forceAlert:YES];
}

-(void)queryNearByStation{
    __weak typeof(self) wkSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSString *location = [[NSUserDefaults standardUserDefaults] objectForKey:LOCATION_LOC_KEY];
    if(location) {
        NSArray *array = [location componentsSeparatedByString:@","];
        [params setObject:array[0] forKey:@"longitude"];
        [params setObject:array[1] forKey:@"latitude"];
    }else{
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
                [wkSelf.webView evaluateJavaScript:[NSString stringWithFormat: @"showLocateStation('%@')", wkSelf.nearbyStation.nameCode] completionHandler:^(id _Nullable data, NSError * _Nullable error) {
                    NSMutableDictionary *messageData = (NSMutableDictionary*)data;
                    if(!messageData) return;
                    wkSelf.toLocate = YES;
                    [self showLocateStation:messageData[@"stationName"] location:messageData[@"location"]];
                }];
                break;
            }
        }
    } failure:^(NSString *errorInfo) {
    }];
}



-(void)showLocateStation:(NSString*)stationName location:(NSMutableArray*)location{
//    YYAnimatedImageView *locationGif = [[YYAnimatedImageView alloc] initWithImage:[YYImage imageNamed:@"location"]];
//    locationGif.frame = CGRectMake(0, 0, 25, 25);
    
    UIImageView *locationGif = [self animateLocationImageView:CGRectMake(0, 0, 25, 25)];
    
    CGFloat scale = _webView.scrollView.zoomScale;
    _locateStationPoint = CGPointMake([(NSNumber*)location[0] floatValue], [(NSNumber*)location[1] floatValue]);
    CGFloat contentWidth = _webView.scrollView.contentSize.width/scale;
    CGFloat contentHeight = _webView.scrollView.contentSize.height/scale;
    //调整图片位置及缩放
    scale = scale<1?1:scale;
    scale = scale>3?3:scale;
    if(!_showDefaultStation){
        contentWidth = contentWidth*scale;
        contentHeight = contentHeight*scale;
        CGFloat offsetX = self.locateStationPoint.x*scale - SCREEN_WIDTH/2;
        CGFloat offsetY = self.locateStationPoint.y*scale - _webView.height/2;
        offsetX = offsetX<0?0:offsetX;
        offsetY = offsetY<0?0:offsetY;
        offsetX = (offsetX+SCREEN_WIDTH)>contentWidth?(contentWidth-SCREEN_WIDTH):offsetX;
        offsetY = (offsetY+_webView.height)>contentHeight?(contentHeight-_webView.height):offsetY;
        [UIView animateWithDuration:.5 animations: ^{
            self.webView.scrollView.zoomScale = scale;
            self.webView.scrollView.contentOffset = CGPointMake(offsetX, offsetY);
        } completion:^(BOOL finished){
        }];
    }
    
    if(_locateStationSign) [_locateStationSign removeFromSuperview];
    _locateStationSign = locationGif;
    [self.webView.scrollView addSubview:self.locateStationSign];
    [self.locateStationSign setTransform:CGAffineTransformMakeTranslation(self.locateStationPoint.x*scale-self.locateStationSign.width/2,self.locateStationPoint.y*scale-self.locateStationSign.height/2)];
        
}


//缩放画布时站点弹出框的位置
-(void)transformStationAlertByScale:(CGFloat)scale{
    _stationInfoAlert.frame = CGRectMake(self.stationPoint.x*scale-_stationInfoAlert.frame.size.width/2, self.stationPoint.y*scale-_stationInfoAlert.frame.size.height, _stationInfoAlert.frame.size.width, _stationInfoAlert.frame.size.height);
}
//缩放画布时始末站点标记的位置
-(void)transfromStationSignsWithScale:(CGFloat)scale{
    if(_startStationSign) [_startStationSign setTransform:CGAffineTransformMakeTranslation(_startStationPoint.x*scale-_startStationSign.width/2,_startStationPoint.y*scale-_startStationSign.height/2)];
    if(_endStationSign) [_endStationSign setTransform:CGAffineTransformMakeTranslation(_endStationPoint.x*scale-_endStationSign.width/2,_endStationPoint.y*scale-_endStationSign.height/2)];
    if(_locateStationSign) [_locateStationSign setTransform:CGAffineTransformMakeTranslation(_locateStationPoint.x*scale-_locateStationSign.width/2,_locateStationPoint.y*scale-_locateStationSign.height/2)];
}

//展示站名弹出框
-(void)showStationAlert:(NSString*)stationName location:(NSMutableArray*)location showAlert:(BOOL)alert scroll:(BOOL)scroll{
    NSMutableArray *lines = [NSMutableArray new];
    //匹配当前选择站点
    BOOL findStation = NO;
    for(int i=0; i<_city.stations.count; i++){
        StationModel *station = _city.stations[i];
        if((station.nameCode && [station.nameCode isEqualToString:stationName])
            || (!station.nameCode && [station.nameCn isEqualToString:stationName])) {
            _selectedStation = station;
            findStation = YES;
            break;
        }
    }
    if(!findStation) return;
    
    //匹配选择站点所在的线路
    for(int i=0; i<_selectedStation.lines.count; i++){
        NSInteger lineId = [_selectedStation.lines[i] integerValue];
        for(int j=0; j<_city.lines.count; j++){
            LineModel *l = _city.lines[j];
            if(l.identifyCode == lineId) [lines addObject:l];
        }
    }
    
    CGFloat scale = _webView.scrollView.zoomScale;
    _stationPoint = CGPointMake([(NSNumber*)location[0] floatValue], [(NSNumber*)location[1] floatValue]);
    CGFloat contentWidth = _webView.scrollView.contentSize.width/scale;
    CGFloat contentHeight = _webView.scrollView.contentSize.height/scale;
    //调整图片位置及缩放
    scale = scale<1?1:scale;
    scale = scale>3?3:scale;
    contentWidth = contentWidth*scale;
    contentHeight = contentHeight*scale;
    CGFloat offsetX = self.stationPoint.x*scale - SCREEN_WIDTH/2;
    CGFloat offsetY = self.stationPoint.y*scale - _webView.height/2;
    offsetX = offsetX<0?0:offsetX;
    offsetY = offsetY<0?0:offsetY;
    offsetX = (offsetX+SCREEN_WIDTH)>contentWidth?(contentWidth-SCREEN_WIDTH):offsetX;
    offsetY = (offsetY+_webView.height)>contentHeight?(contentHeight-_webView.height):offsetY;
    
    if(_stationInfoAlert) [_stationInfoAlert removeFromSuperview];
    
    if(scroll || alert){
        [UIView animateWithDuration:.5 animations: ^{
            self.webView.scrollView.zoomScale = scale;
            self.webView.scrollView.contentOffset = CGPointMake(offsetX, offsetY);
        } completion:^(BOOL finished){
            //显示站点弹框
            CGFloat scale = self.webView.scrollView.zoomScale;
            if(alert){
                self.stationInfoAlert = [[StationInfoAlert alloc] initWithFrame:CGRectMake(self.stationPoint.x*scale, self.stationPoint.y*scale, 0, 0) station:self.selectedStation lines:lines];
                [self setStationInfoAlertCallbacks];
                [self.webView.scrollView addSubview:self.stationInfoAlert];
            }
        }];
        _prevOffset = CGPointZero;
        _prevScale = 0;
    }
}

//站点弹出框回调方法
-(void)setStationInfoAlertCallbacks{
    __weak typeof(self) wkSelf = self;
    [_stationInfoAlert setShowLine:^(LineModel *line) {
        wkSelf.showStationLine = YES;
        wkSelf.showLine = YES;
        [wkSelf.webView evaluateJavaScript:[NSString stringWithFormat: @"showAppointLine('%@')", line.code] completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        }];
    }];
    [_stationInfoAlert setShowStationDetail:^(StationModel *station) {
        if(wkSelf.showStationInfo) wkSelf.showStationInfo(wkSelf.city, station.lineModels[0], station);
    }];
    [_stationInfoAlert setSignStation:^(StationModel *station, NSInteger type) {
        if(wkSelf.stationInfoAlert){
            [wkSelf.stationInfoAlert removeFromSuperview];
            wkSelf.stationInfoAlert = nil;
        }
        station.city = wkSelf.city;
        if(wkSelf.requestForRoute) wkSelf.requestForRoute(station, type==1);
    }];
}


//展示起点站终点站标志
-(void) showStationSign:(NSInteger)type{
    if(type==1){
        if(_startStationSign) [_startStationSign removeFromSuperview];
        _startStationSign = [self createSign:YES width:fitFloat(22)];
        //已选择终点站
        if(_endStation){
            //终点站和起点站相同
            if(_endStation.identifyCode == _startStation.identifyCode){
                _endStation = nil;
                if(self.switchRouteStation) self.switchRouteStation(_startStation, _endStation);
                if(_endStationSign) [_endStationSign removeFromSuperview];
            }else{
                //查询中
                [self queryRoute];
            }
        }
        [self.webView.scrollView addSubview:_startStationSign];
    }else{
        if(_endStationSign) [_endStationSign removeFromSuperview];
        _endStationSign = [self createSign:NO width:fitFloat(22)];
        //已选择起点站
        if(_startStation){
            //终点站和起点站相同
            if(_endStation.identifyCode == _startStation.identifyCode){
                _startStation = nil;
                if(self.switchRouteStation) self.switchRouteStation(_startStation, _endStation);
                if(_startStationSign) [_startStationSign removeFromSuperview];
            }else{
                //查询中
                [self queryRoute];
            }
        }
        [self.webView.scrollView addSubview:_endStationSign];
    }
    [self transfromStationSignsWithScale:_webView.scrollView.zoomScale];
}

//创建起点或终点标志
-(UIView*)createSign:(BOOL)isStart width:(CGFloat)labelWidth{
    UIView *signView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, labelWidth*2+4, labelWidth*2+4)];
    LXPositionView *pview = [[LXPositionView alloc] initWithFrame:CGRectMake((signView.width-labelWidth)/2, (signView.height-labelWidth)/2, labelWidth, labelWidth) animationType:AnimationTypeWithBackground];
    pview.multiple = 2;
    if(isStart) pview.backgroundColors = @[(__bridge id)kRGBA(17, 148, 246, 1).CGColor, (__bridge id)kRGBA(39, 198, 251, 0.5).CGColor];
    else pview.backgroundColors = @[(__bridge id)kRGBA(255, 126, 171, 1).CGColor, (__bridge id)kRGBA(255, 181, 213, 0.5).CGColor];
    pview.backgroundTimes = @[@(0.5),@(0.9)];
    pview.borderColors = @[(__bridge id)kRGBA(255, 126, 171, 0).CGColor];
    pview.borderTimes = @[@(0.9)];
    UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake((signView.width-labelWidth-10)/2, (signView.height-labelWidth-10)/2, labelWidth+10, labelWidth+10)];
    bgView.backgroundColor = main_color_white;
    bgView.layer.cornerRadius = bgView.width/2;
    UIView *frView = [[UIView alloc] initWithFrame:CGRectMake((bgView.width-labelWidth)/2, (bgView.height-labelWidth)/2, labelWidth, labelWidth)];
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = CGRectMake(0,0,labelWidth,labelWidth);
    gl.startPoint = CGPointMake(0, 0);
    gl.endPoint = CGPointMake(1, 1);
    gl.colors = isStart ? gradual_color_blue : gradual_color_pink;
    gl.locations = @[@(0), @(1.0f)];
    [frView.layer addSublayer:gl];
    frView.layer.cornerRadius = frView.width/2;
    frView.layer.masksToBounds = YES;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, labelWidth, labelWidth)];
    label.font = main_font_middle_small;
    label.textColor = main_color_white;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = isStart ? @"起" : @"终";
    [frView addSubview:label];
    [bgView addSubview:frView];
    [signView addSubview:pview];
    [signView addSubview:bgView];
    return signView;
}

//显示指定线路
-(void)showLine:(NSString*)lineCode rect:(NSMutableArray*)rect{
    //用于退回原位置
    _prevScale = _webView.scrollView.zoomScale;
    _prevOffset = _webView.scrollView.contentOffset;
    if(!_stationInfoAlert) _showStationLine = NO;
    
    //计算缩放及偏移量
    CGFloat incScale = 1.3;//缩放增量，四周留出边距
    CGFloat x = ([(NSNumber*)rect[0] floatValue]);
    CGFloat y = ([(NSNumber*)rect[1] floatValue]);
    CGFloat width = ([(NSNumber*)rect[2] floatValue])*incScale;
    CGFloat height = ([(NSNumber*)rect[3] floatValue])*incScale;
    CGFloat contentWidth = _webView.scrollView.contentSize.width/(_prevScale==0?1:_prevScale);
    CGFloat contentHeight = _webView.scrollView.contentSize.height/(_prevScale==0?1:_prevScale);
    width = width>contentWidth?contentWidth:width;
    height = height>contentHeight?contentHeight:height;
    CGFloat toScale = (SCREEN_WIDTH/width>_webView.height/height)?(_webView.height/height):(SCREEN_WIDTH/width);
    toScale = toScale<_webView.scrollView.minimumZoomScale?_webView.scrollView.minimumZoomScale:toScale;
    toScale = toScale>_webView.scrollView.maximumZoomScale?_webView.scrollView.maximumZoomScale:toScale;
    CGFloat offsetX = (x+width/incScale/2)*toScale - SCREEN_WIDTH/2;
    CGFloat offsetY = (y+height/incScale/2)*toScale - _webView.height/2;
    offsetX = (offsetX+SCREEN_WIDTH)>contentWidth*toScale?(contentWidth*toScale-SCREEN_WIDTH):offsetX;
    offsetY = (offsetY+_webView.height)>contentHeight*toScale?(contentHeight*toScale-_webView.height):offsetY;
    offsetX = offsetX<0?0:offsetX;
    offsetY = offsetY<0?0:offsetY;
    
    //查询线路的所有站点
    NSString *stationNames;
    for(int i=0; i<_city.lines.count; i++){
        LineModel *l = _city.lines[i];
        NSArray *codeArray = [lineCode componentsSeparatedByString:@"-"];
        if(codeArray.count<2) return;
        if([l.code isEqualToString:codeArray[1]]) {
            NSMutableArray *stationArray = [NSMutableArray new];
            for(int j=0; j<l.stations.count; j++){
                NSInteger lstationId = [l.stations[j] integerValue];
                for(StationModel *cstation in _city.stations) if(cstation.identifyCode == lstationId) {
                    [stationArray addObject:cstation];
                    if(stationNames) stationNames = [NSString stringWithFormat:@"%@,%@", stationNames, cstation.nameCode];
                    else stationNames = cstation.nameCode;
                    break;
                }
            }
        }
    }
    [self.webView evaluateJavaScript:[NSString stringWithFormat: @"showLine('%@','%@')",lineCode, stationNames] completionHandler:^(id _Nullable data, NSError * _Nullable error) {
    }];
    [UIView animateWithDuration:.5 animations: ^{
        self.webView.scrollView.zoomScale = toScale;
        self.webView.scrollView.contentOffset = CGPointMake(offsetX, offsetY);
    } completion:^(BOOL finished){
    }];
}

//查询规划路线
-(void)queryRoute{
    if(!_hud) _hud = [MBProgressHUD showWaitingWithText:@"正在查询路线" image:nil inView:nil];
//    _routeHelper = [[BaiduRouteHelper alloc] initWithCity:_city start:_startStation end:_endStation];
//    __weak typeof(self) wkSelf = self;
//    [_routeHelper queryForRouteWithSuccess:^(NSMutableArray *routeList) {
//        [wkSelf showRouteLine:0 showRouteView:YES];
//    } failure:^(NSString *errorInfo) {
//        if(wkSelf.hud){
//            [wkSelf.hud showCustomView:@"查询异常" detail:nil image:nil];
//            wkSelf.hud = nil;
//        }
//        NSLog(@"====>error %@",errorInfo);
//    }];
    _routeHelper = [[RouteHelpManager alloc] initWithCity:_city start:_startStation end:_endStation];
    __weak typeof(self) wkSelf = self;
    [_routeHelper getRoutesCountWithSuccess:^(NSInteger count) {
        if(count<=0 && wkSelf.hud){
            [wkSelf.hud showCustomView:@"查询异常" detail:nil image:nil];
            wkSelf.hud = nil;
        }else{
            [wkSelf showRouteLine:0 showRouteView:YES];
        }
    }];
}
//查询路线途经站点
-(void)showRouteLine:(NSInteger)index{
//    if(index>=_routeHelper.routeList.count) return;
//    RouteModel *route = _routeHelper.routeList[index];
    
    __weak typeof(self) wkSelf = self;
    [_routeHelper getRouteAtIndex:index success:^(RouteModel *routeInfo) {
        if(!routeInfo){
            [MBProgressHUD showInfo:@"数据异常" detail:nil image:nil inView:nil];
            return;
        }
//        [wkSelf showRouteSegments:routeInfo.segments];
//        if(showRouteView) [wkSelf showRouteView];

        [wkSelf.webView evaluateJavaScript:@"removeRoutes(1)" completionHandler:^(id _Nullable data, NSError * _Nullable error) {
            [wkSelf showRouteSegments:routeInfo.segments];
        }];
    }];
//    [_webView evaluateJavaScript:@"removeRoutes(1)" completionHandler:^(id _Nullable data, NSError * _Nullable error) {
//        [self showRouteSegments:route.segments];
//    }];
//    [self showRouteLine:index showRouteView:NO];
}
//查询路线途经站点
-(void)showRouteLine:(NSInteger)index showRouteView:(BOOL)showRouteView{
    __weak typeof(self) wkSelf = self;
//    [_routeHelper querySegmentPassBy:index success:^(NSMutableArray *segments){
//        [wkSelf showRouteSegments:segments];
//        if(showRouteView) [wkSelf showRouteView];
//    }];
    [_routeHelper getRouteAtIndex:index success:^(RouteModel *routeInfo) {
        if(!routeInfo){
            [MBProgressHUD showInfo:@"数据异常" detail:nil image:nil inView:nil];
            return;
        }
        [wkSelf showRouteSegments:routeInfo.segments];
        if(showRouteView) [wkSelf showRouteView];
    }];
}
-(void)showRouteView{
    __weak typeof(self) wkSelf = self;
    if ([NSThread isMainThread]) {
        if(wkSelf.showRouteInfoView) wkSelf.showRouteInfoView(wkSelf.routeHelper);
        wkSelf.routeViewShowing = YES;
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            if(wkSelf.showRouteInfoView) wkSelf.showRouteInfoView(wkSelf.routeHelper);
            wkSelf.routeViewShowing = YES;
        });
    }
}
//显示规划路线
-(void)showRouteSegments:(NSMutableArray*)segments{
    // 创建组
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("concurrent.routeShowing.queue", DISPATCH_QUEUE_CONCURRENT);

    self.routeRectMinX = -1;
    self.routeRectMinY = -1;
    self.routeRectMaxX = -1;
    self.routeRectMaxY = -1;
    __weak typeof(self) wkSelf = self;
    for(RouteSegmentModel *segment in segments){
        NSString *stationNames = nil;
        NSString *lineCode = [NSString stringWithFormat:@"L-%@",segment.line.code];
        NSString *lineColor = segment.line.color?segment.line.color:@"#000000";
        if([lineColor hasPrefix:@"0x"]) lineColor = [lineColor stringByReplacingOccurrencesOfString:@"0x" withString:@"#"];
        if([lineColor hasPrefix:@"0X"]) lineColor = [lineColor stringByReplacingOccurrencesOfString:@"0X" withString:@"#"];
        NSString *checkDirection = @"0";
        if(segment.line.type && [@"环线" isEqualToString:segment.line.type]) checkDirection = @"1";
        //北京机场线
        if(segment.line.type && [@"巡回" isEqualToString:segment.line.type]) checkDirection = @"2";
        for(StationModel *station in segment.stationsByWay){
            if(stationNames) stationNames = [stationNames stringByAppendingString:[NSString stringWithFormat:@",%@",station.nameCode]];
            else stationNames = station.nameCode;
        }
        dispatch_group_async(group, queue, ^{
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            if ([NSThread isMainThread]) {
                [wkSelf.webView evaluateJavaScript:[NSString stringWithFormat: @"showRoute('%@','%@', '%@', %@)",lineCode, stationNames,lineColor,checkDirection] completionHandler:^(id _Nullable data, NSError * _Nullable error) {
                    NSMutableDictionary *messageData = (NSMutableDictionary*)data;
                    NSArray *rect = messageData[@"rect"];
                    if(rect && rect.count==4) [wkSelf updateRouteRect:rect];
                    //发送信号量
                    dispatch_semaphore_signal(semaphore);
                }];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wkSelf.webView evaluateJavaScript:[NSString stringWithFormat: @"showRoute('%@','%@', '%@', %@)",lineCode, stationNames,lineColor,checkDirection] completionHandler:^(id _Nullable data, NSError * _Nullable error) {
                        NSMutableDictionary *messageData = (NSMutableDictionary*)data;
                        NSArray *rect = messageData[@"rect"];
                        if(rect && rect.count==4) [wkSelf updateRouteRect:rect];
                        //发送信号量
                        dispatch_semaphore_signal(semaphore);
                    }];
                });
            }
            // 在网络请求任务成功之前，信号量等待中
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        });
    }
    dispatch_group_notify(group, queue, ^{
        if ([NSThread isMainThread]) {
            if(wkSelf.hud){
                [wkSelf.hud hideAnimated:YES];
                wkSelf.hud = nil;
            }
            if(wkSelf.routeRectMinX>=0 && wkSelf.routeRectMinY>=0 && wkSelf.routeRectMaxX>wkSelf.routeRectMinX && wkSelf.routeRectMaxY>wkSelf.routeRectMinY) [wkSelf autoZoomMapWithRouteRect];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(wkSelf.hud){
                    [wkSelf.hud hideAnimated:YES];
                    wkSelf.hud = nil;
                }
                if(wkSelf.routeRectMinX>=0 && wkSelf.routeRectMinY>=0 && wkSelf.routeRectMaxX>wkSelf.routeRectMinX && wkSelf.routeRectMaxY>wkSelf.routeRectMinY) [wkSelf autoZoomMapWithRouteRect];
            });
        }
    });
}

-(void)autoZoomMapWithRouteRect{
    CGFloat incScale = 1.3;//缩放增量，四周留出边距
    CGFloat x = self.routeRectMinX;
    CGFloat y = self.routeRectMinY;
    CGFloat width = (self.routeRectMaxX-self.routeRectMinX)*incScale;
    CGFloat height = (self.routeRectMaxY-self.routeRectMinY)*incScale;
    CGFloat contentWidth = self.webView.scrollView.contentSize.width/_webView.scrollView.zoomScale;
    CGFloat contentHeight = self.webView.scrollView.contentSize.height/_webView.scrollView.zoomScale;
    width = width>contentWidth?contentWidth:width;
    height = height>contentHeight?contentHeight:height;
    CGFloat toScale = (SCREEN_WIDTH/width>(self.webView.height-226)/height)?((self.webView.height-226)/height):(SCREEN_WIDTH/width);
    toScale = toScale<_webView.scrollView.minimumZoomScale?_webView.scrollView.minimumZoomScale:toScale;
    toScale = toScale>_webView.scrollView.maximumZoomScale?_webView.scrollView.maximumZoomScale:toScale;
    CGFloat offsetX = (x+width/incScale/2)*toScale - SCREEN_WIDTH/2;
    CGFloat offsetY = (y+height/incScale/2)*toScale - (self.webView.height-226)/2;
    offsetX = (offsetX+SCREEN_WIDTH)>contentWidth*toScale?(contentWidth*toScale-SCREEN_WIDTH):offsetX;
    offsetY = (offsetY+self.webView.height)>contentHeight*toScale?(contentHeight*toScale-self.webView.height):offsetY;
    offsetX = offsetX<0?0:offsetX;
    offsetY = offsetY<0?0:offsetY;
    __weak typeof(self) wkSelf = self;
    [UIView animateWithDuration:.5 animations: ^{
        wkSelf.webView.scrollView.zoomScale = toScale;
        wkSelf.webView.scrollView.contentOffset = CGPointMake(offsetX, offsetY);
    } completion:^(BOOL finished){
    }];
}

-(void)updateRouteRect:(NSArray *)rect{
    CGFloat minX = ([(NSNumber*)rect[0] floatValue]);
    CGFloat minY = ([(NSNumber*)rect[1] floatValue]);
    CGFloat maxX = ([(NSNumber*)rect[2] floatValue]);
    CGFloat maxY = ([(NSNumber*)rect[3] floatValue]);
    minX = minX<0 ? 0 : minX;
    minY = minY<0 ? 0 : minY;
    maxX = maxX<0 ? 0 : maxX;
    maxY = maxY<0 ? 0 : maxY;
    self.routeRectMinX = (minX<self.routeRectMinX || self.routeRectMinX<0)?minX:self.routeRectMinX;
    self.routeRectMinY = (minY<self.routeRectMinY || self.routeRectMinY<0)?minY:self.routeRectMinY;
    self.routeRectMaxX = maxX>self.routeRectMaxX?maxX:self.routeRectMaxX;
    self.routeRectMaxY = maxY>self.routeRectMaxY?maxY:self.routeRectMaxY;
}

-(void)closeRouteShow{
    [_webView evaluateJavaScript:@"removeRoutes(0)" completionHandler:^(id _Nullable data, NSError * _Nullable error) {
    }];
    _routeViewShowing = NO;
    _routeHelper = nil;
    _startStation = nil;
    _endStation = nil;
    if(self.switchRouteStation) self.switchRouteStation(_startStation, _endStation);
    if(_startStationSign){
        [_startStationSign removeFromSuperview];
        _startStationSign = nil;
    }
    if(_endStationSign){
        [_endStationSign removeFromSuperview];
        _endStationSign = nil;
    }
}

#pragma mark - WKNavigationDelegate
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [_webView evaluateJavaScript:@"setGroupClickFunction()" completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        if(data && [data isKindOfClass:NSString.class]){
            NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
            if(!err) for(int i=0; i<self.city.lines.count; i++){
                LineModel *l = self.city.lines[i];
                if(dic[l.code]) l.color = [dic objectForKey:l.code];
            }
        }
    }];
    [_webView evaluateJavaScript:[NSString stringWithFormat: @"resetSVGSize(%f,%f)",SCREEN_WIDTH*3,_webView.height*3] completionHandler:^(id _Nullable data, NSError * _Nullable error) {
//        self.webView.scrollView.contentSize = CGSizeMake(self.width, self.height);
        [self performSelector:@selector(scrollViewToCenter) withObject:nil afterDelay:1.f];
    }];
    
    //深色模式
    if (@available(iOS 13.0, *)) {
        NSInteger isDarkMode = 0;
        if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
            isDarkMode = 1;
        }
        [_webView evaluateJavaScript:[NSString stringWithFormat: @"initColorParams('%ld')",(long)isDarkMode] completionHandler:^(id _Nullable data, NSError * _Nullable error) {

        }];
    }
    [self queryNearByStation];
}

-(void)scrollViewToCenter{
    if(_hud){
        [_hud hideAnimated:YES];
        _hud = nil;
    }
    self.initZoomScale = self.webView.scrollView.zoomScale;
    if(self.showDefaultStation){
        [self showAppointStationForStart:false forEnd:false scroll:YES];
    }else if(!self.toLocate){
        CGSize contentSize = self.webView.scrollView.contentSize;
        [UIView animateWithDuration:.5f animations:^{
            self.webView.scrollView.contentOffset = CGPointMake((contentSize.width - SCREEN_WIDTH)/2, (contentSize.height - self.height)/2);
        }];
    }
}

-(void)setNearbyStationForStart:(BOOL)start end:(BOOL)end scroll:(BOOL)scroll{
    if(_nearbyStation){
        [self setDefaultStation:_nearbyStation forStart:start forEnd:end scroll:scroll];
    }
}

-(void)setDefaultStation:(StationModel *)defaultStation forStart:(BOOL)start forEnd:(BOOL)end scroll:(BOOL)scroll{
    _defaultStation = defaultStation;
    _showDefaultStation = YES;
    if(_defaultStation.city && _defaultStation.city.identifyCode == _city.identifyCode){
        [self showAppointStationForStart:start forEnd:end scroll:scroll];
    }
}

//显示指定站点
-(void)showAppointStationForStart:(BOOL)start forEnd:(BOOL)end scroll:(BOOL)scroll{
    __weak typeof(self) wkSelf = self;
    [self.webView evaluateJavaScript:[NSString stringWithFormat: @"showAppointStation('%@')", self.defaultStation.nameCode] completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        NSMutableDictionary *messageData = (NSMutableDictionary*)data;
        if(!messageData) return;
        [self showStationAlert:messageData[@"stationName"] location:messageData[@"location"] showAlert:(!start && !end) scroll:scroll];
        if(start){
            wkSelf.startStation = wkSelf.selectedStation;
            wkSelf.startStationPoint = wkSelf.stationPoint;
            [wkSelf showStationSign:1];
            if(wkSelf.switchRouteStation) wkSelf.switchRouteStation(wkSelf.startStation, wkSelf.endStation);
        }else if(end){
            wkSelf.endStation = wkSelf.selectedStation;
            wkSelf.endStationPoint = wkSelf.stationPoint;
            [wkSelf showStationSign:2];
            if(wkSelf.switchRouteStation) wkSelf.switchRouteStation(wkSelf.startStation, wkSelf.endStation);
        }
        wkSelf.showDefaultStation = NO;
    }];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if([@"showStation" isEqualToString:message.name]){
        //显示站点弹出框
        NSMutableDictionary *messageData = (NSMutableDictionary*)(message.body);
        [self showStationAlert:messageData[@"stationName"] location:messageData[@"location"] showAlert:YES scroll:YES];
//    }else if([@"showLocateStation" isEqualToString:message.name]){_toLocate = YES;
//        NSMutableDictionary *messageData = (NSMutableDictionary*)(message.body);
//        [self showLocateStation:messageData[@"stationName"] location:messageData[@"location"]];
    }else if([@"showLine" isEqualToString:message.name]){
        if(self.stationInfoAlert && !self.showStationLine) return;//正在显示站点弹框时，不展示线路
        //显示线路
        NSMutableDictionary *messageData = (NSMutableDictionary*)(message.body);
        [self showLine:messageData[@"lineCode"] rect:messageData[@"rect"]];
        self.showLine = YES;
    }else if([@"removeStation" isEqualToString:message.name]){
        if(self.showLine) self.showLine = NO;
        else if(!self.stationInfoAlert && !self.routeViewShowing)  self.switchTabbar();
        if(!self.showStationLine) [self removeStation];
    }else if([@"showAllLines" isEqualToString:message.name]){
        [self showAllLines];
//    }else if([@"scrollToCenter" isEqualToString:message.name]){
//        _initZoomScale = _webView.scrollView.zoomScale;
//        if(!_toLocate && !_showDefaultStation){
//            CGSize contentSize = _webView.scrollView.contentSize;
//            _webView.scrollView.contentOffset = CGPointMake((contentSize.width - SCREEN_WIDTH)/2, (contentSize.height - self.height)/2);
//        }
    }else if([@"console" isEqualToString:message.name]){
        NSLog(@"%@-->%.2f",message.body,_webView.scrollView.zoomScale);
    }
}
    
-(void)removeStation{
    if(_stationInfoAlert){
        [_stationInfoAlert removeFromSuperview];
        _stationInfoAlert = nil;
        _selectedStation = nil;
//        [self selectedInStationList];
    }
}

//从某条线路回归到显示所有线路
-(void)showAllLines{
    [UIView animateWithDuration:.5 animations: ^{
        if(self.prevScale!=0) self.webView.scrollView.zoomScale = self.prevScale;
        if(!CGPointEqualToPoint(self.prevOffset, CGPointZero)) self.webView.scrollView.contentOffset = self.prevOffset;
    } completion:^(BOOL finished){
        self.prevOffset = CGPointZero;
        self.prevScale = 0;
        self.showStationLine = NO;
    }];
}
    
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
//    [self transformStationAlertWithScale:_webView.scrollView.zoomScale];
    [self transformStationAlertByScale:_webView.scrollView.zoomScale];
    [self transfromStationSignsWithScale:_webView.scrollView.zoomScale];
}
    
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
//    [_webView evaluateJavaScript:[NSString stringWithFormat: @"resetScale(%f)",scale] completionHandler:^(id _Nullable data, NSError * _Nullable error) {
//    }];
}

-(void) scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    UIPinchGestureRecognizer *ges1 = scrollView.pinchGestureRecognizer;
    if(ges1 && ges1.state==UIGestureRecognizerStatePossible) [ges1 setState:UIGestureRecognizerStateBegan];
}
    
-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    UIPinchGestureRecognizer *ges1 = scrollView.pinchGestureRecognizer;
    if(ges1 && ges1.state==UIGestureRecognizerStateBegan) [ges1 setState:UIGestureRecognizerStateChanged];
}
    
-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    self.prevOffset = CGPointZero;
    UIPinchGestureRecognizer *ges1 = scrollView.pinchGestureRecognizer;
    if(ges1 && ges1.state==UIGestureRecognizerStateChanged) [ges1 setState:UIGestureRecognizerStateEnded];
}


-(void)switchMapSize:(UITapGestureRecognizer*)tap{
    CGFloat scale = _webView.scrollView.zoomScale;
    CGPoint point = [tap locationInView:tap.view];
    
    if(scale<3){
        scale = 3;
    }else{
        scale = _webView.scrollView.minimumZoomScale;
    }
    CGFloat contentWidth = _webView.scrollView.contentSize.width/scale;
    CGFloat contentHeight = _webView.scrollView.contentSize.height/scale;
    contentWidth = contentWidth*scale;
    contentHeight = contentHeight*scale;
    CGFloat offsetX = point.x*scale - SCREEN_WIDTH/2;
    CGFloat offsetY = point.y*scale - _webView.height/2;
    offsetX = offsetX<0?0:offsetX;
    offsetY = offsetY<0?0:offsetY;
    offsetX = (offsetX+SCREEN_WIDTH)>contentWidth?(contentWidth-SCREEN_WIDTH):offsetX;
    offsetY = (offsetY+_webView.height)>contentHeight?(contentHeight-_webView.height):offsetY;
    [UIView animateWithDuration:.5 animations: ^{
        self.webView.scrollView.zoomScale = scale;
        self.webView.scrollView.contentOffset = CGPointMake(offsetX, offsetY);
    } completion:^(BOOL finished){
    }];
}

-(void)updateCGColors{
    if(_stationInfoAlert) [_stationInfoAlert updateCGColors];
}



- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    // trait发生了改变
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            NSInteger isDarkMode = 0;
            if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
                isDarkMode = 1;
            }
            [_webView evaluateJavaScript:[NSString stringWithFormat: @"swtichColors(%ld)",(long)isDarkMode] completionHandler:^(id _Nullable data, NSError * _Nullable error) {
                
            }];
        }
    } else {
    }
}


- (UIImageView*)animateLocationImageView:(CGRect)frame {
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:frame];
    
    NSMutableArray *imageArr = [NSMutableArray arrayWithCapacity:12];
    for (int i = 0; i<12; i++) {
        NSString *imageStr = [NSString stringWithFormat:@"location%d",i + 1];
        UIImage *image = [UIImage imageNamed:imageStr];
        [imageArr addObject:image];
    }
    imageView.animationImages = imageArr;
    imageView.animationDuration = 2;
    [imageView startAnimating];
    return imageView;
}
@end
