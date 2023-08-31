//
//  CSVUtils.m
//  MetroMap
//
//  Created by edwin on 2019/9/5.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "CSVUtils.h"

@implementation CSVUtils

+(void)readCSVData{
    NSString *path = [self getDocumentPath:@"data/shanghai" directory:NSCachesDirectory];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator *directoryEnumerator = [fileManager enumeratorAtPath:path];
    BOOL isDir = NO;
    BOOL isExist = NO;
    for (NSString *p in directoryEnumerator.allObjects) {
        isExist = [fileManager fileExistsAtPath:[NSString stringWithFormat:@"%@/%@", path, p] isDirectory:&isDir];
        if (isExist && isDir) {
            NSString *uri = [NSString stringWithFormat:@"data/shanghai/%@", p];
            [self transferDataToPlist:@"line" path:[NSString stringWithFormat:@"%@/%@", path, p] uri:uri];
            [self transferDataToPlist:@"station" path:[NSString stringWithFormat:@"%@/%@", path, p] uri:uri];
            [self transferDataToPlist:@"station-detail" path:[NSString stringWithFormat:@"%@/%@", path, p] uri:uri];
            [self transferDataToPlist:@"way" path:[NSString stringWithFormat:@"%@/%@", path, p] uri:uri];
            [self transferDataToPlist:@"fare-station" path:[NSString stringWithFormat:@"%@/%@", path, p] uri:uri];
            [self transferDataToPlist:@"fare" path:[NSString stringWithFormat:@"%@/%@", path, p] uri:uri];
        }
    }
}

+(void)transferDataToPlist:(NSString*)fileName path:(NSString*)path uri:(NSString*)uri{
    NSError *error = nil;
    unsigned long encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingUTF8);
    NSString *fileContents = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.csv", path, fileName] encoding:encode error:&error];
    fileContents = [fileContents stringByReplacingOccurrencesOfString:@"\r\n" withString:@"\r"];
    //取出每一行的数据
    NSArray *allLinedStrings = [fileContents componentsSeparatedByString:@"\r"];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc ] init];
    NSString *tempKey = nil;
    NSMutableArray *tempArrayValue = [NSMutableArray new];
    NSString *tempString = nil;
    for(NSString *line in allLinedStrings){
        //按逗号分隔，组成字符串列表
        NSArray *values = [line componentsSeparatedByString:@","];
        for(NSString *value in values){
            NSInteger count = [[value mutableCopy] replaceOccurrencesOfString:@"\"" withString:@"A" options:NSLiteralSearch range:NSMakeRange(0, [value length])];
            if(count%2==1 && !tempString) tempString = value;
            else if(count%2==0 && tempString) tempString = [NSString stringWithFormat:@"%@,%@", tempString, value];
            else if(count%2==1 && tempString) {
                tempString = [NSString stringWithFormat:@"%@,%@", tempString, value];
                if(!tempKey) tempKey = [tempString stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                else [tempArrayValue addObject:[tempString stringByReplacingOccurrencesOfString:@"\"" withString:@""]];
                tempString = nil;
            }else if(count%2==0 && !tempString){
                if(!tempKey) tempKey = [value stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                else [tempArrayValue addObject:[value stringByReplacingOccurrencesOfString:@"\"" withString:@""]];
            }
        }
        if(!tempKey || [@"" isEqualToString:tempKey]) continue;
        [dict setObject:tempArrayValue forKey:tempKey];
        tempArrayValue = [NSMutableArray new];
        tempKey = nil;
    }
    
    NSString *mainPath = [self getDocumentPath:uri directory:NSDocumentDirectory];
    //获取文件的完整路径
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.plist", mainPath, fileName];
    [dict writeToFile:filePath atomically:YES];
    dict = [[NSMutableDictionary alloc]initWithContentsOfFile:filePath];
}

//缓存中的csv文件
+(NSString*) getDocumentPath:(NSString*)filePath directory:(NSSearchPathDirectory)directory{
    NSArray *dirArray = NSSearchPathForDirectoriesInDomains(directory, NSUserDomainMask, YES);
    NSString *path = [dirArray firstObject];
    if(filePath!=nil){
        path = [path stringByAppendingPathComponent:filePath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:path]) {
            NSError *err;
            [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&err];
            if (err) {
                NSLog(@"create cache file directory failed err:%@",err);
            }else {
                NSLog(@"create cache file directory succeed");
            }
        }
    }
    return path;
}
    
@end
