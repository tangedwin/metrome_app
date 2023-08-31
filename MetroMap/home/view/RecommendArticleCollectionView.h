//
//  HotCityListView.h
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
#import "PrefixHeader.h"
#import <NSObject+YYModel.h>

#import "NewsModel.h"
#import "HttpHelper.h"

@interface RecommendArticleCollectionView : UICollectionView
@property(nonatomic,copy) void(^showNewsDetail)(NewsModel *newsInfo);

- (void)loadRecommendNews;
@end

