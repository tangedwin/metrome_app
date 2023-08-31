//
//  MetroStationInfo.h
//  test-metro
//
//  Created by edwin on 2019/6/12.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetroLineInfo.h"

@interface MetroStationInfo : NSObject<NSSecureCoding>

@property (nonatomic, retain) NSNumber *identityNum;

//站点uid-线路方向uid列表
@property (nonatomic,retain) NSMutableDictionary *baiduUids;

@property (nonatomic, copy) NSString *stationName;

@property (nonatomic, copy) NSString *stationNameEn;

@property (nonatomic, copy) NSString *stationNamePy;

@property (nonatomic, copy) NSString *stationCode;

@property (nonatomic, copy) NSString *stationLogoImage;

@property (nonatomic, copy) NSString *transferType;

@property (nonatomic, retain) NSMutableArray *locations;

//线路名称-色号
@property (nonatomic, retain) NSDictionary *locationByLines;

@property (nonatomic, retain) NSMutableArray *relationStations;

@property (nonatomic, retain)NSNumber *status;


@property (nonatomic, retain) MetroLineInfo *line;

+(MetroStationInfo*)initWithNumber:(NSNumber*) identityNum stationName:(NSString*) stationName stationNameEn:(NSString*) stationNameEn stationNamePy:(NSString*) stationNamePy stationCode:(NSString*) stationCode stationLogoImage:(NSString*) stationLogoImage transferType:(NSString*) transferType locations:(NSMutableArray*)locations relationStations:(NSMutableArray*)relationStations;

@end
