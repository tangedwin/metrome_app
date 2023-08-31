//
//  CommenAddressCollectionView.h
//  MetroMap
//
//  Created by edwin on 2019/10/30.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrefixHeader.h"
#import "AddressModel.h"
#import "AddressCollectsView.h"

@interface CommenAddressCollectionView : UICollectionView
@property(nonatomic,copy) void(^searchAddress)(NSInteger index, AddressModel *address);

-(void)loadAddressArray:(NSMutableArray*)addressArray;
@end

