//
//  MainViewController.h
//  MetroMap
//
//  Created by edwin on 2019/8/26.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "ScreenSize.h"

#import "ViewUtils.h"
#import "ColorUtils.h"
#import "UIView+FrameChange.h"

#import "CustomerView.h"
#import "StationAlert.h"
#import "StationListView.h"

#import "MetroDataCache.h"
#import "MetroRouteQuery.h"

@interface MainViewController : UIViewController

@property(nonatomic,retain)WKWebView *webView;
    
@property(nonatomic,retain)StationAlert *stationAlertView;
    
    
@property(nonatomic,assign)CGPoint stationPoint;
@property(nonatomic,assign)NSInteger stationAlertType;


@end
