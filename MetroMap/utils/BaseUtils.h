//
//  BaseUtils.h
//  MetroMap
//
//  Created by edwin on 2019/7/3.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCrypto.h>
#import <CommonCrypto/CommonDigest.h>
#import <sys/utsname.h>
@interface BaseUtils : UIView

+ (NSString *)encryptStringWithString:(NSString *)string andKey:(NSString *)key;

+ (NSString *)hexStringFromString:(NSDecimalNumber *)decimal;
+ (NSString *)stringToMD5:(NSString *)str;

+(NSMutableDictionary*)dateByDict;
+(UIImage *)combineImageUpImage:(UIImage *)image1  DownImage:(UIImage *)image2;
+(NSString*) hideWithPhone:(NSString*)phone;

+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize;
//获取view所在controller
+ (UIViewController*)viewController:(UIView*)view;

+(CGFloat)heightOfString:(NSString*)string withConstrainSize:(CGSize)size withAttributes:(NSDictionary*)attributes;

+ (NSString *)decimalString:(float)floatNum maxNum:(NSInteger)num;

+(BOOL)isNum:(NSString *)checkedNumString;

+(BOOL)isLighterColor:(UIColor *)color;

+(NSInteger )getNowTimeTimestamp;

+ (NSString*)iphoneType;

+(BOOL)validatePhoneNum:(NSString *)phone;
@end


