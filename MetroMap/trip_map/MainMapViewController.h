//
//  MainMapViewController.h
//  MetroMap
//
//  Created by edwin on 2019/10/9.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseCitySearchViewController.h"
#import "MainMapView.h"
#import "RouteInfoView.h"
#import "AddressListViewController.h"
#import "LineListViewController.h"
#import "GaodeMapViewController.h"
#import "ShowImageViewController.h"
#import "FeedbackViewController.h"

#import "FeedbackModel.h"

@interface MainMapViewController : BaseCitySearchViewController

-(void)setDefaultStation:(StationModel *)defaultStation forStart:(BOOL)start forEnd:(BOOL)end;
@end

