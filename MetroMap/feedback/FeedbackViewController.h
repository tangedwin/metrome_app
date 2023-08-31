//
//  FeedbackViewController.h
//  MetroMap
//
//  Created by edwin on 2019/11/25.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
#import "UIImage+ImgSize.h"
#import "BaseViewController.h"

#import "HttpHelper.h"
#import "FeedbackModel.h"

@interface FeedbackViewController : BaseViewController
@property(nonatomic,assign) NSInteger selectedType;

-(instancetype)initWithFeedback:(FeedbackModel*)feedback;

@end

