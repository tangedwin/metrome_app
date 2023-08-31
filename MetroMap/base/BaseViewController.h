//
//  BaseViewController.h
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrefixHeader.h"
#import "MBProgressHUD+Customer.h"
#import "LocationHelper.h"

@interface BaseViewController : UIViewController

@property (nonatomic, strong) id<UINavigationControllerDelegate> defaultNCDelegate;


@property(nonatomic, retain) UIView *naviMask;
@property(nonatomic, retain) UIView *backButton;
@property(nonatomic, retain) UIView *cityPickerButton;
@property(nonatomic, retain) UITextField *searchBar;
@property(nonatomic, retain) UIImageView *menuButton;
@property(nonatomic, retain) UIView *messageButton;
@property(nonatomic, retain) UIImageView *settingButton;

@property(nonatomic, retain) LocationHelper *locationHelper;

-(void)naviBack:(UITapGestureRecognizer*)tap;
-(void)cityPicker:(UITapGestureRecognizer*)tap;
-(void)showMessageView:(UITapGestureRecognizer*)tap;
-(void)showSettingView:(UITapGestureRecognizer*)tap;

-(void) loadCityPickerButton;

-(float)mTabbarHeight;

-(void)updateLocation:(void(^)(NSMutableDictionary *dict))success;
-(void)reloadMessageButton:(NSInteger) messageCount;

@end

