//
//  JKwideHighSize.m
//  大小取值
//
//  Created by 王冲 on 2017/2/19.
//  Copyright © 2017年 希爱欧科技有限公司. All rights reserved.
//

#import "WideHighSize.h"
#import "UIView+FrameChange.h"

@implementation WideHighSize

/**
 确定高与宽度的设置
 
 @param string 输入的内容
 @param font 字体的大小
 @param maxSize 最大宽高的设置
 @return cell.workExperienceContent.width = [WideHighSize string:jingyanPanduan sizeWithFont:[UIFont systemFontOfSize:12.f] maxSize:CGSizeMake(300, 12.f)].width+5;(一个文本的宽)
 */
+(CGSize)string:(NSString *)string sizeWithFont:(UIFont *)font maxSize:(CGSize)maxSize{
    
    NSDictionary *attrs = @{NSFontAttributeName:font};
    return [string boundingRectWithSize:maxSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:attrs context:nil].size;
}


/**
 富文本计算高度

 @param aString 富文本的字符串
 @param width 最大宽
 @param height 最大高
 @return 返回 CGSize
 */
+(CGSize)sizeLabelToFit:(NSMutableAttributedString *)aString width:(CGFloat)width height:(CGFloat)height{
    UILabel *tempLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, width, height)];
    tempLabel.attributedText = aString;
    tempLabel.numberOfLines = 0;
    [tempLabel sizeToFit];
    CGSize size = tempLabel.frame.size;
    size = CGSizeMake(tempLabel.width, tempLabel.height);
    return size;
}

/**
 点赞那里的处理，多个人名的处理
 
 @param goodArray 人名的数组
 @param font 字体的大小
 @param color 字体的颜色
 @return 返回富文本
 */
+(NSMutableAttributedString *)attributedStringArray:(NSArray *)goodArray withattributeFont:(UIFont*)font withattributeTextColor:(UIColor *)color{
    
    NSString *goodTotalString = [goodArray componentsJoinedByString:@" "];
    
    __block NSMutableAttributedString *newGoodString = [[NSMutableAttributedString alloc] initWithString:goodTotalString];
    [newGoodString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, goodTotalString.length)];

    //设置行距 实际开发中间距为0太丑了，根据项目需求自己把握
    NSMutableParagraphStyle *paragraphstyle = [[NSMutableParagraphStyle alloc] init];
    paragraphstyle.lineSpacing = 2;
    [newGoodString addAttribute:NSParagraphStyleAttributeName value:paragraphstyle range:NSMakeRange(0, goodTotalString.length)];
    
    //__block  NSString *totalStr = newGoodString.string;
    __block  NSUInteger jkLenth = 0;
    [goodArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       
       [newGoodString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(jkLenth,obj.length)];
        jkLenth = jkLenth+1+obj.length;
        
//        NSLog(@"打印==%@ jkLenth=%lu",obj,(unsigned long)jkLenth);
    

    }];

    
    
    return newGoodString;
}


@end
