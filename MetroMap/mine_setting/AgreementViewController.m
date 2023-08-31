//
//  AgreementViewController.m
//  MetroMap
//
//  Created by edwin on 2019/10/26.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "AgreementViewController.h"

@interface AgreementViewController ()<WKNavigationDelegate, UIScrollViewDelegate, WKUIDelegate>
@property(nonatomic,retain)WKWebView *webView;

@end

@implementation AgreementViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"用户服务及隐私协议";
    [self.view addSubview:self.naviMask];
    [self.naviMask addSubview:self.backButton];
    [self createWebView];
    [self.view setBackgroundColor:dynamic_color_white];
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
    NSString *urlStr = request_agreement;
    NSURL *url = [[NSURL alloc] initWithString:urlStr];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:request];
    [self.view addSubview:_webView];
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

-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    if (@available(iOS 13.0, *)) {
        if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
            [self.webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.color=\"#FFFFFF\"" completionHandler:nil];
        }
    }
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    // trait发生了改变
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
                [self.webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.color=\"#FFFFFF\"" completionHandler:nil];
            }else{
                [self.webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.color=\"#000000\"" completionHandler:nil];
            }
        }else{
            [self.webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.color=\"#000000\"" completionHandler:nil];
        }
    } else {
        [self.webView evaluateJavaScript:@"document.getElementsByTagName('body')[0].style.color=\"#000000\"" completionHandler:nil];
    }
}
@end
