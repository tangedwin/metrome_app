//
//  FeedbackTitleCellView.h
//  MetroMap
//
//  Created by edwin on 2019/11/25.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
#import "PrefixHeader.h"


@interface FeedbackTitleCellView : UICollectionViewCell

@property(nonatomic, retain) UIView *view;
@property(nonatomic, retain) UILabel *label;

-(void)loadCell:(NSString*)title indexPath:(NSIndexPath*)indexPath selected:(BOOL)selected;

@end

