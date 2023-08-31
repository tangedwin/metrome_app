//
//  RouteHelper.m
//  MetroMap
//
//  Created by edwin on 2019/10/22.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "RouteHelper.h"

@interface RouteHelper()


@property(nonatomic, retain) CityModel *city;

@property(nonatomic, retain) StationModel *startStation;
@property(nonatomic, retain) StationModel *endStation;

@end

@implementation RouteHelper

-(instancetype)initWithCity:(CityModel*)city start:(StationModel*)startStation end:(StationModel*)endStation{
    self = [super init];
    _city = city;
    _startStation = startStation;
    _endStation = endStation;
    return self;
}

-(void)querySegmentPassBy:(NSInteger)index success:(void(^)(NSMutableArray *segments))success{
    if(success) success(nil);
}

//-(void)queryForRouteWithStart:(StationModel*)startStation withEnd:(StationModel*)endStation success:(void(^)(NSMutableArray *routeList))success failure:(void(^)(NSString *errorInfo))failure{
//    
//}

-(void)queryForRouteWithSuccess:(void(^)(NSMutableArray *routeList))success failure:(void(^)(NSString *errorInfo))failure{
    if(failure) failure(@"为找到方法");
}

@end
