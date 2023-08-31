//
//  RouteCollectionView.h
//  MetroMap
//
//  Created by edwin on 2019/10/11.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrefixHeader.h"
#import "UIView+Cutter.h"

#import "RouteModel.h"
#import "StationInfo.h"
#import "LineInfo.h"
#import "RouteDetailView.h"
#import "RouteDetailScrollView.h"

@interface RouteCollectionView : UICollectionView
@property(nonatomic,copy) void(^switchSelected)(NSInteger selectedIndex);
@property(nonatomic,copy) void(^showRouteDetail)(NSInteger selectedIndex);

@property (nonatomic, retain) UILabel *detailLabel;

-(instancetype)initWithFrame:(CGRect)frame routes:(NSMutableArray*)routes;

-(void)hideDetailView:(BOOL)hide;
-(void)resetViewHeight:(CGFloat)height;

- (UIImage*)getImageWithCustomRect;
- (RouteModel*) getCurentRouteInfo;
-(void)collectRouteInfo;
@end

