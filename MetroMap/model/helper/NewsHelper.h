//
//  NewsHelper.h
//  MetroMap
//
//  Created by edwin on 2019/10/20.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NSObject+YYModel.h>

#import "NewsModel.h"

#import "HttpHelper.h"

@interface NewsHelper : NSObject

@property (nonatomic, strong) NSMutableArray<NewsModel*>  *newsList;
//当前index
@property (nonatomic, copy) NSIndexPath *indexPath;

@property (nonatomic, retain) NSString  *uri;
@property (nonatomic, retain) NSMutableDictionary* parameters;
@property (nonatomic, assign) int64_t curPage;
@property (nonatomic, assign) int64_t pageCount;
@property (nonatomic, assign) int64_t dataCount;

@property(nonatomic, assign) NSInteger curPageAdCount;

-(void) loadNews:(void(^)(NSInteger count))success failure:(void(^)(NSString *errorInfo))failure;
-(void) moreNews:(void(^)(NSInteger count))success failure:(void(^)(NSString *errorInfo))failure;

-(void) addRenderAdViewArray:(NSArray*)views;
-(UIView*)getRenderAdViewAt:(NSInteger)index;
-(void)removeRenderAdView:(UIView*)view;
@end

