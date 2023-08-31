//
//  CityCollectionView.h
//  MetroMap
//
//  Created by edwin on 2019/10/8.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
#import "PrefixHeader.h"
#import "MBProgressHUD+Customer.h"

#import "AlertUtils.h"
#import "HttpHelper.h"
#import "CityZipUtils.h"
#import "LocationHelper.h"

#import "MetroMapHelper.h"

#import "CityModel.h"

@interface CityCollectionView : UICollectionView
@property(nonatomic,copy) void(^reloadCityData)(void);

@property(nonatomic, retain) LocationHelper *locationHelper;
@property(nonatomic, assign) BOOL withoutHeader;
@property(nonatomic, assign) BOOL onlyLocal;

-(void)beforeDisappear;
- (void)loadRemoteCityList;
@end

