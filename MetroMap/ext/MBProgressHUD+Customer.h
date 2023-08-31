//
//  my.h
//  ipet-photo
//
//  Created by edwin on 2019/9/17.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "MBProgressHUD.h"
#import "PrefixHeader.h"
#import "MBProgressHUDCustomView.h"

@interface MBProgressHUD (Customer)

//@brief 自定义视图
- (void)showCustomView:(NSString *)text detail:(NSString *)detail image:(UIImage *)image;


// @brief 等待视图（菊花）
+ (MBProgressHUD *)showWaitingWithText:(NSString *)text image:(UIImage*)image inView:(UIView *)view;
+ (MBProgressHUD *)showWaitingWithText:(NSString *)text image:(UIImage*)image inView:(UIView *)view delay:(CGFloat)delay;
//@brief 显示进度条(转圈)
+ (MBProgressHUD *)showProgressInView:(UIView *)view;
//圆环
- (void)showAnnularProgress:(CGFloat)progress;
//扇形
- (void)showProgress:(CGFloat)progress;

// @brief 显示信息
+ (MBProgressHUD *)showInfo:(NSString *)text detail:(NSString *)detail image:(UIImage*)image inView:(UIView *)view;


@end
