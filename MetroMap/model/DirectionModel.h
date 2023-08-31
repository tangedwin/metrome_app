//
//  DirectionModel.h
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <Foundation/Foundation.h>
@class StationModel;
@class LineModel;

@interface DirectionModel : NSObject

@property (nonatomic, assign) NSInteger identifyCode;
@property (nonatomic, assign) NSInteger reverseDirectionId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *directionName;
@property (nonatomic, retain) NSString *baiduUid;
@property (nonatomic, retain) NSMutableArray *stations;


@property (nonatomic, retain) StationModel *startStation;
@property (nonatomic, retain) StationModel *endStation;

@property (nonatomic, retain) LineModel *line;

+(DirectionModel*)createFakeModel;
@end

