//
//  LineModel.m
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "LineModel.h"

@implementation LineModel

+(LineModel*)parseLine:(NSDictionary *)dict{
    NSMutableDictionary *lineDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
    LineModel *line = [LineModel new];
    if([lineDict objectForKey:@"id"]) [line setIdentifyCode:[[lineDict objectForKey:@"id"] integerValue]];
    if([lineDict objectForKey:@"nameCn"]) [line setNameCn:[lineDict objectForKey:@"name"]];
    if([lineDict objectForKey:@"nameEn"]) [line setNameEn:[lineDict objectForKey:@"nameEn"]];
    if([lineDict objectForKey:@"code"]) [line setCode:[lineDict objectForKey:@"code"]];
    if([lineDict objectForKey:@"simpleName"]) [line setNameSimple:[lineDict objectForKey:@"simpleName"]];
    if([lineDict objectForKey:@"color"]) [line setColor: [lineDict objectForKey:@"color"]];
    if([lineDict objectForKey:@"type"]) [line setType:[lineDict objectForKey:@"type"]];
    if([lineDict objectForKey:@"status"]) [line setStatus:[[lineDict objectForKey:@"status"] integerValue]];
    return line;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"identifyCode":@"id"
    };
}

+(NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"directions" : [DirectionModel class],
             @"startStation" : [StationModel class],
             @"endStation" : [StationModel class]
    };
}

+(LineModel*)createFakeModel{
    LineModel *line = [LineModel new];
    line.identifyCode = 1111;
    line.nameCn = @"9号线";
    line.code = @"9";
    line.color = @"#81D4FA";
    line.firstTime = @"05:23";
    line.lastTime = @"23:12";
    
    NSMutableArray *directions = [NSMutableArray new];
    [directions addObject:[DirectionModel createFakeModel]];
    [directions addObject:[DirectionModel createFakeModel]];
    line.directions = directions;
    
    return line;
}
@end
