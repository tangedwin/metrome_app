//
//  HGDeviceHelper.h
//  HGPersonalCenter
//
//  Created by Arch on 2018/9/17.
//  Copyright © 2019 mint_bin@163.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface HGDeviceHelper : NSObject

+ (BOOL)isExistFringe;
+ (BOOL)isExistJaw;
+ (CGFloat)safeAreaInsetsTop;
+ (CGFloat)safeAreaInsetsBottom;

@end

