//
//  ColorUtils.h
//  test-metro
//
//  Created by edwin on 2019/6/20.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ColorUtils : NSObject

+ (UIColor*)colorWithHexString:(NSString*)stringToConvert;
+ (UIColor*)colorWithHexString:(NSString*)stringToConvert alpha:(CGFloat)alpha;
+(UIColor*)getColor:(UIColor*)lightColor withDarkMode:(UIColor*)darkColor;
+(CGColorRef)getCGColor:(UIColor*)lightColor withDarkMode:(UIColor*)darkColor;
@end
