//
//  AppDelegate.m
//  MetroMap
//
//  Created by edwin on 2019/6/22.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "AppDelegate.h"
#import <ShareSDK/ShareSDK.h>
#import <MobPush/MobPush.h>
#import <SMS_SDK/SMSSDK+ContactFriends.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "ZYNetworkAccessibity.h"
//#import "GDTSplashAd.h"
#import "HomeViewController.h"
#import "DiscoverViewController.h"
#import "MineViewController.h"
#import "MainMapViewController.h"
#import "MessageViewController.h"
@interface AppDelegate ()<UISplitViewControllerDelegate>
//@property (strong, nonatomic) GDTSplashAd *splash;
//@property (retain, nonatomic) UIView *bottomView;
@property (retain, nonatomic) UITabBarController *masterTabbarController;
@property (retain, nonatomic) MineViewController *mineController;
@property (retain, nonatomic) NSCondition *condition;

@end

static AppDelegate *__delegate = nil;
@implementation AppDelegate
AppDelegate *myDelegate(void){
    return __delegate;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    [AMapServices sharedServices].apiKey = AMAP_API_KEY;
    [ZYNetworkAccessibity start];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChanged:) name:ZYNetworkAccessibityChangedNotification object:nil];
//    [self adPrepare];
    UITabBarController *tabbar = [[UITabBarController alloc] init];
    HomeViewController *homeView = [[HomeViewController alloc] init];
    UINavigationController *nav0 =[[UINavigationController alloc] initWithRootViewController:homeView];
    nav0.tabBarItem.title = @"首页";
    nav0.tabBarItem.image = [UIImage imageNamed:@"shouye_tab"];
    nav0.tabBarItem.selectedImage = [[UIImage imageNamed:@"shouye_tab_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [nav0.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:main_color_blue} forState:UIControlStateSelected];
    [tabbar addChildViewController:nav0];
    
    MainMapViewController *mapView = [[MainMapViewController alloc] init];
    UINavigationController *nav1 =[[UINavigationController alloc] initWithRootViewController:mapView];
    nav1.tabBarItem.title = @"出行";
    nav1.tabBarItem.image = [UIImage imageNamed:@"chuxing_tab"];
    nav1.tabBarItem.selectedImage = [[UIImage imageNamed:@"chuxing_tab_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [nav1.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:main_color_blue} forState:UIControlStateSelected];
    [tabbar addChildViewController:nav1];
    
    DiscoverViewController *discoverView = [[DiscoverViewController alloc] init];
    UINavigationController *nav2 =[[UINavigationController alloc] initWithRootViewController:discoverView];
    nav2.tabBarItem.title = @"发现";
    nav2.tabBarItem.image = [UIImage imageNamed:@"faxian_tab"];
    nav2.tabBarItem.selectedImage = [[UIImage imageNamed:@"faxian_tab_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [nav2.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:main_color_blue} forState:UIControlStateSelected];
    [tabbar addChildViewController:nav2];
    
    MineViewController *mine = [[MineViewController alloc] init];
    UINavigationController *nav3 =[[UINavigationController alloc] initWithRootViewController:mine];
    nav3.tabBarItem.title = @"我的";
    nav3.tabBarItem.image = [UIImage imageNamed:@"wode_tab"];
    nav3.tabBarItem.selectedImage = [[UIImage imageNamed:@"wode_tab_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    [nav3.tabBarItem setTitleTextAttributes:@{NSForegroundColorAttributeName:main_color_blue} forState:UIControlStateSelected];
    [tabbar addChildViewController:nav3];
    
    [_window setRootViewController:tabbar];
    
    __delegate = self;
    _mineController = mine;
    _masterTabbarController = tabbar;
    
    [self.window makeKeyAndVisible];
    
    [SMSSDK enableAppContactFriends:NO];
    [ShareSDK registPlatforms:^(SSDKRegister *platformsRegister) {
        //QQ
        [platformsRegister setupQQWithAppId:QQ_APP_ID appkey:QQ_APP_KEY];
        //微信
//        [platformsRegister setupWeChatWithAppId:WEICHAT_APP_ID appSecret:WEICHAT_APP_SECRET universalLink:UNIVERSAL_LINK];
        [platformsRegister setupWeChatWithAppId:WEICHAT_APP_ID appSecret:WEICHAT_APP_SECRET];
        //新浪
        [platformsRegister setupSinaWeiboWithAppkey:WEIBO_APP_KEY appSecret:WEIBO_APP_SECRET redirectUrl:WEIBO_REDIRECT_URL];
    }];
    // 启动图片延时: 1秒
//    [self sleepForSplashAd:2];
    [NSThread sleepForTimeInterval:1];
    [self pushPrepare];

    return YES;
}


//- (void)showSplashView{
//    UIImageView *splashView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"main_logo"]];
//    splashView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
//    [self.window addSubview:splashView];
//    [self performSelector:@selector(romoveSplashView:) withObject:splashView afterDelay:10.0f];
//}
//
//-(void)romoveSplashView:(UIImageView*)splashView{
//    if(!NSThread.currentThread.isMainThread){
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if(splashView) [splashView removeFromSuperview];
//        });
//    }else{
//        if(splashView) [splashView removeFromSuperview];
//    }
//}

//-(void)sleepForSplashAd:(NSInteger)second {
//    _condition = [NSCondition new];
//    [_condition lock];
//    NSDate *waitUntilDate = [NSDate dateWithTimeIntervalSinceNow:second];
//    [_condition waitUntilDate:waitUntilDate];
//    [_condition unlock];
//}
//-(void)invokeSleep {
//    [_condition lock];
//    [_condition signal];
//    [_condition unlock];
//}

- (void)networkChanged:(NSNotification *)notification {
    ZYNetworkAccessibleState state = ZYNetworkAccessibity.currentState;
    if (state == ZYNetworkRestricted) {
        NSLog(@"网络权限被关闭");
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"网络未开启" message:@"网络权限被关闭，将无法查询地铁线路" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:confirmAction];
        UIViewController *alertVC = [[UIViewController alloc]init];
        [[UIApplication sharedApplication].keyWindow  addSubview:alertVC.view];
        [alertVC presentViewController:alertController animated:YES completion:^{
            [alertVC.view removeFromSuperview];
        }];
    }
}

-(void)pushPrepare{
    #ifdef DEBUG
        [MobPush setAPNsForProduction:NO];
    #else
        [MobPush setAPNsForProduction:YES];
    #endif
    //MobPush推送设置（获得角标、声音、弹框提醒权限）
    MPushNotificationConfiguration *configuration = [[MPushNotificationConfiguration alloc] init];
    configuration.types = MPushAuthorizationOptionsBadge | MPushAuthorizationOptionsSound | MPushAuthorizationOptionsAlert;
    [MobPush setupNotification:configuration];
    [MobPush getRegistrationID:^(NSString *registrationID, NSError *error) {
        NSLog(@"registrationID = %@--error = %@", registrationID, error);
        if(registrationID) [[NSUserDefaults standardUserDefaults] setObject:registrationID forKey:USER_MESSAGE_REGISTER_ID_KEY];
    }];
        
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMessage:) name:MobPushDidReceiveMessageNotification object:nil];
}

//-(void)adPrepare{
//    [GDTSplashAd preloadSplashOrderWithAppId:GDT_APP_ID placementId:GDT_SLASH_AD_ID];
//    self.splash = [[GDTSplashAd alloc] initWithAppId:GDT_APP_ID placementId:GDT_SLASH_AD_ID];
//    self.splash.delegate = self; //设置代理
//    self.splash.backgroundImage = [UIImage imageNamed:@"LaunchImage"];
//    self.splash.fetchDelay = 3; //开发者可以设置开屏拉取时间，超时则放弃展示
//    //［可选］拉取并展示全屏开屏广告
////    [self.splash loadAdAndShowInWindow:self.window];
//    //设置开屏底部自定义LogoView，展示半屏开屏广告
//    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 129)];
//    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"splash_ad_bottom"]];
//    logo.frame = CGRectMake((SCREEN_WIDTH-128)/2, 37, 128, 53);
//    [_bottomView addSubview:logo];
//    logo.center = _bottomView.center;
//    _bottomView.backgroundColor = dynamic_color_white;
//
//    [self.splash loadAdAndShowInWindow:self.window withBottomView:_bottomView];
//
//}
//-(void)splashAdDidLoad:(GDTSplashAd *)splashAd{
//    NSLog(@"---------->%s--------->splashAdDidLoad",__FUNCTION__);
//
//}
//
//- (void)splashAdFailToPresent:(GDTSplashAd *)splashAd withError:(NSError *)error{
//    NSLog(@"---------->%s--------->%@",__FUNCTION__,error);
////    [self invokeSleep];
//}
//
//- (void)splashAdSuccessPresentScreen:(GDTSplashAd *)splashAd{
//    NSLog(@"---------->%s",__FUNCTION__);
////    [self invokeSleep];
//}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    //程序进入前台时,清除角标，但不清空通知栏消息(开发者根据业务需求，自行调用)
    //注意：不建议在进入后台通知(applicationDidEnterBackground:)中调用此方法，原因进入后台将角标清空结果无法通过网络同步到服务器
    [MobPush clearBadge];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}



// 收到通知回调
- (void)didReceiveMessage:(NSNotification *)notification{
    MPushMessage *message = notification.object;
        
    switch (message.messageType){
        case MPushMessageTypeCustom:{// 自定义消息回调
//            [[AlertUtils new] alertWithConfirm:@"自定义消息" content:message.msgInfo.description];
//            [self requestService:message type:@"自定义消息"];
        }
            break;
        case MPushMessageTypeAPNs:{// APNs回调
//            [[AlertUtils new] alertWithConfirm:@"APNs回调" content:message.msgInfo.description];
//            [self requestService:message type:@"APNs回调"];
        }
            break;
        case MPushMessageTypeLocal:{// 本地通知回调
//            [[AlertUtils new] alertWithConfirm:@"本地通知回调" content:body];
//            [self requestService:message type:@"本地通知回调"];
        }
            break;
        case MPushMessageTypeClicked:{// 点击通知回调
            if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive){ // 前台
//                [[AlertUtils new] alertWithConfirm:@"点击通知回调" content:message];
//                [self requestService:message type:@"点击通知回调"];
                [self jumpToMessageView];
            } else{ // 后台
//                [[AlertUtils new] alertWithConfirm:@"点击通知回调---后台" content:message];
//                [self requestService:message type:@"点击通知回调---后台"];
                [self jumpToMessageView];
            }
        }
            break;
        default:
//            [self requestService:message type:@"未知类型哈哈"];
            break;
    }
}

-(void)jumpToMessageView{
    UITabBarController *tabVC = myDelegate().masterTabbarController;
    [tabVC setSelectedIndex:3];
    MineViewController *mineVC = myDelegate().mineController;
    MessageViewController *mview = [[MessageViewController alloc] init];
    mview.hidesBottomBarWhenPushed = YES;
    [mineVC.navigationController pushViewController:mview animated:YES];
}

//-(void)requestService:(MPushMessage*)message type:(NSString*)type{
//    NSMutableDictionary *params = [NSMutableDictionary new];
//    NSMutableDictionary *param = [message yy_modelToJSONObject];
//    [params setObject:param forKey:@"message"];
//    [params setObject:type forKey:@"type"];
//    [[HttpHelper new] submit:@"/metro/data/test" params:params progress:^(NSProgress *progress) {
//
//    } success:^(NSMutableDictionary *responseDic) {
//
//    } failure:^(NSString *errorInfo) {
//
//    }];
//}

//#pragma mark 注册通知
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(nonnull NSData *)deviceToken
{

    NSLog(@"deviceToken:%@",deviceToken);
}
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"%@", userInfo);
}
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"Registfail，注册推送失败原因%@",error);
}

//-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler{
//NSLog(@"----->Userinfo %@",notification.request.content.userInfo);
//
////功能：可设置是否在应用内弹出通知
//completionHandler(UNNotificationPresentationOptionAlert);
//}
//
////点击推送消息后回调
//-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void(^)())completionHandler{
//NSLog(@"-------->Userinfo %@",response.notification.request.content.userInfo);
//}
@end
