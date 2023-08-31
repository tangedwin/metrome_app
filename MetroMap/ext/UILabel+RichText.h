//
//  UILabel+JKRichText.h
//  OCTest
//
//  Created by 王冲 on 2018/8/14.
//  Copyright © 2018年 希爱欧科技有限公司. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RichText : NSObject

@property (nonatomic, copy) NSString *string;
@property (nonatomic, assign) NSRange range;

@end

@interface UILabel (RichText)

#pragma mark 是否显示点击效果，默认是打开
@property (nonatomic, assign) BOOL isShowTagEffect;

#pragma mark TagArray  点击的字符串数组
- (void)onTapRangeActionWithString:(NSArray <NSString *> *)TagArray tapClicked:(void (^) (NSString *string , NSRange range , NSInteger index))tapClick;


@end
