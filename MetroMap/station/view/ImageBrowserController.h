//
//  ImageReview.h
//  MetroMap
//
//  Created by edwin on 2019/11/26.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ImageBrowserHelper.h"
#import "PrefixHeader.h"
#import "Masonry.h"

#import "BaseViewController.h"

@interface ImageBrowserController : BaseViewController
- (instancetype)initWithType:(ImageSourceType)type imageArr:(NSArray *)imageArr selectIndex:(NSInteger)selectIndex;

@end

