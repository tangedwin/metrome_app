//
//  AdScrollView.h
//  MetroMap
//
//  Created by edwin on 2019/10/29.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrefixHeader.h"
#import "HttpHelper.h"

@interface AdScrollView : UIScrollView

/// 页码控制器
@property (nonatomic, strong) UIPageControl *pageControl;

-(instancetype) initWithFrame:(CGRect)frame viewArray:(NSArray*)viewArray;

@end

