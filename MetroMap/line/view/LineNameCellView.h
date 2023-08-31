//
//  LineNameCellView.h
//  MetroMap
//
//  Created by edwin on 2019/11/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
#import "PrefixHeader.h"
#import "CityZipUtils.h"

#import "CityModel.h"
#import "LineModel.h"
#import "StationModel.h"

@interface LineNameCellView : UICollectionViewCell

@property(nonatomic, retain) UIView *view;
@property(nonatomic, retain) UILabel *label;

-(void)loadCell:(LineModel*)line indexPath:(NSIndexPath*)indexPath selected:(BOOL)selected;

@end
