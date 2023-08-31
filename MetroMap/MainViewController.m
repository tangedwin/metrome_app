//
//  MainViewController.m
//  MetroMap
//
//  Created by edwin on 2019/8/26.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "MainViewController.h"


@interface MainViewController ()<WKNavigationDelegate, UIScrollViewDelegate, WKUIDelegate, WKScriptMessageHandler>
    
@property(nonatomic, assign) CGFloat initZoomScale;

//显示线路后退回到原位置
@property(nonatomic, assign) CGFloat prevScale;
@property(nonatomic, assign) CGPoint prevOffset;

//显示经过某站点的线路
@property(nonatomic, assign) BOOL showStationLine;
    
@property(nonatomic, assign) BOOL stationListShowing;
@property(nonatomic, retain) StationListView *stationListView;
@property(nonatomic, retain) StationInfo *selectedStation;

//出发站目的站
@property(nonatomic, retain) StationInfo *startStation;
@property(nonatomic, retain) StationInfo *endStation;
@property(nonatomic, assign) CGPoint startStationPoint;
@property(nonatomic, assign) CGPoint endStationPoint;
@property(nonatomic, retain) UIImageView *startStationSign;
@property(nonatomic, retain) UIImageView *endStationSign;
    
@property(nonatomic, retain) MetroDataCache *dataCache;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"shanghaiMap" ofType:@"svg"];
    urlStr = [NSString stringWithFormat:@"file://%@",urlStr];
    NSURL *url = [[NSURL alloc] initWithString:urlStr];
    [self loadMetroMap:url];
    _dataCache = [MetroDataCache shareInstanceWithCityCode:@"shanghai"];
    
    //导航栏
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.clipsToBounds=YES;
    //左右按钮
    self.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"城市" style:UIBarButtonItemStylePlain target:self action:@selector(switchCityList)];
    self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithTitle:@"站点" style:UIBarButtonItemStylePlain target:self action:@selector(switchStationList)];
    
}


-(void)loadMetroMap:(NSURL * _Nonnull)imageUrl{
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    NSString *snapSvg = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"snap.svg-min" withExtension:@"js"] encoding:NSUTF8StringEncoding error:nil];
    WKUserScript *wkSnapSvg = [[WKUserScript alloc] initWithSource:snapSvg injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    NSString *svgClick = [NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"svg-click" withExtension:@"js"] encoding:NSUTF8StringEncoding error:nil];
    WKUserScript *wkSvgClick = [[WKUserScript alloc] initWithSource:svgClick injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    [config.userContentController addUserScript:wkSnapSvg];
    [config.userContentController addUserScript:wkSvgClick];
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, kNavBarAndStatusBarHeight, kScreenWidth, kScreenHeight-kNavBarAndStatusBarHeight) configuration:config];
    _webView.navigationDelegate = self;
    _webView.scrollView.delegate = self;
    _webView.UIDelegate = self;
    _webView.scrollView.showsVerticalScrollIndicator = NO;
    _webView.scrollView.showsHorizontalScrollIndicator = NO;
    _webView.scrollView.directionalLockEnabled = NO;
    [_webView sizeToFit];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:imageUrl];
    [_webView loadRequest:request];
    [self.view addSubview:_webView];
    
}

    
//展示站名弹出框
-(void)showStationAlert:(NSString*)stationName location:(NSMutableArray*)location{
    NSMutableArray *lines = [NSMutableArray new];
    //匹配当前选择站点
    if(!_selectedStation || ![_selectedStation checkStationByName:stationName]){
        for(int i=0; i<_dataCache.stations.count; i++){
            StationInfo *s = _dataCache.stations.allValues[i];
            if([s checkStationByName:stationName]){
                _selectedStation = s;
                break;
            }
        }
    }
    //匹配选择站点所在的线路
    for(int i=0; i<_selectedStation.lineIds.count; i++){
        for(int j=0; j<_dataCache.lines.count; j++){
            LineInfo *l = _dataCache.lines[j];
            if([l.identityNum integerValue] == [_selectedStation.lineIds[i] integerValue]) [lines addObject:l];
        }
    }
    
    CGFloat scale = _webView.scrollView.zoomScale;
    _stationPoint = CGPointMake([(NSNumber*)location[0] floatValue]/3/_initZoomScale, [(NSNumber*)location[1] floatValue]/3/_initZoomScale);
    CGFloat contentWidth = _webView.scrollView.contentSize.width/scale;
    CGFloat contentHeight = _webView.scrollView.contentSize.height/scale;
    //调整图片位置及缩放
    scale = scale<1?1:scale;
    scale = scale>3?3:scale;
    contentWidth = contentWidth*scale;
    contentHeight = contentHeight*scale;
    CGFloat offsetX = self.stationPoint.x*scale - kScreenWidth/2;
    CGFloat offsetY = self.stationPoint.y*scale - _webView.height/2;
    offsetX = offsetX<0?0:offsetX;
    offsetY = offsetY<0?0:offsetY;
    offsetX = (offsetX+kScreenWidth)>contentWidth?(contentWidth-kScreenWidth):offsetX;
    offsetY = (offsetY+kSafeAreaHeight)>contentHeight?(contentHeight-kSafeAreaHeight):offsetY;
    
    if(_stationAlertView) [_stationAlertView removeFromSuperview];
    [UIView animateWithDuration:.5 animations: ^{
        self.webView.scrollView.zoomScale = scale;
        self.webView.scrollView.contentOffset = CGPointMake(offsetX, offsetY);
    } completion:^(BOOL finished){
        self.stationAlertType=2;
        if(offsetY==0 && self.stationPoint.y*scale<100) self.stationAlertType=1;
        if(offsetX==0 && self.stationPoint.x*scale<200) self.stationAlertType=4;
        if(offsetX==(contentWidth-kScreenWidth) && self.stationPoint.x*scale>contentWidth-200) self.stationAlertType=3;
        self.stationAlertView = [[StationAlert alloc] initWithStation:self.selectedStation lines:lines type:self.stationAlertType];
        [self setStationAlertFunctions];
        [self.webView.scrollView addSubview:self.stationAlertView];
        [self transformStationAlertWithScale:scale];
        [self selectedInStationList];
    }];
    _prevOffset = CGPointZero;
    _prevScale = 0;
}
    
//显示线路
-(void)showLine:(NSString*)lineCode rect:(NSMutableArray*)rect{
    //用于退回原位置
    _prevScale = _webView.scrollView.zoomScale;
    _prevOffset = _webView.scrollView.contentOffset;
    if(!_stationAlertView) _showStationLine = NO;
    
    //计算缩放及偏移量
    CGFloat incScale = 1.3;//缩放增量
    CGFloat x = ([(NSNumber*)rect[0] floatValue]/3)/_initZoomScale;
    CGFloat y = ([(NSNumber*)rect[1] floatValue]/3)/_initZoomScale;
    CGFloat width = ([(NSNumber*)rect[2] floatValue]/3)/_initZoomScale*incScale;
    CGFloat height = ([(NSNumber*)rect[3] floatValue]/3)/_initZoomScale*incScale;
    CGFloat contentWidth = _webView.scrollView.contentSize.width/_prevScale;
    CGFloat contentHeight = _webView.scrollView.contentSize.height/_prevScale;
    CGFloat toScale = (kScreenWidth/width>_webView.height/height)?(_webView.height/height):(kScreenWidth/width);
    toScale = toScale<_initZoomScale?_initZoomScale:toScale;
    CGFloat offsetX = (x+width/incScale/2)*toScale - kScreenWidth/2;
    CGFloat offsetY = (y+height/incScale/2)*toScale - _webView.height/2;
    offsetX = offsetX<0?0:offsetX;
    offsetY = offsetY<0?0:offsetY;
    offsetX = (offsetX+kScreenWidth)>contentWidth*toScale?(contentWidth*toScale-kScreenWidth):offsetX;
    offsetY = (offsetY+kSafeAreaHeight)>contentHeight*toScale?(contentHeight*toScale-kSafeAreaHeight):offsetY;
    
    //查询线路的所有站点
    NSString *stationNames;
    for(int i=0; i<_dataCache.lines.count; i++){
        LineInfo *l = _dataCache.lines[i];
        if([l.scode isEqualToString:[lineCode stringByReplacingOccurrencesOfString:@"L-" withString:@""]]) for(int j=0; j<l.stationIds.count; j++){
            StationInfo *s = [_dataCache.stations objectForKey:[NSString stringWithFormat:@"%@", l.stationIds[j]]];
            if(stationNames) stationNames = [NSString stringWithFormat:@"%@,%@", stationNames, s.nameCnOnly?s.nameCnOnly:s.nameCn];
            else stationNames = s.nameCnOnly?s.nameCnOnly:s.nameCn;
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

//站点列表
-(void)switchStationList{
    if(!_stationListShowing && !_stationListView){
        _stationListView = [[StationListView alloc] initWithFrame:CGRectMake(kScreenWidth-140, -kScreenHeight, 140, kSafeAreaHeight-10)];
        __weak typeof(self) wkSelf = self;
        [_stationListView setDidSelectedCallback:^(StationInfo *station, LineInfo *line) {
            wkSelf.selectedStation = station;
            [wkSelf.webView evaluateJavaScript:[NSString stringWithFormat: @"showAppointStation('%@')", station.nameCnOnly?station.nameCnOnly:station.nameCn] completionHandler:^(id _Nullable data, NSError * _Nullable error) {
            }];
            [wkSelf switchStationList];
        }];
        [_stationListView setHidden:YES];
        [self.view addSubview:_stationListView];
    }
    if(!_stationListShowing){
        _stationListShowing = YES;
        [_stationListView setHidden:NO];
        [UIView animateWithDuration:.5 animations: ^{
            self.stationListView.transform = CGAffineTransformMakeTranslation(0, kScreenHeight+kNavBarAndStatusBarHeight);
        } completion:^(BOOL finished){
            
        }];
    }else{
        _stationListShowing = NO;
        [UIView animateWithDuration:.5 animations: ^{
            self.stationListView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
            [self.stationListView setHidden:YES];
        }];
    }
}
    
//站点弹出框回调方法
-(void)setStationAlertFunctions{
    __weak typeof(self) wkSelf = self;
    [_stationAlertView setShowLine:^(LineInfo *line) {
        wkSelf.showStationLine = YES;
        [wkSelf.webView evaluateJavaScript:[NSString stringWithFormat: @"showAppointLine('%@')", line.scode] completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        }];
    }];
    [_stationAlertView setShowStationDetail:^(StationInfo *station) {
        
    }];
    [_stationAlertView setSignStation:^(StationInfo *station, NSInteger type) {
        if(wkSelf.stationAlertView){
            [wkSelf.stationAlertView removeFromSuperview];
            wkSelf.stationAlertView = nil;
        }
        if(type==1){
            wkSelf.startStation = station;
            wkSelf.startStationPoint = wkSelf.stationPoint;
        }else{
            wkSelf.endStation = station;
            wkSelf.endStationPoint = wkSelf.stationPoint;
        }
        [wkSelf showStationSign:type];
    }];
}

//展示起点站终点站标志
-(void) showStationSign:(NSInteger)type{
    UIImage *image = [UIImage imageNamed:type==1?@"iufadi":@"mudidi"];
    UIImageView *signView = [[UIImageView alloc] initWithImage:image];
    CGFloat width = 40;
    CGFloat height = width/image.size.width * image.size.height;
    signView.frame = CGRectMake(0, 0, width, height);
    if(type==1) {
        if(_startStationSign) [_startStationSign removeFromSuperview];
        _startStationSign = signView;
        [_webView.scrollView addSubview:_startStationSign];
        if(_endStation){
            if([_endStation.identityNum integerValue]==[_startStation.identityNum integerValue]){
                _endStation = nil;
                if(_endStationSign) [_endStationSign removeFromSuperview];
            }else{
                //查询中
                MetroRouteQuery *routeQuery = [MetroRouteQuery new];
                [routeQuery queryRoute:@"shanghai" startStation:_startStation endStation:_endStation];
            }
        }
    }else{
        if(_endStationSign) [_endStationSign removeFromSuperview];
        _endStationSign = signView;
        [_webView.scrollView addSubview:_endStationSign];
        if(_startStation){
            if([_endStation.identityNum integerValue]==[_startStation.identityNum integerValue]){
                _startStation = nil;
                if(_startStationSign) [_startStationSign removeFromSuperview];
            }else{
                //查询中
                MetroRouteQuery *routeQuery = [MetroRouteQuery new];
                [routeQuery queryRoute:@"shanghai" startStation:_startStation endStation:_endStation];
            }
        }
    }
    [self transfromStationSignsWithScale:_webView.scrollView.zoomScale];
}

//缩放画布时站点弹出框的位置
-(void)transformStationAlertWithScale:(CGFloat)scale{
    if(self.stationAlertType==1) [self.stationAlertView setTransform:CGAffineTransformMakeTranslation(self.stationPoint.x*scale-self.stationAlertView.width/2,self.stationPoint.y*scale)];
    else if(self.stationAlertType==2) [self.stationAlertView setTransform:CGAffineTransformMakeTranslation(self.stationPoint.x*scale-self.stationAlertView.width/2,self.stationPoint.y*scale-self.stationAlertView.height)];
    else if(self.stationAlertType==3) [self.stationAlertView setTransform:CGAffineTransformMakeTranslation(self.stationPoint.x*scale-self.stationAlertView.width,self.stationPoint.y*scale-self.stationAlertView.height/2)];
    else if(self.stationAlertType==4) [self.stationAlertView setTransform:CGAffineTransformMakeTranslation(self.stationPoint.x*scale,self.stationPoint.y*scale-self.stationAlertView.height/2)];
}

//缩放画布时始末站点标记的位置
-(void)transfromStationSignsWithScale:(CGFloat)scale{
    if(_startStationSign) [_startStationSign setTransform:CGAffineTransformMakeTranslation(_startStationPoint.x*scale-_startStationSign.width/2,_startStationPoint.y*scale-_startStationSign.height/2)];
    if(_endStationSign) [_endStationSign setTransform:CGAffineTransformMakeTranslation(_endStationPoint.x*scale-_endStationSign.width/2,_endStationPoint.y*scale-_endStationSign.height/2)];
}
    
#pragma mark - WKNavigationDelegate
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    [_webView evaluateJavaScript:@"setGroupClickFunction()" completionHandler:^(id _Nullable data, NSError * _Nullable error) {
        if(data && [data isKindOfClass:NSString.class]){
            NSData *jsonData = [data dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
            if(!err) for(int i=0; i<self.dataCache.lines.count; i++){
                    LineInfo *l = self.dataCache.lines[i];
                    l.bgcolor = [dic objectForKey:l.scode];
            }
        }
    }];
    [_webView evaluateJavaScript:[NSString stringWithFormat: @"resetSVGSize(%f,%f)",kScreenWidth*3,kSafeAreaHeight*3] completionHandler:^(id _Nullable data, NSError * _Nullable error) {
    }];
}

#pragma mark - WKScriptMessageHandler
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message{
    if([@"showStation" isEqualToString:message.name]){
        //显示站点弹出框
        NSMutableDictionary *messageData = (NSMutableDictionary*)(message.body);
        [self showStationAlert:messageData[@"stationName"] location:messageData[@"location"]];
    }else if([@"showLine" isEqualToString:message.name]){
        if(self.stationAlertView && !self.showStationLine) return;//正在显示站点弹框时，不展示线路
        //显示线路
        NSMutableDictionary *messageData = (NSMutableDictionary*)(message.body);
        [self showLine:messageData[@"lineCode"] rect:messageData[@"rect"]];
    }else if([@"removeStation" isEqualToString:message.name]){
        if(!self.showStationLine) [self removeStation];
    }else if([@"showAllLines" isEqualToString:message.name]){
        [self showAllLines];
    }else if([@"scrollToCenter" isEqualToString:message.name]){
        _initZoomScale = _webView.scrollView.zoomScale;
        CGSize contentSize = _webView.scrollView.contentSize;
        _webView.scrollView.contentOffset = CGPointMake((contentSize.width - kScreenWidth)/2, (contentSize.height - kSafeAreaHeight)/2);
    }else if([@"console" isEqualToString:message.name]){
        NSLog(@"%@-->%.2f",message.body,_webView.scrollView.zoomScale);
    }
}
    
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_webView.configuration.userContentController addScriptMessageHandler:self name:@"showStation"];
    [_webView.configuration.userContentController addScriptMessageHandler:self name:@"showLine"];
    [_webView.configuration.userContentController addScriptMessageHandler:self name:@"console"];
    [_webView.configuration.userContentController addScriptMessageHandler:self name:@"removeStation"];
    [_webView.configuration.userContentController addScriptMessageHandler:self name:@"scrollToCenter"];
    [_webView.configuration.userContentController addScriptMessageHandler:self name:@"showAllLines"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillAppear:animated];
    [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"showStation"];
    [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"showLine"];
    [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"console"];
    [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"removeStation"];
    [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"scrollToCenter"];
    [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"showAllLines"];
}
    
-(void)removeStation{
    if(_stationAlertView){
        [_stationAlertView removeFromSuperview];
        _stationAlertView = nil;
        _selectedStation = nil;
        [self selectedInStationList];
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
//弹出站点框与站点列表联动
-(void)selectedInStationList{
    if(_selectedStation) for(int i=0; i<_dataCache.lines.count; i++){
        LineInfo *l = _dataCache.lines[i];
        if([l.identityNum integerValue]==[_selectedStation.lineIds[0] integerValue]){
            [self.stationListView setDefaultSelect:l.scode stationName:_selectedStation.nameCn];
        }
    }else [self.stationListView setDefaultSelect:nil stationName:nil];
}
    
#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    [self transformStationAlertWithScale:_webView.scrollView.zoomScale];
    [self transfromStationSignsWithScale:_webView.scrollView.zoomScale];
}
    
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    [_webView evaluateJavaScript:[NSString stringWithFormat: @"resetScale(%f)",scale] completionHandler:^(id _Nullable data, NSError * _Nullable error) {
    }];
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
    UIPinchGestureRecognizer *ges1 = scrollView.pinchGestureRecognizer;
    if(ges1 && ges1.state==UIGestureRecognizerStateChanged) [ges1 setState:UIGestureRecognizerStateEnded];
}
@end
