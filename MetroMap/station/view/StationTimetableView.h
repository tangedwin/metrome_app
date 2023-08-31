//
//  LinesCollectionView.h
//  MetroMap
//
//  Created by edwin on 2019/10/22.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
#import "Masonry.h"
#import "PrefixHeader.h"
#import "CityZipUtils.h"

#import "CityModel.h"
#import "LineModel.h"
#import "StationModel.h"
#import "StationTimetableCellView.h"

@interface StationTimetableView : UICollectionView
@property (nonatomic, retain) LineModel *selectedLine;

@property(nonatomic,copy) void(^selectLine)(NSInteger index);
@property(nonatomic,copy) void(^resetTimetableHeight)(CGFloat height);


-(instancetype)initWithFrame:(CGRect)frame station:(StationModel*)station lines:(NSMutableArray*)lines city:(CityModel*)city;
-(void)selectLine:(NSInteger)index;

@end
