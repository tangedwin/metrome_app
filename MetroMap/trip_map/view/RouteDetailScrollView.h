//
//  RouteDetailScrollView.h
//  MetroMap
//
//  Created by edwin on 2019/11/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
#import "PrefixHeader.h"
#import "HttpHelper.h"
#import "MBProgressHUD+Customer.h"
#import "UIScrollView+Cutter.h"

#import "RouteModel.h"
#import "StationInfo.h"
#import "LineInfo.h"

#import "YYModel.h"

@interface RouteDetailScrollView : UIScrollView
-(instancetype)initWithFrame:(CGRect)frame route:(RouteModel*)routeInfo;
//截图
- (UIImage*)getImageWithCustomRect;
//添加到行程
-(void)collectRouteInfo;

@end

