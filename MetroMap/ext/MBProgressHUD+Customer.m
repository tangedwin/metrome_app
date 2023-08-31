//
//  my.m
//  ipet-photo
//
//  Created by edwin on 2019/9/17.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "MBProgressHUD+Customer.h"
#import "YYAnimatedImageView.h"
@implementation MBProgressHUD (Customer)

#pragma mark - create function
+ (instancetype)createWithView:(UIView *)view {
    if (view == nil) {
        view = [[UIApplication sharedApplication].delegate window];
    }
    MBProgressHUD * hud = [[MBProgressHUD alloc] initWithView:view];
    hud.removeFromSuperViewOnHide = YES;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = kRGBA(0, 0, 0, 0.5);
    hud.backgroundColor = kRGBA(0, 0, 0, 0.1);
    hud.layer.shadowColor = kRGBA(0, 0, 0, 0.1).CGColor;
    hud.layer.shadowOffset = CGSizeMake(0,0);
    hud.layer.shadowOpacity = 1;
    hud.layer.shadowRadius = 8;
    hud.layer.cornerRadius = 8;
    [view addSubview:hud];
    [view bringSubviewToFront:hud];
    [hud showAnimated:YES];
    hud.minSize = CGSizeMake(50, 50);
    return hud;
}

#pragma mark - show loading
+ (MBProgressHUD *)showWaitingWithText:(NSString *)text image:(UIImage*)image inView:(UIView *)view{
    return [self showWaitingWithText:text image:image inView:view delay:10];
}
+ (MBProgressHUD *)showWaitingWithText:(NSString *)text image:(UIImage*)image inView:(UIView *)view delay:(CGFloat)delay{
    MBProgressHUD * hud = [MBProgressHUD createWithView:view];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [dynamic_color_lightwhite colorWithAlphaComponent:1];
    if(image){
        hud.mode = MBProgressHUDModeCustomView;
        MBProgressHUDCustomView *view = [[MBProgressHUDCustomView alloc] initWithFrame:CGRectMake(0, 0, 96, 96)];
        YYAnimatedImageView * imageView = [[YYAnimatedImageView alloc] initWithImage:image];
        imageView.frame = CGRectMake(0, 0, 96, 96);
        [view addSubview:imageView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 75, 96, 17)];
        label.text = text;
        label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        label.textColor = [dynamic_color_black colorWithAlphaComponent:0.5];
        label.textAlignment = NSTextAlignmentCenter;
        [view addSubview:label];
        
        hud.customView = view;
        hud.margin = 0;
    }else{
        hud.label.text = text;
        hud.label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:12];
        hud.label.textColor = [dynamic_color_black colorWithAlphaComponent:0.5];
    }
    [hud hideAnimated:YES afterDelay:delay];
    return hud;
}

#pragma mark - show progress
+ (MBProgressHUD *)showProgressInView:(UIView *)view {
    MBProgressHUD * hud = [MBProgressHUD createWithView:view];
    [hud setProgress:0];
    return hud;
}

- (void)showAnnularProgress:(CGFloat)progress{
    self.mode = MBProgressHUDModeAnnularDeterminate;
    self.progress = progress;
}

- (void)showProgress:(CGFloat)progress {
    self.mode = MBProgressHUDModeDeterminate;
    [self setProgress:progress];
}

#pragma mark - show tips
+ (MBProgressHUD *)showInfo:(NSString *)text detail:(NSString *)detail image:(UIImage*)image inView:(UIView *)view {
    MBProgressHUD * hud = [MBProgressHUD createWithView:view];
    [hud showCustomView:text detail:detail image:image];
    return hud;
}

#pragma mark - show customView
- (void)showCustomView:(NSString *)text detail:(NSString *)detail image:(UIImage *)image {
    if(self.customView) self.customView = nil;
    if(image){
        UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
        self.customView = imageView;
        self.mode = MBProgressHUDModeCustomView;
    }
    self.bezelView.backgroundColor = kRGBA(0, 0, 0, 0.5);
    self.label.text = text;
    self.contentColor = [dynamic_color_black colorWithAlphaComponent:0.8];
    self.label.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
    self.detailsLabel.text = detail;
    self.mode = MBProgressHUDModeText;
    self.margin = 14;
    [self hideAnimated:YES afterDelay:2];
}

@end
