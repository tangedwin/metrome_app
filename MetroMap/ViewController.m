//
//  ViewController.m
//  MetroMap
//
//  Created by edwin on 2019/6/22.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<UIScrollViewDelegate, UIGestureRecognizerDelegate, UISearchBarDelegate, MBProgressHUDDelegate, UIWebViewDelegate>


@end

@implementation ViewController

- (void)viewDidLoad {
    _viewSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
    if(_viewSize.height>_viewSize.width){
        //竖屏
        _navBarHeight = kNavBarAndStatusBarHeight;
    }else{
        _navBarHeight = kNavBarHeight;
    }
    
    //导航栏
    [self.navigationController.navigationBar setBarTintColor:[UIColor whiteColor]];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationController.navigationBar.clipsToBounds=YES;
    //左右按钮
    _barBtnLeft=[[UIBarButtonItem alloc]initWithTitle:@"城市" style:UIBarButtonItemStylePlain target:self action:@selector(switchCityList)];
    self.navigationItem.leftBarButtonItem=_barBtnLeft;
    _barBtnRight=[[UIBarButtonItem alloc]initWithTitle:@"站点" style:UIBarButtonItemStylePlain target:self action:@selector(switchStationList)];
    self.navigationItem.rightBarButtonItem=_barBtnRight;
    //背景图
    _barBackground = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _viewSize.width, _navBarHeight)];
    [_barBackground setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:_barBackground];
    
    //初始化数据
    [self initData:nil];
    //展示数据
    [self fullMetroMapData];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didChangeRotate:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    
    [super viewDidLoad];
}

//初始化数据
-(void) initData:(NSString*) cityCode{
    
    if(cityCode==nil){
        //获取当前城市
        NSData *cCodeData = [DataUtils getDataFromPlist:USER_PLIST withKey:@"currentCity"];
        NSString *cCode = [[NSString alloc] initWithData:cCodeData encoding:NSUTF8StringEncoding];
        if(cCode!=nil && [@"" compare:cCode]!=NSOrderedSame){
            _prevData = [MetroData initDataWithCityCode:cityCode];
            _data = [MetroData initDataWithCityCode:cCode];
        }else{
            _data = [MetroData initDataWithCityCode:cityCode];
        }
    }else{
        _prevData = _data;
        _data = [MetroData initDataWithCityCode:cityCode];
    }
    
    //设置回调弹框
    __weak typeof(self) wkself = self;
    [_data setAlertSomething:^(NSInteger *type,NSString *content) {[wkself alertSomething:content withType:type];}];
}


-(void)showProgressHUD:(NSString*) text{
    if(_progressHUD!=nil){
    [_progressHUD removeFromSuperview];
    _progressHUD = nil;
    }
    
    _progressHUD = [[MBProgressHUD alloc] initWithView:[UIApplication sharedApplication].keyWindow];
    [[UIApplication sharedApplication].keyWindow addSubview:_progressHUD];
    [[UIApplication sharedApplication].keyWindow bringSubviewToFront:_progressHUD];
    
    _progressHUD.delegate = self;
    
    _progressHUD.label.text=text;
    _progressHUD.userInteractionEnabled= YES;
    _progressHUD.removeFromSuperViewOnHide = YES;
    [_progressHUD showAnimated:YES];
    
}
    
//填充数据
-(void)fullMetroMapData{
    [self showProgressHUD:@"加载数据中..."];
    //开启线程，请求图片资源
//    [NSThread detachNewThreadSelector:@selector(initMetroImage) toTarget:self withObject:nil];
    [self performSelector:@selector(hideProgressView:) withObject:@(1) afterDelay:0.001];
//    [self performSelectorOnMainThread:@selector(hideProgressView:) withObject:@(1) waitUntilDone:NO];
}

//初始化图片
-(void)initMetroImage{
    //回到主线程，生成图片
    [self performSelectorOnMainThread:@selector(hideProgressView:) withObject:@(1) waitUntilDone:NO];
}

//生成scrollView
-(void)fullMetroMap:(UIImage*)mainImage{
    if(_data.cityInfo!=nil && _data.cityInfo.name!=nil) [self.barBtnLeft setTitle:_data.cityInfo.name];
    
    
//    SVGKImage *svgImage = [SVGKImage imageNamed:@"shanghaiMap"];
//    _mainImageSize = svgImage.size;
//    _svgImageView = [[SVGKLayeredImageView alloc] initWithSVGKImage:svgImage];
//    _svgImageView.backgroundColor = [UIColor redColor];
//
//    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, _navBarHeight, _viewSize.width, _viewSize.height-_navBarHeight)];
//    _scrollView.backgroundColor = [UIColor darkGrayColor];
//    _scrollView.delegate = self;
//    _scrollSize = _scrollView.frame.size;
//    //按较大比例缩放图片到最小
//    float scaleH = _scrollSize.height/_mainImageSize.height;
//    float scaleW = _scrollSize.width/_mainImageSize.width;
//    _curScale= scaleH>scaleW ? scaleH : scaleW;
//    CGPoint offsetPoint = CGPointMake(_mainImageSize.width/2 ,_mainImageSize.height/2);
//    //设置最小的缩放大小
//    [_scrollView setMinimumZoomScale: _curScale];
//    //设置最大的缩放大小
//    [_scrollView setMaximumZoomScale: 1.0];
//    //_scrollview可以拖动的范围
//    [_scrollView setContentSize: _mainImageSize];
//    [_scrollView addSubview:_svgImageView];
    
//    SVGKImage *svgImage = [SVGKImage imageNamed:@"shanghaiMap"];
//    UIWebView *web = [[UIWebView alloc] initWithFrame:CGRectMake(0, _navBarHeight, _viewSize.width, _viewSize.height-_navBarHeight)];
//    _scrollSize = web.frame.size;
//    _mainImageSize = svgImage.size;
//    web.scrollView.contentSize = svgImage.size;
////    web.scrollView.contentSize = CGSizeMake(8400, 8400);
//    web.delegate = self;
//    web.scalesPageToFit = YES;
//    web.multipleTouchEnabled = YES;
//    web.userInteractionEnabled = YES;
//    web.scrollView.scrollEnabled = YES;
//    NSString *url = [[NSBundle mainBundle] pathForResource:@"shanghaiMap" ofType:@"svg"];
//    url = [NSString stringWithFormat:@"file://%@",url];
//    [web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
//    [self.view addSubview:web];
//     _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0,0, 0)];
//    [_scrollView setContentSize: CGSizeZero];

//    [web stringByEvaluatingJavaScriptFromString:[NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"svg-click" withExtension:@"js"] encoding:NSUTF8StringEncoding error:nil]];
//    [web sizeToFit];
//    [self.view addSubview:web];
//    CGPoint offsetPoint = CGPointZero;
    
    _mainImageSize = mainImage.size;
    _mainImageView = [[UIImageView alloc] initWithImage:mainImage];
    [_mainImageView setFrame:CGRectMake(0, 0, _mainImageSize.width, _mainImageSize.height)];

    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, _navBarHeight, _viewSize.width, _viewSize.height-_navBarHeight)];
    _scrollView.backgroundColor = [UIColor grayColor];
    _scrollView.delegate = self;
    _scrollSize = _scrollView.frame.size;
//    按较大比例缩放图片到最小
    float scaleH = _scrollSize.height/_mainImageSize.height;
    float scaleW = _scrollSize.width/_mainImageSize.width;
    _curScale= scaleH>scaleW ? scaleH : scaleW;
    
    CGPoint offsetPoint = CGPointMake(_mainImageSize.width/2 ,_mainImageSize.height/2);
//    设置最小的缩放大小
    [_scrollView setMinimumZoomScale: _curScale];
//    设置最大的缩放大小
    [_scrollView setMaximumZoomScale: 1.0];
//    _scrollview可以拖动的范围
    [_scrollView setContentSize: _mainImageSize];
    [_scrollView addSubview:_mainImageView];
    
    CGRect zoomRect = [self zoomRectForScale:_curScale withCenter:offsetPoint];
    [_scrollView zoomToRect:zoomRect animated:YES];
//    控制点击图片放大或缩小
    _zoomOut_In = NO;
        [self.view addSubview:_scrollView];
    
    //图片点击事件
    UITapGestureRecognizer *doubleTap =[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapGesAction:)];
    //双击图片执行tapGesAction
    doubleTap.numberOfTapsRequired = 2;
    _mainImageView.userInteractionEnabled=YES;
    [_mainImageView addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapGesAction:)];
    singleTap.numberOfTapsRequired = 1;
    singleTap.delegate = self;
    [_mainImageView addGestureRecognizer:singleTap];
    [singleTap requireGestureRecognizerToFail:doubleTap];
    //回到主线程，显示图片
    [self hideProgressView:@(2)];
//    [self performSelectorOnMainThread:@selector(hideProgressView:) withObject:@(2) waitUntilDone:NO];
}

//隐藏加载等待框，执行后续操作
-(void)hideProgressView:(NSNumber*)type{
    [_progressHUD removeFromSuperview];
    _progressHUD = nil;
    
    if(type.intValue == 1){
        _mainImage = [_data getMetroImage];
        
        if(_mainImage == nil && _prevData!=nil){
            //如果图片错误，加载上一个地图，即切换不成功
            _data = _prevData;
            _prevData = nil;
            if(_scrollView==nil && _mainImageView==nil){
                //展示数据
                [self fullMetroMapData];
            }
        } else{
            //否则移除
            if(_mainImageView!=nil){
                [_mainImageView removeFromSuperview];
                _mainImageView =nil;
            }
            if(_scrollView!=nil){
                [_scrollView removeFromSuperview];
                _scrollView = nil;
            }
        }
        if(_mainImage == nil) return;
        
        [self showProgressHUD:@"切换城市中..."];
        //开启新线程，生成scrollView
//        [self performSelector:@selector(fullMetroMap:) withObject:_mainImage afterDelay:0.001];
        [self fullMetroMap:_mainImage];
//        [NSThread detachNewThreadSelector:@selector(fullMetroMap:) toTarget:self withObject:_mainImage];
    }else if(type.intValue == 2){
        [self.view addSubview:_scrollView];
    }else if(type.intValue == 3){
        [self showRouteDetail];
    }
}


-(void)viewDidAppear:(BOOL)animated{
    CGSize vSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
        //判断并接收返回的参数
    if(_cityInfo!=nil && [_cityInfo.identityNum compare:_data.cityInfo.identityNum]!=NSOrderedSame){
//        [self showProgressHUD:@"加载数据中..."];
        if(_viewSize.height != vSize.height){
            _viewSize = vSize;
        }
        [self hideAllMenu:YES];
        [self hideStationSign];
        //不是当前城市
        [self initData:_cityInfo.nameCode];
//        [self hideProgressView:@(0)];
        [self fullMetroMapData];
        
        //记录当前城市
        [DataUtils writeDataToPlist:USER_PLIST withKey:@"currentCity" withData:[_cityInfo.nameCode dataUsingEncoding:NSUTF8StringEncoding]];
    }else{
        //当前城市则不处理
        if(_viewSize.height != vSize.height){
            [self reloadView:vSize];
        }
    }
}
    
    
//切换展示城市列表
-(void)switchCityList{
    //隐藏其它菜单
    [self hideAllMenu:NO];
    CityListViewController *cViewController = [[CityListViewController alloc] init];
    [cViewController setData:_data];
    cViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:cViewController animated:YES];
}

//切换展示车站列表
-(void)switchStationList{
    if(![_data checkMetro]) return;
    if(!_stationMenuShowing){
        //展示列表
        if(![_data checkMetro]) return;
        _stationMenuShowing = YES;
        CGRect menuFrame = CGRectMake(_viewSize.width/3*2, -_viewSize.height+_navBarHeight*2, _viewSize.width/3, _viewSize.height-_navBarHeight*2);
        _stationMenu = [[FMenuAlert alloc] initWithFrame:menuFrame withType:2 withMaxHeight:menuFrame.size.height];
        
        [_stationMenu setArrMDataSource:_data.metroInfo.lines];
        __weak typeof (self) wkSelf = self;
        [_stationMenu setDidSelectedCallback:^(NSInteger index, NSObject *content) {
            [wkSelf showStationLocation:content];
        }];
        [self.view addSubview:_stationMenu];
        [self.view bringSubviewToFront:_barBackground];
        [UIView animateWithDuration:.5 animations: ^{
            wkSelf.stationMenu.transform = CGAffineTransformMakeTranslation(0, wkSelf.viewSize.height-wkSelf.navBarHeight);
        } completion:nil];
    }else{
        _stationMenuShowing = NO;
        if(_stationMenu!=nil){
            [self.view bringSubviewToFront:_barBackground];
            __weak typeof (self) wkSelf = self;
            [UIView animateWithDuration:.5 animations: ^{
                wkSelf.stationMenu.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished){
                [wkSelf.stationMenu removeFromSuperview];
                wkSelf.stationMenu = nil;
            }];
        }
    }
}

//切换站点菜单
-(void)switchStationInfoView:(CGPoint) point scrollOffset:(CGPoint) scrollOffset{
    if(_stationInfoView!=nil){
        [_stationInfoView removeFromSuperview];
        _stationInfoView = nil;
        _stationInfoShowing = NO;
    }
    __weak typeof(self) wkSelf = self;
    [_data setShowStationInfo:^(NSString *stationName, NSString *stationLogo, NSMutableArray *lineNames, NSMutableArray *lineColors) {
        if(wkSelf.stationInfoView!=nil){
            [wkSelf.stationInfoView removeFromSuperview];
            wkSelf.stationInfoView = nil;
        }
        wkSelf.stationInfoShowing = YES;
        [wkSelf showStationInfoView:point stationName:stationName stationLogo:stationLogo lineNames:lineNames lineColors:lineColors];
    }];
    [_data setHideStationSign:^(NSInteger *index) {
        [wkSelf hideStationSign];
    }];
    [_data tapStation:point scrollOffset:scrollOffset scale:_curScale barHeight:_navBarHeight];
}

//隐藏所有弹出菜单
-(void)hideAllMenu:(BOOL)withStationInfo{
    if(_stationMenuShowing) [self switchStationList];
    if(_stationInfoShowing && withStationInfo){
        [_stationInfoView removeFromSuperview];
        _stationInfoView = nil;
        _stationInfoShowing = NO;
    }
}

-(void)hideStationSign{
    if(_routeInfoView!=nil){
        __weak typeof (self) wkSelf = self;
        [UIView animateWithDuration:.5 animations: ^{
            wkSelf.routeInfoView.transform = CGAffineTransformMakeTranslation(0, wkSelf.viewSize.height);
        } completion:^(BOOL finished){
            wkSelf.routeDetailStatus = 0;
            [wkSelf.routeInfoView removeFromSuperview];
            wkSelf.routeInfoView = nil;
        }];
    }
    if(_startStationSign!=nil){
        [_startStationSign removeFromSuperview];
        _startStationSign = nil;
    }
    if(_endStationSign!=nil){
        [_endStationSign removeFromSuperview];
        _endStationSign = nil;
    }
    if(_stationSignArray!=nil && _stationSignArray>0){
        for(UIView *uview in _stationSignArray){
            [uview removeFromSuperview];
        }
        _stationSignArray = nil;
    }
    [_data clearStationSign];
}

-(void)bringAllMenuFront{
    if(_routeInfoView!=nil) [self.view bringSubviewToFront:_routeInfoView];
    if(_stationMenu!=nil) [self.view bringSubviewToFront:_stationMenu];
    if(_barBackground) [self.view bringSubviewToFront:_barBackground];
}

//点击站点列表时展示站点菜单
-(void)showStationLocation:(NSObject*)content{
    CGPoint stationLocation = [self.data getStationLocationWithIndex:0 orStation:content];
    if(_stationInfoView!=nil){
        [_stationInfoView removeFromSuperview];
        _stationInfoView = nil;
        _stationInfoShowing = NO;
    }
    
    __weak typeof(self)wkSelf = self;
    [UIView animateWithDuration:.5 animations: ^{
        [wkSelf centerMapToPoint:stationLocation];
    } completion:^(BOOL finished) {
        CGPoint offset = self.scrollView.contentOffset;
        [self switchStationInfoView:stationLocation scrollOffset:offset];
        [self switchStationList];
    }];
}

//以指定点为中心移动图片
-(CGPoint)centerMapToPoint:(CGPoint) point{
    CGFloat x = point.x*_curScale-_scrollSize.width/2;
    CGFloat y = point.y*_curScale-_scrollSize.height/2;
    x = x<0?0:x;
    y = y<0?0:y;
    CGFloat maxX = _scrollView.contentSize.width-_scrollSize.width;
    CGFloat maxY = _scrollView.contentSize.height-_scrollSize.height;
    x = x>maxX?maxX:x;
    y = y>maxY?maxY:y;
    CGPoint pointOffset = CGPointMake(x, y);
    
    [self.scrollView setContentOffset:pointOffset];
//    __weak typeof(self)wkSelf = self;
//    [UIView animateWithDuration:.5 animations: ^{
//        [wkSelf.scrollView setContentOffset:pointOffset];
//    } completion:nil];
    return pointOffset;
}

//展示站点菜单
-(void)showStationInfoView:(CGPoint)point stationName:(NSString*)stationName stationLogo:(NSString*)stationLogo lineNames:(NSMutableArray*)lineNames lineColors:(NSMutableArray*)lineColors{
    CGFloat viewWidth = 200;
    CGFloat viewHeight = 60;
    CGFloat height = 0;
    CGFloat width = 10;
    CustomerView *sinfoView = [[CustomerView alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight) withType:1];
    sinfoView.backgroundColor = [UIColor darkGrayColor];
    sinfoView.layer.cornerRadius = 8;
    
    //站点logo
    if(stationLogo!=nil){
        UIImage *stationLogoImage = [UIImage imageNamed:stationLogo];
        UIImageView *stationLogo = [[UIImageView alloc] initWithImage:stationLogoImage];
        [stationLogo setFrame:CGRectMake(width, height, 28, 28)];
        [sinfoView addSubview:stationLogo];
        width += 30;
    }
    
    //站名
    UILabel *lineNameLabel = [self createLabel:stationName color:nil fontSize:14 bcolor:nil frame:CGRectMake(width, height, 20, 28)];
    [sinfoView addSubview:lineNameLabel];
    lineNameLabel.numberOfLines = 0;//根据最大行数需求来设置
    lineNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    CGSize maximumLabelSize = CGSizeMake(100, 9999);//labelsize的最大值
    CGSize expectSize = [lineNameLabel sizeThatFits:maximumLabelSize];
    expectSize.width = expectSize.width>150?150:expectSize.width;
    //别忘了把frame给回label，如果用xib加了约束的话可以只改一个约束的值
    lineNameLabel.frame = CGRectMake(width, 0, expectSize.width, 28);
    [sinfoView addSubview:lineNameLabel];
    width += expectSize.width;
    
    //线路名
    if(lineNames!=nil && lineNames.count>0){
        CGFloat lnameWith = 2;
        UIScrollView *lineNamesView = [[UIScrollView alloc] initWithFrame:CGRectMake(width+2, height, viewWidth-width-8, 28)];
        for(int i=0; i<lineNames.count; i++){
            NSString *lineName = lineNames[i];
            UIColor *bcolor = nil;
            if(lineColors.count>i && lineColors[i]!=nil) bcolor = [ColorUtils colorWithHexString:lineColors[i]];
            UILabel *lineNameView = [self createLabel:lineName color:nil fontSize:12 bcolor:bcolor frame:CGRectMake(lnameWith, 8, 20, 30)];
            lineNameView.layer.cornerRadius = 8;
            lineNameView.numberOfLines = 0;//根据最大行数需求来设置
            lineNameView.lineBreakMode = NSLineBreakByTruncatingTail;
            CGSize maximumLabelSize = CGSizeMake(100, 9999);//labelsize的最大值
            CGSize expectSize = [lineNameView sizeThatFits:maximumLabelSize];
            //别忘了把frame给回label，如果用xib加了约束的话可以只改一个约束的值
            lineNameView.frame = CGRectMake(lnameWith, 8, expectSize.width, expectSize.height);
            [lineNamesView addSubview:lineNameView];
            lnameWith += expectSize.width+2;
        }
        [lineNamesView setContentSize:CGSizeMake(lnameWith, height)];
        [lineNamesView setShowsVerticalScrollIndicator:NO];
        [lineNamesView setShowsHorizontalScrollIndicator:NO];
        [sinfoView addSubview:lineNamesView];
    }
    
    
    width = 0;
    height += 32;
    UILabel *startLabel = [self createLabel:@"设为起点" color:nil fontSize:12 bcolor:nil frame:CGRectMake(width+15, height, 50, 28)];
    [sinfoView addSubview:startLabel];
    
    width += 75;
    UILabel *endLabel = [self createLabel:@"设为终点" color:nil fontSize:12 bcolor:nil frame:CGRectMake(width, height, 50, 28)];
    [sinfoView addSubview:endLabel];
    
    width += 60;
    UILabel *detailLabel = [self createLabel:@"站点详情" color:nil fontSize:12 bcolor:nil frame:CGRectMake(width, height, 50, 28)];
    [sinfoView addSubview:detailLabel];
    
    UITapGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapStationInfoButton:)];
    [sinfoView addGestureRecognizer:viewTap];
    
    //移动地图到中央
//    [self centerMapToPoint:_data.stationLocation];
    int type = [self calculateStationInfoTransform:YES withScale:_curScale];
    if(type==2){
        [self createStationInfoView:sinfoView size:CGSizeMake(viewWidth+10, viewHeight) point:CGPointMake(10, 0) withType:2];
    }else if(type==3){
        [self createStationInfoView:sinfoView size:CGSizeMake(viewWidth+10, viewHeight) point:CGPointMake(0, 0) withType:3];
    }else if(type==4){
        [self createStationInfoView:sinfoView size:CGSizeMake(viewWidth, viewHeight+10) point:CGPointMake(0, 10) withType:4];
    }else if(type==5){
        [self createStationInfoView:sinfoView size:CGSizeMake(viewWidth, viewHeight+10) point:CGPointMake(0, 0) withType:5];
    }
    
    [self.view addSubview:_stationInfoView];
    
    [self bringAllMenuFront];
    [_stationInfoView setTransform:CGAffineTransformMakeTranslation(_stationInfoOffset.x,_stationInfoOffset.y)];
}

-(int)calculateStationInfoTransform:(BOOL)needType withScale:(float)curScale{
    int type = 5;
    CGFloat viewWidth = 200;
    CGFloat viewHeight = 60;
    CGPoint scrollOffset = _scrollView.contentOffset;
    CGFloat xx = _data.stationLocation.x*curScale - scrollOffset.x;
    CGFloat yy = _data.stationLocation.y*curScale - scrollOffset.y + _navBarHeight;
    if(needType){
        if(xx<110){
            //左侧不足显示在右边,xx不变
//            xx += 10;
            yy -= viewHeight/2;
            type=2;
        }else if(xx>_viewSize.width-110){
            //右侧不足显示在左边
            xx -= viewWidth+10;
            yy -= viewHeight/2;
            type=3;
        }else if(yy<_navBarHeight+70){
            //上边显示不足显示在下边，yy不变
            xx -= viewWidth/2;
            type=4;
        }else{
            //否则显示在上边
            xx -= viewWidth/2;
            yy -= viewHeight+10;
            type=5;
        }
    }else{
        CustomerView *cview = (CustomerView*)_stationInfoView;
        if(cview.type==2){
//            xx += 10;
            yy -= viewHeight/2;
        }else if(cview.type==3){
            xx -= viewWidth+10;
            yy -= viewHeight/2;
        }else if(cview.type==4){
            xx -= viewWidth/2;
        }else if(cview.type==5){
            xx -= viewWidth/2;
            yy -= viewHeight+10;
        }
    }
    _stationInfoOffset = CGPointMake(xx, yy);
    return type;
}

-(void)drawStationSign:(int)type locations:(NSMutableArray*)locations{
    //type==0普通点；type==1起点;type==2终点;type==3路径
    if(type==0){
    }if(type==1){
        if(_startStationSign!=nil){
            [_startStationSign removeFromSuperview];
            _startStationSign = nil;
        }
        UIImage *image = [UIImage imageNamed:@"iufadi"];
        _startStationSign = [[UIImageView alloc] initWithImage:image];
        CGFloat width = _data.metroInfo.buttonSize/_curScale;
        CGFloat height = width/image.size.width * image.size.height;
        _data.startStationLocation = _data.stationLocation;
        _startStationSign.frame = CGRectMake(_data.stationLocation.x-width/2, _data.stationLocation.y-height, width, height);
        [self.mainImageView addSubview:_startStationSign];
    }else if(type==2){
        if(_endStationSign!=nil){
            [_endStationSign removeFromSuperview];
            _endStationSign = nil;
        }
        UIImage *image = [UIImage imageNamed:@"mudidi"];
        _endStationSign = [[UIImageView alloc] initWithImage:image];
        CGFloat width = _data.metroInfo.buttonSize/_curScale;
        CGFloat height = width/image.size.width * image.size.height;
        _data.endStationLocation = _data.stationLocation;
        _endStationSign.frame = CGRectMake(_data.stationLocation.x-width/2, _data.stationLocation.y-height, width,height);
        [self.mainImageView addSubview:_endStationSign];
    }else{
        if(locations!=nil && locations.count>0){
            CGPoint loc = CGPointFromString(locations.firstObject);
            [locations removeObjectAtIndex:0];
            CGFloat width = _data.metroInfo.buttonSize/_curScale/2;
            LXPositionView *sign = [[LXPositionView alloc] initWithFrame:CGRectMake(loc.x-width/2, loc.y-width/2, width, width) animationType:AnimationTypeWithBackground];
            sign.multiple = 2;
            
            if(_stationSignArray==nil) _stationSignArray = [NSMutableArray new];
            [_stationSignArray addObject:sign];
            
            [self.mainImageView addSubview:sign];
            [self drawStationSign:3 locations:locations];
        }
    }
}

-(void)showRouteDetail{
    if(_routeInfoView!=nil){
        [_routeInfoView removeFromSuperview];
        _routeInfoView = nil;
        _routeDetailStatus = 0;
    }
    if(_stationSignArray!=nil && _stationSignArray>0){
        for(UIView *uview in _stationSignArray){
            [uview removeFromSuperview];
        }
        _stationSignArray = nil;
    }
    _routeDetailStatus = 1;
    //展示路线
    CGRect detailViewFrame = CGRectMake(0, 20, _viewSize.width-20, _viewSize.height/2);
    FMenuAlert *routeMenu = [[FMenuAlert alloc] initWithFrame:detailViewFrame withType:4 withMaxHeight:detailViewFrame.size.height];
    [routeMenu setArrMDataSource:_data.routeList];
    
    _routeInfoView = [[UIVisualEffectView alloc] initWithFrame:CGRectMake(10, _viewSize.height-20, routeMenu.frame.size.width, routeMenu.frame.size.height+20)];
    [_routeInfoView setEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
    _routeInfoView.contentView.layer.cornerRadius = 8;
    _routeInfoView.alpha=0.8;
    
    [_routeInfoView.contentView addSubview:routeMenu];
    
    UIView *viewRouteTapZone = [[UIView alloc] initWithFrame:CGRectMake(0, 0, routeMenu.frame.size.width, 20)];
    [viewRouteTapZone setBackgroundColor:[UIColor redColor]];
    [_routeInfoView.contentView setBackgroundColor:[UIColor clearColor]];
    [_routeInfoView.contentView addSubview:viewRouteTapZone];
    
    UILabel *remarkView = [[UILabel alloc] initWithFrame:CGRectMake(_routeInfoView.frame.size.width-80, _routeInfoView.frame.size.height-20, 70, 15)];
    remarkView.font = [UIFont systemFontOfSize:8];
    remarkView.textColor = [UIColor lightGrayColor];
    remarkView.text = @"数据来自百度地图";
    [_routeInfoView.contentView addSubview:remarkView];
    [self.view addSubview:_routeInfoView];
    
    
    UITapGestureRecognizer *viewRouteTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRouteInfoButton:)];
    [viewRouteTapZone addGestureRecognizer:viewRouteTap];
    
    __weak typeof (self) wkSelf =self;
    [UIView animateWithDuration:.5 animations: ^{
        wkSelf.routeInfoView.transform = CGAffineTransformMakeTranslation(0, -routeMenu.frame.size.height-10);
    } completion:nil];
    
    [routeMenu setDidSelectedCallback:^(NSInteger index, NSObject *content) {
        //展示站点
        [wkSelf showRouteSign:index];
    }];
    [routeMenu setDefaultSelect:0 section:0];
    
}

//切换线路时展示中间点
-(void)showRouteSign:(NSInteger)index{
    //隐藏站点菜单
    if(_stationInfoView!=nil){
        [_stationInfoView removeFromSuperview];
        _stationInfoView = nil;
        _stationInfoShowing = NO;
    }
    
    if(self.stationSignArray!=nil && self.stationSignArray>0){
        for(UIView *uview in self.stationSignArray){
            [uview removeFromSuperview];
        }
        self.stationSignArray = nil;
    }
    //展示站点
    NSMutableArray *locations = [self.data getRouteStationLocations:index];
    if(!locations) return;
    
    //计算最左上角和最右下角站点的位置
    CGFloat minX = 0;
    CGFloat minY = 0;
    CGFloat maxX = 0;
    CGFloat maxY = 0;
    if(_data.startStationLocation.x > _data.endStationLocation.x){
        minX = _data.endStationLocation.x;
        maxX = _data.startStationLocation.x;
    }else{
        minX = _data.startStationLocation.x;
        maxX = _data.endStationLocation.x;
    }
    if(_data.startStationLocation.y > _data.endStationLocation.y){
        minY = _data.endStationLocation.y;
        maxY = _data.startStationLocation.y;
    }else{
        minY = _data.startStationLocation.y;
        maxY = _data.endStationLocation.y;
    }
    for(NSString *locStr in locations){
        CGPoint p = CGPointFromString(locStr);
        minX = minX>p.x ? p.x : minX;
        minY = minY>p.y ? p.y : minY;
        maxX = maxX<p.x ? p.x : maxX;
        maxY = maxY<p.y ? p.y : maxY;
    }
    
    float space = _data.metroInfo.buttonSize;
    space = space<=0? 10 : space;
    //展示屏高度:(实际展示高度 + 整张图片的1%高度(避免站点展示在边角上))
    CGFloat rateY = (_scrollSize.height-_routeInfoView.frame.size.height) /(maxY-minY+space);
    CGFloat rateX = _scrollSize.width/(maxX-minX+space);
    CGFloat rate = rateX<rateY?rateX:rateY;
    if(rate>_scrollView.maximumZoomScale) rate = _scrollView.maximumZoomScale;
    if(rate<_scrollView.minimumZoomScale) rate = _scrollView.minimumZoomScale;
    _curScale = rate;
    //面板遮挡站点高度=线路面板高度-(屏幕高度-站点所占高度)/2
    float heightOffset = _routeInfoView.frame.size.height - (_viewSize.height-_navBarHeight-(maxY-minY))/2;
    heightOffset = heightOffset<0 ? 0 : heightOffset;
    CGPoint loc = CGPointMake((maxX+minX)/2, (maxY+minY)/2 + heightOffset);
    
    CGRect zoomRect = [self zoomRectForScale:_curScale withCenter:loc];
    //重新定义其cgrect的x和y值
    [_scrollView zoomToRect:zoomRect animated:YES];
    
    [self drawStationSign:3 locations:locations];
}

#pragma mark --viewCreate
//创建label
-(UILabel*)createLabel:(NSString*)text color:(UIColor*)color fontSize:(float)fontSize bcolor:(UIColor*)bcolor frame:(CGRect)frame{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = bcolor==nil?[UIColor darkGrayColor]:bcolor;
    if(color!=nil){
        label.textColor = color;
    }else if([BaseUtils isLighterColor:label.backgroundColor]){
        label.textColor = [UIColor blackColor];
    }else{
        label.textColor = [UIColor whiteColor];
    }
    
    label.font = [UIFont systemFontOfSize:fontSize];
    label.text = text;
    return label;
}

-(void)createStationInfoView:(UIView*)sinfoView size:(CGSize)sSize point:(CGPoint)point withType:(int)type{
    _stationInfoView = [[CustomerView alloc] initWithFrame:CGRectMake(0, 0, sSize.width, sSize.height) withType:type];
    [_stationInfoView addSubview:sinfoView];
    [_stationInfoView setBackgroundColor:[UIColor clearColor]];
    [sinfoView setTransform:CGAffineTransformMakeTranslation(point.x,point.y)];
}

#pragma mark --viewAction
-(void)tapRouteInfoButton:(UIGestureRecognizer*)gestureRecognizer{
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    if(_stationMenuShowing) [self switchStationList];
    if(point.y>0 && point.y<20 && point.x>0 && point.x<_viewSize.width){
        __weak typeof (self) wkSelf = self;
        [UIView animateWithDuration:.5 animations: ^{
            if(wkSelf.routeDetailStatus==1) wkSelf.routeInfoView.transform = CGAffineTransformIdentity;
            else if(wkSelf.routeDetailStatus==2) wkSelf.routeInfoView.transform = CGAffineTransformMakeTranslation(0, -wkSelf.routeInfoView.frame.size.height+30);
        } completion:^(BOOL finished){
            if(wkSelf.routeDetailStatus==2) wkSelf.routeDetailStatus=1;
            else if(wkSelf.routeDetailStatus==1) wkSelf.routeDetailStatus=2;
        }];
    }
}

-(void)tapStationInfoButton:(UIGestureRecognizer*)gestureRecognizer{
    if(_stationMenuShowing) [self switchStationList];
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    if(!_data.showRouteDetail){
        __weak typeof(self) wkSelf = self;
        [_data setShowRouteDetail:^(NSInteger index) {
//            [wkSelf showRouteDetail];
            if(index==-1){
                [wkSelf performSelectorOnMainThread:@selector(hideProgressView:) withObject:@(-1) waitUntilDone:NO];
            }else{
                //回到主线程，显示路线
                [wkSelf performSelectorOnMainThread:@selector(hideProgressView:) withObject:@(3) waitUntilDone:NO];
            }
        }];
    }
    if(point.y>30 && point.y<60 && point.x>15 && point.x<65){
        //设置起点
        _data.startStationInfo = _data.stationInfo;
        [self drawStationSign:1 locations:nil];
        [self hideAllMenu:YES];
        if(_data.endStationInfo!=nil) {
            [self showProgressHUD:@"查询路线中..."];
            [NSThread detachNewThreadSelector:@selector(queryRouteInfoFromMetroData) toTarget:self withObject:nil];
        }
    }else if(point.y>30 && point.y<60 && point.x>75 && point.x<125){
        //设置终点
        _data.endStationInfo = _data.stationInfo;
        [self drawStationSign:2 locations:nil];
        [self hideAllMenu:YES];
        if(_data.startStationInfo!=nil) {
            [self showProgressHUD:@"查询路线中..."];
            [NSThread detachNewThreadSelector:@selector(queryRouteInfoFromMetroData) toTarget:self withObject:nil];
        }
    }else if(point.y>30 && point.y<60 && point.x>135 && point.x<185){
        //详情
        StationDetailViewController *sViewController = [[StationDetailViewController alloc] init];
        [sViewController setData:_data];
        [sViewController setSinfo:_data.stationInfo];
        sViewController.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:sViewController animated:YES];
    }
    
}

-(void)queryRouteInfoFromMetroData{
    [_data queryRouteData];
}

//单击显示站点名称信息
-(void)singleTapGesAction:(UIGestureRecognizer*)gestureRecognizer{
    if(_routeDetailStatus==1){
        __weak typeof (self) wkSelf = self;
        [UIView animateWithDuration:.5 animations: ^{
            wkSelf.routeInfoView.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished){
            wkSelf.routeDetailStatus=2;
        }];
        return;
    }
    
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGPoint offset = self.scrollView.contentOffset;
    [self switchStationInfoView:point scrollOffset:offset];
}

//双击缩放
-(void)doubleTapGesAction:(UIGestureRecognizer*)gestureRecognizer{
    float newscale=0.0;
    if(_scrollView.maximumZoomScale-_scrollView.zoomScale>_scrollView.zoomScale-_scrollView.minimumZoomScale){
        _zoomOut_In = NO;
    }else{
        _zoomOut_In = YES;
    }
    
    if (_zoomOut_In) {
        newscale = _scrollView.minimumZoomScale;
        _zoomOut_In = NO;
    }else{
        newscale = _scrollView.maximumZoomScale;
        _zoomOut_In = YES;
    }
    CGRect zoomRect = [self zoomRectForScale:newscale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
    //重新定义其cgrect的x和y值
    [_scrollView zoomToRect:zoomRect animated:YES];
}

#pragma mark --popup window
-(void)alertSomething:(NSString*)content withType:(NSInteger*)type{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:content preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
        return;
    }];
    [alert addAction:okAction];
    [self presentViewController:alert animated:true completion:nil];
}

#pragma mark --scroll
- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
}

//当UIScrollView尝试进行缩放的时候调用
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return _mainImageView;
//    return _svgImageView;
}

//当缩放完毕的时候调用
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    _curScale = scale;
    [self zoomSign:scale];
    [self scrollSign:scale];
}

//当正在缩放的时候调用
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
//    NSLog(@"scroll scale is ------>%.5f",scrollView.zoomScale);
    [self zoomSign:scrollView.zoomScale];
    [self scrollSign:scrollView.zoomScale];
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [self scrollSign:scrollView.zoomScale];
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView{
    [self scrollSign:scrollView.zoomScale];
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    CGRect zoomRect;
    zoomRect.size.height = [_scrollView frame].size.height / scale;
    zoomRect.size.width  = [_scrollView frame].size.width  / scale;
    zoomRect.origin.x    = center.x - (zoomRect.size.width  / 2.0);
    zoomRect.origin.y    = center.y - (zoomRect.size.height / 2.0);
    return zoomRect;
}

-(void)zoomSign:(CGFloat) curScale{
    if(_startStationSign!=nil){
        [_startStationSign removeFromSuperview];
        UIImage *image = [UIImage imageNamed:@"iufadi"];
        _startStationSign = [[UIImageView alloc] initWithImage:image];
        CGFloat width = _data.metroInfo.buttonSize/curScale;
        CGFloat height = width/image.size.width * image.size.height;
        _startStationSign.frame = CGRectMake(_data.startStationLocation.x-width/2, _data.startStationLocation.y-height, width, height);
        [self.mainImageView addSubview:_startStationSign];
    }
    if(_endStationSign!=nil){
        [_endStationSign removeFromSuperview];
        UIImage *image = [UIImage imageNamed:@"mudidi"];
        _endStationSign = [[UIImageView alloc] initWithImage:image];
        CGFloat width = _data.metroInfo.buttonSize/curScale;
        CGFloat height = width/image.size.width * image.size.height;
        _endStationSign.frame = CGRectMake(_data.endStationLocation.x-width/2, _data.endStationLocation.y-height, width, height);
        [self.mainImageView addSubview:_endStationSign];
    }
    if(_stationSignArray!=nil){
        if(_stationSignArray!=nil && _stationSignArray>0){
            for(UIView *uview in _stationSignArray){
                [uview removeFromSuperview];
            }
            _stationSignArray = nil;
        }
        NSMutableArray *locations = [_data getRouteStationLocations:_data.curRouteIndex];
        if(locations) [self drawStationSign:3 locations:locations];
    }
    [self bringAllMenuFront];
}

-(void)scrollSign:(CGFloat) curScale{
    [self calculateStationInfoTransform:NO withScale:curScale];
    [_stationInfoView setTransform:CGAffineTransformIdentity];
    [_stationInfoView setTransform:CGAffineTransformMakeTranslation(_stationInfoOffset.x,_stationInfoOffset.y)];
    [self bringAllMenuFront];
}

#pragma mark MBProgressHUDDelegate methods
- (void)hudWasHidden:(MBProgressHUD *)hud {
    // Remove HUD from screen when the HUD was hidded
    [self.progressHUD removeFromSuperview];
    self.progressHUD = nil;
}
    
- (void)didChangeRotate:(NSNotification*)notice {
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait
        || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown) {
        //竖屏
    } else {
        //横屏
    }
}

#pragma - mark WebViewDelegate  必须都实现,否则会有警告
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    [webView stringByEvaluatingJavaScriptFromString:@"setGroupClickFunction()"];
    //禁止用户选择
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitUserSelect='none';"];
    
    //禁止长按弹出选择框
    [webView stringByEvaluatingJavaScriptFromString:@"document.documentElement.style.webkitTouchCallout='none';"];
}
    
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    // 延时一下 获得的高度才正确，要不然是转屏前的宽高
    __weak typeof(self) wkSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [wkSelf reloadView:size];
    });
}
    
-(void)reloadView:(CGSize)size{
    self.viewSize = size;
    if(size.height>size.width){
        //竖屏
        self.navBarHeight = kNavBarAndStatusBarHeight;
    }else{
        self.navBarHeight = kNavBarHeight;
    }
    
    [self.mainImageView removeFromSuperview];
    [self.scrollView removeFromSuperview];
    //展示数据
    [self fullMetroMap:self.mainImage];
    if(self.routeInfoView!=nil){
        [self.routeInfoView removeFromSuperview];
        [self showRouteDetail];
    }
    [self hideAllMenu:YES];
}
@end
