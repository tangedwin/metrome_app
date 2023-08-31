//
//  StationDetailView.m
//  MetroMap
//
//  Created by edwin on 2019/11/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "StationDetailView.h"

@interface StationDetailView()<UIScrollViewDelegate>

@end

@implementation StationDetailView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.delegate = self;
    return self;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    OffsetType type = self.parentView.offsetType;
    if (scrollView.contentOffset.y <= 0) {
        self.offsetType = OffsetTypeMin;
    } else {
        self.offsetType = OffsetTypeCenter;
    }
    if (type == OffsetTypeMin) {
        scrollView.contentOffset = CGPointZero;
    }
    if (type == OffsetTypeCenter) {
        scrollView.contentOffset = CGPointZero;
    }
}
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
        return YES;
    }

@end
