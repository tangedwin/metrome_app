//
//  BaseViewController.m
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "BaseViewController.h"

@interface BaseViewController ()<UINavigationControllerDelegate>
@end

@implementation BaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置初始导航栏透明度
    [self.navigationController.navigationBar setHidden:YES];
    _defaultNCDelegate = self.navigationController.delegate;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [self.view setBackgroundColor:dynamic_color_white];
    //设置代理即可
    self.navigationController.delegate = self;
}

- (UIView *)naviMask{
    if(!_naviMask) {
        _naviMask = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, STATUS_BAR_HEIGHT+NAVIGATION_BAR_HEIGHT)];
        _naviMask.backgroundColor = dynamic_color_white;
    }
    return _naviMask;
}

- (UIView *)backButton{
    if(!_backButton) {
        _backButton = [[UIView alloc] initWithFrame:CGRectMake(16, STATUS_BAR_HEIGHT+7, 28, 28)];
        UIImageView *backImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navi_back"]];
        backImg.frame = CGRectMake(0, 0, 28, 28);
        [_backButton addSubview:backImg];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(naviBack:)];
        _backButton.userInteractionEnabled = YES;
        [_backButton addGestureRecognizer:tap];
    }
    return _backButton;
}

-(UIView *)cityPickerButton{
    if(!_cityPickerButton){
        [self loadCityPickerButton];
    }
    return _cityPickerButton;
}

-(void) loadCityPickerButton{
    if(_cityPickerButton){
        if(_cityPickerButton.subviews) for(UIView *sview in _cityPickerButton.subviews) [sview removeFromSuperview];
    }
    
    NSString *city = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_CITY_NAME_KEY];
    if(!city) city = @"选择城市";
    UIFont *font = main_font_big;
    CGSize size = [city sizeWithAttributes:@{NSFontAttributeName:font}];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, ceil(size.width), 25)];
    titleLabel.font = font;
    titleLabel.textColor = main_color_blue;
    titleLabel.text = city;
    
    if(!_cityPickerButton){
        _cityPickerButton = [[UIView alloc] initWithFrame:CGRectMake(view_margin, STATUS_BAR_HEIGHT+10, titleLabel.width+12, 25)];
    }else{
        _cityPickerButton.frame = CGRectMake(view_margin, STATUS_BAR_HEIGHT+10, titleLabel.width+12, 25);
    }
    [_cityPickerButton addSubview:titleLabel];

    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pull_down"]];
    image.frame = CGRectMake(_cityPickerButton.width-10, 1, 15, 15);
    [_cityPickerButton addSubview:image];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cityPicker:)];
    _cityPickerButton.userInteractionEnabled = YES;
    [_cityPickerButton addGestureRecognizer:tap];
}


-(UITextField*)searchBar{
    if(!_searchBar){
        _searchBar = [[UITextField alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-view_margin-fitFloat(69), STATUS_BAR_HEIGHT+4, fitFloat(69), 36)];
        NSString *text = @"搜索";
        NSMutableAttributedString *fieldText = [[NSMutableAttributedString alloc] initWithString:text];
        [fieldText addAttribute:NSFontAttributeName value:sub_font_middle range:NSMakeRange(0, text.length)];
        [fieldText addAttribute:NSForegroundColorAttributeName value:dynamic_color_gray range:NSMakeRange(0, text.length)];
        [_searchBar setAttributedPlaceholder:fieldText];
        _searchBar.returnKeyType = UIReturnKeySearch;
        
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 36)];
        UIImageView *searchIconImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_icon"]];
        searchIconImage.frame = CGRectMake(6, 6, 24, 24);
        [view addSubview:searchIconImage];
        _searchBar.leftView = view;
        _searchBar.leftViewMode =UITextFieldViewModeAlways;

        UIButton *button = [_searchBar valueForKey:@"_clearButton"];
        [button setImage:[UIImage imageNamed:@"cancel_button"] forState:UIControlStateNormal];
        _searchBar.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        _searchBar.backgroundColor = dynamic_color_lightGrayWhite;
        _searchBar.layer.cornerRadius = 18;
    }
    return _searchBar;
}

-(UIImageView*)menuButton{
    if(!_menuButton){
        _menuButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search_icon"]];
        _menuButton.frame = CGRectMake(SCREEN_WIDTH-view_margin-24, STATUS_BAR_HEIGHT+10, 24, 24);
    }
    return _menuButton;
}

-(UIView*)messageButton{
    if(!_messageButton){
        [self reloadMessageButton:0];
    }
    return _messageButton;
}

-(void)reloadMessageButton:(NSInteger) messageCount{
    _messageButton = [[UIView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-72, STATUS_BAR_HEIGHT+6, 30, 30)];
    _menuButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_icon"]];
    _menuButton.frame = CGRectMake(0, 4, 24, 24);
    [_messageButton addSubview:_menuButton];

    if(messageCount>0){
        if(messageCount>99) messageCount=99;
        UIView *lview = [[UIView alloc] initWithFrame:CGRectMake(15, 0, 15, 15)];
        UILabel *llabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        llabel.textColor = dynamic_color_white;
        llabel.text = [NSString stringWithFormat:@"%ld",(long)messageCount];
        llabel.textAlignment = NSTextAlignmentCenter;
        if(llabel.text.length<3) llabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:10];
        else llabel.font = [UIFont fontWithName:@"PingFangSC-Semibold" size:7];
        CAGradientLayer *gl = [CAGradientLayer layer];
        gl.frame = CGRectMake(0, 0, 15, 15);
        gl.startPoint = CGPointMake(0, 0.5);
        gl.endPoint = CGPointMake(1, 0.5);
        gl.colors = gradual_color_pink;
        gl.locations = @[@(0), @(1.0f)];
        [lview.layer addSublayer:gl];
        lview.layer.cornerRadius = 7.5;
        lview.layer.masksToBounds = YES;
        
        [lview addSubview:llabel];
        [_messageButton addSubview:lview];
    }
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMessageView:)];
    _messageButton.userInteractionEnabled = YES;
    [_messageButton addGestureRecognizer:tap];
}

-(UIImageView*)settingButton{
    if(!_settingButton){
        _settingButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"setting_icon"]];
        _settingButton.frame = CGRectMake(SCREEN_WIDTH-36, STATUS_BAR_HEIGHT+10, 24, 24);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSettingView:)];
        _settingButton.userInteractionEnabled = YES;
        [_settingButton addGestureRecognizer:tap];
    }
    return _settingButton;
}

-(void)updateLocation:(void(^)(NSMutableDictionary *dict))success{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOCATION_LOC_KEY];
    if(!_locationHelper) _locationHelper = [[LocationHelper alloc] init];
    [_locationHelper queryLocation:^(NSMutableDictionary *dict){
        if(success) success(dict);
    } failure:^(NSString *info){
        if(success) success(nil);
    }];
}



- (void)naviBack:(UITapGestureRecognizer*)tap {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)cityPicker:(UITapGestureRecognizer*)tap {
}

-(void)showMessageView:(UITapGestureRecognizer*)tap {
}

-(void)showSettingView:(UITapGestureRecognizer*)tap {
}

-(float)mTabbarHeight{
    //Tabbar高度
    return self.tabBarController.tabBar.bounds.size.height;
}

@end
