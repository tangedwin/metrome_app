//
//  StationModel.h
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LineModel.h"
#import "CityModel.h"
#import "StationTimetableModel.h"
#import "StationDetailModel.h"

@interface StationModel : NSObject

@property (nonatomic, assign) NSInteger identifyCode;
@property (nonatomic, retain) NSString *nameCn;
@property (nonatomic, retain) NSString *nameCode;
@property (nonatomic, retain) NSString *nameEn;
@property (nonatomic, retain) NSString *namePy;
@property (nonatomic, retain) NSString *code;
@property (nonatomic, retain) NSString *iconUri;
@property (nonatomic, assign) float latitude;
@property (nonatomic, assign) float longitude;
@property (nonatomic, retain) NSString *baiduUid;
@property (nonatomic, retain) NSString *baiduPx;
@property (nonatomic, retain) NSString *baiduPy;
@property (nonatomic, retain) NSString *baiduName;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, assign) NSInteger status;

@property (nonatomic, retain) NSMutableArray *lines;
@property (nonatomic, retain) NSMutableArray<StationTimetableModel*> *timetable;
@property (nonatomic, retain) StationDetailModel *detailInfo;

//仅在搜索站点时返回线路及城市
@property (nonatomic, retain) NSMutableArray *lineModels;
@property (nonatomic, retain) CityModel *city;

+(StationModel*)parseStation:(NSDictionary *)dict;


+(StationModel*)createFakeModel:(NSString*)stationName;
+(StationModel*)createFakeModel;
@end

