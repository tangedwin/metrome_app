//
//  SegmentWithTabView.h
//  ipet-photo
//
//  Created by edwin on 2019/9/16.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <YYWebImage/YYWebImage.h>
#import "PrefixHeader.h"
#import "StationDetailView.h"
#import "MultstageScrollViewHeader.h"

@interface SegmentWithTabView : UIView
@property(nonatomic,copy) void(^moveTabToIndex)(NSInteger toIndex, NSInteger fromIndex);

@property (nonatomic, retain) UIScrollView *mainScrollView;
@property(nonatomic, assign) NSInteger selectedIndex;

@property(nonatomic, retain) NSMutableArray<StationDetailView*> *subViewArray;

-(void)scrollToIndex:(NSInteger)index;
-(CGSize)getSubviewContentSize;
-(StationDetailView*)getCurrentCollectionView;
-(OffsetType)getSubviewOffset;

@end
