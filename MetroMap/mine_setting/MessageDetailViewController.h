//
//  MessageDetailViewController.h
//  MetroMap
//
//  Created by edwin on 2019/10/30.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "HttpHelper.h"

#import "MessageModel.h"

@interface MessageDetailViewController : BaseViewController

-(instancetype) initWithMessage:(MessageModel*)message;
@end
