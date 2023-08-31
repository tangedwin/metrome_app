//
//  RouteModel.h
//  MetroMap
//
//  Created by edwin on 2019/10/9.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StationModel.h"
#import "RouteSegmentModel.h"


@interface RouteModel : NSObject

@property (nonatomic, retain) NSString *identifyCode;
@property (nonatomic, retain) NSString *routeTime;
//地铁、打车
@property (nonatomic, retain) NSString *routeType;
@property (nonatomic, retain) StationModel *startStation;
@property (nonatomic, retain) StationModel *endStation;

@property (nonatomic, retain) NSMutableArray<RouteSegmentModel*> *segments;

@property (nonatomic, assign) NSInteger costTime;
@property (nonatomic, assign) NSInteger countStop;
@property (nonatomic, assign) NSInteger countTransfor;
@property (nonatomic, assign) NSInteger transforTime;
@property (nonatomic, assign) NSInteger costPrice;
@property (nonatomic, assign) NSInteger distance;
@property (nonatomic, assign) NSInteger distanceTransfor;

@property (nonatomic, retain) NSString *lastTime;
@property (nonatomic, retain) RouteSegmentModel *segmentLast;


@property (nonatomic, assign) BOOL detailQueried;

+(RouteModel*)createFakeModel;

-(NSString*)parseRouteModelToJSONStr;
@end

