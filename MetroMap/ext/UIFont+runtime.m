//
//  UIFont+runtime.m
//  MetroMap
//
//  Created by edwin on 2019/10/8.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "UIFont+runtime.h"

@implementation UIFont (runtime)

+ (void)load {
    // 获取替换后的类方法
    Method newMethod = class_getClassMethod([self class], @selector(adjustFont:size:));
    // 获取替换前的类方法
    Method method = class_getClassMethod([self class], @selector(fontWithName:size:));
    // 然后交换类方法，交换两个方法的IMP指针，(IMP代表了方法的具体的实现）
    method_exchangeImplementations(newMethod, method);
}

+ (UIFont *)adjustFont:(NSString*)fontName size:(CGFloat)fontSize {
    UIFont *newFont = nil;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    newFont = [UIFont adjustFont:fontName size:fontSize * screenWidth/MyUIScreen];
    return newFont;
}
@end
