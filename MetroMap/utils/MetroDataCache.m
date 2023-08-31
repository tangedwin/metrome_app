//
//  MetroDataUtils.m
//  MetroMap
//
//  Created by edwin on 2019/9/5.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "MetroDataCache.h"

static MetroDataCache *_metroDataCache = nil;
@interface MetroDataCache()

@property(nonatomic, retain) NSString *cityCode;
@end
@implementation MetroDataCache
    
+ (instancetype)shareInstanceWithCityCode:(NSString*)cityCode {
    if(!cityCode) cityCode = @"beijing";
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (_metroDataCache == nil || !_metroDataCache.cityCode || ![_metroDataCache.cityCode isEqualToString:cityCode]) {
            _metroDataCache = [[self alloc]init];
            _metroDataCache.cityCode = cityCode;
            [_metroDataCache loadData];
        }
    });
    return _metroDataCache;
}
    
   
-(void) loadData{
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [NSString stringWithFormat:@"%@/data/%@", [pathArray objectAtIndex:0], _cityCode];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *directoryEnumerator = [fileManager enumeratorAtPath:path];
    BOOL isDir = NO;
    BOOL isExist = NO;
    for (NSString *p in directoryEnumerator.allObjects) {
        isExist = [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", path, p] isDirectory:&isDir];
        if (isExist && isDir) {
            NSMutableDictionary *stations = [self getDataArrayFromPlist:@"station" path:[NSString stringWithFormat:@"%@/%@", path, p]];
            NSMutableDictionary *lines = [self getDataArrayFromPlist:@"line" path:[NSString stringWithFormat:@"%@/%@", path, p]];
            
            //解析线路站点的集合
            if(!_lines) _lines = [NSMutableArray new];
            if(!_stations) _stations = [NSMutableDictionary new];
            
            //解析站点
            NSArray *stationIds = [stations allKeys];
            NSMutableArray *reduplicateStationNames = [NSMutableArray new];
            NSMutableArray *stationNames = [NSMutableArray new];
            for(NSString *sid in stationIds){
                NSMutableArray *array = [stations mutableArrayValueForKey:sid];
                StationInfo *s = [StationInfo new];
                s.identityNum = @([sid integerValue]);
                s.status = @(1);
                s.nameCn = [array[0] stringByReplacingOccurrencesOfString:@" " withString:@""];
                s.nameEn = array[1];
                s.namePy = array[2];
                if(array[3] && [@"" isEqualToString:array[3]]) s.location = CGPointFromString([NSString stringWithFormat:@"{%@}", array[3]]);
                s.iconUrl = array[4];
                s.lineIds = [NSMutableArray new];
                [_stations setObject:s forKey:sid];
                
                if([stationNames containsObject:s.nameCn]) [reduplicateStationNames addObject:s.nameCn];
                [stationNames addObject:s.nameCn];
            }
            
            //解析线路
            NSArray *lineIds = [lines allKeys];
            lineIds = [lineIds sortedArrayUsingComparator:^NSComparisonResult(NSNumber *id1, NSNumber *id2){
                return [id1 integerValue]>[id2 integerValue]?1:([id1 integerValue]<[id2 integerValue]?-1:0);
            }];
            
            for(NSString *lid in lineIds){
                NSMutableArray *array = [lines mutableArrayValueForKey:lid];
                LineInfo *l = [LineInfo new];
                l.identityNum = @([lid integerValue]);
                l.code = array[0];
                l.scode = array[1];
                l.nameCn = array[2];
                l.nameEn = array[3];
                NSData *jsonData = [array[4] dataUsingEncoding:NSUTF8StringEncoding];
                NSError *err;
                NSArray *sids = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
                l.stationIds = [[NSMutableArray alloc] initWithArray:sids];
//                [_lines setObject:l forKey:lid];
                [_lines addObject:l];
                //将线路写入站点
                for(NSString *sid in l.stationIds){
                    StationInfo *s = [_stations objectForKey:[NSString stringWithFormat:@"%@",sid]];
                    [s.lineIds addObject:l.identityNum];
                    if([reduplicateStationNames containsObject:s.nameCn]) s.nameCnOnly = [NSString stringWithFormat:@"%@%@",s.nameCn,l.code];
//                    NSUInteger index = [stationIds indexOfObject:[NSString stringWithFormat:@"%@",sid]];
//                    if(index!=NSNotFound) {
//                        StationInfo *s = [_stations objectAtIndex:index];
//                        [s.lineIds addObject:l.identityNum];
//                    }
                }
            }
        }
    }
}

-(NSMutableDictionary*)getDataArrayFromPlist:(NSString*)plistName path:(NSString*)path{
    if(![plistName containsString:@".plist"]) plistName= [NSString stringWithFormat:@"%@.plist", plistName];
    NSString *filePath = [path stringByAppendingPathComponent:plistName];
    return [[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
}
    
#pragma mark - plist
+(NSData*)getDataFromPlist:(NSString*) plistName withKey:(NSString*) key {
    //沙盒获取路径
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [pathArray objectAtIndex:0];
    //获取文件的完整路径
    NSString *filePatch = [path stringByAppendingPathComponent:plistName];//没有会自动创建
    //    NSLog(@"file patch%@",filePatch);
    NSMutableDictionary *sandBoxDataDic = [[NSMutableDictionary alloc]initWithContentsOfFile:filePatch];
    if (sandBoxDataDic!=nil) {
        return sandBoxDataDic[key];
    }else{
        return nil;
    }
}
@end
