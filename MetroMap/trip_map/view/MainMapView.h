//
//  MainMapView.h
//  MetroMap
//
//  Created by edwin on 2019/10/9.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "PrefixHeader.h"
#import "YYImage.h"

#import "CityModel.h"
#import "CityZipUtils.h"

#import "CustomerView.h"
#import "StationListView.h"
#import "StationInfoAlert.h"
#import "LXPositionView.h"

#import "MetroDataCache.h"
#import "MetroRouteQuery.h"

#import "RouteModel.h"
#import "RouteHelpManager.h"
#import "HttpHelper.h"
#import "LocationHelper.h"
#import "MBProgressHUD+Customer.h"

@interface MainMapView : UIView
@property(nonatomic,copy) void(^showRouteInfoView)(RouteHelpManager *routeHelper);
@property(nonatomic,copy) void(^switchTabbar)(void);
@property(nonatomic,copy) void(^switchRouteStation)(StationModel *start, StationModel *end);
@property(nonatomic,copy) void(^requestForRoute)(StationModel *station, BOOL isStart);
@property(nonatomic,copy) void(^showStationInfo)(CityModel *city, LineModel *line, StationModel *station);
@property(nonatomic,copy) void(^switchCityData)(void);

@property(nonatomic,retain)WKWebView *webView;
    
@property(nonatomic,assign)CGPoint stationPoint;
@property(nonatomic,assign)NSInteger stationAlertType;
@property(nonatomic, retain) StationModel *defaultStation;
@property (nonatomic, assign) BOOL scriptAdded;

-(void)showRouteLine:(NSInteger)index;
-(void)closeRouteShow;
- (void)beforeViewAppear;
- (void)beforeViewDisappear;
- (void)loadMapView;
-(void)updateLocation;
-(void)setDefaultStation:(StationModel *)defaultStation forStart:(BOOL)start forEnd:(BOOL)end scroll:(BOOL)scroll;
-(void)setNearbyStationForStart:(BOOL)start end:(BOOL)end scroll:(BOOL)scroll;

-(void)updateCGColors;

//-(void)setDefaultStation:(StationModel *)defaultStation forStart:(BOOL)start withNearbyStation:(BOOL)nearBy;

@end
