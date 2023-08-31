//
//  CityModel.h
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CityModel : NSObject

@property(nonatomic, assign) NSInteger identifyCode;
@property(nonatomic, retain) NSString *nameCn;
@property(nonatomic, retain) NSString *nameEn;
@property(nonatomic, retain) NSString *namePy;
@property(nonatomic, retain) NSString *nameFirstLetter;
@property(nonatomic, retain) NSString *updateTime;
@property(nonatomic, retain) NSString *hotCityImage;
@property(nonatomic, retain) NSString *hotCityImageDark;
@property(nonatomic, retain) NSString *iconUri;
@property(nonatomic, retain) NSString *baiduUid;
@property(nonatomic, assign) float contentSize;
@property(nonatomic, assign) NSInteger priority;
@property(nonatomic, assign) NSInteger version;
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;


@property(nonatomic, retain) NSMutableArray *lines;
@property(nonatomic, retain) NSMutableArray *stations;
//id->line
@property(nonatomic, retain) NSMutableDictionary *lineDicts;
@property(nonatomic, retain) NSMutableDictionary *stationDicts;

+(CityModel*)createFakeModel;
+(CityModel*)parseCity:(NSDictionary *)dict;

@end

