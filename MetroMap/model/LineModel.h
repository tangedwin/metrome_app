//
//  LineModel.h
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DirectionModel.h"
#import "StationModel.h"

@interface LineModel : NSObject

@property (nonatomic, assign) NSInteger identifyCode;
@property (nonatomic, retain) NSString *nameCn;
@property (nonatomic, retain) NSString *nameEn;
@property (nonatomic, retain) NSString *nameSimple;
@property (nonatomic, retain) NSString *code;
@property (nonatomic, retain) NSString *iconUri;
@property (nonatomic, retain) NSString *color;
@property (nonatomic, retain) NSString *baiduUid;
@property (nonatomic, retain) NSString *type;
@property (nonatomic, assign) NSInteger status;

@property (nonatomic, retain) NSMutableArray *directions;

@property (nonatomic, retain) NSMutableArray *stations;



@property (nonatomic, retain) StationModel *startStation;
@property (nonatomic, retain) StationModel *endStation;
@property (nonatomic, retain) NSString *firstTime;
@property (nonatomic, retain) NSString *lastTime;

+(LineModel*)createFakeModel;

+(LineModel*)parseLine:(NSDictionary *)dict;
@end
