//
//  MetroLineInfo.h
//  test-metro
//
//  Created by edwin on 2019/6/12.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MetroLineInfo : NSObject<NSSecureCoding>

@property (nonatomic, retain) NSNumber *identityNum;

//baiduLineUid-方向名
@property (nonatomic, retain) NSMutableDictionary *baiduUids;

@property (nonatomic, copy) NSString *lineName;

@property (nonatomic, copy) NSString *lineNameEn;

@property (nonatomic, copy) NSString *lineCode;

@property (nonatomic, copy) NSString *lineColor;

@property (nonatomic, copy) NSString *lineBorderColor;

@property (nonatomic, copy) NSString *lineTextColor;

@property (nonatomic, copy) NSString *forwardName;

@property (nonatomic, copy) NSString *reverseName;

//顺序站点列表(换线一定是按外环顺序)
@property (nonatomic, retain) NSMutableArray *stationNumbers;

@property (nonatomic, retain) NSMutableArray *stations;

//支线
@property (nonatomic, retain) NSMutableArray *relationLineNumbers;

+(MetroLineInfo*)initWithNumber:(NSNumber*) identityNum lineName:(NSString*) lineName lineNameEn:(NSString*) lineNameEn lineCode:(NSString*) lineCode lineColor:(NSString*) lineColor lineBorderColor:(NSString*) lineBorderColor lineTextColor:(NSString*) lineTextColor forwardName:(NSString*) forwardName reverseName:(NSString*) reverseName stationNumbers:(NSMutableArray*)stationNumbers relationLineNumbers:(NSMutableArray*)relationLineNumbers;

@end
