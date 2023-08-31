//
//  RouteInfo.h
//  test-metro
//
//  Created by edwin on 2019/6/18.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetroLineInfo.h"

@interface RouteInfo : NSObject

@property (nonatomic, retain) NSNumber *distance;
@property (nonatomic, retain) NSNumber *price;
@property (nonatomic, retain) NSNumber *time;

@property (nonatomic, retain) NSMutableArray *routeFrags;
@property (nonatomic, retain) NSMutableArray *lineUids;
//站点坐标
@property (nonatomic, retain) NSMutableArray *routeStationLocations;

@end


@interface RouteFrag : NSObject

@property (nonatomic, retain) NSNumber *distance;
@property (nonatomic, retain) NSNumber *stationNum;
@property (nonatomic, retain) NSNumber *time;

@property (nonatomic, retain) NSString *startStationName;
@property (nonatomic, retain) NSString *startStationUid;
@property (nonatomic, retain) NSString *endStationName;
@property (nonatomic, retain) NSString *endStationUid;
@property (nonatomic, retain) NSString *lineName;
@property (nonatomic, retain) NSString *lineUid;
//首末班车时间
@property (nonatomic, retain) NSString *startTime;
@property (nonatomic, retain) NSString *endTime;

@property (nonatomic, retain) NSString *lineDirection;
@property (nonatomic, retain) MetroLineInfo *line;

@end
