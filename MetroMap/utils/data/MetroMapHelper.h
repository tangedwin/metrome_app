//
//  MetroMapHelper.h
//  MetroMap
//
//  Created by edwin on 2019/10/25.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LocationHelper.h"
#import "MBProgressHUD+Customer.h"

#import "CityModel.h"
#import "LineModel.h"
#import "StationModel.h"
#import "CityZipUtils.h"
#import "HttpHelper.h"

@interface MetroMapHelper : NSObject

-(void)loadMetroMap:(CityModel*)city success:(void(^)(void))success;

-(void)updateLocation:(void(^)(void))success loadData:(BOOL)loadData showAlert:(BOOL)showAlert forceAlert:(BOOL)forceAlert;

-(void)loadMapWithoutData;
@end
