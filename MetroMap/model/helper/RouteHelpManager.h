//
//  RouteHelpManager.h
//  MetroMap
//
//  Created by edwin on 2019/11/29.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CityModel.h"
#import "StationModel.h"
#import "RouteModel.h"

@interface RouteHelpManager : NSObject
@property(nonatomic, retain) NSMutableArray *routeList;
@property(nonatomic, readonly) StationModel *startStation;
@property(nonatomic, readonly) StationModel *endStation;


-(instancetype)initWithCity:(CityModel*)city start:(StationModel*)startStation end:(StationModel*)endStation;


-(void) getRoutesCountWithSuccess:(void(^)(NSInteger count))success;
-(void) getRouteAtIndex:(NSInteger)index success:(void(^)(RouteModel *routeInfo))success;
@end

