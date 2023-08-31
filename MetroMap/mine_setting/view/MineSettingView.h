//
//  MineSetting.h
//  MetroMap
//
//  Created by edwin on 2019/10/8.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
#import "PrefixHeader.h"
#import "BaseViewController.h"
#import "LoginViewController.h"
#import "MyTripViewController.h"
#import "AboutUsViewController.h"
#import "RewardUsViewController.h"
#import "AddressListViewController.h"
#import <ShareSDK/ShareSDK.h>
#import <ShareSDKUI/ShareSDK+SSUI.h>
#import <ShareSDKUI/SSUIShareSheetConfiguration.h>
#import "FeedbackViewController.h"

#import "AddressCollectsView.h"
#import "UserModel.h"

@protocol MineSettingViewDeleaget<NSObject>

@required
- (void)pushViewController:(BaseViewController *)vc animated:(BOOL)animated;

@optional
@end

typedef NS_ENUM(NSInteger, UserFunctionType) {
    UserFunctionTypeVIPMember,
    UserFunctionTypeTrip,
    UserFunctionTypeWallet,
};
@interface MineSettingView : UICollectionView
@property(nonatomic,copy) void(^editCommenAddress)(NSMutableArray *addressArray);
@property (nonatomic, weak) id<MineSettingViewDeleaget> viewDelegate;

-(void)reloadAddressData;
-(void)reloadUserData;
-(void)updateCGColors;
@end

