//
//  CityCollectionViewController.h
//  MetroMap
//
//  Created by edwin on 2019/10/29.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "HttpHelper.h"
#import "CityCollectionView.h"

@interface CityCollectionViewController : BaseViewController

//1所有城市 2本地城市
@property(nonatomic, assign) NSInteger type;

@end
