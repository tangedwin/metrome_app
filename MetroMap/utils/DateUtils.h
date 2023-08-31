//
//  DateUtils.h
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface DateUtils : NSObject

+ (NSString *)parseTime:(NSString*)dateTime;

+ (NSString *)time:(NSString*)dateTime beforeSeconds:(NSInteger)seconds;

+(BOOL) checkTime:(NSString*)time1 beforeTime:(NSString*)time2;
@end

