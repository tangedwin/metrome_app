//
//  AutoRouteHelper.m
//  MetroMap
//
//  Created by edwin on 2019/11/29.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "AutoRouteHelper.h"

@interface AutoRouteHelper()

@end

@implementation AutoRouteHelper

-(void)queryForRouteWithSuccess:(void(^)(NSMutableArray *routeList))success failure:(void(^)(NSString *errorInfo))failure{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:@(self.startStation.identifyCode) forKey:@"startStationId"];
    [params setObject:@(self.endStation.identifyCode) forKey:@"endStationId"];
    [[HttpHelper new] findRoute:request_route_detail params:params progress:^(NSProgress *progress) {
        
    } success:^(NSMutableDictionary *responseDic) {
        NSMutableArray *resultArray = (NSMutableArray *)responseDic;
        if(!resultArray) {
            failure(nil);
            return;
        }
        NSMutableArray *array = [NSMutableArray new];
        for(int i=0; i<resultArray.count; i++){
            RouteModel *route = [RouteModel yy_modelWithJSON:resultArray[i]];
            route.detailQueried = YES;
            [array addObject:route];
        }
        success(array);
    } failure:^(NSString *errorInfo) {
        failure(errorInfo);
    }];
}

@end
