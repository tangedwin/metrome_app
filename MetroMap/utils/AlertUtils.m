//
//  AlertUtils.m
//  ipet-photo
//
//  Created by edwin on 2019/8/1.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "AlertUtils.h"

@interface AlertUtils()
@property(nonatomic,retain) UIProgressView *progressView;
@property(nonatomic,retain) UIView *progressMaskView;

@property(nonatomic,assign) BOOL showProgressView;

@end

@implementation AlertUtils

- (UIAlertController *)showTipsView:(NSString*)content seconds:(float)seconds {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:content preferredStyle:UIAlertControllerStyleAlert];
    UIViewController *alertVC = [[UIViewController alloc]init];
    [[UIApplication sharedApplication].keyWindow  addSubview:alertVC.view];
    [alertVC presentViewController:alertController animated:YES completion:^{
        [alertVC.view removeFromSuperview];
    }];
    [self performSelector:@selector(dismissAlert:) withObject:alertController afterDelay:seconds];
    return alertController;
}
- (void)dismissAlert:(UIAlertController*)alertController {
    if (alertController) {
        [alertController dismissViewControllerAnimated:YES completion:nil];
    }
}


//自定义进度条
-(void)showMyProgressView:(NSProgress*)progress{
//    _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
//    [_progressView setFrame:CGRectMake(20, SCREEN_HEIGHT/2-5, SCREEN_WIDTH-40, 10)];
//
//    _progressMaskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
//    UIVisualEffectView *progressViewBG = [[UIVisualEffectView alloc] initWithFrame:_progressMaskView.frame];
//    progressViewBG.backgroundColor = [UIColor darkGrayColor];
//    [progressViewBG setEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
//    progressViewBG.alpha=0.2;
//
//    [_progressMaskView addSubview:progressViewBG];
//    [_progressMaskView addSubview:_progressView];
//
//    if(!_showProgressView){
//        _showProgressView = YES;
//        [[UIApplication sharedApplication].keyWindow addSubview:_progressMaskView];
//    }
//    _progressView.progress = progress.fractionCompleted;
//    [progress addObserver:self forKeyPath:@"fractionCompleted" options:NSKeyValueObservingOptionNew context:nil];
}

//进度条
-(void)showProgressView:(NSProgress*)progress{
    if(!_progressMaskView){
        _progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        [_progressView setFrame:CGRectMake(20, SCREEN_HEIGHT/2-5, SCREEN_WIDTH-40, 10)];
        
        _progressMaskView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
        UIVisualEffectView *progressViewBG = [[UIVisualEffectView alloc] initWithFrame:_progressMaskView.frame];
        progressViewBG.backgroundColor = [UIColor darkGrayColor];
        [progressViewBG setEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight]];
        progressViewBG.alpha=0.2;
        
        [_progressMaskView addSubview:progressViewBG];
        [_progressMaskView addSubview:_progressView];
        if(!_showProgressView){
            _showProgressView = YES;
            [[UIApplication sharedApplication].keyWindow addSubview:_progressMaskView];
        }
    }
    
    _progressView.progress = progress.fractionCompleted;
    if(progress.fractionCompleted==1 && _showProgressView){
        [_progressMaskView removeFromSuperview];
    }
}

//确认弹框
-(void)alertWithAgreeAndReject:(NSString*)title content:(NSString*)content withBlock:(void(^)(void))confirmBlock rejectBlock:(void(^)(void))rejectBlock{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(confirmBlock) confirmBlock();
    }];
    UIAlertAction *rejectAction = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(rejectBlock) rejectBlock();
    }];
    [alertController addAction:confirmAction];
    [alertController addAction:rejectAction];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    UIViewController *alertVC = [[UIViewController alloc]init];
    [[UIApplication sharedApplication].keyWindow  addSubview:alertVC.view];
    [alertVC presentViewController:alertController animated:YES completion:^{
        [alertVC.view removeFromSuperview];
    }];
}


//确认弹框
-(void)alertWithConfirm:(NSString*)title content:(NSString*)content{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alertController addAction:confirmAction];
    UIViewController *alertVC = [[UIViewController alloc]init];
    [[UIApplication sharedApplication].keyWindow  addSubview:alertVC.view];
    [alertVC presentViewController:alertController animated:YES completion:^{
        [alertVC.view removeFromSuperview];
    }];
}


//确认弹框
-(void)alertWithConfirm:(NSString*)title content:(NSString*)content withBlock:(void(^)(void))confirmBlock{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:content preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if(confirmBlock) confirmBlock();
    }];
    [alertController addAction:confirmAction];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    UIViewController *alertVC = [[UIViewController alloc]init];
    [[UIApplication sharedApplication].keyWindow  addSubview:alertVC.view];
    [alertVC presentViewController:alertController animated:YES completion:^{
        [alertVC.view removeFromSuperview];
    }];
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
//    if([@"fractionCompleted" isEqualToString:keyPath]){
//        if(!NSThread.currentThread.isMainThread){
//            __weak typeof(self) wkSelf = self;
//            dispatch_sync(dispatch_get_main_queue(), ^{
//                NSProgress *progress = (NSProgress*)object;
//                if(wkSelf.progressView && wkSelf.progressMaskView){
//                    wkSelf.progressView.progress = progress.fractionCompleted;
//                    if(progress.fractionCompleted==1 && wkSelf.showProgressView){
//                        [wkSelf.progressMaskView removeFromSuperview];
//                    }
//                }
//            });
//        }else{
//            NSProgress *progress = (NSProgress*)object;
//            if(self.progressView && self.progressMaskView){
//                self.progressView.progress = progress.fractionCompleted;
//                if(progress.fractionCompleted==1 && self.showProgressView){
//                    [self.progressMaskView removeFromSuperview];
//                }
//            }
//        }
//    }
//    
//}
@end
