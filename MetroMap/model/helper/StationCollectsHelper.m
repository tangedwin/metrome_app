//
//  NewsHelper.m
//  MetroMap
//
//  Created by edwin on 2019/10/20.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "StationCollectsHelper.h"

@interface StationCollectsHelper()

@property(nonatomic, assign) BOOL loading;

@end

@implementation StationCollectsHelper

-(instancetype)init{
    self = [super init];
    if(!self.stationList) self.stationList = [NSMutableArray array];
    return self;
}


-(void) loadStations:(void(^)(NSInteger count))success failure:(void(^)(NSString *errorInfo))failure{
    _curPage = 0;
    _pageCount = 1;
    _stationList = [NSMutableArray new];
    [self moreStations:success failure:failure];
}

- (void) moreStations: (NSArray *) inputArray{
    [self moreStations: [inputArray objectAtIndex:0] failure: [inputArray objectAtIndex:1]];
}

-(void) moreStations:(void(^)(NSInteger count))success failure:(void(^)(NSString *errorInfo))failure{
    __weak typeof(self) wkSelf = self;
    if(!_loading) _loading = YES;
    else {
        [self performSelector:@selector(moreStations:) withObject:[[NSMutableArray alloc] initWithObjects:success,failure, nil] afterDelay:1.0];
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
                if(dict[@"station"]){
                    StationModel *station = [StationModel yy_modelWithJSON:dict[@"station"]];
                    if(station) [wkSelf.stationList addObject:station];
                }
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
