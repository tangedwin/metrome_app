//
//  SplashAdLaunch.m
//  MetroMap
//
//  Created by edwin on 2019/11/29.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "SplashAdLaunch.h"
#import "GDTSplashAd.h"
#import "PrefixHeader.h"


#define delaytime 5
@interface SplashAdLaunch ()<GDTSplashAdDelegate>
@property (nonatomic, strong) UIWindow* window;
@property (nonatomic, assign) NSInteger downCount;
@property (nonatomic, weak) UIButton* downCountButton;
@property (strong, nonatomic) GDTSplashAd *splash;
@property (retain, nonatomic) UIView *bottomView;
@property (retain, nonatomic) UIImageView *imageView;
@end

@implementation SplashAdLaunch
///在load 方法中，启动监听，可以做到无注入
+ (void)load
{
    [self shareInstance];
}
+ (instancetype)shareInstance
{
    static id instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        ///如果是没啥经验的开发，请不要在初始化的代码里面做别的事，防止对主线程的卡顿，和 其他情况
        
        ///应用启动, 首次开屏广告
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidFinishLaunchingNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            ///要等DidFinished方法结束后才能初始化UIWindow，不然会检测是否有rootViewController
            [self checkAD];
        }];
        ///进入后台
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationDidEnterBackgroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
            [self request];
        }];
        ///后台启动,二次开屏广告
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note) {
//            [self checkAD];
        }];
    }
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidFinishLaunchingNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)request
{
    ///.... 请求新的广告数据
}
- (void)checkAD
{
    ///如果有则显示，无则请求， 下次启动再显示。
    ///我们这里都当做有
    [self show];
}
- (void)show
{
    ///初始化一个Window， 做到对业务视图无干扰。
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.rootViewController = [UIViewController new];
    self.window.rootViewController.view.backgroundColor = dynamic_color_white;
    self.window.rootViewController.view.userInteractionEnabled = NO;
    
    ///设置为最顶层，防止 AlertView 等弹窗的覆盖
    self.window.windowLevel = UIWindowLevelStatusBar + 1;
    
    ///默认为YES，当你设置为NO时，这个Window就会显示了
    self.window.hidden = NO;
    self.window.alpha = 1;
    
    [self setupSubviews:self.window];
    [self adPrepare];
    ///防止释放，显示完后  要手动设置为 nil
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delaytime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self hide];
    });
}

- (void)hide{
    if(!self.window) return;
    ///来个渐显动画
    [UIView animateWithDuration:0.3 animations:^{
        if(self.window) self.window.alpha = 0;
    } completion:^(BOOL finished) {
        [self.window.subviews.copy enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        if(self.window) self.window.hidden = YES;
        if(self.window) self.window = nil;
    }];
}

///初始化显示的视图， 可以挪到具
- (void)setupSubviews:(UIWindow*)window{
    ///随便写写
    _imageView = [[UIImageView alloc] initWithFrame:window.bounds];
    _imageView.image = [UIImage imageNamed:@"launch_backImage"];
    _imageView.contentMode = UIViewContentModeScaleAspectFill;
    [window addSubview:_imageView];
}


-(void)adPrepare{
    [GDTSplashAd preloadSplashOrderWithAppId:GDT_APP_ID placementId:GDT_SLASH_AD_ID];
    self.splash = [[GDTSplashAd alloc] initWithAppId:GDT_APP_ID placementId:GDT_SLASH_AD_ID];
    self.splash.delegate = self; //设置代理
    self.splash.backgroundImage = [UIImage imageNamed:@"LaunchImage"];
    self.splash.fetchDelay = delaytime; //开发者可以设置开屏拉取时间，超时则放弃展示
    //［可选］拉取并展示全屏开屏广告
//    [self.splash loadAdAndShowInWindow:self.window];
    //设置开屏底部自定义LogoView，展示半屏开屏广告
    _bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 129)];
    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"splash_ad_bottom"]];
    logo.frame = CGRectMake((SCREEN_WIDTH-128)/2, 37, 128, 53);
    [_bottomView addSubview:logo];
    logo.center = _bottomView.center;
    _bottomView.backgroundColor = dynamic_color_white;
    
    [self.splash loadAdAndShowInWindow:self.window withBottomView:_bottomView];
        
}

-(void)splashAdSuccessPresentScreen:(GDTSplashAd *)splashAd{
    [_imageView removeFromSuperview];
}

-(void)splashAdWillClosed:(GDTSplashAd *)splashAd{
    [self hide];
}

-(void)splashAdWillDismissFullScreenModal:(GDTSplashAd *)splashAd{
    [self hide];
}
@end
