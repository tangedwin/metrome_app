//
//  HotCityListView.h
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
#import "PrefixHeader.h"
#import "YYModel.h"
#import "MetroMapHelper.h"

#import "CityModel.h"
#import "HttpHelper.h"

@interface HotCityListView : UICollectionView
@property(nonatomic,copy) void(^reloadCityData)(void);

@end

