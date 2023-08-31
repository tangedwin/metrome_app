//
//  UserSettingView.m
//  MetroMap
//
//  Created by edwin on 2019/10/8.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "UserSettingView.h"

@interface UserSettingView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, retain) UICollectionViewFlowLayout *fallLayout;
@property (nonatomic, retain) UserModel *userInfo;
@property (nonatomic, retain) UISwitch *notifycationSwi;
@property (nonatomic, assign) BOOL notifycationOpened;

@end


static NSString * const user_setting_id = @"user_setting";
@implementation UserSettingView

-(instancetype)initWithFrame:(CGRect)frame{
    // 创建布局
    _fallLayout = [[UICollectionViewFlowLayout alloc]init];
    _fallLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self = [super initWithFrame:frame collectionViewLayout:_fallLayout];
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:user_setting_id];
    self.dataSource = self;
    self.delegate = self;
    self.allowsSelection = NO;
    self.alwaysBounceVertical = YES;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    self.backgroundColor = dynamic_color_lightgray2;
    self.showsVerticalScrollIndicator = NO;
    
    self.userInfo = [UserModel createFakeModel];
    
    [self checkNotified];
    return self;
}

-(void)reloadSettingData{
    [self checkNotified];
    [self reloadData];
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //根据注册标记查找cell
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:user_setting_id forIndexPath:indexPath];
    if(cell.contentView.subviews) for(UIView *sview in cell.contentView.subviews) [sview removeFromSuperview];
    if(indexPath.section==0){
        if(indexPath.item==0) [self createTableLabel:@"选择城市" line:YES cell:cell indexPath:indexPath];
        else if(indexPath.item==1) [self createTableLabel:@"离线地铁" line:NO cell:cell indexPath:indexPath];
    }else if(indexPath.section==1){
        if(indexPath.item==0) [self createNotifacationTableCell:cell indexPath:indexPath];
        else if(indexPath.item==1) [self createTableLabel:@"清理缓存" line:NO cell:cell indexPath:indexPath];
    }else if(indexPath.section==2){
        if(indexPath.item==0) [self createTableLabel:@"常用地址" line:YES cell:cell indexPath:indexPath];
//        else if(indexPath.item==1) [self createTableLabel:@"开通会员" line:NO cell:cell indexPath:indexPath];
    }else if(indexPath.section==3){
        if(indexPath.item==0) [self createTableLabel:@"意见反馈" line:YES cell:cell indexPath:indexPath];
        else if(indexPath.item==1) [self createTableLabel:@"QQ 交流群" line:YES cell:cell indexPath:indexPath];
        else if(indexPath.item==2) [self createTableLabel:@"去评分" line:NO cell:cell indexPath:indexPath];
    }else if(indexPath.section==4){
        if(indexPath.item==0){
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 16, SCREEN_WIDTH, 20)];
            titleLabel.font = main_font_small;
            titleLabel.textColor = main_color_pink;
            titleLabel.textAlignment = NSTextAlignmentCenter;
            
            NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_USER_ID_KEY];
            if(userId){
                titleLabel.text = @"退出登录";
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(logout:)];
                titleLabel.userInteractionEnabled = YES;
                [titleLabel addGestureRecognizer:tap];
            }else{
                titleLabel.text = @"登录";
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(login:)];
                titleLabel.userInteractionEnabled = YES;
                [titleLabel addGestureRecognizer:tap];
            }
            [cell.contentView addSubview:titleLabel];
        }
    }
    cell.backgroundColor = dynamic_color_white;
    return cell;
}

-(void)changeNotifycationStatus:(UISwitch *)swi{
    swi.on = !swi.isOn;
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [application openURL:URL options:@{} completionHandler:nil];
}

-(void)createNotifacationTableCell:(UICollectionViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    CGFloat width = SCREEN_WIDTH-view_margin;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(view_margin, 0, width, 52)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 16, 100, 20)];
    titleLabel.font = main_font_small;
    titleLabel.textColor = dynamic_color_black;
    titleLabel.text = @"消息通知";
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [view addSubview:titleLabel];
    
    CALayer *viewBorder = [CALayer layer];
    viewBorder.frame = CGRectMake(0, view.height, view.width, 1);
    viewBorder.backgroundColor = dynamic_color_lightgray.CGColor;
    viewBorder.opacity = 0.5;
    [view.layer addSublayer:viewBorder];
        
    _notifycationSwi = [[UISwitch alloc]initWithFrame:CGRectMake(view.width-51-view_margin, (52-31)/2, 51, 31)];
//    _notifycationSwi.tintColor = main_color_blue;
//    _notifycationSwi.onTintColor = main_color_blue;
    _notifycationSwi.userInteractionEnabled = YES;
    [_notifycationSwi addTarget:self action:@selector(changeNotifycationStatus:) forControlEvents:UIControlEventValueChanged];
    _notifycationSwi.on = _notifycationOpened;
    [view addSubview:_notifycationSwi];
    [cell.contentView addSubview:view];
}

-(void)createTableLabel:(NSString*)title line:(BOOL)showLine cell:(UICollectionViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    CGFloat width = SCREEN_WIDTH-view_margin;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(view_margin, 0, width, 52)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 16, 100, 20)];
    titleLabel.font = main_font_small;
    titleLabel.textColor = dynamic_color_black;
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [view addSubview:titleLabel];
    
    UIImageView *nextButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navi_right_big"]];
    nextButton.frame = CGRectMake(view.width-view_margin-15, (52-15)/2, 15, 15);
    [view addSubview:nextButton];
    [cell.contentView addSubview:view];
    
    if(showLine){
        CALayer *viewBorder = [CALayer layer];
        viewBorder.frame = CGRectMake(0, view.height, view.width, 1);
        viewBorder.backgroundColor = dynamic_color_lightgray.CGColor;
        viewBorder.opacity = 0.5;
        [view.layer addSublayer:viewBorder];
    }
    
    if([@"清理缓存" isEqualToString:title]){
        long long cacheSize = [CityZipUtils getCacheSize];
        NSString *sizeStr = @"";
        if(cacheSize/(1024*1024)>=1){
            sizeStr = [NSString stringWithFormat:@"%.2f M", (float)cacheSize/(1024*1024)];
        }else{
            sizeStr = [NSString stringWithFormat:@"%.2f KB", (float)cacheSize/1024];
        }

        UILabel *sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(view.width-33-180, (view.height-20)/2, 180, 20)];
        sizeLabel.font = main_font_small;
        sizeLabel.textColor = dynamic_color_gray;
        sizeLabel.text = sizeStr;
        sizeLabel.textAlignment = NSTextAlignmentRight;
        [view addSubview:sizeLabel];
    }else if([@"QQ 交流群" isEqualToString:title]){
        UILabel *sizeLabel = [[UILabel alloc] initWithFrame:CGRectMake(view.width-33-180, (view.height-20)/2, 180, 20)];
        sizeLabel.font = main_font_small;
        sizeLabel.textColor = dynamic_color_gray;
        sizeLabel.text = qqNumber;
        sizeLabel.textAlignment = NSTextAlignmentRight;
        [view addSubview:sizeLabel];
    }
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTap:)];
    view.userInteractionEnabled = YES;
    view.tag = indexPath.item + indexPath.section*10;
    [view addGestureRecognizer:tap];
}


-(void)menuTap:(UITapGestureRecognizer*)tap{
    NSInteger section = tap.view.tag/10;
    NSInteger item = tap.view.tag%10;
    if(section==0 && item==0){
        CityCollectionViewController *ccVC = [CityCollectionViewController new];
        ccVC.type = 1;
        ccVC.hidesBottomBarWhenPushed = YES;
        [self.viewDelegate pushViewController:ccVC animated:YES];
    }else if(section==0 && item==1){
        CityCollectionViewController *ccVC = [CityCollectionViewController new];
        ccVC.type = 2;
        ccVC.hidesBottomBarWhenPushed = YES;
        [self.viewDelegate pushViewController:ccVC animated:YES];
    }else if(section==1 && item==0){
    }else if(section==1 && item==1){
        MBProgressHUD *hud = [MBProgressHUD showWaitingWithText:@"正在清理缓存" image:nil inView:nil];
        [CityZipUtils cleanAllCache];
        
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:SELECTED_CITY_ID_KEY];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:SELECTED_CITY_NAME_KEY];
        
        [hud showCustomView:@"完成清理" detail:nil image:nil];
        [self reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:1 inSection:1]]];
    }else if(section==2 && item==0){
        [self loadCommenAddress];
    }else if(section==2 && item==1){
        [MBProgressHUD showInfo:@"暂未开通" detail:nil image:nil inView:nil];
    }else if(section==3 && item==0){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat: @"mailto:%@",email]] options:@{} completionHandler:^(BOOL success) {
        }];
    }else if(section==3 && item==1){
        NSString *urlStr = [NSString stringWithFormat:@"mqqapi://card/show_pslcard?src_type=internal&version=1&uin=%@&key=%@&card_type=group&source=external", qqNumber, qqKey];
            NSURL *url = [NSURL URLWithString:urlStr];
            if([[UIApplication sharedApplication] canOpenURL:url]){
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success){
                    
                }];
            }
    }else if(section==3 && item==2){
        #if __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_11_0
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_OPEN_EVALUATE_AFTER_IOS11] options:@{} completionHandler:^(BOOL success) {
        }];
        #else
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:APP_OPEN_EVALUATE] options:@{} completionHandler:^(BOOL success) {
        }];
        #endif
    }
}


-(void)login:(UITapGestureRecognizer*)tap{
    LoginViewController *loginVC = [[LoginViewController alloc] init];
    loginVC.hidesBottomBarWhenPushed = YES;
    [self.viewDelegate pushViewController:loginVC animated:YES];
}


-(void)logout:(UITapGestureRecognizer*)tap{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_USER_ID_KEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_USER_TOKEN_KEY];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_USER_KEY];
    [[NSUserDefaults standardUserDefaults] setObject:LOGIN_USER_TYPE_TOURIST forKey:LOGIN_USER_TYPE_KEY];
    [self reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:0 inSection:4]]];
}


//设置cell的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(SCREEN_WIDTH, 53);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

//设置section间隔
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    //分别为上、左、下、右
    return UIEdgeInsetsMake(0, 0, 12, 0);
}

//返回列表分组数，默认为1
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 5;
}

//返回列表每个分组section拥有cell行数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(section==0) return 2;
    else if(section==1) return 2;
    else if(section==2) return 1;
    else if(section==3) return 3;
    else if(section==4) return 1;
    return 0;
}





-(void)checkNotified{
    __weak typeof(self) wkSelf = self;
    if(@available(iOS 10.0, *)){
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            if ([NSThread isMainThread]) {
                if(settings.authorizationStatus == UNAuthorizationStatusAuthorized){
                    wkSelf.notifycationOpened = YES;
                    if(wkSelf.notifycationSwi) wkSelf.notifycationSwi.on = YES;
                }else{
                    wkSelf.notifycationOpened = NO;
                    if(wkSelf.notifycationSwi) wkSelf.notifycationSwi.on = NO;
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(settings.authorizationStatus == UNAuthorizationStatusAuthorized){
                        wkSelf.notifycationOpened = YES;
                        if(wkSelf.notifycationSwi) wkSelf.notifycationSwi.on = YES;
                    }else{
                        wkSelf.notifycationOpened = NO;
                        if(wkSelf.notifycationSwi) wkSelf.notifycationSwi.on = NO;
                    }
                });
            }
        }];
    }
}


-(void)loadCommenAddress{
    __weak typeof(self) wkSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary new];
    [[HttpHelper new] findList:request_commen_address_collect params:params page:0 progress:^(NSProgress *progress) {
    } success:^(NSMutableDictionary *responseDic) {
        NSMutableArray *resultArray = (NSMutableArray *)[responseDic mutableArrayValueForKey:@"list"];
        if(!resultArray) return;
        NSMutableArray *addressCollects = [NSMutableArray new];
        for(int i=0; i<resultArray.count; i++){
            [addressCollects addObject:[AddressModel yy_modelWithJSON:resultArray[i]]];
        }
        CommenAddressViewController *caVC = [[CommenAddressViewController alloc] initWithAddressArray:addressCollects];
        caVC.hidesBottomBarWhenPushed = YES;
        [wkSelf.viewDelegate pushViewController:caVC animated:YES];
    } failure:^(NSString *errorInfo) {
    }];
}

@end
