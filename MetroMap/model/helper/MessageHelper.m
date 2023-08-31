//
//  NewsHelper.m
//  MetroMap
//
//  Created by edwin on 2019/10/20.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "MessageHelper.h"

@interface MessageHelper()

@property(nonatomic, assign) BOOL loading;

@end

@implementation MessageHelper

-(instancetype)init{
    self = [super init];
    if(!self.messageList) self.messageList = [NSMutableArray array];
    return self;
}


-(void) loadMessages:(void(^)(NSInteger count))success failure:(void(^)(NSString *errorInfo))failure{
    _curPage = 0;
    _pageCount = 1;
    _messageList = [NSMutableArray new];
    [self moreMessages:success failure:failure];
}

- (void) moreMessages: (NSArray *) inputArray{
    [self moreMessages: [inputArray objectAtIndex:0] failure: [inputArray objectAtIndex:1]];
}

-(void) moreMessages:(void(^)(NSInteger count))success failure:(void(^)(NSString *errorInfo))failure{
    __weak typeof(self) wkSelf = self;
    if(!_loading) _loading = YES;
    else {
        [self performSelector:@selector(moreMessages:) withObject:[[NSMutableArray alloc] initWithObjects:success,failure, nil] afterDelay:1.0];
        return;
    }
    [[HttpHelper http] findList:_uri params:_parameters page:_curPage progress:nil success:^(NSMutableDictionary *responseDic) {
        wkSelf.curPage = [[responseDic objectForKey:@"pageNum"] integerValue];
        wkSelf.pageCount = [[responseDic objectForKey:@"pageCount"] integerValue];
        wkSelf.dataCount = [[responseDic objectForKey:@"count"] integerValue];
        
        NSInteger count = [[responseDic objectForKey:@"curSize"] integerValue];
        
        if(count>0){
            NSMutableArray *collectionArray = (NSMutableArray *)[responseDic mutableArrayValueForKey:@"list"];
            for(int i=0; i<collectionArray.count; i++){
                NSMutableDictionary *dict = (NSMutableDictionary*)collectionArray[i];
                MessageModel *messageModel = [MessageModel yy_modelWithJSON:dict];
                if(messageModel) [wkSelf.messageList addObject:messageModel];
            }
            success(collectionArray.count);
        }else{
            success(0);
        }
        wkSelf.loading = NO;
    } failure:^(NSString *errorInfo) {
        failure(errorInfo);
        wkSelf.loading = NO;
    }];
}

@end
