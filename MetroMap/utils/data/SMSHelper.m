//
//  SMSHelper.m
//  ipet-photo
//
//  Created by edwin on 2019/9/19.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "SMSHelper.h"
#import "MBProgressHUD+Customer.h"

@implementation SMSHelper

-(void)sendSMSVerify:(NSString*)phoneNumber success:(void(^)(void))success{
    NSString *key = [NSString stringWithFormat:@"sms_verify_%@",phoneNumber];
    NSDate *lastSendTime = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    if(lastSendTime && [lastSendTime timeIntervalSinceNow] > -1*60){
        [MBProgressHUD showInfo:@"验证码已发送，请1分钟后再次尝试" detail:nil image:nil inView:nil];
        return;
    }
    //不带自定义模版
    [SMSSDK getVerificationCodeByMethod:SMSGetCodeMethodSMS phoneNumber:phoneNumber zone:@"86"  result:^(NSError *error) {
        if (!error){
            // 请求成功
            [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:key];
            [MBProgressHUD showInfo:@"已发送" detail:nil image:nil inView:nil];
            if(success) success();
        } else {
            // error
            if(error.code==300456 || error.code==300457) [MBProgressHUD showInfo:@"手机号码错误" detail:nil image:nil inView:nil];
            else if(error.code==300458) [MBProgressHUD showInfo:@"手机号码异常" detail:nil image:nil inView:nil];
            else if(error.code==300461) [MBProgressHUD showInfo:@"不支持该手机号" detail:nil image:nil inView:nil];
            else if(error.code==300463 || error.code==300465 || error.code==300464) [MBProgressHUD showInfo:@"操作过于频繁" detail:nil image:nil inView:nil];
            else if(error.code==300462) [MBProgressHUD showInfo:@"系统繁忙，请稍后再试" detail:nil image:nil inView:nil];
            else [MBProgressHUD showInfo:@"系统异常" detail:nil image:nil inView:nil];
        }
    }];
}

-(void)verify:(NSString*)phoneNumber verifyCode:(NSString*)code success:(void(^)(void))success{
    [SMSSDK commitVerificationCode:code phoneNumber:phoneNumber zone:@"86" result:^(NSError *error) {
        if (!error) {
            // 验证成功
            success();
        }else {
            // error
            if(error.code==300466 || error.code==300468) [MBProgressHUD showInfo:@"验证码错误" detail:nil image:nil inView:nil];
            else if(error.code==300467) [MBProgressHUD showInfo:@"操作过于频繁" detail:nil image:nil inView:nil];
            else [MBProgressHUD showInfo:@"系统异常" detail:nil image:nil inView:nil];
        }
    }];
}
@end
