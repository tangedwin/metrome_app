//
//  UIScrollView+Cutter.h
//  ScreenShotTest
//
//  Created by 张雷 on 14/10/26.
//  Copyright (c) 2014年 zhanglei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Cutter.h"
#import "PrefixHeader.h"

@interface UIScrollView (Cutter)

/**
 *  根据视图尺寸获取视图截屏（一屏无法显示完整）,适用于UIScrollView UITableviewView UICollectionView UIWebView
 *
 *  @return UIImage 截取的图片
 */
- (UIImage *)scrollViewCutter;
- (UIImage *)scrollViewCutter:(CGFloat)margin_left right:(CGFloat)margin_right top:(CGFloat)margin_top bottom:(CGFloat)margin_bottom;

@end
