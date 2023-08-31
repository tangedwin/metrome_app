//
//  HotCityListView.h
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
#import "PrefixHeader.h"
#import "YYModel.h"
#import "ScrollSignView.h"

#import "StationModel.h"

#import "HttpHelper.h"

@interface StationNearByView : UICollectionView
@property(nonatomic,copy) void(^showTimetable)(StationModel *station);
@property(nonatomic,copy) void(^showStationInfo)(StationModel *station);
@property(nonatomic,copy) void(^showExit)(StationModel *station);

-(instancetype)initWithFrame:(CGRect)frame nearbyStation:(StationModel*)station distance:(NSInteger)distance;

-(void)updateCGColors;
@end

