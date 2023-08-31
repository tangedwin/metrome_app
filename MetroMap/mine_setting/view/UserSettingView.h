//
//  UserSettingView.h
//  MetroMap
//
//  Created by edwin on 2019/10/8.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "MBProgressHUD+Customer.h"
#import <YYWebImage/YYWebImage.h>
#import "PrefixHeader.h"
#import "BaseViewController.h"
#import "CityCollectionViewController.h"
#import "CommenAddressViewController.h"
#import "LoginViewController.h"

#import "CityZipUtils.h"
#import "UserModel.h"

@protocol UserSettingViewDeleaget<NSObject>

@required
- (void)pushViewController:(BaseViewController *)vc animated:(BOOL)animated;

@optional
@end

@interface UserSettingView : UICollectionView
@property (nonatomic, weak) id<UserSettingViewDeleaget> viewDelegate;

-(void)reloadSettingData;

@end

