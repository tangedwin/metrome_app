//
//  MJChiBaoZiHeader.m
//  MetroMap
//
//  Created by edwin on 2019/11/5.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "MJChiBaoZiHeader.h"


@implementation MJChiBaoZiHeader
#pragma mark - 重写方法
#pragma mark 基本设置
- (void)prepare
{
    [super prepare];
    
    // 设置普通状态的动画图片
    NSMutableArray *idleImages = [NSMutableArray array];
    for (NSUInteger i = 1; i<=3; i++) {
        UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"about_us"]];
        [idleImages addObject:image];
    }
    [self setImages:idleImages forState:MJRefreshStateIdle];
    
    // 设置即将刷新状态的动画图片（一松开就会刷新的状态）
    NSMutableArray *refreshingImages = [NSMutableArray array];
    
    BOOL darkMode = NO;
    if (@available(iOS 13.0, *)) {
        if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
            darkMode = YES;
            for (NSUInteger i = 1; i<=12; i++) {
                UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"mj_loading_dark%zd",i]];
                if(image) [refreshingImages addObject:image];
            }
        }
    }
    if(!darkMode){
        for (NSUInteger i = 1; i<=12; i++) {
            UIImage *image = [UIImage imageNamed:[NSString stringWithFormat:@"mj_loading%zd",i]];
            if(image) [refreshingImages addObject:image];
        }
    }
    [self setImages:refreshingImages forState:MJRefreshStatePulling];
    
    // 设置正在刷新状态的动画图片
    [self setImages:refreshingImages forState:MJRefreshStateRefreshing];
}
@end
