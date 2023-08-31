//
//  StationInfoAlert.h
//  MetroMap
//
//  Created by edwin on 2019/10/10.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrefixHeader.h"
#import "StationModel.h"
#import "LineModel.h"

@interface StationInfoAlert : UIView

-(instancetype)initWithFrame:(CGRect)frame station:(StationModel*)station lines:(NSMutableArray*)lines;
    
@property(nonatomic, copy) void(^showLine)(LineModel *line);
@property(nonatomic, copy) void(^signStation)(StationModel *station, NSInteger type);
@property(nonatomic, copy) void(^showStationDetail)(StationModel *station);

-(void)updateCGColors;
@end

