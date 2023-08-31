//
//  AddressModel.h
//  MetroMap
//
//  Created by edwin on 2019/10/30.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AddressModel : NSObject

@property(nonatomic, assign) NSInteger identifyCode;
@property(nonatomic, assign) NSInteger userId;
@property(nonatomic, retain) NSString *addressName;
@property(nonatomic, retain) NSString *address;
@property(nonatomic, retain) NSString *type;
@property(nonatomic, assign) NSInteger cityId;
@property(nonatomic, retain) NSString *cityName;
@property(nonatomic, assign) float longitude;
@property(nonatomic, assign) float latitude;

@end

