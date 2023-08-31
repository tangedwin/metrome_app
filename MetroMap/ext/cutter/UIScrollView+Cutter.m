//
//  UIScrollView+Cutter.m
//  ScreenShotTest
//
//  Created by 张雷 on 14/10/26.
//  Copyright (c) 2014年 zhanglei. All rights reserved.
//

#import "UIScrollView+Cutter.h"

@implementation UIScrollView (Cutter)

/**
 *  根据视图尺寸获取视图截屏（一屏无法显示完整）,适用于UIScrollView UITableviewView UICollectionView UIWebView
 *
 *  @return UIImage 截取的图片
 */
- (UIImage *)scrollViewCutter{
    return [self scrollViewCutter:0 right:0 top:0 bottom:0];
}
- (UIImage *)scrollViewCutter:(CGFloat)margin_left right:(CGFloat)margin_right top:(CGFloat)margin_top bottom:(CGFloat)margin_bottom{
    //保存
    CGPoint savedContentOffset = self.contentOffset;
    CGRect savedFrame = self.frame;
    UIColor *savedBackgroundcolor = self.backgroundColor;
    
    self.contentOffset = CGPointZero;
    
    self.frame = CGRectMake(0, 0, self.contentSize.width+(margin_left+margin_right), self.contentSize.height+(margin_top+margin_bottom));
    if(!self.backgroundColor || [self.backgroundColor isEqual:[UIColor clearColor]]) self.backgroundColor = dynamic_color_white;
    
    UIImage *image = [self viewCutter];
    
    //还原数据
    self.contentOffset = savedContentOffset;
    self.frame = savedFrame;
    self.backgroundColor = savedBackgroundcolor;
    
    return image;
    
    
}

@end
