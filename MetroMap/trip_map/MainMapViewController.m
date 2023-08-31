//
//  MainMapViewController.m
//  MetroMap
//
//  Created by edwin on 2019/10/9.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "MainMapViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareSheetConfiguration.h>

@interface MainMapViewController ()<UITextFieldDelegate>

@property(nonatomic, retain) MainMapView *mainMapView;
@property(nonatomic, retain) UIView *routeSearchBar;
@property(nonatomic, retain) RouteInfoView *routeInfoView;
@property(nonatomic, retain) UIImageView *locationButton;
@property(nonatomic, retain) UITextField *startField;
@property(nonatomic, retain) UITextField *endField;
@property(nonatomic, assign) BOOL tabbarHideWhenRouteShowing;
@property(nonatomic, retain) MetroMapHelper *metroMapHelper;

@property(nonatomic, assign) BOOL showingDefaultStation;

@property(nonatomic, retain) NSMutableArray *layers;


@end

@implementation MainMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:dynamic_color_white];
    [self.view addSubview:self.naviMask];
    [self.naviMask addSubview:self.cityPickerButton];
    [self.naviMask addSubview:self.searchBar];
    
    _mainMapView = [[MainMapView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT)];
    [self.view addSubview:_mainMapView];
//    [_mainMapView loadMapView];
    
    __weak typeof(self) wkSelf = self;
    [_mainMapView setShowRouteInfoView:^(RouteHelpManager *routeHelper) {
//        if(SAFE_AREA_INSERTS_BOTTOM>0) wkSelf.routeInfoView = [[RouteInfoView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-fitFloat(226+26), SCREEN_WIDTH, SCREEN_HEIGHT)];
//        else wkSelf.routeInfoView = [[RouteInfoView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-fitFloat(226+26)-14, SCREEN_WIDTH, SCREEN_HEIGHT)];
        
        wkSelf.routeInfoView = [[RouteInfoView alloc] initWithFrame:CGRectMake(0, SCREEN_HEIGHT-fitFloat(36+52*2+72+6+12)-SAFE_AREA_INSERTS_BOTTOM, SCREEN_WIDTH, SCREEN_HEIGHT)];
        wkSelf.routeInfoView.routeHelper = routeHelper;
        [wkSelf.view addSubview:wkSelf.routeInfoView];
        [wkSelf.routeInfoView loadData];
        [wkSelf setRouteInfoViewCallback];
        if(![wkSelf.tabBarController.tabBar isHidden]) [wkSelf switchTabBarByMapViewDuration:0];
        else wkSelf.tabbarHideWhenRouteShowing = YES;
    }];
    [_mainMapView setSwitchTabbar:^{
        [wkSelf switchTabBarByMapViewDuration:.5f];
    }];
    [_mainMapView setSwitchRouteStation:^(StationModel *start, StationModel *end) {
        NSString *selectedCityId = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_CITY_ID_KEY];
        NSString *curCityId = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_CITY_ID_KEY];
        if(wkSelf.startField){
            if(start) wkSelf.startField.text = start.nameCn;
            else if(selectedCityId && curCityId && [selectedCityId integerValue]==[curCityId integerValue]) wkSelf.startField.text = @"我的位置";
            else wkSelf.startField.text = @"";
        }
        if(wkSelf.endField){
            if(end) wkSelf.endField.text = end.nameCn;
            else wkSelf.endField.text = @"";
        }
    }];
    [_mainMapView setRequestForRoute:^(StationModel *station, BOOL isStart) {
        if(!isStart && [@"我的位置" isEqualToString: wkSelf.startField.text]){
            [wkSelf.mainMapView setDefaultStation:station forStart:isStart forEnd:!isStart scroll:NO];
            [wkSelf.mainMapView setNearbyStationForStart:YES end:NO scroll:NO];
        }else if(isStart && [@"我的位置" isEqualToString: wkSelf.endField.text]){
            [wkSelf.mainMapView setDefaultStation:station forStart:isStart forEnd:!isStart scroll:NO];
            [wkSelf.mainMapView setNearbyStationForStart:NO end:YES scroll:NO];
        }else{
            [wkSelf.mainMapView setDefaultStation:station forStart:isStart forEnd:!isStart scroll:YES];
        }
    }];
    
    [_mainMapView setShowStationInfo:^(CityModel *city, LineModel *line, StationModel *station) {
        [wkSelf showStationWithDetailInfo:station city:city line:line];
    }];
    
    [_mainMapView setSwitchCityData:^{
        [wkSelf switchCityData];
    }];
    
    [self createLocationButton];
    [self createRouteSearchBar];
}

-(void)setDefaultStation:(StationModel *)defaultStation forStart:(BOOL)start forEnd:(BOOL)end{
//    _showingDefaultStation = YES;
    [super setDefaultStation:defaultStation];
    

    if(end && [@"我的位置" isEqualToString: _startField.text]){
        if(self.defaultStation && _mainMapView) [_mainMapView setDefaultStation:self.defaultStation forStart:start forEnd:end scroll:NO];
        if(self.defaultStation && _mainMapView) [_mainMapView setNearbyStationForStart:YES end:NO scroll:NO];
    }else if(start && [@"我的位置" isEqualToString: _endField.text]){
        if(self.defaultStation && _mainMapView) [_mainMapView setDefaultStation:self.defaultStation forStart:start forEnd:end scroll:NO];
        if(self.defaultStation && _mainMapView) [_mainMapView setNearbyStationForStart:NO end:YES scroll:NO];
    }else{
        if(self.defaultStation && _mainMapView) [_mainMapView setDefaultStation:self.defaultStation forStart:start forEnd:end scroll:YES];
    }
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if(self.mapTabbarHide!=[self.tabBarController.tabBar isHidden]){
        [self switchMapTabBar:self.mapTabbarHide duration:.5f];
    }
    
    [self checkVersion];
    
    NSInteger cityId = [[[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_CITY_ID_KEY] integerValue];
    if(!cityId){
        _metroMapHelper = [MetroMapHelper new];
        CityModel *city = [CityModel new];
        //默认北京
        city.identifyCode = 1;

        __weak typeof(self) wkSelf = self;
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setObject:@(1) forKey:@"cityId"];
        [[HttpHelper new] findDetail:request_version params:params progress:^(NSProgress *progress) {
        } success:^(NSMutableDictionary *responseDic) {
            if(responseDic[@"latestVersion"]) city.version = [responseDic[@"latestVersion"] integerValue];
            if(responseDic[@"nameCn"]) city.nameCn = responseDic[@"nameCn"];
            if(responseDic[@"nameEn"]) city.nameEn = responseDic[@"nameEn"];
            if(responseDic[@"namePy"]) city.namePy = responseDic[@"namePy"];
            if(responseDic[@"iconUri"]) city.iconUri = responseDic[@"iconUri"];
            [wkSelf.metroMapHelper loadMetroMap:city success:^{
                [wkSelf.mainMapView loadMapView];
                [[NSUserDefaults standardUserDefaults] setObject:@(city.identifyCode) forKey:SELECTED_CITY_ID_KEY];
                [[NSUserDefaults standardUserDefaults] setObject:@"北京" forKey:SELECTED_CITY_NAME_KEY];
                [wkSelf loadCityPickerButton];
                self.cityId = city.identifyCode;
            }];
        } failure:^(NSString *errorInfo) {
            [MBProgressHUD showInfo:@"未选择城市" detail:nil image:nil inView:nil];
        }];
    }else if(self.cityId != cityId || !_mainMapView.scriptAdded){
        self.startField.text = @"";
        self.endField.text = @"";
        [_mainMapView loadMapView];
        self.cityId = cityId;
    }

    if(self.startField && (self.startField.text.length<=0 || [@"我的位置" isEqualToString:self.startField.text])){
        NSString *curCityId = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_CITY_ID_KEY];
        if(cityId == [curCityId integerValue]) self.startField.text = @"我的位置";
        else self.startField.text = @"";
    }
}

-(void)checkVersion{
    [[HttpHelper new] findDetail:request_version params:nil progress:^(NSProgress *progress) {
    } success:^(NSMutableDictionary *responseDic) {
        if(responseDic[@"deprecatedVersion"]){
            NSArray *myVersion = [MY_VERSION componentsSeparatedByString:@"."];
            NSArray *array = [responseDic[@"deprecatedVersion"] componentsSeparatedByString:@"."];
            if(myVersion.count != array.count){
                [[AlertUtils new] alertWithConfirm:@"版本更新" content:@"您当前的应用版本已过时，部分功能将受到影响，请及时到App Store中更新应用"];
            }else for(int i=0; i<myVersion.count; i++){
                if([myVersion[i] intValue]<[array[i] intValue]){
                    [[AlertUtils new] alertWithConfirm:@"版本更新" content:@"您当前的应用版本已过时，部分功能将受到影响，请及时到App Store中更新应用" withBlock:^{
                        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_STORE_OPEN_IOS11] options:@{} completionHandler:^(BOOL success) {
                        }];
                        #else
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_OPEN_EVALUATE] options:@{} completionHandler:^(BOOL success) {
                        }];
                        #endif
                    }];
                }else if([myVersion[i] intValue]>[array[i] intValue]){
                    break;
                }
            }
        }
    } failure:^(NSString *errorInfo) {
    }];
}


-(void)setRouteInfoViewCallback{
    if(!_routeInfoView) return;
    __weak typeof(self) wkSelf = self;
    [_routeInfoView setCloseRouteSearch:^{
        [wkSelf.mainMapView closeRouteShow];
        //展示路线窗口时如果tabbar没有隐藏，则关闭窗口时展示tabbar
        if(!wkSelf.tabbarHideWhenRouteShowing) [wkSelf switchTabBarByMapViewDuration:.5f];
        wkSelf.tabbarHideWhenRouteShowing = NO;
        wkSelf.routeInfoView = nil;
    }];
    
    [_routeInfoView setShareRouteImage:^(UIImage *image, RouteModel *routeInfo) {
        ShowImageViewController *vc = [[ShowImageViewController alloc] init];
        vc.image = image;
        vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        vc.modalPresentationStyle = UIModalPresentationCustom;
        __weak typeof(vc) wkVC = vc;
        [vc setShareText:^{
            [wkSelf shareRoute:routeInfo image:image forImage:NO success:^{
                [wkVC dismissViewControllerAnimated:YES completion:nil];
            }];
        }];
        [vc setShareImage:^{
            [wkSelf shareRoute:routeInfo image:image forImage:YES success:^{
                [wkVC dismissViewControllerAnimated:YES completion:nil];
            }];
        }];
        [wkSelf presentViewController:vc animated:YES completion:nil];
    }];
    [_routeInfoView setFeedbackRouteInfo:^(RouteModel *routeInfo) {
        [wkSelf feedbackRouteInfo:routeInfo];
    }];
    
    [_routeInfoView setSwitchSelected:^(NSInteger index) {
        if(wkSelf.mainMapView) [wkSelf.mainMapView showRouteLine:index];
    }];
}

-(void)feedbackRouteInfo:(RouteModel*)routeModel{
    FeedbackModel *feedback = [FeedbackModel new];
    feedback.type = 2;
    feedback.objectType = 2;
    feedback.titles = [[NSMutableArray alloc] initWithObjects:@"方案规划异常",@"方案数据错误", nil];
    feedback.dataDetailStr = [routeModel parseRouteModelToJSONStr];

    FeedbackViewController *feedbackVC = [[FeedbackViewController alloc] initWithFeedback:feedback];
    feedbackVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:feedbackVC animated:YES];
}


-(void)showStationWithDetailInfo:(StationModel*)station city:(CityModel*)city line:(LineModel*)line{
    StationInfoViewController *stationVC = [[StationInfoViewController alloc] initWithCity:city lines:nil selectedLine:line station:station];
    stationVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:stationVC animated:YES];
}

-(void)switchTabBarByMapViewDuration:(float)duration{
    __weak typeof(self) wkSelf = self;
    if([self.tabBarController.tabBar isHidden]){
        [self switchMapTabBar:NO duration:duration];
        self.routeSearchBar.hidden = NO;
        self.locationButton.hidden = NO;
        if(duration>0){
            [UIView animateWithDuration:duration animations:^{
//                wkSelf.routeSearchBar.transform = CGAffineTransformIdentity;
//                wkSelf.locationButton.transform = CGAffineTransformIdentity;
                wkSelf.routeSearchBar.alpha = 1;
                wkSelf.locationButton.alpha = 1;
            } completion:^(BOOL finished) {
                wkSelf.routeSearchBar.alpha = 1;
                wkSelf.locationButton.alpha = 1;
            }];
        }else{
//            self.routeSearchBar.transform = CGAffineTransformIdentity;
//            self.locationButton.transform = CGAffineTransformIdentity;
        }
    }else{
        [self switchMapTabBar:YES duration:duration];
        if(duration>0){
            [UIView animateWithDuration:duration animations:^{
//                wkSelf.routeSearchBar.transform = CGAffineTransformMakeTranslation(0, [wkSelf mTabbarHeight]+12+156);
//                wkSelf.locationButton.transform = CGAffineTransformMakeTranslation(0, [wkSelf mTabbarHeight]+12+156+fitIconFloat(24));
                wkSelf.routeSearchBar.alpha = 0;
                wkSelf.locationButton.alpha = 0;
            } completion:^(BOOL finished) {
                wkSelf.routeSearchBar.hidden = YES;
                wkSelf.locationButton.hidden = YES;
            }];
        }else{
//            self.routeSearchBar.transform = CGAffineTransformMakeTranslation(0, [self mTabbarHeight]+12+156);
//            self.locationButton.transform = CGAffineTransformMakeTranslation(0, [self mTabbarHeight]+12+156+fitIconFloat(24));
            self.routeSearchBar.hidden = YES;
            self.locationButton.hidden = YES;
        }
    }
}

-(void)createLocationButton{
    _locationButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"location_white"]];
    _locationButton.frame = CGRectMake(view_margin, SCREEN_HEIGHT-[self mTabbarHeight]-12-156-12-fitIconFloat(24), fitIconFloat(24), fitIconFloat(24));
    [self.view addSubview:_locationButton];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(location:)];
    [_locationButton addGestureRecognizer:tap];
    _locationButton.userInteractionEnabled = YES;
}

-(void)createRouteSearchBar{
    _routeSearchBar = [[UIView alloc] initWithFrame:CGRectMake(view_margin, SCREEN_HEIGHT-[self mTabbarHeight]-12-156, SCREEN_WIDTH-view_margin*2, 156)];
    _routeSearchBar.backgroundColor = dynamic_color_lightwhite;
    _routeSearchBar.layer.cornerRadius = 12;
    _routeSearchBar.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:1].CGColor;
    _routeSearchBar.layer.shadowOffset = CGSizeMake(0,0);
    _routeSearchBar.layer.shadowOpacity = 0.1;
    _routeSearchBar.layer.shadowRadius = 6;
    CAShapeLayer *lineLayer1 = [CAShapeLayer layer];
    lineLayer1.strokeColor = dynamic_color_lightgray.CGColor;
    lineLayer1.fillColor = [UIColor clearColor].CGColor;
    lineLayer1.opacity = 0.5;
    lineLayer1.lineWidth = 1;
    UIBezierPath *linePath1 = [UIBezierPath bezierPath];
    [linePath1 moveToPoint:CGPointMake(view_margin, 52)];
    [linePath1 addLineToPoint:CGPointMake(_routeSearchBar.width-38, 52)];
    [linePath1 moveToPoint:CGPointMake(view_margin, 104)];
    [linePath1 addLineToPoint:CGPointMake(_routeSearchBar.width-38, 104)];
    lineLayer1.path = linePath1.CGPath;
    [_routeSearchBar.layer addSublayer:lineLayer1];
    if(!_layers) _layers = [NSMutableArray new];
    [_layers addObject:lineLayer1];
    
    _startField = [[UITextField alloc] initWithFrame:CGRectMake(12, 13, _routeSearchBar.width-12-38, 26)];
    [_startField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_startField setAutocorrectionType:UITextAutocorrectionTypeNo];
    _startField.font = main_font_small;
    _startField.textColor = dynamic_color_black;
    _startField.text = @"我的位置";
    NSString *placeholder1 = @"出发地";
    NSMutableAttributedString *fieldText1 = [[NSMutableAttributedString alloc] initWithString:placeholder1];
    [fieldText1 addAttribute:NSFontAttributeName value:sub_font_big range:NSMakeRange(0, placeholder1.length)];
    [fieldText1 addAttribute:NSForegroundColorAttributeName value:dynamic_color_gray range:NSMakeRange(0, placeholder1.length)];
    [_startField setAttributedPlaceholder:fieldText1];
    UIView *startIcon = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 26)];
    UIView *subStartIcon = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 6, 6)];
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = CGRectMake(0,0,6,6);
    gl.startPoint = CGPointMake(0, 0);
    gl.endPoint = CGPointMake(1, 1);
    gl.colors = gradual_color_blue;
    gl.locations = @[@(0), @(1.0f)];
    [subStartIcon.layer addSublayer:gl];
    subStartIcon.layer.cornerRadius = 3;
    subStartIcon.layer.masksToBounds = YES;
    [startIcon addSubview:subStartIcon];
    _startField.leftView = startIcon;
    _startField.leftViewMode =UITextFieldViewModeAlways;
    UIButton *button = [_startField valueForKey:@"_clearButton"];
    [button setImage:[UIImage imageNamed:@"cancel_button"] forState:UIControlStateNormal];
    _startField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_routeSearchBar addSubview:_startField];
    _startField.delegate = self;
    
    _endField = [[UITextField alloc] initWithFrame:CGRectMake(12, 52+13, _routeSearchBar.width-12-38, 26)];
    [_endField setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_endField setAutocorrectionType:UITextAutocorrectionTypeNo];
    _endField.font = main_font_small;
    _endField.textColor = dynamic_color_black;
    NSString *placeholder2 = @"目的地";
    NSMutableAttributedString *fieldText2 = [[NSMutableAttributedString alloc] initWithString:placeholder2];
    [fieldText2 addAttribute:NSFontAttributeName value:sub_font_big range:NSMakeRange(0, placeholder2.length)];
    [fieldText2 addAttribute:NSForegroundColorAttributeName value:dynamic_color_gray range:NSMakeRange(0, placeholder2.length)];
    [_endField setAttributedPlaceholder:fieldText2];
    UIView *endIcon = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 18, 26)];
    UIView *subEndIcon = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 6, 6)];
    CAGradientLayer *gl1 = [CAGradientLayer layer];
    gl1.frame = CGRectMake(0,0,6,6);
    gl1.startPoint = CGPointMake(0, 0);
    gl1.endPoint = CGPointMake(1, 1);
    gl1.colors = gradual_color_pink;
    gl1.locations = @[@(0), @(1.0f)];
    [subEndIcon.layer addSublayer:gl1];
    subEndIcon.layer.cornerRadius = 3;
    subEndIcon.layer.masksToBounds = YES;
    [endIcon addSubview:subEndIcon];
    _endField.leftView = endIcon;
    _endField.leftViewMode =UITextFieldViewModeAlways;
    UIButton *button1 = [_endField valueForKey:@"_clearButton"];
    [button1 setImage:[UIImage imageNamed:@"cancel_button"] forState:UIControlStateNormal];
    _endField.clearButtonMode = UITextFieldViewModeWhileEditing;
    [_routeSearchBar addSubview:_endField];
    _endField.delegate = self;
    
    UIImageView *switchButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"switch_vertical"]];
    switchButton.frame = CGRectMake(_routeSearchBar.width-12-15, 45, 15, 15);
    [_routeSearchBar addSubview:switchButton];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchAddress:)];
    [switchButton addGestureRecognizer:tap];
    switchButton.userInteractionEnabled = YES;
    
    UIView *stationButtons = [self createStationButtons:CGRectMake(0, 104, _routeSearchBar.width, 52)];
    [_routeSearchBar addSubview:stationButtons];
    
    [self.view addSubview:_routeSearchBar];
}


-(UIView*)createStationButtons:(CGRect)frame{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    UIView *lineInfo = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.width/2, view.height)];
    UIImageView *lineInfoIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_info"]];
    lineInfoIcon.frame = CGRectMake((lineInfo.width-46)/2, (lineInfo.height-10)/2, 10, 10);
    [lineInfo addSubview:lineInfoIcon];
    UILabel *lineInfoTitle = [[UILabel alloc] initWithFrame:CGRectMake(lineInfoIcon.x+16, (lineInfo.height-14)/2, 30, 14)];
    lineInfoTitle.font = sub_font_small;
    lineInfoTitle.textColor = dynamic_color_gray;
    lineInfoTitle.text = @"线路列表";
    [lineInfoTitle sizeToFit];
    [lineInfo addSubview:lineInfoTitle];
    [view addSubview:lineInfo];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLineInfo:)];
    lineInfo.userInteractionEnabled = YES;
    [lineInfo addGestureRecognizer:tap1];
    
    UIView *exit = [[UIView alloc] initWithFrame:CGRectMake(view.width/2, 0, view.width/2, view.height)];
    UIImageView *exitIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"show_map"]];
    exitIcon.frame = CGRectMake((exit.width-46)/2, (exit.height-10)/2, 10, 10);
    [exit addSubview:exitIcon];
    UILabel *exitTitle = [[UILabel alloc] initWithFrame:CGRectMake(exitIcon.x+16, (exit.height-14)/2, 30, 14)];
    exitTitle.font = sub_font_small;
    exitTitle.textColor = dynamic_color_gray;
    exitTitle.text = @"显示地图";
    [exitTitle sizeToFit];
    [exit addSubview:exitTitle];
    [view addSubview:exit];
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMap:)];
    exit.userInteractionEnabled = YES;
    [exit addGestureRecognizer:tap3];
    
    return view;
}



-(void)location:(UITapGestureRecognizer*)tap{
    if(_mainMapView) [_mainMapView updateLocation];
}
-(void)showLineInfo:(UITapGestureRecognizer*)tap{
    LineListViewController *lineVC = [[LineListViewController alloc] init];
    lineVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:lineVC animated:YES];
}
-(void)showMap:(UITapGestureRecognizer*)tap{
    GaodeMapViewController *gaodeVC = [[GaodeMapViewController alloc] init];
    gaodeVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:gaodeVC animated:YES];
}

-(void)switchAddress:(UITapGestureRecognizer*)tap{
    if(_startField && _endField){
        if([@"我的位置" isEqualToString: _startField.text]){
            _startField.text = @"";
            _endField.text = @"我的位置";
        }else if([@"我的位置" isEqualToString: _endField.text]){
            _startField.text = @"我的位置";
            _endField.text = @"";
        }
    }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(textField==_startField || textField==_endField){
        NSInteger type = textField==_startField ? 1 : 2;
        AddressListViewController *addressVC = [[AddressListViewController alloc] initWithStationFor:type];
        addressVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:addressVC animated:YES];
        return NO;
    }else{
        return [super textFieldShouldBeginEditing:textField];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if(_mainMapView) [_mainMapView beforeViewAppear];
//    self.tabBarController.tabBar.hidden = NO;
}
- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    if(_mainMapView) [_mainMapView beforeViewDisappear];
}


- (void)saveCustomRect{
    UIGraphicsBeginImageContext(CGSizeMake(SCREEN_WIDTH, 500)); //设置截屏区域
    [_mainMapView.webView drawViewHierarchyInRect:CGRectMake(200, 200, 200, 200) afterScreenUpdates:NO];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);  //保存到相册中
}




-(void)shareRoute:(RouteModel*)route image:(UIImage*)image forImage:(BOOL)forImage success:(void(^)(void))success{
    if(!route) return;
    if(forImage && !image) return;
    
    NSString *title = @"分享地铁线路";
    if(route && route.startStation && route.endStation){
        title = [NSString stringWithFormat:@"%@: %@ -> %@", title, route.startStation.nameCn, route.endStation.nameCn];
    }
    NSString *content = [self parseRouteInfoToString:route];
    NSURL *url = [NSURL URLWithString:@"https://apps.apple.com/cn/app/地铁迷-metrome/id1477038745"];
    
    
    //1.构造分享参数
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:forImage?nil:content images:forImage?image:nil url:url title:title type:SSDKContentTypeAuto];
    [shareParams SSDKSetupWeChatParamsByText:forImage?nil:content title:title url:url
        thumbImage:[UIImage imageNamed:@"main_logo"] image:forImage?image:nil musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil sourceFileExtension:nil
    sourceFileData:nil type:SSDKContentTypeAuto forPlatformSubType:SSDKPlatformSubTypeWechatSession];
    
    [shareParams SSDKSetupQQParamsByText:forImage?nil:content title:title url:url audioFlashURL:nil videoFlashURL:nil thumbImage:[UIImage imageNamed:@"main_logo"] images:forImage?image:nil type:SSDKContentTypeAuto forPlatformSubType:SSDKPlatformSubTypeQQFriend];
    
    [shareParams SSDKSetupQQParamsByText:forImage?nil:content title:title url:url audioFlashURL:nil videoFlashURL:nil thumbImage:[UIImage imageNamed:@"main_logo"] images:forImage?image:nil type:SSDKContentTypeAuto forPlatformSubType:SSDKPlatformSubTypeQZone];
    
    SSUIShareSheetConfiguration *config = [[SSUIShareSheetConfiguration alloc] init];
    
    //设置分享菜单为简洁样式
    config.style = SSUIActionSheetStyleSystem;
    //设置竖屏有多少个item平台图标显示
    config.columnPortraitCount = 4;
    //设置横屏有多少个item平台图标显示
    config.columnLandscapeCount = 4;
    config.itemAlignment = SSUIItemAlignmentLeft;
    //设置取消按钮标签文本颜色
    config.cancelButtonTitleColor = kRGBA(255, 220, 0, 1);
    //设置标题文本颜色
    config.itemTitleColor = [ColorUtils getColor:kRGBA(0, 0, 0, 1) withDarkMode:kRGBA(255, 255, 255, 1)];
    //设置分享菜单栏状态栏风格
    config.statusBarStyle = UIStatusBarAnimationFade;
    //设置支持的页面方向（单独控制分享菜单栏）
    config.interfaceOrientationMask = UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscape;
    //设置分享菜单栏的背景颜色
    config.menuBackgroundColor = [ColorUtils getColor:kRGBA(255, 255, 255, 1) withDarkMode:kRGBA(26, 26, 26, 1)];
    config.cancelButtonBackgroundColor = [ColorUtils getColor:kRGBA(255, 255, 255, 1) withDarkMode:kRGBA(26, 26, 26, 1)];
    //取消按钮是否隐藏，默认不隐藏
    config.cancelButtonHidden = YES;

    [ShareSDK showShareActionSheet:nil customItems:nil shareParams:shareParams sheetConfiguration:config onStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
         switch (state) {
             case SSDKResponseStateSuccess:
                 [MBProgressHUD showInfo:@"分享成功" detail:nil image:nil inView:nil];
                 success();
                 NSLog(@"成功");//成功
                 break;
             case SSDKResponseStateFail:
                 [MBProgressHUD showInfo:@"分享失败" detail:error.description image:nil inView:nil];
                 //失败
                 break;
             case SSDKResponseStateCancel:
                 break;
             default:
                 break;
         }
     }];
}


-(NSString*)parseRouteInfoToString:(RouteModel*)route{
    NSMutableArray *results = [NSMutableArray new];
    for(int j=0; j<route.segments.count; j++){
        RouteSegmentModel *segment = route.segments[j];
        LineModel *line = segment.line;
        NSString *lineName = line.code?[line.nameCn stringByReplacingOccurrencesOfString:line.code withString:[NSString stringWithFormat:@"%@ ",line.code]]:line.nameCn;
        NSString *timetable = [NSString stringWithFormat:@" (首班车:%@, 末班车:%@) ",segment.firstTime,segment.lastTime];
        NSString *direction = [NSString stringWithFormat:@"%@ 方向 (下一站 %@)",segment.directionName,segment.stationsByWay[1].nameCn];
        
        NSString *firstStation = @"";
        NSString *lastStation = @"";
        NSMutableArray *stations = [NSMutableArray new];
        for(int i=0; i<segment.stationsByWay.count; i++){
            StationModel *station = segment.stationsByWay[i];
            if(i==0){
                firstStation = station.nameCn;
            }if(i==segment.stationsByWay.count-1 && segment.costTime){
                lastStation = [NSString stringWithFormat:@"%@ 耗时 %ld 分钟", station.nameCn, segment.costTime/60];
            }else{
                [stations addObject:station.nameCn];
            }
        }
        NSString *stationNames = [stations componentsJoinedByString:@","];
        
        NSString *result = [NSString stringWithFormat:@"\n%@%@ :\n 方向: %@ \n上车站点: %@\n 途经站点: %@ \n 下车站点: %@", lineName,timetable,direction,firstStation,stationNames,lastStation];
        
        if(segment.transforType && j!=route.segments.count-1){
            NSString *transforType = [NSString stringWithFormat:@"%@ 换乘", segment.transforType];
            if(segment.transforTime){
                result = [NSString stringWithFormat:@"%@ \n %@ %ld分钟", result, transforType, segment.transforTime>60?(segment.transforTime/60):1];
            }
        }
        [results addObject:result];
    }
    NSString *r = [results componentsJoinedByString:@"\n"];
    r = [NSString stringWithFormat:@"%@ \n\t\t 来自 地铁迷 的分享", r];
    return r;
}



- (void)switchMapTabBar:(BOOL)hide duration:(float)duration{
    UIView *tabbar = self.tabBarController.tabBar;
    if([tabbar isHidden] == hide) return;
    if(hide){
        tabbar.hidden = NO;
        tabbar.alpha = 1;
    }else{
        tabbar.hidden = NO;
        tabbar.alpha = 0;
    }
    
    if(duration>0){
        [UIView animateWithDuration:duration animations:^{
            tabbar.alpha = hide?0:1;
        } completion:^(BOOL finished) {
            tabbar.hidden = hide;
            self.mapTabbarHide = hide;
        }];
    }else{
        tabbar.alpha = hide?0:1;
        tabbar.hidden = hide;
        self.mapTabbarHide = hide;
    }
}


-(BOOL)checkTapEnable{
    if(_routeInfoView) return NO;
    else return YES;
}




- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    __weak typeof(self) wkSelf = self;
    // trait发生了改变
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            if(wkSelf.routeInfoView) [wkSelf.routeInfoView updateCGColors];
            if(wkSelf.mainMapView) [wkSelf.mainMapView updateCGColors];
            // 执行操作
            if(wkSelf.layers) for(CALayer *layer in wkSelf.layers){
                if([layer isKindOfClass:CAShapeLayer.class]){
                    CAShapeLayer *clayer = (CAShapeLayer*)layer;
                    clayer.strokeColor = dynamic_color_lightgray.CGColor;
                }
            }
            
        }
    } else {
    }
}
@end
