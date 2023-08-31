//
//  RouteModel.m
//  MetroMap
//
//  Created by edwin on 2019/10/9.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "RouteModel.h"
#import "YYModel.h"

@implementation RouteModel

+(RouteModel*)createFakeModel{
    RouteModel *routeModel = [RouteModel new];
    routeModel.identifyCode = @"aaaa";
    routeModel.costPrice = 400;
    routeModel.routeTime = @"2019-10-09 12:23:21";
    routeModel.routeType = @"地铁";
    
    NSMutableArray *array = [NSMutableArray new];
    
    int r = arc4random() % 6;
    r = (r<=0)?1:r;
    for(int i=0; i<r; i++){
        RouteSegmentModel *segment = [RouteSegmentModel createFakeModel];
        routeModel.countStop += segment.countStop;
        routeModel.countTransfor++;
        routeModel.costTime = routeModel.costTime + segment.transforTime + segment.costTime;
        if(i==0) routeModel.startStation = segment.startStation;
        if(i==2) routeModel.endStation = segment.endStation;
        [array addObject:segment];
    }
    routeModel.segments = array;
    return routeModel;
}

+(NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"startStation" : [StationModel class],
             @"endStation" : [StationModel class],
             @"segments" : [RouteSegmentModel class]
    };
}



-(NSString*)parseRouteModelToJSONStr{
    RouteModel *routeModel = self;
    if(routeModel){
        NSMutableDictionary *routeInfo = [NSMutableDictionary new];
        NSMutableDictionary *startStation = [self copyStation:routeModel.startStation];
        NSMutableDictionary *endStation = [self copyStation:routeModel.endStation];
        if(startStation) [routeInfo setObject:startStation forKey:@"startStation"];
        if(endStation) [routeInfo setObject:endStation forKey:@"endStation"];
        
        if(routeModel.costTime) [routeInfo setObject:@(routeModel.costTime) forKey:@"costTime"];
        if(routeModel.countStop) [routeInfo setObject:@(routeModel.countStop) forKey:@"countStop"];
        if(routeModel.countTransfor) [routeInfo setObject:@(routeModel.countTransfor) forKey:@"countTransfor"];
        if(routeModel.transforTime) [routeInfo setObject:@(routeModel.transforTime) forKey:@"transforTime"];
        if(routeModel.costPrice) [routeInfo setObject:@(routeModel.costPrice) forKey:@"costPrice"];
        if(routeModel.distance) [routeInfo setObject:@(routeModel.distance) forKey:@"distance"];
        if(routeModel.distanceTransfor) [routeInfo setObject:@(routeModel.distanceTransfor) forKey:@"distanceTransfor"];
        
        NSMutableArray *segments = [NSMutableArray new];
        for(RouteSegmentModel *segment in routeModel.segments){
            NSMutableDictionary *nsegment = [NSMutableDictionary new];
            if(segment.identifyCode) [nsegment setObject:@(segment.identifyCode) forKey:@"identifyCode"];
            NSMutableDictionary *sStation = [self copyStation:segment.startStation];
            NSMutableDictionary *eStation = [self copyStation:segment.endStation];
            NSMutableDictionary *seStation = [self copyStation:segment.secondStation];
            if(sStation) [nsegment setObject:sStation forKey:@"startStation"];
            if(eStation) [nsegment setObject:eStation forKey:@"endStation"];
            if(seStation) [nsegment setObject:seStation forKey:@"secondStation"];
            
            NSMutableDictionary *direction = [self copyDirection:segment.direction];
            if(direction) [nsegment setObject:direction forKey:@"direction"];
            NSMutableDictionary *line = [self copyLine:segment.line];
            if(line) [nsegment setObject:line forKey:@"line"];
            
            if(segment.directionName) [nsegment setObject:segment.directionName forKey:@"directionName"];
            if(segment.transforType) [nsegment setObject:segment.transforType forKey:@"transforType"];
            if(segment.transforTime) [nsegment setObject:@(segment.transforTime) forKey:@"transforTime"];
            if(segment.firstTime) [nsegment setObject:segment.firstTime forKey:@"firstTime"];
            if(segment.lastTime) [nsegment setObject:segment.lastTime forKey:@"lastTime"];
            if(segment.costTime) [nsegment setObject:@(segment.costTime) forKey:@"costTime"];
            if(segment.countStop) [nsegment setObject:@(segment.countStop) forKey:@"countStop"];
            NSMutableArray *stations = [NSMutableArray new];
            for(StationModel *station in segment.stationsByWay){
                NSMutableDictionary *s = [self copyStation:station];
                if(s) [stations addObject:s];
            }
            if(stations) [nsegment setObject:stations forKey:@"stationsByWay"];
            [segments addObject:nsegment];
        }
        if(segments) [routeInfo setObject:segments forKey:@"segments"];
        
        return [routeInfo yy_modelToJSONString];
    }
    return nil;
}

-(NSMutableDictionary*)copyStation:(StationModel*)station{
    if(!station) return nil;
    NSMutableDictionary *nstation = [NSMutableDictionary new];
    if(station.identifyCode) [nstation setObject:@(station.identifyCode) forKey:@"identifyCode"];
    if(station.nameCn) [nstation setObject:station.nameCn forKey:@"nameCn"];
    return nstation;
}
-(NSMutableDictionary*)copyLine:(LineModel*)line{
    if(!line) return nil;
    NSMutableDictionary *nline = [NSMutableDictionary new];
    if(line.identifyCode) [nline setObject:@(line.identifyCode) forKey:@"identifyCode"];
    if(line.nameCn) [nline setObject:line.nameCn forKey:@"nameCn"];
    if(line.code) [nline setObject:line.code forKey:@"code"];
    if(line.nameSimple) [nline setObject:line.nameSimple forKey:@"nameSimple"];
    if(line.color) [nline setObject:line.color forKey:@"color"];
    return nline;
}
-(NSMutableDictionary*)copyDirection:(DirectionModel*)direction{
    if(!direction) return nil;
    NSMutableDictionary *ndirection = [NSMutableDictionary new];
    if(direction.identifyCode) [ndirection setObject:@(direction.identifyCode) forKey:@"identifyCode"];
    if(direction.name) [ndirection setObject:direction.name forKey:@"name"];
    return ndirection;
}
@end
