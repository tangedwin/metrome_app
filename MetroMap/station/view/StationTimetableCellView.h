//
//  StationTimetableCellView.h
//  MetroMap
//
//  Created by edwin on 2019/11/3.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrefixHeader.h"
#import "Masonry.h"

#import "LineModel.h"
#import "DirectionModel.h"


@interface StationTimetableCellView : UICollectionViewCell

@property (nonatomic, assign) CGFloat cellheight;
-(CGFloat)loadCellView:(NSMutableArray*)timetable line:(LineModel*)line city:(CityModel*)city;

-(void)updateCGColors;
@end

