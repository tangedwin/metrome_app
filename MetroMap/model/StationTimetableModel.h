//
//  StationTimetable.h
//  MetroMap
//
//  Created by edwin on 2019/10/23.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface StationTimetableModel : NSObject
    
@property (nonatomic, assign) NSInteger directionId;
@property (nonatomic, assign) NSInteger reverseDirectionId;
@property (nonatomic, retain) NSString *directionName;
@property (nonatomic, assign) NSInteger first;
@property (nonatomic, assign) NSInteger last;

@property (nonatomic, retain) NSMutableArray *timetable;
@property (nonatomic, retain) NSMutableArray *special;


@property (nonatomic, retain) NSMutableArray *inweek;
@property (nonatomic, retain) NSMutableArray *bydate;


-(NSString*) findFirstTime;
-(NSString*) findLastTime;
@end

