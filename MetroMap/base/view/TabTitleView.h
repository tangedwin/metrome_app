//
//  TabTitleView.h
//  ipet-photo
//
//  Created by edwin on 2019/9/16.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
#import "PrefixHeader.h"

typedef NS_ENUM(NSInteger, SegmentTabType) {
    SegmentTabTypeByAverage,
    SegmentTabTypeByTitleLength,
//    SegmentTabTypeByMaxTitleLength,
};
@interface TabTitleView : UIView
@property(nonatomic,copy) void(^scrollToIndex)(NSInteger toIndex);


@property(nonatomic, retain) UIColor *textColor;
@property(nonatomic, retain) UIColor *textSelectedColor;
@property(nonatomic, retain) UIFont *textFont;
@property(nonatomic, retain) UIFont *textSelectedFont;
@property(nonatomic, assign) BOOL withoutCursor;

-(instancetype)initWithFrame:(CGRect)frame titles:(NSMutableArray*)titles type:(SegmentTabType)type;
-(void)selected:(NSInteger)index from:(NSInteger)fromIndex;
@end

