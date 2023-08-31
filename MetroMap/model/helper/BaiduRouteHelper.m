//
//  BaiduRouteHelper.m
//  MetroMap
//
//  Created by edwin on 2019/10/20.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "BaiduRouteHelper.h"


@interface BaiduRouteHelper()

@end

@implementation BaiduRouteHelper

#define baiduRouteQueryUrl @"https://map.baidu.com/?qt=bt&newmap=1&ie=utf-8&f=[1,12,13,14]&c=%@&sn=0$$%@$$%@,%@$$null$$&en=0$$%@$$%@,%@$$null$$&m=sbw&ccode=%@&from=dtzt&sy=0"
#define baiduRouteStationUrl @"https://map.baidu.com/?qt=bsl&newmap=1&bsltp=1&uid=%@&c=%@&ie=utf-8&suid=%@&euid=%@&ccode=%@"



//查询路线途经站点
-(void)querySegmentPassBy:(NSInteger)index success:(void(^)(NSMutableArray *segments))success{
    if(!self.routeList || index>=self.routeList.count) return;
    RouteModel *route = self.routeList[index];
    if(route.detailQueried){
        if(success) success(route.segments);
        return;
    }
    // 创建组
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("concurrent.segmentPassBy.queue", DISPATCH_QUEUE_CONCURRENT);
    __weak typeof(self) wkSelf = self;
    for(RouteSegmentModel *segment in route.segments){
        dispatch_group_async(group, queue, ^{
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [wkSelf queryForPassByWidthDirectionUid:segment.direction.baiduUid line:segment.line start:segment.startStationBaiduUid end:segment.endStationBaiduUid success:^(NSMutableArray *stations) {
                if(stations) {
                    [stations insertObject:segment.startStation atIndex:0];
                    [stations addObject:segment.endStation];
                }
                segment.stationsByWay = stations;
                segment.secondStation = stations[1];
                //发送信号量
                dispatch_semaphore_signal(semaphore);
            } failure:^(NSString *errorInfo) {
                //发送信号量
                dispatch_semaphore_signal(semaphore);
            }];
            // 在网络请求任务成功之前，信号量等待中
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        });
    }
    dispatch_group_notify(group, queue, ^{
        route.detailQueried = YES;
        if(success) success(route.segments);
    });
}


//查询路线途经站点
-(void)queryForPassByWidthDirectionUid:(NSString* _Nonnull)directionUid line:(LineModel* _Nonnull)line start:(NSString* _Nonnull)startUid end:(NSString* _Nonnull)endUid success:(void(^)(NSMutableArray *stations))success failure:(void(^)(NSString *errorInfo))failure{
    if(self.city==nil) {
        if(failure) failure(@"参数异常");
        return;
    }
    NSString *str = [NSString stringWithFormat:baiduRouteStationUrl,directionUid,self.city.baiduUid,startUid,endUid,self.city.baiduUid];
    
    //查询途经点
    __weak typeof(self) wkSelf = self;
    [[HttpHelper new] requestDetail:str params:nil progress:^(NSProgress *progress) {
    } success:^(NSMutableDictionary *responseDic) {
        if(responseDic[@"content"]){
            NSArray *contentArray = responseDic[@"content"];
            if(contentArray && contentArray.count>0){
                NSArray *stations = contentArray[0][@"stations"];
                NSMutableDictionary *localStations = [NSMutableDictionary new];
                NSMutableArray *resultStations = [NSMutableArray new];
                for(int i=0; i<line.stations.count; i++) {
                    StationModel *s = wkSelf.city.stationDicts[[NSString stringWithFormat:@"%ld", (long)[line.stations[i] integerValue]]];
                    if(s.baiduName) [localStations setObject:s forKey:s.baiduName];
                    else [localStations setObject:s forKey:[s.nameCn componentsSeparatedByString:@"."][0]];
                }
                for(NSDictionary *sdict in stations){
                    if(sdict[@"name"] && localStations[sdict[@"name"]]) [resultStations addObject:localStations[sdict[@"name"]]];
                }
                if(success) success(resultStations);
            }else if(failure) failure(@"未查询到数据");
        }else if(failure) failure(@"未查询到数据");
    } failure:^(NSString *errorInfo) {
        if(failure) failure(errorInfo);
    }];
}

//查询规划线路
-(void)queryForRouteWithSuccess:(void(^)(NSMutableArray *routeList))success failure:(void(^)(NSString *errorInfo))failure{
    if(self.city==nil || self.startStation==nil || self.endStation==nil) {
        if(failure) failure(@"参数异常");
        return;
    }
    NSString *str = [NSString stringWithFormat:baiduRouteQueryUrl,self.city.baiduUid,self.startStation.baiduUid,self.startStation.baiduPx,self.startStation.baiduPy,self.endStation.baiduUid,self.endStation.baiduPx,self.endStation.baiduPy,self.city.baiduUid];
    
    //规划路线
    __weak typeof(self) wkSelf = self;
    [[HttpHelper new] requestDetail:str params:nil progress:^(NSProgress *progress) {
    } success:^(NSMutableDictionary *responseDic) {
        if(responseDic[@"content"]){
            NSMutableArray *routesAll = [[NSMutableArray alloc]init];
            NSArray *contentArray = responseDic[@"content"];
            for(NSDictionary *dict in contentArray){
                if(![dict isKindOfClass:[NSDictionary class]]) continue;
                RouteModel *route = [wkSelf parseRouteContent:dict];
                if(route) [routesAll addObject:route];
            }
            wkSelf.routeList = routesAll;
            if(routesAll.count>0 && success) success(routesAll);
            else if(routesAll.count<=0 && failure) failure(@"未找到数据");
        }else if(failure) failure(@"未查询到数据");
    } failure:^(NSString *errorInfo) {
        if(failure) failure(errorInfo);
    }];
}

//解析路线
-(RouteModel*)parseRouteContent:(NSDictionary*)content{
    NSArray *extsOutterArray = content[@"exts"];
    NSArray *linesOutterArray = content[@"lines"];
    NSArray *stopsOutterArray = content[@"stops"];
    if(!extsOutterArray || extsOutterArray.count<=0 || !linesOutterArray || linesOutterArray.count<=0 || !stopsOutterArray || stopsOutterArray.count<=0) return nil;
    NSDictionary *exit = extsOutterArray[0];
    NSArray *linesArray = linesOutterArray[0];
    NSArray *stopsArray = stopsOutterArray[0];
    if(!exit || !linesArray || !stopsArray) return nil;
    
    RouteModel *route = [RouteModel new];
    NSMutableArray<RouteSegmentModel*> *segmentArray = [NSMutableArray new];
    NSInteger countStop = 0;
    NSInteger countTransfor = 0;
    StationModel *startStation = nil;
    StationModel *endStation = nil;
    for(int i=0; i<stopsArray.count; i++){
        LineModel *offLine = segmentArray.count>(i-1)?segmentArray[i-1].line:nil;
        LineModel *lineInSegment = nil;
        RouteSegmentModel *segment = [RouteSegmentModel new];
        //线路
        if(i<stopsArray.count-1) {
            if(linesArray.count<=i || ![linesArray[i] isKindOfClass:NSDictionary.class]) return nil;
            NSDictionary *line = linesArray[i];
            segment.firstTime = line[@"startTime"];
            segment.lastTime = line[@"endTime"];
            if(line[@"time"]) segment.costTime = [line[@"time"] integerValue];
            if(line[@"station_num"]) segment.countStop = [line[@"station_num"] integerValue];
            countStop = countStop + segment.countStop;
            countTransfor = countTransfor + 1;
            for(LineModel *lineModel in self.city.lines){
                if([lineModel.baiduUid containsString:line[@"uid"]]){
                    lineInSegment = lineModel;
                    for(DirectionModel *direction in lineModel.directions){
                        if([direction.baiduUid isEqualToString:line[@"uid"]]) {
                            segment.directionName = direction.name;
                            segment.direction = direction;
                        }
                    }
                    break;
                }
            }
            if(!lineInSegment) return nil;
        }
        
        if(lineInSegment) segment.line = lineInSegment;
        
        NSDictionary *stop = stopsArray[i];
        NSDictionary *off = stop[@"getOff"];
        NSDictionary *on = stop[@"getOn"];
        NSDictionary *walk = stop[@"walk"];
        segment.transforType = @"步行";
        segment.transforTime = [walk[@"time"] integerValue];
        
        
        for(StationModel *stationModel in self.city.stations){
            BOOL curLine = [segment.line.stations containsObject:@(stationModel.identifyCode)];
            BOOL prevLine = offLine?[offLine.stations containsObject:@(stationModel.identifyCode)]:YES;
            if(!curLine && !prevLine) continue;
            NSString *sname = stationModel.baiduName?stationModel.baiduName:[stationModel.nameCn componentsSeparatedByString:@"."][0];
            if(lineInSegment && [sname isEqualToString:on[@"name"]] && [lineInSegment.stations containsObject:@(stationModel.identifyCode)]){
                segment.startStationBaiduUid = on[@"uid"];
                segment.startStation = stationModel;
                if(!startStation) startStation = stationModel;
            }
            if(offLine && [sname isEqualToString:off[@"name"]] && [offLine.stations containsObject:@(stationModel.identifyCode)]){
                segmentArray[i-1].endStationBaiduUid = off[@"uid"];
                segmentArray[i-1].endStation = stationModel;
                endStation = stationModel;
            }
        }
        if(segment.startStation && segment.direction){
            if(segment.startStation.timetable) for(StationTimetableModel *stModel in segment.startStation.timetable){
                if(stModel.directionId == segment.direction.identifyCode){
                    NSString *firstTime = [stModel findFirstTime];
                    NSString *lastTime = [stModel findLastTime];
                    if(firstTime) segment.firstTime = firstTime;
                    if(lastTime) segment.lastTime = lastTime;
                    break;
                }
            }
        }
        
        if(i<stopsArray.count-1) [segmentArray addObject:segment];
    }
    route.countStop = countStop;
    route.countTransfor = countTransfor;
    route.segments = segmentArray;
    route.startStation = startStation;
    route.endStation = endStation;
    route.countTransfor = route.countTransfor>0?(route.countTransfor-1):0;
    if(exit[@"price"]) route.costPrice = [exit[@"price"] integerValue];
    if(exit[@"time"]) route.costTime = [exit[@"time"] integerValue];
    if(exit[@"walk_time"]) route.transforTime = [exit[@"walk_time"] integerValue];
    if(exit[@"distance"]) route.distance = [exit[@"distance"] integerValue];
    if(exit[@"walk_distance"]) route.distanceTransfor = [exit[@"walk_distance"] integerValue];
    
    NSString *segmentLastTime = nil;
    RouteSegmentModel *segmentLast = nil;
    if(route.segments && route.segments.count>0) for(NSInteger i=route.segments.count-1; i>=0; i--){
        RouteSegmentModel *segment = route.segments[i];
        if(segmentLastTime) {
            NSInteger timeCost = (i==0?5*60:3*60) + segment.transforTime + segment.costTime;
            segmentLastTime = [DateUtils time:segmentLastTime beforeSeconds:timeCost];
            NSString *tempSegmentLastTime = [DateUtils time:segment.lastTime beforeSeconds:(i==0?5*60:3*60)];
            if([DateUtils checkTime:tempSegmentLastTime beforeTime:segmentLastTime]) {
                segmentLastTime = tempSegmentLastTime;
                segmentLast = segment;
            }
        }else{
            NSInteger timeCost = (i==0?5*60:3*60);
            segmentLastTime = [DateUtils time:segment.lastTime beforeSeconds:timeCost];
            segmentLast = segment;
        }
    }
    route.lastTime = segmentLastTime;
    route.segmentLast = segmentLast;
    
    return route;
}

@end
