//
//  CommenAddressViewController.h
//  MetroMap
//
//  Created by edwin on 2019/10/30.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CommenAddressCollectionView.h"
#import "AddressModel.h"
#import "AddressSearchViewController.h"

@interface CommenAddressViewController : BaseViewController
-(instancetype)initWithAddressArray:(NSMutableArray*)addressArray;

-(void) setAddress:(AddressModel*)address city:(CityModel*)city forIndex:(NSInteger)index;
@end

