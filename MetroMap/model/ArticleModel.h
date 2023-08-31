//
//  ArticleModel.h
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ArticleModel : NSObject

@property (nonatomic, retain) NSString *identifyCode;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *summary;
@property (nonatomic, retain) NSString *homeImage;
@property (nonatomic, retain) NSString *publishTime;
@property (nonatomic, retain) NSString *writerName;
@property (nonatomic, retain) NSString *articleUrl;
@property (nonatomic, retain) NSString *sourceName;
@property (nonatomic, retain) NSString *sourceIcon;
@property (nonatomic, retain) NSString *sourceUrl;


@property (nonatomic, assign) NSInteger likedSum;
@property (nonatomic, assign) NSInteger commentedSum;
@property (nonatomic, assign) BOOL liked;

+(ArticleModel*)createFakeModel;
@end

