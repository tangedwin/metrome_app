//
//  NewsDetailViewController.m
//  MetroMap
//
//  Created by edwin on 2019/10/26.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "NewsDetailViewController.h"
#import "GDTUnifiedBannerView.h"

@interface NewsDetailViewController ()<WKNavigationDelegate, UIScrollViewDelegate, WKUIDelegate, GDTUnifiedBannerViewDelegate>
@property(nonatomic,retain)WKWebView *webView;
@property(nonatomic,retain)NewsModel *newsInfo;
@property (nonatomic, strong) GDTUnifiedBannerView *bannerView;

@end

@implementation NewsDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.naviMask];
    [self.naviMask addSubview:self.backButton];
    
    [self createWebView];
    [self.view setBackgroundColor:dynamic_color_white];
    [self loadAdAndShow];
}

-(void)loadNewsInfo:(NewsModel*)news{
    _newsInfo = news;
    if(_webView){
        NSString *urlStr = [NSString stringWithFormat:@"%@/%@/%ld",Base_URL,request_news_detail,_newsInfo.identifyCode];
        NSLog(@"%@",urlStr);
        NSURL *url = [[NSURL alloc] initWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [_webView loadRequest:request];
        _webView.scrollView.delegate = self;
    }
    if(_newsInfo.sourceUrl){
        UIImageView *openInSafari = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"safari_icon"]];
        openInSafari.frame = CGRectMake(self.naviMask.width-fitFloat(24)-view_margin, STATUS_BAR_HEIGHT+10, fitFloat(24), fitFloat(24));
        openInSafari.userInteractionEnabled = YES;
        [openInSafari addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showInfSafari:)]];
        [self.naviMask addSubview:openInSafari];
    }
}

-(void)showInfSafari:(UITapGestureRecognizer*)tap{
    if(!_newsInfo.sourceUrl){
        [MBProgressHUD showInfo:@"跳转地址错误" detail:nil image:nil inView:nil];
        return;
    }
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:_newsInfo.sourceUrl] options: @{} completionHandler:nil];
}


-(void) createWebView{
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT) configuration:config];
    _webView.navigationDelegate = self;
    _webView.scrollView.delegate = self;
    _webView.UIDelegate = self;
    _webView.scrollView.showsVerticalScrollIndicator = YES;
    _webView.scrollView.showsHorizontalScrollIndicator = NO;
    _webView.scrollView.directionalLockEnabled = YES;
    [_webView sizeToFit];
    [_webView setOpaque:NO];
    _webView.backgroundColor = dynamic_color_white;
    if(_newsInfo) {
        NSString *urlStr = [NSString stringWithFormat:@"%@/%@/%ld",Base_URL,request_news_detail,(long)_newsInfo.identifyCode];
        NSLog(@"%@",urlStr);
        NSURL *url = [[NSURL alloc] initWithString:urlStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [_webView loadRequest:request];
    }
    [self.view addSubview:_webView];
    
    if(_bannerView) [self.view addSubview:_bannerView];
}


-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    if (@available(iOS 13.0, *)) {
        if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
            [self.webView evaluateJavaScript:@"document.getElementsByTagName('h1')[0].style.color=\"#FFFFFF\"" completionHandler:nil];
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

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return nil;
}

- (GDTUnifiedBannerView *)bannerView{
  if (!_bannerView) {
      //banner长宽比6.4:1
      CGRect rect = CGRectMake(0, ceil(SCREEN_HEIGHT-SCREEN_WIDTH/6.4), SCREEN_WIDTH, ceil(SCREEN_WIDTH/6.4));
      _bannerView = [[GDTUnifiedBannerView alloc] initWithFrame:rect appId:GDT_APP_ID placementId:GDT_BANNER_AD_ID viewController:self];
      _bannerView.animated = YES;
      _bannerView.autoSwitchInterval = 3.f;
      _bannerView.delegate = self;
  }
  return _bannerView;
}

- (void)loadAdAndShow {
    if (self.bannerView.superview) {
        [self.bannerView removeFromSuperview];
    }
    [self.view addSubview:self.bannerView];
    [self.bannerView loadAdAndShow];
}

- (IBAction)removeAd:(id)sender {
    [self.bannerView removeFromSuperview];
    self.bannerView = nil;
}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    // trait发生了改变
    BOOL darkMode = NO;
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
                darkMode = YES;
                [self.webView evaluateJavaScript:@"document.getElementsByTagName('h1')[0].style.color=\"#FFFFFF\"" completionHandler:nil];
            }
        }
    }
    if(!darkMode) {
        [self.webView evaluateJavaScript:@"document.getElementsByTagName('h1')[0].style.color=\"#001627\"" completionHandler:nil];
    }
}
@end
