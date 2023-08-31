//
//  MetroRouteQuery.h
//  MetroMap
//
//  Created by edwin on 2019/9/8.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RouteUtils.h"

#import "StationInfo.h"
#import "RouteInfo.h"
#import "MetroInfo.h"

#define baidu_cities_file @"baidu-cities.plist"
#define baidu_stations_file @"baidu-stations.plist"
@interface MetroRouteQuery : UIView
    @property(nonatomic, copy) void(^alertSomething)(NSInteger *type, NSString *content);
    @property(nonatomic, copy) void(^showRouteDetail)(NSInteger index);

//    @property(nonatomic,retain)MetroInfo *metroInfo;
    @property(nonatomic,retain)NSMutableArray *routeList;
    
    
    -(void)queryRoute:(NSString*)cityCode startStation:(StationInfo*)startStation endStation:(StationInfo*)endStation;
@end
