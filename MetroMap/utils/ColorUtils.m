//
//  ColorUtils.m
//  test-metro
//
//  Created by edwin on 2019/6/20.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "ColorUtils.h"

@implementation ColorUtils



+(UIColor*)getColor:(UIColor*)lightColor withDarkMode:(UIColor*)darkColor{
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trait) {
            if (trait.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return darkColor;
            } else {
                return lightColor;
            }
        }];
    } else {
        return lightColor;
    }
}
+(CGColorRef)getCGColor:(UIColor*)lightColor withDarkMode:(UIColor*)darkColor{
    if (@available(iOS 13.0, *)) {
        UIColor *dyColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull trait) {
            if (trait.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return darkColor;
            } else {
                return lightColor;
            }
        }];
//        UIColor *resolvedColor = [dyColor resolvedColorWithTraitCollection:previousTraitCollection];
//        return resolvedColor.CGColor;
        return dyColor.CGColor;
    } else {
        return lightColor.CGColor;
    }
}

+ (UIColor*)colorWithHexString:(NSString*)stringToConvert{
    return [self colorWithHexString:stringToConvert alpha:1.0f];
}

+ (UIColor*)colorWithHexString:(NSString*)stringToConvert alpha:(CGFloat)alpha{
    if([stringToConvert hasPrefix:@"#"]){
        stringToConvert = [stringToConvert substringFromIndex:1];
    }else if([stringToConvert hasPrefix:@"0x"]){
        stringToConvert = [stringToConvert substringFromIndex:2];
    }
    NSScanner *scanner = [NSScanner scannerWithString:stringToConvert];
    unsigned hexNum;
    if(![scanner scanHexInt:&hexNum]){
        return nil;
    }
    
    return [self colorWithRGBHex:hexNum alpha:alpha];
}

+ (UIColor*)colorWithRGBHex:(UInt32)hex alpha:(CGFloat)alpha{
    int r = (hex >>16) &0xFF;
    int g = (hex >>8) &0xFF;
    int b = (hex) &0xFF;
    return [UIColor colorWithRed:r /255.0f green:g /255.0f  blue:b /255.0f alpha:alpha];
}

@end
