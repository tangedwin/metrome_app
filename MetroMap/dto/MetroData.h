//
//  MetroData.h
//  MetroMap
//
//  Created by edwin on 2019/6/22.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetroInfo.h"
#import "CityInfo.h"
#import "MapInfo.h"
#import "RouteInfo.h"
#import "DataUtils.h"
#import "RouteUtils.h"
#import "UIImage+YHPDFIcon.h"
#import "HGMacro.h"

#import "UIImage+SVGManager.h"
#import "SVGKImage.h"

#define USER_PLIST (NSString*)(@"mapInfo.plist")
#define DATA_PLIST (NSString*)(@"metro.plist")

@interface MetroData : NSObject

@property(nonatomic, copy) void(^alertSomething)(NSInteger *type, NSString *content);

@property(nonatomic, copy) void(^showStationInfo)(NSString *stationName, NSString *stationLogo, NSMutableArray *lineNames, NSMutableArray* lineColors);

@property(nonatomic, copy) void(^showRouteDetail)(NSInteger index);

@property(nonatomic, copy) void(^hideStationSign)(NSInteger *index);

//城市数据
@property(nonatomic,retain)NSMutableArray *cities;

//当前城市地铁数据
@property(nonatomic,retain)CityInfo *cityInfo;
@property(nonatomic,retain)MapInfo *mapInfo;
@property(nonatomic,retain)MetroInfo *metroInfo;
@property(nonatomic,retain)MetroStationInfo *stationInfo;
@property(nonatomic,retain)MetroStationInfo *startStationInfo;
@property(nonatomic,retain)MetroStationInfo *endStationInfo;

@property(nonatomic,retain)NSMutableArray *routeList;
@property(nonatomic,assign)NSInteger curRouteIndex;

@property(nonatomic,assign)CGPoint stationLocation;
@property(nonatomic,assign)CGPoint startStationLocation;
@property(nonatomic,assign)CGPoint endStationLocation;
@property(nonatomic,assign)CGPoint showStationInfoLocation;

@property(nonatomic,copy)NSString *errorMsg;

+(MetroData*) initDataWithCityCode:(NSString*)cityCode;

-(BOOL)checkData;
-(BOOL)checkCities;
-(BOOL)checkMetro;

-(UIImage*)getMetroImage;
-(SVGKLayeredImageView*)getMetroSVGImage;

-(CGPoint)getStationLocationWithIndex:(NSInteger)index orStation:(NSObject*)station;
-(void)queryRouteData;
-(NSMutableArray*)getRouteStationLocations:(NSInteger) index;

-(void)clearStationSign;

-(void)tapStation:(CGPoint)point scrollOffset:(CGPoint)scrollOffset scale:(float)scale barHeight:(CGFloat)barHeight;
@end
