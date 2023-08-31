//
//  MetroRouteQuery.m
//  MetroMap
//
//  Created by edwin on 2019/9/8.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "MetroRouteQuery.h"

@implementation MetroRouteQuery

-(void)queryRoute:(NSString*)cityCode startStation:(StationInfo*)startStation endStation:(StationInfo*)endStation{
    NSString *startName = startStation.nameCn;
    NSString *endName = endStation.nameCn;
    if(startStation.nameCnOnly) startName = [NSString stringWithFormat:@"%@(%@号线)",startName,[startStation.nameCnOnly stringByReplacingOccurrencesOfString:startName withString:@""]];
    if(endStation.nameCnOnly) startName = [NSString stringWithFormat:@"%@(%@号线)",endName,[endStation.nameCnOnly stringByReplacingOccurrencesOfString:endName withString:@""]];
    [self queryCityCode:cityCode startName:startName endName:endName];
}
    
    

-(void)queryCityCode:(NSString*)cityName startName:(NSString*)startStationName endName:(NSString*)endStationName{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/data", [pathArray objectAtIndex:0]];
    NSString *filePath = [path stringByAppendingPathComponent:baidu_cities_file];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
    if(!dict){
        //请求百度接口查询
        RouteUtils *routeUtils = [RouteUtils new];
        [routeUtils setQueryCallback:^(NSMutableDictionary *data) {
            //写入文件
            [data writeToFile:filePath atomically:YES];
            //查询站点对应code
            NSString *cityCode = [data objectForKey:cityName];
            [self queryStationCode:cityCode startName:startStationName endName:endStationName];
        }];
        [routeUtils queryCityCode];
    }else{
        NSString *cityCode = [dict objectForKey:cityName];
        [self queryStationCode:cityCode startName:startStationName endName:endStationName];
    }
}
    
-(void) queryStationCode:(NSString*)cityCode startName:(NSString*)startStationName endName:(NSString*)endStationName{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/data/%@", [pathArray objectAtIndex:0], cityCode];
    NSString *filePath = [path stringByAppendingPathComponent:baidu_stations_file];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
    if(!dict){
        //请求百度接口查询
        RouteUtils *routeUtils = [RouteUtils new];
        [routeUtils setQueryCallback:^(NSMutableDictionary *data) {
            //写入文件
            [data writeToFile:filePath atomically:YES];
            //查询站点对应code
            NSString *startStationCode = [data objectForKey:startStationName];
            NSString *endStationCode = [data objectForKey:endStationName];
            [self queryRoute:cityCode withStartUid:startStationCode withEndUid:endStationCode];
        }];
        [routeUtils queryForRouteWithCityCode:cityCode];
    }else{
        NSString *startStationCode = [dict objectForKey:startStationName];
        NSString *endStationCode = [dict objectForKey:endStationName];
        [self queryRoute:cityCode withStartUid:startStationCode withEndUid:endStationCode];
    }
}
    
-(void)queryRoute:(NSString*)cityCode withStartUid:(NSString*)startUid withEndUid:(NSString*)endUid{
    RouteUtils *routeUtils = [RouteUtils new];
    __weak typeof(self) wkSelf = self;
    [routeUtils setQueryRouteCallback:^(NSMutableArray *data) {
        NSLog(@"%@",data);
    }];
    [routeUtils queryForRouteWithCityCode:cityCode withStartUid:startUid withEndUid:endUid];
}
   
@end
