//
//  BaseUtils.m
//  MetroMap
//
//  Created by edwin on 2019/7/3.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "BaseUtils.h"

@implementation BaseUtils

+ (NSString *)encryptStringWithString:(NSString *)string andKey:(NSString *)key{
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSData *encryptedData = [self encryptDataWithData:data Key:key gIv:@"A-16-Byte-String"];
    if(encryptedData) return [self base64EncodeData:encryptedData];
    else return nil;
}
+ (NSData *)encryptDataWithData:(NSData *)data Key:(NSString *)key gIv:(NSString*)iv{
     char keyPtr[kCCKeySizeAES128 + 1];
     bzero(keyPtr, sizeof(keyPtr));
     [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    char ivPtr[kCCKeySizeAES128+1];
    memset(ivPtr, 0, sizeof(ivPtr));
    [iv getCString:ivPtr maxLength:sizeof(ivPtr) encoding:NSUTF8StringEncoding];
    
     NSUInteger dataLength = [data length];
     size_t bufferSize = dataLength + kCCBlockSizeAES128;
     void *buffer = malloc(bufferSize);
     size_t numBytesEncrypted = 0;
     CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, kCCAlgorithmAES128, kCCOptionPKCS7Padding, keyPtr, kCCBlockSizeAES128,  ivPtr, [data bytes], dataLength, buffer, bufferSize, &numBytesEncrypted);
     if(cryptStatus == kCCSuccess) {
        return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
     }
     free(buffer);
     return nil;
}

+(NSString *)base64EncodeData:(NSData *)data{
    //2、对二进制数据进行base64编码，完成后返回字符串
    return [data base64EncodedStringWithOptions:0];
}

+ (NSString *)hexStringFromString:(NSDecimalNumber *)decimal{
    //10进制转换16进制（支持无穷大数）
    NSString *hex =@"";
    NSString *letter;
    NSDecimalNumber *lastNumber = decimal;
    for (int i = 0; i<999; i++) {
        NSDecimalNumber *tempShang = [lastNumber decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"16"]];
        NSString *tempShangString = [tempShang stringValue];
        if ([tempShangString containsString:@"."]) {
            // 有小数
            tempShangString = [tempShangString substringToIndex:[tempShangString rangeOfString:@"."].location];
            //            DLog(@"%@", tempShangString);
            NSDecimalNumber *number = [[NSDecimalNumber decimalNumberWithString:tempShangString] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"16"]];
            NSDecimalNumber *yushu = [lastNumber decimalNumberBySubtracting:number];
            int yushuInt = [[yushu stringValue] intValue];
            switch (yushuInt) {
                case 10:
                    letter =@"A"; break;
                case 11:
                    letter =@"B"; break;
                case 12:
                    letter =@"C"; break;
                case 13:
                    letter =@"D"; break;
                case 14:
                    letter =@"E"; break;
                case 15:
                    letter =@"F"; break;
                default:
                    letter = [NSString stringWithFormat:@"%d", yushuInt];
            }
            lastNumber = [NSDecimalNumber decimalNumberWithString:tempShangString];
        } else {
            // 没有小数
            if (tempShangString.length <= 2 && [tempShangString intValue] < 16) {
                int num = [tempShangString intValue];
                if (num == 0) {
                    break;
                }
                switch (num) {
                    case 10:
                        letter =@"A"; break;
                    case 11:
                        letter =@"B"; break;
                    case 12:
                        letter =@"C"; break;
                    case 13:
                        letter =@"D"; break;
                    case 14:
                        letter =@"E"; break;
                    case 15:
                        letter =@"F"; break;
                    default:
                        letter = [NSString stringWithFormat:@"%d", num];
                }
                hex = [letter stringByAppendingString:hex];
                break;
            } else {
                letter = @"0";
            }
            lastNumber = tempShang;
        }
        
        hex = [letter stringByAppendingString:hex];
    }
    //    return hex;
    return hex.length > 0 ? hex : @"0";
}


+ (NSString *)stringToMD5:(NSString *)str {
    // 1.首先将字符串转换成UTF-8编码, 因为MD5加密是基于C语言的,所以要先把字符串转化成C语言的字符串
    const char *fooData = [str UTF8String];
    // 2.然后创建一个字符串数组,接收MD5的值
    unsigned char result[16];
    // 3.计算MD5的值, 这是官方封装好的加密方法:把我们输入的字符串转换成16进制的32位数,然后存储到result中
//    CC_MD5(fooData, strlen(fooData), result);
    CC_MD5(fooData, (unsigned int)strlen(fooData), result);
    /*
    第一个参数:要加密的字符串
    第二个参数: 获取要加密字符串的长度
    第三个参数: 接收结果的数组
    */
    // 4.创建一个字符串保存加密结果
    NSMutableString *saveResult = [NSMutableString string];
    // 5.从result 数组中获取加密结果并放到 saveResult中
    for (int i = 0; i < 16; i++) {
        [saveResult appendFormat:@"%02x", result[i]];
    }
    // x表示十六进制，%02X  意思是不足两位将用0补齐，如果多余两位则不影响
    return saveResult;
}


+(NSMutableDictionary*)dateByDict{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate *now;
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    now=[NSDate date];
    comps = [calendar components:unitFlags fromDate:now];
    
    NSMutableDictionary *date = [NSMutableDictionary new];
    if([comps weekday]) [date setObject:@([comps weekday]) forKey:@"weekday"];
    if([comps year]) [date setObject:@([comps year]) forKey:@"year"];
    if([comps month]) [date setObject:@([comps month]) forKey:@"month"];
    if([comps day]) [date setObject:@([comps day]) forKey:@"day"];
    if([comps hour]) [date setObject:@([comps hour]) forKey:@"hour"];
    if([comps minute]) [date setObject:@([comps minute]) forKey:@"minute"];
    if([comps second]) [date setObject:@([comps second]) forKey:@"second"];
    return date;
}


+(NSString*) hideWithPhone:(NSString*)phone{
    if(phone && phone.length>10){
        return [NSString stringWithFormat:@"%@****%@",[phone substringToIndex:3],[phone substringFromIndex:7]];
    }
    return phone;
}

+(UIImage *)combineImageUpImage:(UIImage *)image1  DownImage:(UIImage *)image2{
    if (image1 == nil) return image2;
    if (image2 == nil) return image1;
    CGFloat width = image1.size.width>image2.size.width?image1.size.width:image2.size.width;
    CGFloat height = image1.size.height  + image2.size.height;
    CGSize offScreenSize = CGSizeMake(width, height);
    // UIGraphicsBeginImageContext(offScreenSize);用这个重绘图片会模糊
    UIGraphicsBeginImageContextWithOptions(offScreenSize, NO, [UIScreen mainScreen].scale);
    
    CGRect rectUp = CGRectMake((width - image1.size.width)/2, 0, image1.size.width, image1.size.height);
    [image1 drawInRect:rectUp];
    
    CGRect rectDown = CGRectMake((width - image2.size.width)/2, rectUp.origin.y + rectUp.size.height, image2.size.width, image2.size.height);
    [image2 drawInRect:rectDown];
    
    UIImage* imagez = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imagez;
}

+ (UIImage *)thumbnailWithImageWithoutScale:(UIImage *)image size:(CGSize)asize{
    UIImage *newimage;
    if (nil == image){
        newimage = nil;
    } else {
        CGSize oldsize = image.size;
        CGRect rect;
        if (asize.width/asize.height > oldsize.width/oldsize.height){
            rect.size.width = asize.height*oldsize.width/oldsize.height;
            rect.size.height = asize.height;
            rect.origin.x = (asize.width - rect.size.width)/2;
            rect.origin.y = 0;
        } else {
            rect.size.width = asize.width;
            rect.size.height = asize.width*oldsize.height/oldsize.width;
            rect.origin.x = 0;
            rect.origin.y = (asize.height - rect.size.height)/2;
        }
        UIGraphicsBeginImageContext(asize);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(context, [[UIColor clearColor] CGColor]);
        UIRectFill(CGRectMake(0, 0, asize.width, asize.height));//clear background
        [image drawInRect:rect];
        newimage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    return newimage;

}

+ (UIViewController*)viewController:(UIView*)view {
    for (UIView* next = [view superview]; next; next = next.superview) {
        UIResponder* nextResponder = [next nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController*)nextResponder;
        }
    }
    return nil;
}

+(CGFloat)heightOfString:(NSString*)string withConstrainSize:(CGSize)size withAttributes:(NSDictionary*)attributes{
    CGFloat height = 0;
    string = [string stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    NSArray* stringArray = [string componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    for (NSString* string in stringArray) {
        if (string.length > 0) {
            CGRect bounds = [string boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attributes context:nil];
            height += bounds.size.height;
        }
    }
    return height;
}

+ (NSString *)decimalString:(float)floatNum maxNum:(NSInteger)num{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    formatter.numberStyle = NSNumberFormatterDecimalStyle;
    formatter.maximumFractionDigits = num;//最多保留几位小数，就是几
    formatter.groupingSeparator = @"";
    return [formatter stringFromNumber:[NSNumber numberWithFloat:floatNum]];
}

//字符串是否为纯数字
+(BOOL)isNum:(NSString *)checkedNumString {
    checkedNumString = [checkedNumString stringByTrimmingCharactersInSet:[NSCharacterSet decimalDigitCharacterSet]];
    if(checkedNumString.length > 0) {
        return NO;
    }
    return YES;
}

//颜色是否为浅色
+(BOOL)isLighterColor:(UIColor *)color {
    const CGFloat* components = CGColorGetComponents(color.CGColor);
    return (components[0]+components[1]+components[2])/3 >= 0.5;
}


+(NSInteger )getNowTimeTimestamp{
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss SSS"]; // ----------设置你想要的格式,hh与HH的区别:分别表示12小时制,24小时制
    
    //设置时区,这个对于时间的处理有时很重要
    
    NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    [formatter setTimeZone:timeZone];
    
    NSDate *datenow = [NSDate date];//现在时间,你可以输出来看下是什么格式
    
    return [datenow timeIntervalSince1970]*1000;
}


+ (NSString*)iphoneType {
    
    //需要导入头文件：#import <sys/utsname.h>
    
    struct utsname systemInfo;
    
    uname(&systemInfo);
    
    NSString*platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    
    if([platform isEqualToString:@"iPhone1,1"]) return @"iPhone 2G";
    
    if([platform isEqualToString:@"iPhone1,2"]) return @"iPhone 3G";
    
    if([platform isEqualToString:@"iPhone2,1"]) return @"iPhone 3GS";
    
    if([platform isEqualToString:@"iPhone3,1"]) return @"iPhone 4";
    
    if([platform isEqualToString:@"iPhone3,2"]) return @"iPhone 4";
    
    if([platform isEqualToString:@"iPhone3,3"]) return @"iPhone 4";
    
    if([platform isEqualToString:@"iPhone4,1"]) return @"iPhone 4S";
    
    if([platform isEqualToString:@"iPhone5,1"]) return @"iPhone 5";
    
    if([platform isEqualToString:@"iPhone5,2"]) return @"iPhone 5";
    
    if([platform isEqualToString:@"iPhone5,3"]) return @"iPhone 5c";
    
    if([platform isEqualToString:@"iPhone5,4"]) return @"iPhone 5c";
    
    if([platform isEqualToString:@"iPhone6,1"]) return @"iPhone 5s";
    
    if([platform isEqualToString:@"iPhone6,2"]) return @"iPhone 5s";
    
    if([platform isEqualToString:@"iPhone7,1"]) return @"iPhone 6 Plus";
    
    if([platform isEqualToString:@"iPhone7,2"]) return @"iPhone 6";
    
    if([platform isEqualToString:@"iPhone8,1"]) return @"iPhone 6s";
    
    if([platform isEqualToString:@"iPhone8,2"]) return @"iPhone 6s Plus";
    
    if([platform isEqualToString:@"iPhone8,4"]) return @"iPhone SE";
    
    if([platform isEqualToString:@"iPhone9,1"]) return @"iPhone 7";
    
    if([platform isEqualToString:@"iPhone9,2"]) return @"iPhone 7 Plus";
    
    if([platform isEqualToString:@"iPhone10,1"]) return @"iPhone 8";
    
    if([platform isEqualToString:@"iPhone10,4"]) return @"iPhone 8";
    
    if([platform isEqualToString:@"iPhone10,2"]) return @"iPhone 8 Plus";
    
    if([platform isEqualToString:@"iPhone10,5"]) return @"iPhone 8 Plus";
    
    if([platform isEqualToString:@"iPhone10,3"]) return @"iPhone X";
    
    if([platform isEqualToString:@"iPhone10,6"]) return @"iPhone X";
    
    if([platform isEqualToString:@"iPod1,1"]) return @"iPod Touch 1G";
    
    if([platform isEqualToString:@"iPod2,1"]) return @"iPod Touch 2G";
    
    if([platform isEqualToString:@"iPod3,1"]) return @"iPod Touch 3G";
    
    if([platform isEqualToString:@"iPod4,1"]) return @"iPod Touch 4G";
    
    if([platform isEqualToString:@"iPod5,1"]) return @"iPod Touch 5G";
    
    if([platform isEqualToString:@"iPad1,1"]) return @"iPad 1G";
    
    if([platform isEqualToString:@"iPad2,1"]) return @"iPad 2";
    
    if([platform isEqualToString:@"iPad2,2"]) return @"iPad 2";
    
    if([platform isEqualToString:@"iPad2,3"]) return @"iPad 2";
    
    if([platform isEqualToString:@"iPad2,4"]) return @"iPad 2";
    
    if([platform isEqualToString:@"iPad2,5"]) return @"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad2,6"]) return @"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad2,7"]) return @"iPad Mini 1G";
    
    if([platform isEqualToString:@"iPad3,1"]) return @"iPad 3";
    
    if([platform isEqualToString:@"iPad3,2"]) return @"iPad 3";
    
    if([platform isEqualToString:@"iPad3,3"]) return @"iPad 3";
    
    if([platform isEqualToString:@"iPad3,4"]) return @"iPad 4";
    
    if([platform isEqualToString:@"iPad3,5"]) return @"iPad 4";
    
    if([platform isEqualToString:@"iPad3,6"]) return @"iPad 4";
    
    if([platform isEqualToString:@"iPad4,1"]) return @"iPad Air";
    
    if([platform isEqualToString:@"iPad4,2"]) return @"iPad Air";
    
    if([platform isEqualToString:@"iPad4,3"]) return @"iPad Air";
    
    if([platform isEqualToString:@"iPad4,4"]) return @"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,5"]) return @"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,6"]) return @"iPad Mini 2G";
    
    if([platform isEqualToString:@"iPad4,7"]) return @"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad4,8"]) return @"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad4,9"]) return @"iPad Mini 3";
    
    if([platform isEqualToString:@"iPad5,1"]) return @"iPad Mini 4";
    
    if([platform isEqualToString:@"iPad5,2"]) return @"iPad Mini 4";
    
    if([platform isEqualToString:@"iPad5,3"]) return @"iPad Air 2";
    
    if([platform isEqualToString:@"iPad5,4"]) return @"iPad Air 2";
    
    if([platform isEqualToString:@"iPad6,3"]) return @"iPad Pro 9.7";
    
    if([platform isEqualToString:@"iPad6,4"]) return @"iPad Pro 9.7";
    
    if([platform isEqualToString:@"iPad6,7"]) return @"iPad Pro 12.9";
    
    if([platform isEqualToString:@"iPad6,8"]) return @"iPad Pro 12.9";
    
    if([platform isEqualToString:@"i386"]) return @"iPhone Simulator";
    
    if([platform isEqualToString:@"x86_64"]) return @"iPhone Simulator";
    
    return platform;
    
}

+(BOOL)validatePhoneNum:(NSString *)phone{
    /**
     手机号码 13[0-9],14[5|7|9],15[0-3],15[5-9],17[0|1|3|5|6|8],18[0-9]
     移动：134[0-8],13[5-9],147,15[0-2],15[7-9],178,18[2-4],18[7-8]
     联通：13[0-2],145,15[5-6],17[5-6],18[5-6]
     电信：133,1349,149,153,173,177,180,181,189
     虚拟运营商: 170[0-2]电信  170[3|5|6]移动 170[4|7|8|9],171 联通
     上网卡又称数据卡，14号段为上网卡专属号段，中国联通上网卡号段为145，中国移动上网卡号段为147，中国电信上网卡号段为149
     */
    NSString * MOBIL = @"^1(3[0-9]|4[579]|5[0-35-9]|7[01356]|8[0-9])\\d{8}$";
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBIL];
    if ([regextestmobile evaluateWithObject:phone]) {
        return YES;
    }
    return NO;
}

@end
