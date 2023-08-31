//
//  StationAlert.h
//  MetroMap
//
//  Created by edwin on 2019/9/3.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewWithDraw.h"

#import "LineInfo.h"
#import "StationInfo.h"

#import "ViewUtils.h"
#import "ColorUtils.h"
#import "UIView+FrameChange.h"

@interface StationAlert : ViewWithDraw
    
@property(nonatomic, copy) void(^showLine)(LineInfo *line);
@property(nonatomic, copy) void(^signStation)(StationInfo *station, NSInteger type);
@property(nonatomic, copy) void(^showStationDetail)(StationInfo *station);


-(instancetype)initWithStation:(StationInfo*)station lines:(NSMutableArray*)lines type:(NSInteger)type;
    
@end

