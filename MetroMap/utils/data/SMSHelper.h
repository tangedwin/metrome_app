//
//  SMSHelper.h
//  ipet-photo
//
//  Created by edwin on 2019/9/19.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SMS_SDK/SMSSDK.h>

#define verify_SMS_Time NSString stringfo @"verify_sms_time"

@interface SMSHelper : NSObject
-(void)sendSMSVerify:(NSString*)phoneNumber success:(void(^)(void))success;
-(void)verify:(NSString*)phoneNumber verifyCode:(NSString*)code success:(void(^)(void))success;
@end

