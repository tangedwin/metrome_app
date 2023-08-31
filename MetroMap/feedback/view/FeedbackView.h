//
//  FeedbackView.h
//  MetroMap
//
//  Created by edwin on 2019/11/25.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrefixHeader.h"
#import "FeedbackModel.h"

@interface FeedbackView : UICollectionView
-(instancetype)initWithFrame:(CGRect)frame type:(NSInteger)type feedback:(FeedbackModel*)feedback;
@property(nonatomic, copy) void(^popView)(void);

//-(void)updateCGColors;
-(void)viewTapped;
-(void)initSelectedData;
@end
