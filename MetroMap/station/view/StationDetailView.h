//
//  StationDetailView.h
//  MetroMap
//
//  Created by edwin on 2019/11/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultstageScrollViewHeader.h"
#import "StationInfoViewController.h"


@interface StationDetailView : UIScrollView

@property (nonatomic, assign) OffsetType offsetType;

@property (nonatomic, weak) StationInfoViewController *parentView;

@end

