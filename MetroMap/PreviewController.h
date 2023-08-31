//
//  ThirdViewController.h
//  test-metro
//
//  Created by edwin on 2019/6/21.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "CityInfo.h"
#import "ScreenSize.h"

@interface PreviewController : UIViewController
    
@property(nonatomic,retain)CityInfo *cinfo;
@property(nonatomic,retain) WKWebView *webView;
    
@property(nonatomic,assign)CGSize viewSize;
@property(nonatomic,assign)float navBarHeight;
    
@property(nonatomic,retain) NSURLRequest *request;

@end
