//
//  RouteInfoView.h
//  MetroMap
//
//  Created by edwin on 2019/10/11.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrefixHeader.h"
#import "ScrollSignView.h"
#import "RouteCollectionView.h"

#import "RouteModel.h"
#import "StationInfo.h"
#import "LineInfo.h"
#import "RouteHelpManager.h"

@interface RouteInfoView : UIView
@property (nonatomic, retain) RouteHelpManager *routeHelper;

@property(nonatomic,copy) void(^closeRouteSearch)(void);
@property(nonatomic,copy) void(^switchSelected)(NSInteger index);
@property(nonatomic,copy) void(^shareRouteImage)(UIImage* image, RouteModel *routeInfo);
@property(nonatomic,copy) void(^feedbackRouteInfo)(RouteModel *routeInfo);

-(void)loadData;

-(void)updateCGColors;

@end

