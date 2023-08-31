//
//  ShowImageViewController.h
//  ScreenShotTest
//
//  Created by 张雷 on 14/10/26.
//  Copyright (c) 2014年 zhanglei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrefixHeader.h"

@interface ShowImageViewController : UIViewController

@property(nonatomic,copy) void(^shareImage)(void);
@property(nonatomic,copy) void(^shareText)(void);


@property (nonatomic,retain) UIImage *image;

@end
