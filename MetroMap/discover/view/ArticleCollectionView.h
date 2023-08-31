//
//  ArticleCollectionView.h
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
#import "PrefixHeader.h"
#import <NSObject+YYModel.h>

//#import "ArticleModel.h"
#import "NewsModel.h"
#import "NewsTypeModel.h"

#import "HttpHelper.h"
#import "NewsHelper.h"

#import "MJRefresh.h"
#import "MJChiBaoZiHeader.h"

@interface ArticleCollectionView : UICollectionView
@property(nonatomic,copy) void(^showNewsDetail)(NewsModel *newsInfo);

@property (nonatomic, retain) NewsHelper *newsHelper;
@property (nonatomic, assign) BOOL searching;

- (void)loadNewsCollection:(BOOL)mjRefresh;
@end

