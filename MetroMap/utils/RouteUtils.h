//
//  RouteUtils.h
//  test-metro
//
//  Created by edwin on 2019/6/17.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface RouteUtils : NSObject

@property(nonatomic, copy) void(^queryRouteCallback)(NSMutableArray *data);

@property(nonatomic, copy) void(^queryCallback)(NSMutableDictionary *data);

-(void)queryForRouteWithCityCode:(NSString*)cityCode withStartUid:(NSString*)startUid withEndUid:(NSString*)endUid;
-(NSMutableDictionary *)queryStationTime:(NSString*)cityCode withStationUid:(NSString*)stationUid;

    
-(void)queryForRouteWithCityCode:(NSString*)cityCode;
-(void)queryCityCode;
@end
