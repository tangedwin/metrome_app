//
//  JKwideHighSize.h
//  大小取值
//
//  Created by 王冲 on 2017/2/19.
//  Copyright © 2017年 希爱欧科技有限公司. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface WideHighSize : NSObject

#pragma mark 确定高度的设置
+(CGSize)string:(NSString *)string sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize;

#pragma mark 富文本计算高度
+(CGSize)sizeLabelToFit:(NSMutableAttributedString *)aString width:(CGFloat)width height:(CGFloat)height;

#pragma mark 点赞那里的处理，多个人名的处理
+(NSMutableAttributedString *)attributedStringArray:(NSArray *)goodArray withattributeFont:(UIFont*)font withattributeTextColor:(UIColor *)color;


@end
