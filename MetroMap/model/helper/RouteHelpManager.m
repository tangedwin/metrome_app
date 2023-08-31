//
//  RouteHelpManager.m
//  MetroMap
//
//  Created by edwin on 2019/11/29.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "RouteHelpManager.h"
#import "BaiduRouteHelper.h"
#import "AutoRouteHelper.h"


@interface RouteHelpManager()


@property(nonatomic, assign) BOOL autoQuery;
@property(nonatomic, assign) BOOL querying;

@property(nonatomic, retain) BaiduRouteHelper *baiduRouteHelper;
@property(nonatomic, retain) AutoRouteHelper *autoRouteHelper;
@end


@implementation RouteHelpManager


-(instancetype)initWithCity:(CityModel*)city start:(StationModel*)startStation end:(StationModel*)endStation{
    self = [super init];
    _startStation = startStation;
    _endStation = endStation;
    _baiduRouteHelper = [[BaiduRouteHelper alloc] initWithCity:city start:startStation end:endStation];
    _autoRouteHelper = [[AutoRouteHelper alloc] initWithCity:city start:startStation end:endStation];
    [self queryRouteList];
    return self;
}

//获取路径数量
-(void) getRoutesCountWithSuccess:(void(^)(NSInteger count))success{
    if(success) [self getRoutesCountWithSuccess:success times:0];
}

//获取指定路径
-(void) getRouteAtIndex:(NSInteger)index success:(void(^)(RouteModel *routeInfo))success{
    if(!success) return;
    if(_routeList && _routeList.count>index){
        RouteModel *route = _routeList[index];
        if(route.detailQueried) success(route);
        else if(_baiduRouteHelper && !_autoQuery){
            [_baiduRouteHelper querySegmentPassBy:index success:^(NSMutableArray *segments) {
                route.segments = segments;
                route.detailQueried = YES;
                success(route);
            }];
        }else if(_autoQuery && _autoQuery){
            [_autoRouteHelper querySegmentPassBy:index success:^(NSMutableArray *segments) {
                route.segments = segments;
                route.detailQueried = YES;
                success(route);
            }];
        }else{
            success(nil);
        }
    }else{
        success(nil);
    }
}


-(void)queryRouteList{
//    if(arc4random()%10>9){
//        [self queryRouteListFromBaidu:YES];
//    }else{
        //1/10几率请求后台
        [self queryAutoRouteList:YES];
//    }
}

-(void)queryRouteListFromBaidu:(BOOL)recheckIfFail{
    _querying = YES;
    __weak typeof(self) wkSelf = self;
    [_baiduRouteHelper queryForRouteWithSuccess:^(NSMutableArray *routeList) {
        wkSelf.routeList = routeList;
        wkSelf.querying = NO;
    } failure:^(NSString *errorInfo) {
        if(recheckIfFail) [wkSelf queryAutoRouteList:NO];
        else wkSelf.querying = NO;
    }];
}

-(void)queryAutoRouteList:(BOOL)recheckIfFail{
    _querying = YES;
    __weak typeof(self) wkSelf = self;
    [_autoRouteHelper queryForRouteWithSuccess:^(NSMutableArray *routeList) {
        wkSelf.routeList = routeList;
        wkSelf.querying = NO;
        wkSelf.autoQuery = YES;
    } failure:^(NSString *errorInfo) {
        if(recheckIfFail) [wkSelf queryRouteListFromBaidu:NO];
        else wkSelf.querying = NO;
    }];
}


-(void) getRoutesCountWithSuccess:(void(^)(NSInteger count))success times:(NSInteger)times{
    if(_querying && times<=20){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getRoutesCountWithSuccess:success times:times+1];
        });
    }else{
        success(_routeList?_routeList.count:0);
    }
}
@end
