//
//  StationDetailViewController.h
//  MetroMap
//
//  Created by edwin on 2019/6/24.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMenuAlert.h"
#import "ScreenSize.h"
#import "MetroStationInfo.h"
#import "MetroData.h"
#import "RouteUtils.h"


@interface StationDetailViewController : UIViewController

@property(nonatomic,retain) MetroStationInfo *sinfo;
@property(nonatomic,retain) MetroData *data;
@property(nonatomic,retain) NSMutableDictionary *lineStationTimes;
    
@property(nonatomic,assign)CGSize viewSize;
@property(nonatomic,assign)float navBarHeight;
    
@property(nonatomic,retain) FMenuAlert *stationInfoView;

@end
