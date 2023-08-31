//
//  CitySearchView.h
//  MetroMap
//
//  Created by edwin on 2019/10/8.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
#import "PrefixHeader.h"
#import "HttpHelper.h"
#import "YYModel.h"

#import "StationModel.h"
#import "CityModel.h"
#import "MetroMapHelper.h"
#import "MJChiBaoZiHeader.h"

@interface CitySearchView : UICollectionView
@property(nonatomic,copy) void(^reloadCityData)(void);
@property(nonatomic,copy) void(^reloadCityDataWithStation)(StationModel *station);

-(void) searchCityAndStations:(NSString*)keyword;
@end

