//
//  CityZipUtils.h
//  MetroMap
//
//  Created by edwin on 2019/10/19.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NSObject+YYModel.h>

#import "YYModel.h"
#import "ZipArchive.h"

#import "CityModel.h"
#import "LineModel.h"
#import "StationModel.h"

@interface CityZipUtils : NSObject

+(long long) getCacheSize;
+(void) cleanAllCache;
+(NSString*) getMapPath:(NSInteger)cityId darkMode:(BOOL) dark;

+ (void)downloadZip:(NSString *)zipUrl city:(CityModel*)city success:(void(^)(void))success;
+(NSMutableDictionary *)readCityLatestVersionWithCityId;

+ (CityModel*) parseFileToCityModel:(NSInteger)cityId;
@end
