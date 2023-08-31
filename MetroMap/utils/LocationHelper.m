//
//  LocationHelper.m
//  MetroMap
//
//  Created by edwin on 2019/10/24.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "LocationHelper.h"

@interface LocationHelper()<AMapLocationManagerDelegate>

@property (nonatomic, retain) AMapLocationManager *locationManager;
@end

@implementation LocationHelper

-(instancetype)init{
    self = [super init];
    _locationManager = [[AMapLocationManager alloc] init];
    [_locationManager setDesiredAccuracy:kCLLocationAccuracyHundredMeters];
    _locationManager.locationTimeout = 10;
    _locationManager.reGeocodeTimeout = 10;
    _locationManager.locatingWithReGeocode = YES;
    _locationManager.delegate = self;
    return self;
}
  

-(void)queryLocation:(void(^)(NSMutableDictionary *dict))success failure:(void(^)(NSString *info))failure{
    [self queryLocation:success failure:failure showAlert:NO];
}

-(void)queryLocation:(void(^)(NSMutableDictionary *dict))success failure:(void(^)(NSString *info))failure showAlert:(BOOL)showAlert{
    [self checkLocation:^{
        BOOL result = [self.locationManager requestLocationWithReGeocode:YES completionBlock:^(CLLocation *location, AMapLocationReGeocode *regeocode, NSError *error) {
            if(error){
                failure(error.description);
            }
            if(regeocode){
                NSMutableDictionary *dict = [NSMutableDictionary new];
                NSString *loc = [NSString stringWithFormat:@"%f,%f", location.coordinate.longitude, location.coordinate.latitude];
                if(loc) [dict setObject:loc forKey:key_loc];
                if(regeocode.district) [dict setObject:regeocode.district forKey:key_area];
                if(regeocode.city) [dict setObject:regeocode.city forKey:key_city];
                if(regeocode.province) [dict setObject:regeocode.province forKey:key_province];
                if(regeocode.formattedAddress) [dict setObject:regeocode.formattedAddress forKey:key_address];
                if(regeocode.POIName) [dict setObject:regeocode.POIName forKey:key_POIName];
                if(regeocode.AOIName) [dict setObject:regeocode.AOIName forKey:key_AOIName];
                if(success) success(dict);
            }
        }];
        if(!result) failure(@"定位失败");
    } showAlert:showAlert];
}

-(void)amapLocationManager:(AMapLocationManager *)manager doRequireLocationAuth:(CLLocationManager *)locationManager{
    
}


-(void)checkLocation:(void(^)(void))successBlock showAlert:(BOOL)showAlert{
    if([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedAlways)){
        if(successBlock) successBlock();
    }else{
        //记录已经弹出过网络提示框,下次将不再提示
        NSString *alertedLocation = [[NSUserDefaults standardUserDefaults] objectForKey:@"alerted_location"];
        if(!alertedLocation || showAlert){
            [[AlertUtils new] alertWithConfirm:@"提示" content:@"您还未开启定位服务，是否需要开启？" withBlock:^{
                NSURL *setingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                [[UIApplication sharedApplication] openURL:setingsURL options:@{} completionHandler:^(BOOL success) {
                    if(successBlock) successBlock();
                }];
            }];
            [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:@"alerted_location"];
        }
    }
}

+(void) queryStationByAddress:(AddressModel*)address success:(void(^)(StationModel *station))success{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:[NSString stringWithFormat:@"%f",address.longitude] forKey:@"longitude"];
    [params setObject:[NSString stringWithFormat:@"%f",address.latitude] forKey:@"latitude"];
    [params setObject:@(5000) forKey:@"radius"];
    
    [[HttpHelper new] findList:request_station_nearby params:params page:1 progress:nil success:^(NSMutableDictionary *responseDic) {
        NSMutableArray *resultArray = (NSMutableArray *)[responseDic mutableArrayValueForKey:@"list"];
        if(!resultArray) {
            success(nil);
            return;
        }
        NSMutableArray *stations = [NSMutableArray new];
        for(int i=0; i<resultArray.count && i<5; i++){
            NSDictionary *sdict = resultArray[i][@"station"];
            NSString *dist = resultArray[i][@"distance"];
            if(sdict && dist) {
                StationModel *nearbyStation = [StationModel yy_modelWithJSON:sdict];
                [stations addObject:nearbyStation];
            }
        }
        if(stations.count>1){
            //应当弹出选择
            success(stations[0]);
            return;
        }else if(stations.count==1){
            success(stations[0]);
            return;
        }
        success(nil);
    } failure:^(NSString *errorInfo) {
        success(nil);
    }];
}

+(double) getDistanceBetweenLat1:(double)lat1 lon1:(double)lon1 lat2:(double)lat2 lon2:(double)lon2{
    double radLat1 = lat1 * M_PI / 180.0;
    double radLat2 = lat2 * M_PI / 180.0;
    double a = radLat1 - radLat2;
    double b = lon1 * M_PI / 180.0 - lon2 * M_PI / 180.0;
    double s = 2 * asin(sqrt(pow(sin(a/2),2) + cos(radLat1)*cos(radLat2) * pow(sin(b/2), 2)));
    //s*地球半径（m）
    s = s * 6378137;
    return s;
}
@end
