//
//  AddressListViewController.h
//  MetroMap
//
//  Created by edwin on 2019/10/22.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "AddressCollectsView.h"
#import "AddressSearchView.h"
#import "CommenAddressViewController.h"
#import "StationInfoViewController.h"

@interface AddressListViewController : BaseViewController
-(instancetype)initWithStationFor:(NSInteger)type;
@end
