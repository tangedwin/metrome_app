//
//  StationModel.m
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "StationModel.h"

@implementation StationModel



+(StationModel*)parseStation:(NSDictionary *)dict{
    NSMutableDictionary *stationDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
    StationModel *station = [StationModel new];
    if([stationDict objectForKey:@"id"]) [station setIdentifyCode:[[stationDict objectForKey:@"id"] integerValue]];
    if([stationDict objectForKey:@"nameCn"]) [station setNameCn:[stationDict objectForKey:@"name"]];
    if([stationDict objectForKey:@"nameEn"]) [station setNameEn:[stationDict objectForKey:@"nameEn"]];
    if([stationDict objectForKey:@"namePy"]) [station setNamePy:[stationDict objectForKey:@"namePy"]];
    if([stationDict objectForKey:@"code"]) [station setCode:[stationDict objectForKey:@"code"]];
    if([stationDict objectForKey:@"iconUri"]) [station setIconUri: [stationDict objectForKey:@"iconUri"]];
    if([stationDict objectForKey:@"latitude"]) [station setLatitude: [[stationDict objectForKey:@"latitude"] floatValue]];
    if([stationDict objectForKey:@"longitude"]) [station setLongitude: [[stationDict objectForKey:@"longitude"] floatValue]];
    if([stationDict objectForKey:@"baiduUid"]) [station setBaiduUid: [stationDict objectForKey:@"baiduUid"]];
    if([stationDict objectForKey:@"type"]) [station setType:[stationDict objectForKey:@"type"]];
    if([stationDict objectForKey:@"status"]) [station setStatus:[[stationDict objectForKey:@"status"] integerValue]];
    return station;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"identifyCode":@"id",
             @"detailInfo":@"stationDetailJson",
             @"timetable":@"timetableJson",
             @"lineModels":@"linesArray",
             @"city":@"cityObject"};
}


+(NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"detailInfo" : [StationDetailModel class],
             @"timetable" : [StationTimetableModel class],
             @"lineModels" : [LineModel class],
             @"city" : [CityModel class]};
}

-(void)setNameCn:(NSString *)nameCn{
    _nameCode = nameCn;
    _nameCn = nameCn;
    if(_nameCode){
        _nameCode = [_nameCode stringByReplacingOccurrencesOfString:@" " withString:@""];
        _nameCode = [_nameCode stringByReplacingOccurrencesOfString:@"-" withString:@""];
        _nameCode = [_nameCode stringByReplacingOccurrencesOfString:@"·" withString:@""];
        _nameCode = [_nameCode stringByReplacingOccurrencesOfString:@"(" withString:@""];
        _nameCode = [_nameCode stringByReplacingOccurrencesOfString:@")" withString:@""];
        _nameCode = [_nameCode stringByReplacingOccurrencesOfString:@"（" withString:@""];
        _nameCode = [_nameCode stringByReplacingOccurrencesOfString:@"）" withString:@""];
    }
    
    if([nameCn containsString:@"."]){
        _nameCn = [nameCn componentsSeparatedByString:@"."][0];
    }
}

+(StationModel*)createFakeModel:(NSString*)stationName{
    StationModel *station = [StationModel new];
    station.identifyCode = 111;
    station.nameCn = @"1 号线";
    return station;
}

+(StationModel*)createFakeModel{
    StationModel *station = [self createFakeModel:@"佘山"];
    
    NSMutableArray *lines = [NSMutableArray new];
    [lines addObject:[LineModel createFakeModel]];
    [lines addObject:[LineModel createFakeModel]];
    station.lines = lines;
    
    return station;
}

@end
