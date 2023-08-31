//
//  StationCollectionView.h
//  MetroMap
//
//  Created by edwin on 2019/10/22.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
#import "PrefixHeader.h"
#import "CityZipUtils.h"

#import "CityModel.h"
#import "LineModel.h"
#import "StationModel.h"

@interface StationCollectionView : UICollectionView
-(instancetype)initWithFrame:(CGRect)frame city:(CityModel*)city line:(LineModel*)line;

@property(nonatomic,copy) void(^showStationInfo)(CityModel *city, StationModel *station);
@end

