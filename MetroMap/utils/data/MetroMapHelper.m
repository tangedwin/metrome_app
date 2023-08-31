//
//  MetroMapHelper.m
//  MetroMap
//
//  Created by edwin on 2019/10/25.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "MetroMapHelper.h"

@interface MetroMapHelper()


@property(nonatomic, retain) LocationHelper *locationHelper;

@end

@implementation MetroMapHelper

//加载城市数据
-(void)loadMetroMap:(CityModel*)city success:(void(^)(void))success{
    BOOL download = YES;
    MBProgressHUD *hud = [MBProgressHUD showWaitingWithText:@"正在加载" image:nil inView:nil];
    NSMutableDictionary *localCityDict = [CityZipUtils readCityLatestVersionWithCityId];
    if(localCityDict && localCityDict[[NSString stringWithFormat:@"%ld",city.identifyCode]]){
        CityModel *localCity = localCityDict[[NSString stringWithFormat:@"%ld",city.identifyCode]];
        if(localCity.version >= city.version) download = NO;
    }
    if(download){
        __weak typeof(self) wkSelf = self;
        [CityZipUtils downloadZip:[NSString stringWithFormat:@"%@%@/%ld",Base_URL,request_data_download,city.identifyCode] city:city success:^{
            CityModel *showCity = [CityZipUtils parseFileToCityModel:city.identifyCode];
            [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",showCity.identifyCode] forKey:SELECTED_CITY_ID_KEY];
            [[NSUserDefaults standardUserDefaults] setObject:showCity.nameCn forKey:SELECTED_CITY_NAME_KEY];

            if ([NSThread isMainThread]) {
                [hud hideAnimated:YES];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hideAnimated:YES];
                });
            }
            if(success) [wkSelf successInMainThread:success];
        }];
    }else{
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",city.identifyCode] forKey:SELECTED_CITY_ID_KEY];
        [[NSUserDefaults standardUserDefaults] setObject:city.nameCn forKey:SELECTED_CITY_NAME_KEY];
        if ([NSThread isMainThread]) {
            [hud hideAnimated:YES];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
            });
        }
        if(success) success();
    }
}

//定位并匹配城市、加载城市,forceAlert表示是否强制弹出打开定位的弹出框
-(void)updateLocation:(void(^)(void))success loadData:(BOOL)loadData showAlert:(BOOL)showAlert forceAlert:(BOOL)forceAlert{
    if(!_locationHelper) _locationHelper = [[LocationHelper alloc] init];
    __weak typeof(self) wkSelf = self;
    MBProgressHUD *hud = showAlert?[MBProgressHUD showWaitingWithText:@"正在定位" image:nil inView:nil]:nil;
    [_locationHelper queryLocation:^(NSMutableDictionary *dict){
        NSString *cityNameCn = [dict[key_city] stringByReplacingOccurrencesOfString:@"市" withString:@""];
        [[NSUserDefaults standardUserDefaults] setObject:dict[key_loc] forKey:LOCATION_LOC_KEY];
        
        NSString * cityName = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_CITY_NAME_KEY];
        if(!cityName || ![cityName isEqualToString:cityNameCn] || loadData){
            //搜索城市匹配以下载该城市数据
            [[NSUserDefaults standardUserDefaults] setObject:cityNameCn forKey:CURRENT_CITY_NAME_KEY];
            NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
            [params setObject:cityNameCn forKey:@"keywords"];
            [params setObject:@"城市" forKey:@"type"];
            [[HttpHelper new] findList:request_city_search params:params page:0 progress:^(NSProgress *progress) {
            } success:^(NSMutableDictionary *responseDic) {
                NSMutableArray *stationArray = (NSMutableArray *)[responseDic mutableArrayValueForKey:@"list"];
                if(stationArray && stationArray.count>0){
                    //匹配到城市
                    StationModel *station = [StationModel yy_modelWithJSON:stationArray[0]];
                    if(station && station.city){
                        [[NSUserDefaults standardUserDefaults] setObject:station.city.nameCn forKey:CURRENT_CITY_NAME_KEY];
                        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", station.city.identifyCode] forKey:CURRENT_CITY_ID_KEY];
                        if(hud){
                            if ([NSThread isMainThread]) {
                                [hud hideAnimated:YES];
                            } else {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [hud hideAnimated:YES];
                                });
                            }
                        }
                        //加载数据
                        if(loadData) [wkSelf loadMetroMap:station.city success:success];
                        else if(success) [wkSelf successInMainThread:success];
                    }else{
                        if(hud){
                            if ([NSThread isMainThread]) {
                                [hud hideAnimated:YES];
                            } else {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    [hud hideAnimated:YES];
                                });
                            }
                        }
                        //数据异常
                        if(showAlert) [wkSelf showErrorTips:@"定位失败，数据异常"];
                    }
                }else if(loadData){
                    if(hud){
                        if ([NSThread isMainThread]) {
                            [hud hideAnimated:YES];
                        } else {
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [hud hideAnimated:YES];
                            });
                        }
                    }
                    [wkSelf loadMapWithoutData];
                }
            } failure:^(NSString *errorInfo) {
                if(hud){
                    if ([NSThread isMainThread]) {
                        [hud hideAnimated:YES];
                    } else {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [hud hideAnimated:YES];
                        });
                    }
                }
                //数据异常
                if(showAlert) [wkSelf showErrorTips:@"定位失败，数据异常"];
            }];
        }else{
            if(hud){
                if ([NSThread isMainThread]) {
                    [hud hideAnimated:YES];
                } else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [hud hideAnimated:YES];
                    });
                }
            }
            if(success) [wkSelf successInMainThread:success];
        }
    } failure:^(NSString *info){
        if(hud){
            if ([NSThread isMainThread]) {
                [hud hideAnimated:YES];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [hud hideAnimated:YES];
                });
            }
        }
        //定位失败
        if(showAlert) [wkSelf showErrorTips:@"定位失败，数据异常"];
    } showAlert:forceAlert];
}

-(void)loadMapWithoutData{
    //没有该城市的数据
    if ([NSThread isMainThread]) {
        [[AlertUtils new] alertWithConfirm:@"提示" content:@"您所在城市暂时还缺少轨道交通数据哦" withBlock:^{
            
        }];
    }else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AlertUtils new] alertWithConfirm:@"提示" content:@"您所在城市暂时还缺少轨道交通数据哦" withBlock:^{
                
            }];
        });
    }
}

-(void)showErrorTips:(NSString*)info{
    if ([NSThread isMainThread]) {
        [[AlertUtils new] showTipsView:info seconds:2.f];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[AlertUtils new] showTipsView:info seconds:2.f];
        });
    }
}

-(void)successInMainThread:(void(^)(void))block{
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            block();
        });
    }
}

@end
