//
//  LinesCollectionView.h
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

#import "StationCollectionView.h"

@interface LinesCollectionView : UICollectionView
@property(nonatomic,copy) void(^selectLine)(NSInteger index);


-(instancetype)initWithFrame:(CGRect)frame city:(CityModel*)city lines:(NSMutableArray*)lines;
-(void)selectLine:(NSInteger)index;

@end
