//
//  StationList.h
//  MetroMap
//
//  Created by edwin on 2019/9/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LineInfo.h"
#import "StationInfo.h"

#import "MetroDataCache.h"

@interface StationListView : UIView

    /**
     点击回调,返回所点的角标以及点击的内容
     */
    @property(nonatomic, copy) void(^didSelectedCallback)(StationInfo *station, LineInfo *line);
    
    -(instancetype)initWithFrame:(CGRect)frame;
    
    -(void)setDefaultSelect:(NSString*)lineCode stationName:(NSString*) stationName;
@end
