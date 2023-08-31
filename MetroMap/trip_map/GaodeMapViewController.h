//
//  GaodeMapViewController.h
//  MetroMap
//
//  Created by edwin on 2019/10/24.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "BaseViewController.h"

#import "CityModel.h"

#import "CityZipUtils.h"

@interface GaodeMapViewController : BaseViewController

-(instancetype)initWithStation:(StationModel*)station;

@end
