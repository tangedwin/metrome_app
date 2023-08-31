//
//  NewsHelper.h
//  MetroMap
//
//  Created by edwin on 2019/10/20.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <NSObject+YYModel.h>

#import "RouteModel.h"

#import "HttpHelper.h"

@interface RouteCollectsHelper : NSObject

@property (nonatomic, strong) NSMutableArray<RouteModel*>  *routeList;
//当前index
@property (nonatomic, copy) NSIndexPath *indexPath;

@property (nonatomic, retain) NSString  *uri;
@property (nonatomic, retain) NSMutableDictionary* parameters;
@property (nonatomic, assign) int64_t curPage;
@property (nonatomic, assign) int64_t pageCount;
@property (nonatomic, assign) int64_t dataCount;
-(void) loadRoutes:(void(^)(NSInteger count))success failure:(void(^)(NSString *errorInfo))failure;
-(void) moreRoutes:(void(^)(NSInteger count))success failure:(void(^)(NSString *errorInfo))failure;

@end

