//
//  mapInfo.h
//  test-metro
//
//  Created by edwin on 2019/6/21.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapInfo : NSObject<NSSecureCoding>

@property (nonatomic, retain) NSNumber *scale;
@property (nonatomic, retain) NSNumber *rate;

@end
