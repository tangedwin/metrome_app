//
//  LocationHelper.h
//  MetroMap
//
//  Created by edwin on 2019/10/24.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import "StationModel.h"
#import "AddressModel.h"
#import "AlertUtils.h"
#import "HttpHelper.h"
#import "YYModel.h"

#define key_province @"province"
#define key_city @"city"
#define key_area @"area"
#define key_address @"address"
#define key_loc @"loc"
#define key_POIName @"POIName"
#define key_AOIName @"AOIName"
#define key_coordinate @"coordinate"
@interface LocationHelper : NSObject

-(void)queryLocation:(void(^)(NSMutableDictionary *dict))success failure:(void(^)(NSString *info))failure;
-(void)queryLocation:(void(^)(NSMutableDictionary *dict))success failure:(void(^)(NSString *info))failure showAlert:(BOOL)showAlert;

+(void) queryStationByAddress:(AddressModel*)address success:(void(^)(StationModel *station))success;
+(double) getDistanceBetweenLat1:(double)lat1 lon1:(double)lon1 lat2:(double)lat2 lon2:(double)lon2;
@end

