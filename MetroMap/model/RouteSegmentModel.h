//
//  RouteSegmentModel.h
//  MetroMap
//
//  Created by edwin on 2019/10/9.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StationModel.h"
#import "LineModel.h"

@interface RouteSegmentModel : NSObject

@property (nonatomic, assign) NSInteger identifyCode;
@property (nonatomic, retain) StationModel *startStation;
@property (nonatomic, retain) StationModel *secondStation;
@property (nonatomic, retain) StationModel *endStation;

@property (nonatomic, retain) NSMutableArray<StationModel*> *stationsByWay;

@property (nonatomic, retain) NSString *startStationBaiduUid;
@property (nonatomic, retain) NSString *endStationBaiduUid;
@property (nonatomic, retain) LineModel *line;
@property (nonatomic, retain) DirectionModel *direction;
@property (nonatomic, retain) NSString *directionName;
@property (nonatomic, retain) NSString *transforType;
@property (nonatomic, assign) NSInteger transforTime;


@property (nonatomic, retain) NSString *firstTime;
@property (nonatomic, retain) NSString *lastTime;
@property (nonatomic, assign) NSInteger costTime;
@property (nonatomic, assign) NSInteger countStop;

+(RouteSegmentModel*)createFakeModel;
@end
