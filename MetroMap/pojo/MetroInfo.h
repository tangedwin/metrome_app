//
//  MetroInfo.h
//  test-metro
//
//  Created by edwin on 2019/6/12.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetroLineInfo.h"
#import "MetroStationInfo.h"

@interface MetroInfo : NSObject<NSSecureCoding>

@property (nonatomic, retain) NSNumber *identityNum;

@property (nonatomic, retain) NSString *baiduUid;

@property (nonatomic, retain) NSMutableArray<MetroStationInfo *> *stations;
@property (nonatomic, retain) NSMutableArray<MetroLineInfo *> *lines;

@property (nonatomic, assign) float buttonSize;

+(MetroInfo*)initWithNumber:(NSNumber*)identityNum lines:(NSMutableArray*) lines stations:(NSMutableArray*)stations buttonSize:(float)buttonSize;

//+(MetroInfo*)initWithNumber:(long)identityNum lines:(NSMutableArray*) lines buttonSize:(float)buttonSize;

@end
