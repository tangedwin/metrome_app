//
//  HomeCollectionView.h
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrefixHeader.h"

#import "MJRefresh.h"
#import "MJChiBaoZiHeader.h"

#import "HotCityListView.h"
#import "StationNearByView.h"
#import "RecommendArticleCollectionView.h"

@interface HomeCollectionView : UICollectionView
@property(nonatomic,copy) void(^showTimetable)(StationModel *station);
@property(nonatomic,copy) void(^showStationInfo)(StationModel *station);
@property(nonatomic,copy) void(^showExit)(StationModel *station);
@property(nonatomic,copy) void(^showNewsDetail)(NewsModel *newsInfo);
@property(nonatomic,copy) void(^reloadCityData)(void);

-(void)reloadNearByStation;
-(void)reloadNews;
@end
