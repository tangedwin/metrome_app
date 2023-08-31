//
//  TripCollectionView.h
//  MetroMap
//
//  Created by edwin on 2019/10/9.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
#import "PrefixHeader.h"
#import "HttpHelper.h"
#import "LocationHelper.h"
#import "YYModel.h"

#import "StationCollectsHelper.h"
#import "StationModel.h"
#import "UserModel.h"
#import "AddressModel.h"
#import "MBProgressHUD+Customer.h"
#import "MJChiBaoZiHeader.h"

#define company_type @"company"
#define home_type @"family"
@interface AddressCollectsView : UICollectionView

-(instancetype)initWithFrame:(CGRect)frame withCommenAddress:(BOOL)withAddress;

@property(nonatomic,copy) void(^editCommenAddress)(NSMutableArray *addressArray);
@property(nonatomic,copy) void(^selectedStation)(StationModel *station);

-(void)reloadAddressData;
@end
