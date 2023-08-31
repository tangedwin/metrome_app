//
//  CityZipUtils.m
//  MetroMap
//
//  Created by edwin on 2019/10/19.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "CityZipUtils.h"

#define cityVersionPlistName @"cityVersion.plist"
@implementation CityZipUtils

+(long long) getCacheSize{
    long long fileTotalSize = 0;
    NSFileManager * fileManger = [NSFileManager defaultManager];
    NSArray *plistPathes = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [plistPathes objectAtIndex:0];
    NSString *plist = [plistPath stringByAppendingPathComponent:cityVersionPlistName];
    NSDictionary * fileAttributes = [fileManger attributesOfItemAtPath:plist error:nil];
    if (![fileAttributes[NSFileType] isEqualToString:NSFileTypeDirectory])
        fileTotalSize += [fileAttributes[NSFileSize] integerValue];

    NSArray *pathes = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
    NSString *path = [pathes objectAtIndex:0];//大文件放在沙盒下的Library/Caches
//    NSString *cityPath = [NSString stringWithFormat:@"%@/cityData",path];
    NSEnumerator *childFilesEnumerator = [[fileManger subpathsAtPath:path] objectEnumerator];//从前向后枚举器
    NSString* fileName;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [path stringByAppendingPathComponent:fileName];
        NSDictionary * subfileAttributes = [fileManger attributesOfItemAtPath:fileAbsolutePath error:nil];
        if ([fileManger fileExistsAtPath:fileAbsolutePath] && ![subfileAttributes[NSFileType] isEqualToString:NSFileTypeDirectory]){
            fileTotalSize += [subfileAttributes[NSFileSize] integerValue];
        }


//        fileTotalSize += [self getFileSize:fileAbsolutePath];
    }
    return fileTotalSize;
}

+(long long) getFileSize:(NSString*)targetpath{
    long long fileTotalSize = 0;
    NSFileManager * fileManger = [NSFileManager defaultManager];
    if(![fileManger fileExistsAtPath:targetpath]) return 0;
    NSDictionary * fileAttributes = [fileManger attributesOfItemAtPath:targetpath error:nil];
    if ([fileAttributes[NSFileType] isEqualToString:NSFileTypeDirectory]) {
    }else{
        fileTotalSize += [fileAttributes[NSFileSize] integerValue];
    }
    return fileTotalSize;
}



+(void) cleanAllCache{
    //这里使用位于沙盒的plist（程序会自动新建的那一个）
    NSArray *plistPathes = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *plistPath = [plistPathes objectAtIndex:0];
    //获取文件的完整路径
    NSString *plist = [plistPath stringByAppendingPathComponent:cityVersionPlistName];
    [[NSFileManager defaultManager] removeItemAtPath:plist error:nil];
    
    NSArray *pathes = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
    NSString *path = [pathes objectAtIndex:0];//大文件放在沙盒下的Library/Caches
//    NSString *cityPath = [NSString stringWithFormat:@"%@/cityData",path];
    [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
}

+(NSString*) getMapPath:(NSInteger)cityId darkMode:(BOOL) dark{
    NSArray *pathes = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
    NSString *path = [pathes objectAtIndex:0];//大文件放在沙盒下的Library/Caches
    NSString *mapPath = [NSString stringWithFormat:@"%@/cityData/%ld/%@",path,(long)cityId,@"metroMap.svg"];
    return mapPath;
}

+ (CityModel*) parseFileToCityModel:(NSInteger)cityId{
    NSArray *pathes = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
    NSString *path = [pathes objectAtIndex:0];//大文件放在沙盒下的Library/Caches
    NSString *cityPath = [NSString stringWithFormat:@"%@/cityData/%ld",path,(long)cityId];
    
    NSString *cityJsonPath = [NSString stringWithFormat:@"%@/city.json", cityPath];
    NSString *linesJsonPath = [NSString stringWithFormat:@"%@/lines.json", cityPath];
    NSString *stationsJsonPath = [NSString stringWithFormat:@"%@/stations.json", cityPath];
    if (![[NSFileManager defaultManager] fileExistsAtPath:cityJsonPath]) return nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:linesJsonPath]) return nil;
    if (![[NSFileManager defaultManager] fileExistsAtPath:stationsJsonPath]) return nil;
    
    NSData *cityData = [[NSData alloc] initWithContentsOfFile:cityJsonPath];
    NSDictionary *cityDict = [NSJSONSerialization JSONObjectWithData:cityData options:kNilOptions error:nil];
    CityModel *city = [CityModel yy_modelWithJSON:cityDict];
    
    NSData *linesData = [[NSData alloc] initWithContentsOfFile:linesJsonPath];
    NSArray *linesArray = [NSJSONSerialization JSONObjectWithData:linesData options:kNilOptions error:nil];
    NSMutableArray *lines = [NSMutableArray new];
    NSMutableDictionary *lineDicts = [NSMutableDictionary new];
    for(NSDictionary *lineDict in linesArray){
        LineModel *line = [LineModel yy_modelWithJSON:lineDict];
        [lines addObject:line];
        [lineDicts setObject:line forKey:[NSString stringWithFormat:@"%ld",(long)line.identifyCode]];
    }
    city.lines = lines;
    city.lineDicts = lineDicts;
    
    NSData *stationsData = [[NSData alloc] initWithContentsOfFile:stationsJsonPath];
    NSArray *stationsArray = [NSJSONSerialization JSONObjectWithData:stationsData options:kNilOptions error:nil];
    NSMutableArray *stations = [NSMutableArray new];
    NSMutableDictionary *stationDicts = [NSMutableDictionary new];
    for(NSDictionary *stationDict in stationsArray){
        StationModel *station = [StationModel yy_modelWithJSON:stationDict];
        [stations addObject:station];
        [stationDicts setObject:station forKey:[NSString stringWithFormat:@"%ld",(long)station.identifyCode]];
    }
    city.stations = stations;
    city.stationDicts = stationDicts;
    return city;
}

//下载文件
+ (void)downloadZip:(NSString *)zipUrl city:(CityModel*)city success:(void(^)(void))success{
    NSURL *url = [NSURL URLWithString:zipUrl];
    NSArray *pathes = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
    NSString *path = [pathes objectAtIndex:0];//大文件放在沙盒下的Library/Caches
    NSString *finishPath = [NSString stringWithFormat:@"%@/cityData/%ld",path,(long)city.identifyCode];//保存解压后文件的文件夹的路径
    NSString *tempPath = [NSString stringWithFormat:@"%@/temp/",path];//zip目录
    NSString *zipPath = [NSString stringWithFormat:@"%@/temp/%ld.zip",path,(long)city.identifyCode];//下载的zip包存放路径
    if (![[NSFileManager defaultManager] fileExistsAtPath:tempPath]) {
        NSError *err;
        [[NSFileManager defaultManager] createDirectoryAtPath:tempPath withIntermediateDirectories:YES attributes:nil error:&err];
        if (err) {
            NSLog(@"create cache file directory failed err:%@",err);
        }else {
            NSLog(@"create cache file directory succeed");
        }
    }
    //下载zip
    dispatch_queue_t queue =dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0);
    dispatch_async(queue, ^{
        NSError *error = nil;
        NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
        if(!error){
            [data writeToFile:zipPath options:0 error:nil];
            
            if(!city.contentSize){
                NSDictionary * fileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:zipPath error:nil];
                city.contentSize = [fileAttributes[NSFileSize] integerValue];
            }
            //解压zip文件
            ZipArchive *zip= [[ZipArchive alloc]init];
            if([zip UnzipOpenFile:zipPath Password:@"city.metrome"]){//将解压缩的内容写到缓存目录中
                BOOL ret = [zip UnzipFileTo:finishPath overWrite:YES];
                if(!ret) {
                    [zip UnzipCloseFile];
                }
                //解压完成 删除压缩包
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager removeItemAtPath:zipPath error:nil];
                [CityZipUtils writeCityLatestVersionWithCity:city];
                if(success) success();
            }else{
                NSLog(@"------>%@",[zip debugDescription]);
            }
        }
    });
}


+(NSMutableDictionary *)readCityLatestVersionWithCityId {
    //这里使用位于沙盒的plist（程序会自动新建的那一个）
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [pathArray objectAtIndex:0];
    //获取文件的完整路径
    NSString *filePatch = [path stringByAppendingPathComponent:cityVersionPlistName];
    NSMutableDictionary *sandBoxDataDic = [[NSMutableDictionary alloc]initWithContentsOfFile:filePatch];
    NSMutableDictionary *versionResult = [NSMutableDictionary new];
    if(sandBoxDataDic){
        NSArray *keys = sandBoxDataDic.allKeys;
        for(NSNumber *key in keys){
            NSInteger cityId = key.intValue;
            NSArray *cityDataPaths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES);
            NSString *cityDataPath = [cityDataPaths objectAtIndex:0];//大文件放在沙盒下的Library/Caches
            NSString *dataPath = [NSString stringWithFormat:@"%@/cityData/%ld",cityDataPath,(long)cityId];//保存解压后文件的文件夹的路径
            if([[NSFileManager defaultManager] fileExistsAtPath:dataPath]) {
                CityModel *city = [CityModel parseCity:sandBoxDataDic[key]];
                [versionResult setObject:city forKey:key];
            }
        }
    }
    return versionResult;
}

+(void)writeCityLatestVersionWithCity:(CityModel*)city {
    //这里使用位于沙盒的plist（程序会自动新建的那一个）
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [pathArray objectAtIndex:0];
    //获取文件的完整路径
    NSString *filePatch = [path stringByAppendingPathComponent:cityVersionPlistName];
    NSMutableDictionary *sandBoxDataDic = [[NSMutableDictionary alloc]initWithContentsOfFile:filePatch];
    if(sandBoxDataDic == nil){
         sandBoxDataDic = [[NSMutableDictionary alloc ] init];
    }
    NSMutableDictionary *cityDict = [NSMutableDictionary new];
    [cityDict setObject:[NSString stringWithFormat:@"%ld", (long)city.version] forKey:@"latestVersion"];
    [cityDict setObject:[NSString stringWithFormat:@"%ld", (long)city.identifyCode] forKey:@"id"];
    if(city.nameCn) [cityDict setObject:city.nameCn forKey:@"nameCn"];
    if(city.nameEn) [cityDict setObject:city.nameEn forKey:@"nameEn"];
    if(city.namePy) [cityDict setObject:city.namePy forKey:@"namePy"];
    if(city.updateTime) [cityDict setObject:city.updateTime forKey:@"updateDate"];
    if(city.contentSize) [cityDict setObject:[NSString stringWithFormat:@"%.0f", city.contentSize] forKey:@"fileSize"];
    [sandBoxDataDic setObject:cityDict forKey:[NSString stringWithFormat:@"%ld",(long)city.identifyCode]];
    [sandBoxDataDic writeToFile:filePatch atomically:YES];
}
@end
