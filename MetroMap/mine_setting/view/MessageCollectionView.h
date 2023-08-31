//
//  MessageCollectionView.h
//  MetroMap
//
//  Created by edwin on 2019/10/30.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>
#import "PrefixHeader.h"
#import "MessageHelper.h"
#import "YYModel.h"

#import "MessageModel.h"
#import "MJChiBaoZiHeader.h"


@interface MessageCollectionView : UICollectionView
@property(nonatomic,copy) void(^showMessageDetail)(MessageModel *message);

@end

