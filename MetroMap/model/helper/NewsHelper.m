//
//  NewsHelper.m
//  MetroMap
//
//  Created by edwin on 2019/10/20.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "NewsHelper.h"

@interface NewsHelper()

@property(nonatomic, assign) BOOL loading;
@property(nonatomic, assign) NSInteger lastADIndex;
//广告位
@property (nonatomic, strong) NSMutableArray *expressAdViews;

@end

@implementation NewsHelper

-(instancetype)init{
    self = [super init];
    if(!self.newsList) self.newsList = [NSMutableArray array];
    return self;
}

-(void) addRenderAdViewArray:(NSArray*)views{
    if(!_expressAdViews) _expressAdViews = [NSMutableArray new];
    [_expressAdViews addObjectsFromArray:views];
}
-(UIView*)getRenderAdViewAt:(NSInteger)index{
    NSInteger adIndex = -1;
    for(NSInteger i=0; i<_newsList.count; i++){
        NewsModel *news = _newsList[i];
        if(!news.identifyCode) adIndex++;
        if(i == index && _expressAdViews.count>adIndex) return _expressAdViews[adIndex];
    }
    return nil;
}
-(void)removeRenderAdView:(UIView*)view{
    NSInteger adIndex = -1;
    for(NSInteger i=0; i<_newsList.count; i++){
        NewsModel *news = _newsList[i];
        if(!news.identifyCode) adIndex++;
        if(_expressAdViews.count>adIndex && _expressAdViews[adIndex]==view){
            [_expressAdViews removeObjectAtIndex:adIndex];
            [_newsList removeObjectAtIndex:i];
            break;
        }
    }
}

-(void) loadNews:(void(^)(NSInteger count))success failure:(void(^)(NSString *errorInfo))failure{
    _curPage = 0;
    _pageCount = 1;
    _newsList = [NSMutableArray new];
    _lastADIndex = 0;
    [self moreNews:success failure:failure];
}

//- (void) moreNews: (NSArray *) inputArray{
//    [self moreNews: [inputArray objectAtIndex:0] failure: [inputArray objectAtIndex:1]];
//}

-(void) moreNews:(void(^)(NSInteger count))success failure:(void(^)(NSString *errorInfo))failure{
    __weak typeof(self) wkSelf = self;
    if(!_loading) _loading = YES;
    else {
//        [self performSelector:@selector(moreNews:) withObject:[[NSMutableArray alloc] initWithObjects:success,failure, nil] afterDelay:1.0];
        return;
    }
    _curPageAdCount = 0;
    [[HttpHelper http] findList:_uri params:_parameters page:_curPage progress:nil success:^(NSMutableDictionary *responseDic) {
        wkSelf.curPage = [[responseDic objectForKey:@"pageNum"] integerValue];
        wkSelf.pageCount = [[responseDic objectForKey:@"pageCount"] integerValue];
        wkSelf.dataCount = [[responseDic objectForKey:@"count"] integerValue];
        
        NSInteger count = [[responseDic objectForKey:@"curSize"] integerValue];
        
        if(count>0){
            NSMutableArray *collectionArray = (NSMutableArray *)[responseDic mutableArrayValueForKey:@"list"];
            for(int i=0; i<collectionArray.count; i++){
                NSMutableDictionary *dict = (NSMutableDictionary*)collectionArray[i];
                NewsModel *news = [NewsModel yy_modelWithJSON:dict];
                [wkSelf.newsList addObject:news];
                if(++wkSelf.lastADIndex>4){
                    [wkSelf.newsList addObject:[NewsModel new]];
                    wkSelf.lastADIndex = 0;
                    wkSelf.curPageAdCount++;
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
