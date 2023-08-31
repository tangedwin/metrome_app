//
//  ThirdViewController.m
//  test-metro
//
//  Created by edwin on 2019/6/21.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "PreviewController.h"

@interface PreviewController()<WKNavigationDelegate>

@end

@implementation PreviewController

-(void) viewDidLoad{
    [super viewDidLoad];
    
    _viewSize = self.view.frame.size;
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = _cinfo.name;
    if(_viewSize.height>_viewSize.width){
        //竖屏
        _navBarHeight = kNavBarAndStatusBarHeight;
    }else{
        _navBarHeight = kNavBarHeight;
    }
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, _navBarHeight, _viewSize.width, _viewSize.height-_navBarHeight)];
    _webView.navigationDelegate = self;
    _webView.backgroundColor = [UIColor grayColor];
    
    
    
    
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"myMapBundle" ofType :@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    
    NSURL *url = [bundle URLForResource:_cinfo.nameCode withExtension:@"svg"];
    if(url==nil){
        url = [bundle URLForResource:_cinfo.namePdf withExtension:@"pdf"];
    }
    if(url==nil){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"数据丢失" preferredStyle:UIAlertControllerStyleAlert];
        __weak typeof(self) wkSelf = self;
        // 确定注销
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *_Nonnull action) {
            [wkSelf.navigationController popViewControllerAnimated:YES];
        }];
        
        [alert addAction:okAction];
        // 弹出对话框
        [self presentViewController:alert animated:true completion:nil];
    }
    
    _request = [NSURLRequest requestWithURL:url];
    [_webView loadRequest:_request];
    
    [self.view addSubview:_webView];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didChangeRotate:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
}

    
- (void)didChangeRotate:(NSNotification*)notice {
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait
        || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown) {
        //竖屏
    } else {
        //横屏
    }
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
    
    if(_webView!=nil){
        [_webView removeFromSuperview];
        _webView = nil;
    }
    
    _webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, _navBarHeight, _viewSize.width, _viewSize.height-_navBarHeight)];
    _webView.navigationDelegate = self;
    _webView.backgroundColor = [UIColor grayColor];
    [_webView loadRequest:_request];
    [self.view addSubview:_webView];
}

@end
