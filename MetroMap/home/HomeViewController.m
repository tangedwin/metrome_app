//
//  HomeViewController.m
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "HomeViewController.h"

@interface HomeViewController ()

@property(nonatomic, retain) HomeCollectionView *homeCollectionView;
@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.naviMask];
    [self.naviMask addSubview:self.cityPickerButton];
    [self.naviMask addSubview:self.searchBar];
    [self addHomeCollectionView];
    
    self.tabBarController.tabBar.layer.shadowColor = main_color_black.CGColor;
    self.tabBarController.tabBar.layer.shadowOffset = CGSizeMake(0, -5);
    self.tabBarController.tabBar.layer.shadowOpacity = 0.2;
    self.tabBarController.tabBar.layer.shadowRadius = 10;

//    __weak typeof(self) wkSelf = self;
//    [self updateLocation:^(NSMutableDictionary *dict){
//        if(!dict){
//            if(wkSelf.homeCollectionView) [wkSelf.homeCollectionView loadData];
//            return;
//        }
//        NSString *cityNameCn = [dict[key_city] stringByReplacingOccurrencesOfString:@"市" withString:@""];
//        [[NSUserDefaults standardUserDefaults] setObject:cityNameCn forKey:CURRENT_CITY_NAME_KEY];
//        [[NSUserDefaults standardUserDefaults] setObject:dict[key_loc] forKey:LOCATION_LOC_KEY];
//        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//        [params setObject:cityNameCn forKey:@"keywords"];
//        [params setObject:@"城市" forKey:@"type"];
//        [[HttpHelper new] findList:request_city_search params:params page:0 progress:^(NSProgress *progress) {
//        } success:^(NSMutableDictionary *responseDic) {
//            NSMutableArray *stationArray = (NSMutableArray *)[responseDic mutableArrayValueForKey:@"list"];
//            if(stationArray && stationArray.count>0){
//                StationModel *station = [StationModel yy_modelWithJSON:stationArray[0]];
//                if(station && station.city){
//                    NSString *selectedCity = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_CITY_NAME_KEY];
//                    if(selectedCity!=nil){
//                        [[NSUserDefaults standardUserDefaults] setObject:station.city.nameCn forKey:SELECTED_CITY_NAME_KEY];
//                        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", (long)station.city.identifyCode] forKey:SELECTED_CITY_ID_KEY];
//                        [wkSelf loadCityPickerButton];
//                        if(wkSelf.homeCollectionView) [wkSelf.homeCollectionView loadData];
//                    }
//                    [[NSUserDefaults standardUserDefaults] setObject:station.city.nameCn forKey:CURRENT_CITY_NAME_KEY];
//                    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", (long)station.city.identifyCode] forKey:CURRENT_CITY_ID_KEY];
//                }
//            }
//        } failure:^(NSString *errorInfo) {
//        }];
//    }];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    if(_homeCollectionView) [_homeCollectionView reloadNews];
//    if(self.homeCollectionView) [self.homeCollectionView loadData];
    __weak typeof(self) wkSelf = self;
    NSString *locationLoc = [[NSUserDefaults standardUserDefaults] objectForKey:LOCATION_LOC_KEY];
    [self updateLocation:^(NSMutableDictionary *dict){
        if(!dict){
            if(wkSelf.homeCollectionView) [wkSelf.homeCollectionView reloadNearByStation];
            return;
        }
        if(!dict[key_city] || !dict[key_loc]) return;
        NSString *cityNameCn = [dict[key_city] stringByReplacingOccurrencesOfString:@"市" withString:@""];
        [[NSUserDefaults standardUserDefaults] setObject:cityNameCn forKey:CURRENT_CITY_NAME_KEY];
        [[NSUserDefaults standardUserDefaults] setObject:dict[key_loc] forKey:LOCATION_LOC_KEY];
        
        if(locationLoc && dict[key_loc]){
            NSArray *larray = [locationLoc componentsSeparatedByString:@","];
            NSString *llatitude = [NSString stringWithFormat:@"%.4f",[larray[0] floatValue]];
            NSString *llongitude = [NSString stringWithFormat:@"%.4f",[larray[1] floatValue]];
            NSArray *darray = [dict[key_loc] componentsSeparatedByString:@","];
            NSString *dlatitude = [NSString stringWithFormat:@"%.4f",[darray[0] floatValue]];
            NSString *dlongitude = [NSString stringWithFormat:@"%.4f",[darray[1] floatValue]];
            //当经纬度完全相同时，不更新
            if([llatitude isEqualToString:dlatitude] && [llongitude isEqualToString:dlongitude]) return;
        }
        
        NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
        [params setObject:cityNameCn forKey:@"keywords"];
        [params setObject:@"城市" forKey:@"type"];
        [[HttpHelper new] findList:request_city_search params:params page:0 progress:^(NSProgress *progress) {
        } success:^(NSMutableDictionary *responseDic) {
            NSMutableArray *stationArray = (NSMutableArray *)[responseDic mutableArrayValueForKey:@"list"];
            if(stationArray && stationArray.count>0){
                StationModel *station = [StationModel yy_modelWithJSON:stationArray[0]];
                if(station && station.city){
                    NSString *selectedCity = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_CITY_NAME_KEY];
                    if(selectedCity==nil){
                        if(station.city.nameCn) [[NSUserDefaults standardUserDefaults] setObject:station.city.nameCn forKey:SELECTED_CITY_NAME_KEY];
                        if(station.city.identifyCode) [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", (long)station.city.identifyCode] forKey:SELECTED_CITY_ID_KEY];
                        [wkSelf loadCityPickerButton];
                        if(wkSelf.homeCollectionView) [wkSelf.homeCollectionView reloadNearByStation];
                    }
                    if(station.city.nameCn) [[NSUserDefaults standardUserDefaults] setObject:station.city.nameCn forKey:CURRENT_CITY_NAME_KEY];
                    if(station.city.identifyCode) [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", (long)station.city.identifyCode] forKey:CURRENT_CITY_ID_KEY];
                }
            }
        } failure:^(NSString *errorInfo) {
        }];
    }];
}

-(void)addHomeCollectionView{
    _homeCollectionView = [[HomeCollectionView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT-[self mTabbarHeight])];
    [self.view addSubview:_homeCollectionView];
    __weak typeof(self) wkSelf = self;
    [_homeCollectionView setShowTimetable:^(StationModel *station) {
        [wkSelf loadStationDetail:station type:0];
    }];
    [_homeCollectionView setShowStationInfo:^(StationModel *station) {
        [wkSelf loadStationDetail:station type:1];
    }];
    [_homeCollectionView setShowExit:^(StationModel *station) {
        [wkSelf loadStationDetail:station type:2];
    }];
    [_homeCollectionView setShowNewsDetail:^(NewsModel *newsInfo) {
        NewsDetailViewController *detailVC = [[NewsDetailViewController alloc] init];
        [detailVC loadNewsInfo:newsInfo];
        detailVC.hidesBottomBarWhenPushed = YES;
        [wkSelf.navigationController pushViewController:detailVC animated:YES];
    }];
    [_homeCollectionView setReloadCityData:^(void) {
        [wkSelf switchCityData];
    }];
    [_homeCollectionView reloadNearByStation];
}

-(void)loadStationDetail:(StationModel*)station type:(NSInteger)type{
    if(!station || !station.identifyCode) return;
    __weak typeof(self) wkSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:@(station.identifyCode) forKey:@"stationId"];
    [[HttpHelper new] findDetail:request_station_detail params:params progress:^(NSProgress *progress) {
    } success:^(NSMutableDictionary *responseDic) {
        StationModel *stationDetail = [StationModel yy_modelWithJSON:responseDic];
        StationInfoViewController *sVC = [[StationInfoViewController alloc] initWithCity:stationDetail.city lines:stationDetail.lineModels selectedLine:stationDetail.lineModels[0] station:stationDetail];
//        sVC.hidesBottomBarWhenPushed = YES;
        sVC.hideTabbar = YES;
        [wkSelf.navigationController pushViewController:sVC animated:YES];
    } failure:^(NSString *errorInfo) {
        
    }];
}


- (void)switchMapTabBar:(BOOL)hide duration:(float)duration{
    [UIView animateWithDuration:.2f animations:^{
        self.tabBarController.tabBar.hidden = hide;
    }];
}

@end
