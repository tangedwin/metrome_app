//
//  NewsModel.h
//  MetroMap
//
//  Created by edwin on 2019/10/20.
//  Copyright © 2019 edwin. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface NewsModel : NSObject

@property(nonatomic, assign) NSInteger identifyCode;
@property(nonatomic, assign) NSInteger cityId;
@property(nonatomic, assign) NSInteger typeId;
@property(nonatomic, retain) NSString *cityName;
@property(nonatomic, retain) NSString *typeName;
@property(nonatomic, retain) NSString *sourceUrl;
@property(nonatomic, retain) NSString *sourceName;
@property(nonatomic, retain) NSString *sourceIcon;
@property(nonatomic, retain) NSString *authorName;
@property(nonatomic, retain) NSString *title;
@property(nonatomic, retain) NSString *summary;
@property(nonatomic, retain) NSString *uri;
@property(nonatomic, retain) NSString *publishedTime;
@property(nonatomic, retain) NSString *recommendTime;
@property(nonatomic, retain) NSMutableArray *innerUrls;

@property(nonatomic, assign) NSInteger viewsSum;
@property(nonatomic, assign) NSInteger commentSum;
@property(nonatomic, assign) NSInteger likeSum;
@property(nonatomic, assign) BOOL liked;
@end

