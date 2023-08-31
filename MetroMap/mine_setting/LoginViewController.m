//
//  LoginViewController.m
//  MetroMap
//
//  Created by edwin on 2019/10/9.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "LoginViewController.h"

@interface LoginViewController ()

@property(nonatomic, retain) UITextField *phone;
@property(nonatomic, retain) NSString *phoneNumber;
@property(nonatomic, retain) NSString *verifyCode;

@property(nonatomic, retain) NSString *weiboUid;
@property(nonatomic, retain) NSString *qqUid;

@property(nonatomic, retain) SMSHelper *smsHelper;
@property(nonatomic, assign) BOOL verified;
@property(nonatomic, assign) BOOL submit;

@property(nonatomic, retain) CodeInputView *codeInputView;

@property(nonatomic, retain) NSMutableArray *layers;
@property(nonatomic, retain) UIImageView *imageView;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createBackgroundImage];
    [self createLogoView];
    [self createMainView];
    [self createThirdLoginIcon];
    
    self.view.backgroundColor = dynamic_color_white;
    _smsHelper = [[SMSHelper alloc] init];
    [self.view addSubview:self.backButton];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, STATUS_BAR_HEIGHT+10, 200, 25)];
    title.font = main_font_big;
    title.textColor = dynamic_color_black;
    title.text = @"登录";
    title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:title];
}

-(void)createBackgroundImage{
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -fitFloat(546)/2, SCREEN_WIDTH, fitFloat(600))];
    [_imageView setImage:[UIImage imageNamed:@"mine_background"]];
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = CGRectMake(0,0,SCREEN_WIDTH,fitFloat(600));
    gl.startPoint = CGPointMake(0.5, 0.5);
    gl.endPoint = CGPointMake(0.5, 1);
//    gl.colors = @[(__bridge id)[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.0].CGColor, (__bridge id)[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor];
    gl.colors = dynamic_gradual_color_dark_settingbg;
    gl.locations = @[@(0), @(1.0f)];
    [_imageView.layer addSublayer:gl];
    [self.view insertSubview:_imageView atIndex:0];
    if(!_layers) _layers = [NSMutableArray new];
    [_layers addObject:gl];
    if (@available(iOS 13.0, *)) {
        if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
            _imageView.alpha=0.1;
        }else{
            _imageView.alpha = 1;
        }
    } else {
        _imageView.alpha = 1;
    }
}


-(void)createLogoView{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-88)/2, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT+12, 88, 88)];
    [imageView setImage:[UIImage imageNamed:@"main_logo"]];
    
    imageView.layer.cornerRadius = 24;
    imageView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05].CGColor;
    imageView.layer.shadowOffset = CGSizeMake(0,3);
    imageView.layer.shadowOpacity = 1;
    imageView.layer.shadowRadius = 6;
    [self.view addSubview:imageView];
}

-(void)createMainView{
    _phone = [[UITextField alloc] initWithFrame:CGRectMake(view_margin*2, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT+12+88+48+20, SCREEN_WIDTH-view_margin*4, 44)];
    NSString *placeholderText = @"请输入手机号码";
    NSMutableAttributedString *fieldText = [[NSMutableAttributedString alloc] initWithString:placeholderText];
    [fieldText addAttribute:NSFontAttributeName value:[UIFont fontWithName:@"DIN-Medium" size: 18] range:NSMakeRange(0, placeholderText.length)];
    [fieldText addAttribute:NSForegroundColorAttributeName value:dynamic_color_lightgray range:NSMakeRange(0, placeholderText.length)];
    [_phone setAttributedPlaceholder:fieldText];
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, _phone.height-1, _phone.width, 1);
    layer.backgroundColor = dynamic_color_middlegray.CGColor;
    [layer setValue:@"nosel" forUndefinedKey:@"my_underline"];
    [_phone.layer addSublayer:layer];
    if(!_layers) _layers = [NSMutableArray new];
    [_layers addObject:layer];
    
    [_phone setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [_phone setAutocorrectionType:UITextAutocorrectionTypeNo];
    [_phone setKeyboardType:UIKeyboardTypeNumberPad];
    _phone.font = [UIFont fontWithName:@"DIN-Medium" size: 18];
    _phone.textColor = dynamic_color_black;
    
    UIButton *button = [_phone valueForKey:@"_clearButton"];
    [button setImage:[UIImage imageNamed:@"cancel_button"] forState:UIControlStateNormal];
    _phone.clearButtonMode = UITextFieldViewModeWhileEditing;

    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 36, 44)];
    UIImageView *phoneIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"phone_icon"]];
    phoneIcon.frame = CGRectMake(0, 9, 24, 24);
    [view addSubview:phoneIcon];
    _phone.leftView = view;
    _phone.leftViewMode =UITextFieldViewModeAlways;
    [self.view addSubview:_phone];
    
    UIView *verifyView = [[UIView alloc] initWithFrame:CGRectMake(view_margin*2, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT+12+88+48+62+20, SCREEN_WIDTH-view_margin*4, 44)];
    UIImageView *verifyCodeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"verify_code"]];
    verifyCodeIcon.frame = CGRectMake(0, 11, 24, 24);
    [verifyView addSubview:verifyCodeIcon];
    
    __weak typeof(self) wkSelf = self;
    _codeInputView = [[CodeInputView alloc] initWithFrame:CGRectMake(24+12, 0, 168, 44) inputType:4 selectCodeBlock:^(NSString *string){
        wkSelf.verifyCode = string;
    }];
    [verifyView addSubview:_codeInputView];
    
    UILabel *verifySendButton = [[UILabel alloc] initWithFrame:CGRectMake(verifyView.width-6-fitFloat(60), 13, fitFloat(60), fitFloat(17))];
    verifySendButton.font = sub_font_middle;
    verifySendButton.textColor = main_color_blue;
    verifySendButton.text = @"获取验证码";
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sendVerifyCode:)];
    [verifySendButton addGestureRecognizer:tap];
    verifySendButton.userInteractionEnabled = YES;
    [verifyView addSubview:verifySendButton];
    [self.view addSubview:verifyView];
    
    
    UIButton *submitButton = [[UIButton alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-240)/2, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT+12+88+48+62+62+44, 240, 44)];
    submitButton.layer.cornerRadius = 8;
    submitButton.layer.masksToBounds = YES;
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = CGRectMake(0,0,SCREEN_WIDTH,fitFloat(600));
    gl.startPoint = CGPointMake(0, 0.5);
    gl.endPoint = CGPointMake(1, 0.5);
    gl.colors = gradual_color_blue;
    gl.locations = @[@(0), @(1.0f)];
    [submitButton.layer addSublayer:gl];
    NSString *title = @"登录 | 注册";
    NSMutableAttributedString *labelStr = [[NSMutableAttributedString alloc] initWithString:title];
    [labelStr addAttribute:NSFontAttributeName value:main_font_middle range:NSMakeRange(0, title.length)];
    [labelStr addAttribute:NSForegroundColorAttributeName value:main_color_white range:NSMakeRange(0, title.length)];
    [submitButton setAttributedTitle:labelStr forState:UIControlStateNormal];
    [self.view addSubview:submitButton];
    UITapGestureRecognizer *submit = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(submit:)];
    submitButton.userInteractionEnabled = YES;
    [submitButton addGestureRecognizer:submit];
    [self.view addSubview:submitButton];
    
    UILabel *userPrivacyLabel = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-12-fitFloat(160))/2+12, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT+12+88+48+62+62+44+44+6, fitFloat(160), fitFloat(14))];
    NSString *privacyText = @"阅读并同意用户服务协议与隐私协议";
    NSMutableAttributedString *privacyStr = [[NSMutableAttributedString alloc] initWithString:privacyText];
    [privacyStr addAttribute:NSFontAttributeName value:sub_font_small range:NSMakeRange(0, privacyText.length)];
    [privacyStr addAttribute:NSForegroundColorAttributeName value:main_color_blue range:NSMakeRange(0, privacyText.length)];
    [privacyStr addAttribute:NSForegroundColorAttributeName value:main_color_pink range:NSMakeRange(5, 6)];
    [privacyStr addAttribute:NSForegroundColorAttributeName value:main_color_pink range:NSMakeRange(12, privacyText.length-12)];
    userPrivacyLabel.attributedText = privacyStr;
    userPrivacyLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:userPrivacyLabel];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUserPrivacy:)];
    userPrivacyLabel.userInteractionEnabled = YES;
    [userPrivacyLabel addGestureRecognizer:tap2];
    
    UIImageView *userPrivacyIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"user_privacy"]];
    userPrivacyIcon.frame = CGRectMake(userPrivacyLabel.x-12, userPrivacyLabel.y+2, 10, 10);
    [self.view addSubview:userPrivacyIcon];
}

-(void)createThirdLoginIcon{
    UIView *weiboView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-72)/2+48, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT+12+88+48+62+62+44+44+6+14+24, 24, 24)];
    UIImageView *weiboIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [weiboIcon setImage:[UIImage imageNamed:@"weibo_icon"]];
    [weiboView addSubview:weiboIcon];
    UILabel *weiboLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 27, 24, 17)];
    weiboLabel.font = sub_font_small;
    weiboLabel.textColor = dynamic_color_middlegray;
    weiboLabel.textAlignment = NSTextAlignmentCenter;
    weiboLabel.text = @"微博";
    [weiboView addSubview:weiboLabel];
    [self.view addSubview:weiboView];
    UITapGestureRecognizer *weiboTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(weiboAuthorize:)];
    [weiboView addGestureRecognizer:weiboTap];
    weiboView.userInteractionEnabled = YES;
    
    UIView *qqView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-72)/2, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT+12+88+48+62+62+44+44+6+14+24, 24, 24)];
    UIImageView *qqIcon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 24, 24)];
    [qqIcon setImage:[UIImage imageNamed:@"qq_icon"]];
    [qqView addSubview:qqIcon];
    UILabel *qqLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 27, 24, 17)];
    qqLabel.font = sub_font_small;
    qqLabel.textColor = dynamic_color_middlegray;
    qqLabel.textAlignment = NSTextAlignmentCenter;
    qqLabel.text = @"QQ";
    [qqView addSubview:qqLabel];
    [self.view addSubview:qqView];
    UITapGestureRecognizer *qqTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(qqAuthorize:)];
    [qqView addGestureRecognizer:qqTap];
    qqView.userInteractionEnabled = YES;
}

-(void)sendVerifyCode:(UITapGestureRecognizer*)tap{
    if(!_phone || _phone.text.length<=0) return;
    _phoneNumber = _phone.text;
    //校验手机号码
    if(![BaseUtils validatePhoneNum:_phoneNumber]){
        [MBProgressHUD showInfo:@"手机号码格式错误" detail:nil image:nil inView:nil];
        return;
    }
    [_smsHelper sendSMSVerify:_phoneNumber success:^{
        [self.phone endEditing:YES];
        //已发送
//        [MBProgressHUD showInfo:@"验证码已发送" detail:nil image:nil inView:nil];
    }];
}
-(void)submit:(UITapGestureRecognizer*)tap{
    if(_verifyCode.length!=4){
        [MBProgressHUD showInfo:@"验证码格式错误" detail:nil image:nil inView:nil];
        return;
    }
    if(self.verified){
        [MBProgressHUD showInfo:@"已提交过" detail:nil image:nil inView:nil];
        self.verified = NO;
        return;
    }
    __weak typeof(self) wkSelf = self;
    [_smsHelper verify:_phoneNumber verifyCode:_verifyCode success:^{
        self.verified = YES;
        //已成功验证
        [wkSelf registerUser:wkSelf.phoneNumber password:nil];
    }];
}
-(void)showUserPrivacy:(UITapGestureRecognizer*)tap{
    AgreementViewController *aVC = [[AgreementViewController alloc] init];
    aVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:aVC animated:YES];
}
-(void)qqAuthorize:(UITapGestureRecognizer*)tap{
    __weak typeof(self) wkSelf = self;
    [ShareSDK authorize:SSDKPlatformTypeQQ settings:nil onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        switch (state) {
            case SSDKResponseStateSuccess:
                [wkSelf createQQThirdUser:user];
                NSLog(@"%@",[user rawData]);
                break;
            case SSDKResponseStateFail:
                [MBProgressHUD showInfo:@"授权失败" detail:error.description image:nil inView:nil];
                //失败
                break;
            case SSDKResponseStateCancel:
                //用户取消授权
                break;
            default:
                break;
        }
    }];
}
-(void)weiboAuthorize:(UITapGestureRecognizer*)tap{
    __weak typeof(self) wkSelf = self;
    [ShareSDK authorize:SSDKPlatformTypeSinaWeibo settings:nil onStateChanged:^(SSDKResponseState state, SSDKUser *user, NSError *error) {
        switch (state) {
            case SSDKResponseStateSuccess:
                [wkSelf createWeiboThirdUser:user];
                NSLog(@"%@",[user.credential rawData]);
                break;
            case SSDKResponseStateFail:
                [MBProgressHUD showInfo:@"授权失败" detail:error.description image:nil inView:nil];
                NSLog(@"--%@",error.description);
                //失败
                break;
            case SSDKResponseStateCancel:
                //用户取消授权
                break;
            default:
                break;
        }
    }];
}

-(void)createQQThirdUser:(SSDKUser *)user{
    [[NSUserDefaults standardUserDefaults] setObject:[user.credential rawData] forKey: THLOGIN_QQ_CREDENTIAL_KEY];
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    if(user.icon) [userInfo setObject:user.icon forKey:@"userPortrait"];
    if(user.nickname) [userInfo setObject:user.nickname forKey:@"userName"];
    if(user.uid) [userInfo setObject:user.uid forKey:@"uid"];
    if(user.url) [userInfo setObject:user.url forKey:@"url"];
    [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey: THLOGIN_QQ_USER_KEY];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:THLOGIN_WEIBO_CREDENTIAL_KEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:THLOGIN_WEIBO_USER_KEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:THLOGIN_WEIXIN_CREDENTIAL_KEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:THLOGIN_WEIXIN_USER_KEY];
    
    if(user.uid){
        __weak typeof(self) wkSelf = self;
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setObject:user.uid forKey:@"uid"];
        [params setObject:@"qq" forKey:@"type"];
        [[HttpHelper http] findDetail:request_user_third_check params:params progress:nil success:^(NSMutableDictionary *responseDic) {
            NSInteger count = [(NSString*)responseDic integerValue];
            if(count>0){
                //登录
                [wkSelf qqLogin];
            }else{
                [MBProgressHUD showInfo:@"授权成功，请验证手机号码登录" detail:nil image:nil inView:nil];
                //注册
                self.qqUid = user.uid;
            }
        } failure:^(NSString *errorInfo) {
            [MBProgressHUD showInfo:@"登录异常" detail:nil image:nil inView:nil];
        }];
    }else{
        [MBProgressHUD showInfo:@"获取身份信息错误" detail:nil image:nil inView:nil];
    }
}

-(void)qqLogin{
    __weak typeof(self) wkSelf = self;
    NSMutableDictionary *userCredential = [[NSUserDefaults standardUserDefaults] objectForKey: THLOGIN_QQ_CREDENTIAL_KEY];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:userCredential[@"openid"] forKey:@"uid"];
    [params setObject:userCredential[@"access_token"] forKey:@"token"];
    [params setObject:userCredential[@"expires_in"] forKey:@"expireTime"];
    [params setObject:@"qq" forKey:@"type"];
    [[HttpHelper http] submit:request_user_third_login params:params progress:nil success:^(NSMutableDictionary *responseDic) {
       NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary*)[responseDic objectForKey:@"userInfo"]];
       NSString *session = [responseDic objectForKey:@"session"];
       if(userDict){
           [MBProgressHUD showInfo:@"登录成功" detail:nil image:nil inView:nil];
            //记录登录信息
            UserModel *user = [UserModel yy_modelWithJSON:userDict];
            [[NSUserDefaults standardUserDefaults] setObject:user.identifyCode forKey:LOGIN_USER_ID_KEY];
            [[NSUserDefaults standardUserDefaults] setObject:session forKey:LOGIN_USER_TOKEN_KEY];
            [[NSUserDefaults standardUserDefaults] setObject:userDict forKey:LOGIN_USER_KEY];
            [wkSelf.navigationController popViewControllerAnimated:YES];
            //后续处理，记录token
//           [wkSelf successUserRegister:user];
       }else{
           [MBProgressHUD showInfo:@"登录异常" detail:@"用户数据解析错误" image:nil inView:nil];
       }
    } failure:^(NSString *errorInfo) {
        [MBProgressHUD showInfo:@"登录异常" detail:errorInfo image:nil inView:nil];
    }];
}

-(void)createWeiboThirdUser:(SSDKUser *)user{
    [[NSUserDefaults standardUserDefaults] setObject:[user.credential rawData] forKey: THLOGIN_WEIBO_CREDENTIAL_KEY];
    NSMutableDictionary *userInfo = [NSMutableDictionary new];
    if(user.icon) [userInfo setObject:user.icon forKey:@"userPortrait"];
    if(user.nickname) [userInfo setObject:user.nickname forKey:@"userName"];
    if(user.uid) [userInfo setObject:user.uid forKey:@"uid"];
    if(user.url) [userInfo setObject:user.url forKey:@"url"];
    [[NSUserDefaults standardUserDefaults] setObject:userInfo forKey: THLOGIN_WEIBO_USER_KEY];
    
    if(user.uid){
        __weak typeof(self) wkSelf = self;
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setObject:user.uid forKey:@"uid"];
        [params setObject:@"weibo" forKey:@"type"];
        [[HttpHelper http] findDetail:request_user_third_check params:params progress:nil success:^(NSMutableDictionary *responseDic) {
            NSInteger count = [(NSString*)responseDic integerValue];
            if(count>0){
                //登录
                [wkSelf weiboLogin];
            }else{
                //注册
                self.weiboUid = user.uid;
            }
        } failure:^(NSString *errorInfo) {
            [MBProgressHUD showInfo:@"登录异常" detail:nil image:nil inView:nil];
        }];
    }else{
        [MBProgressHUD showInfo:@"获取身份信息错误" detail:nil image:nil inView:nil];
    }
}

-(void)weiboLogin{
    __weak typeof(self) wkSelf = self;
    NSMutableDictionary *userCredential = [[NSUserDefaults standardUserDefaults] objectForKey: THLOGIN_WEIBO_CREDENTIAL_KEY];
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:userCredential[@"uid"] forKey:@"uid"];
    [params setObject:userCredential[@"access_token"] forKey:@"token"];
    [params setObject:userCredential[@"expires_in"] forKey:@"expireTime"];
    [params setObject:@"weibo" forKey:@"type"];
    [[HttpHelper http] submit:request_user_third_login params:params progress:nil success:^(NSMutableDictionary *responseDic) {
       NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary*)[responseDic objectForKey:@"userInfo"]];
       NSString *session = [responseDic objectForKey:@"session"];
       if(userDict){
           [MBProgressHUD showInfo:@"登录成功" detail:nil image:nil inView:nil];
           //记录登录信息
           UserModel *user = [UserModel yy_modelWithJSON:userDict];
           [[NSUserDefaults standardUserDefaults] setObject:user.identifyCode forKey:LOGIN_USER_ID_KEY];
           [[NSUserDefaults standardUserDefaults] setObject:session forKey:LOGIN_USER_TOKEN_KEY];
           [[NSUserDefaults standardUserDefaults] setObject:userDict forKey:LOGIN_USER_KEY];
           [wkSelf.navigationController popViewControllerAnimated:YES];
           //后续处理，记录token
//           [wkSelf successUserRegister:user];
       }else{
           [MBProgressHUD showInfo:@"登录异常" detail:@"用户数据解析错误" image:nil inView:nil];
       }
    } failure:^(NSString *errorInfo) {
        [MBProgressHUD showInfo:@"登录异常" detail:errorInfo image:nil inView:nil];
    }];
}

-(void)resetSubmit{
    _submit = NO;
}

-(void)registerUser:(NSString*)phone password:(NSString*)password{
    if(_submit) return;
    else {
        _submit = YES;
        [self performSelector:@selector(resetSubmit) withObject:nil afterDelay:2.f];
    }
    if(![BaseUtils validatePhoneNum:_phoneNumber]){
        [MBProgressHUD showInfo:@"手机号码格式错误" detail:nil image:nil inView:nil];
        return;
    }
    NSMutableDictionary *dict = [NSMutableDictionary new];
    [dict setObject:phone forKey:@"phone"];
    if(_qqUid) [dict setObject:_qqUid forKey:@"qqUid"];
    if(_weiboUid) [dict setObject:_weiboUid forKey:@"weiboUid"];
    if(password) [dict setObject:password forKey:@"password"];
    
    __weak typeof(self) wkSelf = self;
    [[HttpHelper new] submit:request_user_register params:dict progress:^(NSProgress *progress) {
    } success:^(NSMutableDictionary *responseDic) {
        NSMutableDictionary *userDict = [NSMutableDictionary dictionaryWithDictionary:(NSDictionary*)[responseDic objectForKey:@"userInfo"]];
        NSString *session = [responseDic objectForKey:@"session"];
        if(userDict){
            [MBProgressHUD showInfo:@"登录成功" detail:nil image:nil inView:nil];
            UserModel *user = [UserModel yy_modelWithJSON:userDict];
            [[NSUserDefaults standardUserDefaults] setObject:user.identifyCode forKey:LOGIN_USER_ID_KEY];
            [[NSUserDefaults standardUserDefaults] setObject:session forKey:LOGIN_USER_TOKEN_KEY];
            [[NSUserDefaults standardUserDefaults] setObject:userDict forKey:LOGIN_USER_KEY];
            [[NSUserDefaults standardUserDefaults] setObject:LOGIN_USER_TYPE_TOURIST forKey:LOGIN_USER_TYPE_NORMAL];
            [wkSelf.navigationController popViewControllerAnimated:YES];
            //后续处理，记录token
            [wkSelf successUserRegister:user];
        }else{
            [MBProgressHUD showInfo:@"登录异常" detail:@"用户数据解析错误" image:nil inView:nil];
        }
    } failure:^(NSString *errorInfo) {
    }];
}

-(void)successUserRegister:(UserModel*)user{
    //更新第三方登录信息
    if([[NSUserDefaults standardUserDefaults] objectForKey:THLOGIN_WEIBO_CREDENTIAL_KEY]){
        NSMutableDictionary *userCredential = [[NSUserDefaults standardUserDefaults] objectForKey:THLOGIN_WEIBO_CREDENTIAL_KEY];
        if(userCredential && userCredential[@"uid"] && userCredential[@"access_token"] && userCredential[@"expires_in"]){
            NSMutableDictionary *parameters = [NSMutableDictionary new];
            [parameters setObject:userCredential[@"uid"] forKey:@"uid"];
            [parameters setObject:userCredential[@"access_token"] forKey:@"token"];
            [parameters setObject:userCredential[@"expires_in"] forKey:@"expireTime"];
            [[HttpHelper http] submit:request_user_third_token params:parameters progress:nil success:^(NSMutableDictionary *responseDic) {
                if(responseDic){
                }else{
                }
            } failure:^(NSString *errorInfo) {
            }];
        }
    }
}

//- (void)viewWillAppear:(BOOL)animated{
//    self.tabBarController.tabBar.hidden = YES;
//}
//
//- (void)viewWillDisappear:(BOOL)animated{
//  self.tabBarController.tabBar.hidden = NO;
//}



- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    __weak typeof(self) wkSelf = self;
    // trait发生了改变
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            // 执行操作
            if(wkSelf.layers) for(CALayer *layer in wkSelf.layers){
                if([layer isKindOfClass:CAGradientLayer.class]){
                    CAGradientLayer *glayer = (CAGradientLayer*)layer;
                    glayer.colors = dynamic_gradual_color_dark_settingbg;
                }else{
                    //虚线的颜色
                    layer.backgroundColor = dynamic_color_middlegray.CGColor;
                }
            }
            if(wkSelf.codeInputView) [wkSelf.codeInputView updateCGColors];
            
            if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
                _imageView.alpha=0.1;
            }else{
                _imageView.alpha = 1;
            }
        }
    } else {
    }
}

@end
