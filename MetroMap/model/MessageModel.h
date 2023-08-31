//
//  MessageModel.h
//  MetroMap
//
//  Created by edwin on 2019/10/30.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface MessageModel : NSObject

@property(nonatomic, assign) NSInteger identifyCode;
@property(nonatomic, assign) BOOL readed;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *content;
@property(nonatomic, retain) NSString *publishTime;

@end

