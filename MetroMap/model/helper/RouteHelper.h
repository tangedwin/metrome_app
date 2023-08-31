//
//  RouteHelper.h
//  MetroMap
//
//  Created by edwin on 2019/10/22.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HttpHelper.h"

#import "CityModel.h"
#import "LineModel.h"
#import "RouteModel.h"
#import "RouteSegmentModel.h"

@interface RouteHelper : NSObject


@property(nonatomic, readonly) CityModel *city;
@property(nonatomic, readonly) StationModel *startStation;
@property(nonatomic, readonly) StationModel *endStation;

@property(nonatomic, retain) NSMutableArray *routeList;
//@property(nonatomic, retain) RouteModel *selectedRoute;

-(instancetype)initWithCity:(CityModel*)city start:(StationModel*)startStation end:(StationModel*)endStation;

-(void)querySegmentPassBy:(NSInteger)index success:(void(^)(NSMutableArray *segments))success;

-(void)queryForRouteWithSuccess:(void(^)(NSMutableArray *routeList))success failure:(void(^)(NSString *errorInfo))failure;

@end

