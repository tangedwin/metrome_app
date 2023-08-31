//
//  NewsHelper.m
//  MetroMap
//
//  Created by edwin on 2019/10/20.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "RouteCollectsHelper.h"

@interface RouteCollectsHelper()

@property(nonatomic, assign) BOOL loading;

@end

@implementation RouteCollectsHelper

-(instancetype)init{
    self = [super init];
    if(!self.routeList) self.routeList = [NSMutableArray array];
    return self;
}


-(void) loadRoutes:(void(^)(NSInteger count))success failure:(void(^)(NSString *errorInfo))failure{
    _curPage = 0;
    _pageCount = 1;
    _routeList = [NSMutableArray new];
    [self moreRoutes:success failure:failure];
}

- (void) moreRoutes: (NSArray *) inputArray{
    [self moreRoutes: [inputArray objectAtIndex:0] failure: [inputArray objectAtIndex:1]];
}

-(void) moreRoutes:(void(^)(NSInteger count))success failure:(void(^)(NSString *errorInfo))failure{
    __weak typeof(self) wkSelf = self;
    if(!_loading) _loading = YES;
    else {
        [self performSelector:@selector(moreRoutes:) withObject:[[NSMutableArray alloc] initWithObjects:success,failure, nil] afterDelay:1.0];
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
                RouteModel *route = [RouteModel yy_modelWithJSON:dict[@"routeJson"]];
                route.routeType = dict[@"type"];
                if(route) [wkSelf.routeList addObject:route];
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
