//
//  AlertUtils.h
//  ipet-photo
//
//  Created by edwin on 2019/8/1.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrefixHeader.h"

@interface AlertUtils : NSObject

-(void)showMyProgressView:(NSProgress*)progress;
- (UIAlertController *)showTipsView:(NSString*)content seconds:(float)seconds;
-(void)showProgressView:(NSProgress*)progress;
-(void)alertWithConfirm:(NSString*)title content:(NSString*)content;
-(void)alertWithConfirm:(NSString*)title content:(NSString*)content withBlock:(void(^)(void))confirmBlock;
-(void)alertWithAgreeAndReject:(NSString*)title content:(NSString*)content withBlock:(void(^)(void))confirmBlock rejectBlock:(void(^)(void))rejectBlock;

@end

