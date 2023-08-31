//
//  MineSetting.m
//  MetroMap
//
//  Created by edwin on 2019/10/8.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "MineSettingView.h"

@interface MineSettingView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, retain) UICollectionViewFlowLayout *fallLayout;
@property (nonatomic, retain) UserModel *userInfo;
@property (nonatomic, retain) NSMutableArray *addressCollects;

@end

static NSString * const mine_setting_id = @"mine_setting";
@implementation MineSettingView

-(instancetype)initWithFrame:(CGRect)frame{
    // 创建布局
    _fallLayout = [[UICollectionViewFlowLayout alloc]init];
    _fallLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self = [super initWithFrame:frame collectionViewLayout:_fallLayout];
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:mine_setting_id];
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
    
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_USER_ID_KEY];
    self.userInfo = [UserModel yy_modelWithJSON:userDict];
    return self;
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //根据注册标记查找cell
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:mine_setting_id forIndexPath:indexPath];
    if(cell.contentView.subviews) for(UIView *sview in cell.contentView.subviews) [sview removeFromSuperview];
    if(indexPath.item==0) [self createUserPortrait:_userInfo cell:cell indexPath:indexPath];
    else if(indexPath.item==1) [self createFunctionListInCell:cell indexPath:indexPath];
    else if(indexPath.item==2) {
        AddressModel *home = nil;
        AddressModel *company = nil;
        if(_addressCollects) for(AddressModel *address in _addressCollects){
            if([home_type isEqualToString:address.type]) home = address;
            if([company_type isEqualToString:address.type]) company = address;
        }
        [self createCommonAddress: home company:company cell:cell indexPath:indexPath];
    }
    else if(indexPath.item==3) [self createTableLabel:@"我的收藏" icon:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"my_collects"]] cell:cell indexPath:indexPath];
    else if(indexPath.item==4) [self createTableLabel:@"问题反馈" icon:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"question_reback"]] cell:cell indexPath:indexPath];
    else if(indexPath.item==5) [self createTableLabel:@"邀请好友" icon:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"invate_icon"]] cell:cell indexPath:indexPath];
    else if(indexPath.item==6) [self createTableLabel:@"应用评分" icon:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"comment_us"]] cell:cell indexPath:indexPath];
    else if(indexPath.item==7) [self createTableLabel:@"关于我们" icon:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"about_us"]] cell:cell indexPath:indexPath];
    else if(indexPath.item==8) [self createTableLabel:@"打赏我们" icon:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"reward_us"]] cell:cell indexPath:indexPath];
    return cell;
}

-(void)createUserPortrait:(UserModel*)userInfo cell:(UICollectionViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT, SCREEN_WIDTH, 143)];
    UIImageView *portrait = [[UIImageView alloc] initWithFrame:CGRectMake((cell.width-83)/2, 15, 83, 83)];
    portrait.layer.borderColor = dynamic_color_white.CGColor;
    portrait.layer.borderWidth = 3;
    portrait.layer.cornerRadius = 83/2;
    portrait.layer.masksToBounds = YES;
    if(userInfo && userInfo.portraitUrl){
        [portrait yy_setImageWithURL:[NSURL URLWithString:userInfo.portraitUrl] options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation];
    }else {
        [portrait setImage:[UIImage imageNamed:@"user_portrait"]];
    }
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, portrait.height+portrait.y+6, SCREEN_WIDTH, 25)];
    title.font = main_font_big;
    title.textColor = dynamic_color_black;
    title.textAlignment = NSTextAlignmentCenter;
    title.text =  @"未登录";
    if(userInfo){
        if(userInfo.nickName) title.text = userInfo.nickName;
        else if(userInfo.phone) title.text = [BaseUtils hideWithPhone:userInfo.phone];
        else title.text = @"火星用户";
    }
    
    [view addSubview:portrait];
    [view addSubview:title];
    [cell.contentView addSubview:view];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loginUser:)];
    [view addGestureRecognizer:tap];
    view.userInteractionEnabled = YES;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, -(NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT)-fitFloat(600)/2, SCREEN_WIDTH, fitFloat(600))];
    [imageView setImage:[UIImage imageNamed:@"mine_background"]];
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = CGRectMake(0,0,SCREEN_WIDTH,fitFloat(600));
    gl.startPoint = CGPointMake(0.5, 0.5);
    gl.endPoint = CGPointMake(0.5, 1);
//    gl.colors = @[(__bridge id)[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:0.0].CGColor, (__bridge id)[UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0].CGColor];
    gl.colors = dynamic_gradual_color_dark_settingbg;
    gl.locations = @[@(0), @(1.0f)];
    [imageView.layer addSublayer:gl];
    [view insertSubview:imageView atIndex:0];
//    if (@available(iOS 13.0, *)) {
//        [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trait) {
//            if (trait.userInterfaceStyle == UIUserInterfaceStyleDark) {
//                imageView.alpha = 0.1;
//            }else{
//                imageView.alpha = 1;
//            }
//            return nil;
//        }];
//    }else{
//        imageView.alpha = 0.1;
//    }
//
    
    if (@available(iOS 13.0, *)) {
        if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
            imageView.alpha=0.1;
        }else{
            imageView.alpha = 1;
        }
    } else {
        imageView.alpha = 1;
    }
}

-(void)createFunctionListInCell:(UICollectionViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 76)];
    [cell.contentView addSubview:scrollView];
    
//    UIView *vip = [self createFunctionView:UserFunctionTypeVIPMember];
//    vip.x = view_margin;
//    [scrollView addSubview:vip];
//
//    UIView *trip = [self createFunctionView:UserFunctionTypeTrip];
//    trip.x = view_margin+vip.width+6;
//    [scrollView addSubview:trip];
//
//    UIView *wallet = [self createFunctionView:UserFunctionTypeWallet];
//    wallet.x = view_margin+vip.width+6+trip.width+6;
//    [scrollView addSubview:wallet];
    
    
    UIView *trip = [self createFunctionView:UserFunctionTypeTrip];
    trip.x = view_margin;
    [scrollView addSubview:trip];
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
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editCommenAddress:)];
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
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(editCommenAddress:)];
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

-(void)createTableLabel:(NSString*)title icon:(UIImageView*)icon cell:(UICollectionViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    CGFloat width = SCREEN_WIDTH-view_margin;
    CGFloat labelX = 0;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(view_margin, 0, width, 52)];
    if(icon){
        icon.frame = CGRectMake(0, (52-15)/2, 15, 15);
        [view addSubview:icon];
        labelX = 21;
    }
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, 16, 100, 20)];
    titleLabel.font = main_font_small;
    titleLabel.textColor = dynamic_color_black;
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [view addSubview:titleLabel];
    
    UIImageView *nextButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navi_right_big"]];
    nextButton.frame = CGRectMake(view.width-view_margin-15, (52-15)/2, 15, 15);
    [view addSubview:nextButton];
    [cell.contentView addSubview:view];
    
    CALayer *viewBorder = [CALayer layer];
    viewBorder.frame = CGRectMake(0, view.height, view.width, 1);
    viewBorder.backgroundColor = dynamic_color_lightgray.CGColor;
    viewBorder.opacity = 0.5;
    [view.layer addSublayer:viewBorder];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTap:)];
    view.userInteractionEnabled = YES;
    view.tag = indexPath.item;
    [view addGestureRecognizer:tap];
}


-(UIView*)createFunctionView:(UserFunctionType)type {
    CGFloat width = (SCREEN_WIDTH-view_margin*2-12)/3;
    CGFloat height = 64*width/113;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = CGRectMake(0, 0, width, height);
    gl.startPoint = CGPointMake(0, 0.5);
    gl.endPoint = CGPointMake(1, 0.5);
    if(type == UserFunctionTypeTrip) gl.colors = gradual_color_blue;
    else if(type == UserFunctionTypeWallet) gl.colors = gradual_color_pink;
    else if(type == UserFunctionTypeVIPMember) gl.colors = gradual_color_black;
    else return nil;
    gl.locations = @[@(0), @(1.0f)];
    [view.layer addSublayer:gl];
    view.layer.cornerRadius = 6;
    view.layer.masksToBounds = YES;
    
    view.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05].CGColor;
    view.layer.shadowOffset = CGSizeMake(0,3);
    view.layer.shadowOpacity = 1;
    view.layer.shadowRadius = 6;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(12, (view.height-25)/2, fitFloat(36), 25)];
    label.font = main_font_big;
    label.textColor = main_color_white;
    if(type == UserFunctionTypeTrip) label.text = @"行程";
    else if(type == UserFunctionTypeWallet) label.text = @"钱包";
    else if(type == UserFunctionTypeVIPMember) label.text = @"会员";
    [view addSubview:label];
    
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(view.width-6-48, (view.height-48)/2, 48, 48)];
    if(type == UserFunctionTypeTrip) [icon setImage: [UIImage imageNamed:@"trip_icon"]];
    else if(type == UserFunctionTypeWallet) [icon setImage: [UIImage imageNamed:@"wallet_icon"]];
    else if(type == UserFunctionTypeVIPMember) [icon setImage: [UIImage imageNamed:@"vip_icon"]];
    [view addSubview:icon];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(functionTap:)];
    if(type == UserFunctionTypeTrip) view.tag = 1;
    else if(type == UserFunctionTypeWallet) view.tag = 2;
    else if(type == UserFunctionTypeVIPMember) view.tag = 0;
    view.userInteractionEnabled = YES;
    [view addGestureRecognizer:tap];
    return view;
}


//设置cell的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.item==0) return CGSizeMake(SCREEN_WIDTH, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT+143);
    else if(indexPath.item==1) return CGSizeMake(SCREEN_WIDTH, 76);
    else if(indexPath.item==2) return CGSizeMake(SCREEN_WIDTH, 117);
    return CGSizeMake(SCREEN_WIDTH, 53);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

//设置section间隔
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    //分别为上、左、下、右
    return UIEdgeInsetsMake(0, 0, view_margin*2, 0);
}

//返回列表分组数，默认为1
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

//返回列表每个分组section拥有cell行数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 9;
}


-(void)loginUser:(UITapGestureRecognizer*)tap{
    if(!_userInfo){
        LoginViewController *loginVC = [[LoginViewController alloc] init];
        loginVC.hidesBottomBarWhenPushed = YES;
        [self.viewDelegate pushViewController:loginVC animated:YES];
    }else{
        //后续修改
    }
}

-(void)functionTap:(UITapGestureRecognizer*)tap{
    if(tap.view.tag==1){
        MyTripViewController *tripVC = [[MyTripViewController alloc] init];
        tripVC.hidesBottomBarWhenPushed = YES;
        [self.viewDelegate pushViewController:tripVC animated:YES];
    }else{
        [MBProgressHUD showInfo:@"暂未开通" detail:nil image:nil inView:nil];
    }
}

-(void)menuTap:(UITapGestureRecognizer*)tap{
    if(tap.view.tag == 3){
        AddressListViewController *alVC = [[AddressListViewController alloc] initWithStationFor:3];
        alVC.hidesBottomBarWhenPushed = YES;
        [self.viewDelegate pushViewController:alVC animated:YES];
    }else if(tap.view.tag == 4){
//        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat: @"mailto:%@",email]] options:@{} completionHandler:^(BOOL success) {
//        }];
        FeedbackViewController *feedback = [[FeedbackViewController alloc] initWithFeedback:nil];
        feedback.hidesBottomBarWhenPushed = YES;
        [self.viewDelegate pushViewController:feedback animated:YES];
    }else if(tap.view.tag == 5){
        [self shareApp];
    }else if(tap.view.tag == 6){
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_OPEN_EVALUATE_AFTER_IOS11] options:@{} completionHandler:^(BOOL success) {
        }];
        #else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_OPEN_EVALUATE] options:@{} completionHandler:^(BOOL success) {
        }];
        #endif
    }else if(tap.view.tag == 7){
        AboutUsViewController *aboutUsVC = [[AboutUsViewController alloc] init];
        aboutUsVC.hidesBottomBarWhenPushed = YES;
        [self.viewDelegate pushViewController:aboutUsVC animated:YES];
    }else if(tap.view.tag == 8){
        RewardUsViewController *rewardUsVC = [[RewardUsViewController alloc] init];
        rewardUsVC.hidesBottomBarWhenPushed = YES;
        [self.viewDelegate pushViewController:rewardUsVC animated:YES];
    }
}

-(void)reloadAddressData{
    [self loadCommenAddress];
    [self reloadData];
}
-(void)reloadUserData{
    NSDictionary *userDict = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_USER_KEY];
    self.userInfo = [UserModel yy_modelWithJSON:userDict];
    [self reloadData];
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



- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < -SCREEN_HEIGHT/3) {
        scrollView.contentOffset = CGPointMake(scrollView.contentOffset.x, -SCREEN_HEIGHT/3);
    }
}




-(void)shareApp{
    //1.构造分享参数
    NSDictionary *userInfo = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_USER_KEY];
    NSString *title = (!userInfo || !userInfo[@"userName"])?@"":[NSString stringWithFormat:@"%@ 邀请您加入地铁迷", userInfo[@"userName"]];
    NSString *content = @"地铁迷 地铁出行必备";
    NSURL *url = [NSURL URLWithString:@"https://apps.apple.com/cn/app/%E5%9C%B0%E9%93%81%E8%BF%B7-metrome/id1477038745"];
    
    NSMutableDictionary *shareParams = [NSMutableDictionary dictionary];
    [shareParams SSDKSetupShareParamsByText:content images:nil url:url title:title type:SSDKContentTypeAuto];
    [shareParams SSDKSetupSinaWeiboShareParamsByText:[NSString stringWithFormat:@"%@ \n%@ \n%@", title, content, url] title:title
            images:nil video:nil url:url latitude:0 longitude:0 objectID:0 isShareToStory:false type:SSDKContentTypeText];
    [shareParams SSDKSetupWeChatParamsByText:content title:title url:url
             thumbImage:[UIImage imageNamed:@"main_logo"] image:nil musicFileURL:nil extInfo:nil fileData:nil emoticonData:nil sourceFileExtension:nil
         sourceFileData:nil type:SSDKContentTypeApp forPlatformSubType:SSDKPlatformSubTypeWechatSession];
    [shareParams SSDKSetupQQParamsByText:content title:title url:url audioFlashURL:nil videoFlashURL:nil thumbImage:[UIImage imageNamed:@"main_logo"] images:nil type:SSDKContentTypeWebPage forPlatformSubType:SSDKPlatformSubTypeQQFriend];
    [shareParams SSDKSetupQQParamsByText:content title:title url:url audioFlashURL:nil videoFlashURL:nil thumbImage:[UIImage imageNamed:@"main_logo"] images:nil type:SSDKContentTypeWebPage forPlatformSubType:SSDKPlatformSubTypeQZone];
    
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
    //设置直接分享的平台（不弹编辑界面）
    config.directSharePlatforms = @[@(SSDKPlatformTypeWechat),@(SSDKPlatformTypeQQ),@(SSDKPlatformTypeSinaWeibo)];

    [ShareSDK showShareActionSheet:nil customItems:@[@(SSDKPlatformSubTypeWechatSession), @(SSDKPlatformSubTypeQQFriend), @(SSDKPlatformSubTypeQZone), @(SSDKPlatformTypeSinaWeibo)] shareParams:shareParams sheetConfiguration:config onStateChanged:^(SSDKResponseState state, SSDKPlatformType platformType, NSDictionary *userData, SSDKContentEntity *contentEntity, NSError *error, BOOL end) {
         switch (state) {
             case SSDKResponseStateSuccess:
                 NSLog(@"成功");//成功
                 break;
             case SSDKResponseStateFail:
                 NSLog(@"--%@",error.description);
                 //失败
                 break;
             case SSDKResponseStateCancel:
                 break;
             default:
                 break;
         }
     }];
}

-(void)updateCGColors{
    
}
@end
