//
//  StationDetailViewController.h
//  MetroMap
//
//  Created by edwin on 2019/10/23.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <YYWebImage/YYWebImage.h>
#import "UIImage+ImgSize.h"
#import "BaseViewController.h"
#import "BaseCitySearchViewController.h"

#import "HttpHelper.h"
#import "StationTimetableView.h"
#import "LineNameCollectionView.h"
#import "GaodeMapViewController.h"
#import "MultstageScrollViewHeader.h"
#import "ImageBrowserHelper.h"

#import "FeedbackModel.h"
#import "FeedbackViewController.h"

@interface StationInfoViewController : BaseViewController
@property(nonatomic,assign) NSInteger selectedType;
@property(nonatomic,assign) BOOL hideTabbar;

@property (nonatomic, assign) OffsetType offsetType;

-(instancetype)initWithCity:(CityModel*)city lines:(NSMutableArray*)lines selectedLine:(LineModel*)line station:(StationModel*)station;


@end

