//
//  AddressSearchView.h
//  MetroMap
//
//  Created by edwin on 2019/10/22.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "PrefixHeader.h"
#import "HttpHelper.h"
#import "MBProgressHUD+Customer.h"
#import "LocationHelper.h"

#import "StationModel.h"
#import "UserModel.h"
#import "AddressModel.h"
#import "CityZipUtils.h"

@interface AddressSearchView : UICollectionView
@property(nonatomic,copy) void(^selectedAddress)(AddressModel *address, CityModel *city);
@property(nonatomic,copy) void(^selectedStation)(StationModel *station, CityModel *city);

-(void)searchMap:(NSString*)keywords forStation:(BOOL)forStation;
@end
