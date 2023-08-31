//
//  DataUtils.h
//  test-metro
//
//  Created by edwin on 2019/6/16.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetroInfo.h"

@interface DataUtils : UIView
+(NSData*) archiveData:(NSObject*) obj;
+(NSObject*) unArchiveData:(NSData*) data withClasses:(NSSet<Class> *)classes;
+(NSData*)getDataFromPlist:(NSString*) plistName withKey:(NSString*) key;
+(void)writeDataToPlist:(NSString*) plistName withKey:(NSString*)key withData:(NSData*) data;
+(void)writeDataToNSUserDefaults:(NSString*)key withData:(NSData*) data;
+(NSData*)getDataFromNSUserDefaults:(NSString*)key;

+(NSBundle*)getMyBundle;
    
+(void) saveImageToPlist:(UIImage*)image withName:(NSString*)pngName;
+(UIImage*) findImageWithNameFromPlist:(NSString*)pngName;
+(NSData*) findImageDataWithNameFromPlist:(NSString*)pngName;

+(void) saveImage:(UIImage*)image withName:(NSString*)pngName withFilePath:(NSString*)filePath;
+(UIImage*) findImageWithName:(NSString*)pngName withFilePath:(NSString*)filePath withScale:(float) scale;
+(void) deleteImageWithName:(NSString*)pngName withFilePath:(NSString*)filePath;

+(NSURL*)getfilePathFromBundle:(NSString *)fileName withType:(NSString *)type;
+(NSData*)getDataFromBundlePlist:(NSString *)plistName withKey:(NSString *)key;
@end

