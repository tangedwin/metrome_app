//
//  NewsHelper.h
//  MetroMap
//
//  Created by edwin on 2019/10/20.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NSObject+YYModel.h>

#import "MessageModel.h"

#import "HttpHelper.h"

@interface MessageHelper : NSObject

@property (nonatomic, strong) NSMutableArray<MessageModel*>  *messageList;
//当前index
@property (nonatomic, copy) NSIndexPath *indexPath;

@property (nonatomic, retain) NSString  *uri;
@property (nonatomic, retain) NSMutableDictionary* parameters;
@property (nonatomic, assign) int64_t curPage;
@property (nonatomic, assign) int64_t pageCount;
@property (nonatomic, assign) int64_t dataCount;
-(void) loadMessages:(void(^)(NSInteger count))success failure:(void(^)(NSString *errorInfo))failure;
-(void) moreMessages:(void(^)(NSInteger count))success failure:(void(^)(NSString *errorInfo))failure;

@end

