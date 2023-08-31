//
//  FeedbackModel.h
//  MetroMap
//
//  Created by edwin on 2019/11/25.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FeedbackModel : NSObject

@property(nonatomic, assign) NSInteger identifyCode;
@property(nonatomic, assign) NSInteger userId;
@property(nonatomic, assign) NSInteger type;
@property(nonatomic, assign) NSInteger objectType;

@property(nonatomic, retain) NSString *dataDetailStr;

@property(nonatomic, retain) NSMutableArray *titles;
@property(nonatomic, retain) NSString *phoneType;
@property(nonatomic, retain) NSString *systemType;
@property(nonatomic, retain) NSString *content;
@property(nonatomic, retain) NSString *contactType;
@property(nonatomic, retain) NSMutableArray *imageUrls;

@end
