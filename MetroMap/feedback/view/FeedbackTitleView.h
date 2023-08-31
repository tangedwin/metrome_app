//
//  FeedbackTitleView.h
//  MetroMap
//
//  Created by edwin on 2019/11/25.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
#import "PrefixHeader.h"
#import "FeedbackTitleCellView.h"

@interface FeedbackTitleView : UICollectionView
@property (nonatomic, retain) NSMutableArray *selectedTitles;

-(instancetype)initWithFrame:(CGRect)frame titles:(NSMutableArray*)titles selected:(NSMutableArray*)selected;
-(void)selectTitle:(NSInteger)index;
@end

