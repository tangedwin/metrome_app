//
//  RouteSegmentModel.m
//  MetroMap
//
//  Created by edwin on 2019/10/9.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "RouteSegmentModel.h"

@implementation RouteSegmentModel

+(RouteSegmentModel*)createFakeModel{
    RouteSegmentModel *routeSegmentModel = [RouteSegmentModel new];
    routeSegmentModel.identifyCode = @"aaaa";
    routeSegmentModel.startStation = [StationModel createFakeModel];
    routeSegmentModel.endStation = [StationModel createFakeModel];
    routeSegmentModel.secondStation = [StationModel createFakeModel];
    routeSegmentModel.directionName = @"杨高中路方向(下一站 桂林路)";
    routeSegmentModel.line = [LineModel createFakeModel];
    routeSegmentModel.transforTime = 2*60;
    routeSegmentModel.transforType = @"步行";
    routeSegmentModel.costTime = 5*60;
    
    NSMutableArray *array = [NSMutableArray new];
    [array addObject:routeSegmentModel.startStation];
    [array addObject:routeSegmentModel.secondStation];
    [array addObject:[StationModel createFakeModel]];
    [array addObject:[StationModel createFakeModel]];
    [array addObject:routeSegmentModel.endStation];
    routeSegmentModel.stationsByWay = array;
    routeSegmentModel.countStop = array.count-1;
    return routeSegmentModel;
}



+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"stationsByWay":@"stationsByway"};
}

+(NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"startStation" : [StationModel class],
             @"secondStation" : [StationModel class],
             @"stationsByWay" : [StationModel class],
             @"endStation" : [StationModel class],
             @"segments" : [RouteSegmentModel class],
             @"line" : [LineModel class],
             @"direction" : [DirectionModel class]
    };
}
@end
