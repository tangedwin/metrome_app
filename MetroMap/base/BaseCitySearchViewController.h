//
//  BaseCItySearchViewController.h
//  MetroMap
//
//  Created by edwin on 2019/10/9.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CityCollectionView.h"
#import "CitySearchView.h"

@interface BaseCitySearchViewController : BaseViewController

@property(nonatomic, assign) NSInteger cityId;
@property(nonatomic, retain) StationModel *defaultStation;

//是否全屏展示地铁图(hide tabbar)
@property(nonatomic, assign) BOOL mapTabbarHide;

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;

-(void)switchCityData;
//地图页设置起点终点站
-(void)setDefaultStation:(StationModel *)defaultStation forStart:(BOOL)start forEnd:(BOOL)end;
- (void)switchMapTabBar:(BOOL)hide duration:(float)duration;

-(BOOL)checkTapEnable;
@end

