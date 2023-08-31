//
//  DirectionModel.m
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "DirectionModel.h"
#import "StationModel.h"

@implementation DirectionModel

+(DirectionModel*)createFakeModel{
    DirectionModel *direction = [DirectionModel new];
    direction.identifyCode = 111;
    direction.startStation = [StationModel createFakeModel:@"曹路"];
    direction.endStation = [StationModel createFakeModel:@"松江南站"];
    return direction;
}


+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"identifyCode":@"id"};
}
@end
