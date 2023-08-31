//
//  DataUtils.m
//  test-metro
//
//  Created by edwin on 2019/6/16.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "DataUtils.h"
#import "MetroInfo.h"
#import "MetroLineInfo.h"
#import "MetroStationInfo.h"

@implementation DataUtils

+(void) saveImageToPlist:(UIImage*)image withName:(NSString*)pngName{
    NSData *imageData = UIImagePNGRepresentation(image);
    [self writeDataToPlist:@"metroMaps.plist" withKey:pngName withData:imageData];
}

+(UIImage*) findImageWithNameFromPlist:(NSString*)pngName{
    NSData *imageData = [self getDataFromPlist:@"metroMaps.plist" withKey:pngName];
    UIImage *_decodedImage = [UIImage imageWithData:imageData];
    return _decodedImage;
}

+(NSData*) findImageDataWithNameFromPlist:(NSString*)pngName{
    NSData *imageData = [self getDataFromPlist:@"metroMaps.plist" withKey:pngName];
    return imageData;
}

+(void) saveImage:(UIImage*)image withName:(NSString*)pngName withFilePath:(NSString*)filePath{
    NSString *path = [self getDocumentPath:filePath withName:pngName];
//    NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
    NSData *imageData = UIImagePNGRepresentation(image);
    NSLog(@"image scale is %.2f", image.scale);
    [imageData writeToFile:path atomically:YES];
}

+(UIImage*) findImageWithName:(NSString*)pngName withFilePath:(NSString*)filePath withScale:(float) scale{
    NSString *path = [self getDocumentPath:filePath withName:pngName];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        NSData *picData = [NSData dataWithContentsOfFile:path];
//        return [UIImage imageWithData:picData];
        UIImage *image = [[UIImage alloc] initWithData:picData scale:scale==0?1:scale];
        NSLog(@"image scale is %.2f", image.scale);
        return image;
    }
    return nil;
}

+(void) deleteImageWithName:(NSString*)pngName withFilePath:(NSString*)filePath{
    NSString *path = [self getDocumentPath:filePath withName:pngName];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",pngName]];
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        [[NSFileManager defaultManager]  removeItemAtPath:path error:nil];
    }
}

+(NSString*) getDocumentPath:(NSString*)filePath withName:(NSString*)fileName{
    NSArray *dirArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
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
    ///var/mobile/Containers/Data/Application/9644F99A-A851-4A08-A804-D6AC8F48E5B3/Documents/metroMaps
    ///Users/apple/Library/Developer/CoreSimulator/Devices/123290A4-8EAC-4ED3-8010-2DE7145689BA/data/Containers/Data/Application/44D496C0-43BB-4685-B05E-623BF79054F7/Documents/metroMaps
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", fileName]];
    return path;
}


#pragma mark - NSArchiver
+(NSData*) archiveData:(NSObject*) obj{
    if(obj==nil) return nil;
    // 归档
    NSError *error;
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:obj requiringSecureCoding:YES error:&error];
    NSLog(@"error : %@", error);
    return data;
}

+(NSObject*) unArchiveData:(NSData*) data withClasses:(NSSet<Class> *)classes{
    if(data==nil) return nil;
    // 解档
    NSError *error;
    NSObject *obj = [NSKeyedUnarchiver unarchivedObjectOfClasses:classes fromData:data error:&error];
    NSLog(@"error : %@", error);
    return obj;
    
}

#pragma mark --bundle
+(NSBundle*)getMyBundle{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"myMapBundle" ofType :@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    return bundle;
}
    
#pragma mark --bundle
+(NSURL*)getfilePathFromBundle:(NSString *)fileName withType:(NSString *)type{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"myMapBundle" ofType :@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSURL *url = [bundle URLForResource:fileName withExtension:type];
    return url;
}

+(NSData*)getDataFromBundlePlist:(NSString *)plistName withKey:(NSString *)key{
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"myMapBundle" ofType :@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
    NSURL *url = [bundle URLForResource:plistName withExtension:nil];
    NSMutableDictionary *sandBoxDataDic = [[NSMutableDictionary alloc]initWithContentsOfURL:url];
    if (sandBoxDataDic!=nil) {
        return sandBoxDataDic[key];
    }else{
        return nil;
    }
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

+(void)writeDataToPlist:(NSString*) plistName withKey:(NSString*)key withData:(NSData*) data {
    //这里使用位于沙盒的plist（程序会自动新建的那一个）
    NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [pathArray objectAtIndex:0];
    //获取文件的完整路径
    NSString *filePatch = [path stringByAppendingPathComponent:plistName];
    NSMutableDictionary *sandBoxDataDic = [[NSMutableDictionary alloc]initWithContentsOfFile:filePatch];
    if(sandBoxDataDic == nil){
         sandBoxDataDic = [[NSMutableDictionary alloc ] init];
    }
//    NSLog(@"old sandBox is %@",sandBoxDataDic);
    sandBoxDataDic[key] = data;
    [sandBoxDataDic writeToFile:filePatch atomically:YES];
    sandBoxDataDic = [[NSMutableDictionary alloc]initWithContentsOfFile:filePatch];
//    NSLog(@"new sandBox is %@",sandBoxDataDic);
}

#pragma mark - NSUserDefaults
+(void)writeDataToNSUserDefaults:(NSString*)key withData:(NSData*) data{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:data forKey:key];
    [userDefault synchronize];
}

+(NSData*)getDataFromNSUserDefaults:(NSString*)key{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    return [userDefault objectForKey:key];
}

@end
