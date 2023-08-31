//
//  SegmentWithTabView.m
//  ipet-photo
//
//  Created by edwin on 2019/9/16.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "SegmentWithTabView.h"

@interface SegmentWithTabView()<UIScrollViewDelegate>

@end

@implementation SegmentWithTabView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    [self initUI];
    return self;
}

-(void) initUI{    
    _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    _mainScrollView.bounces = NO;
    [_mainScrollView setContentSize:CGSizeMake(self.width, self.height)];
    _mainScrollView.pagingEnabled = YES;
    _mainScrollView.showsHorizontalScrollIndicator = NO;
    _mainScrollView.delegate = self;
    [self addSubview:_mainScrollView];
}

-(void) setSubViewArray:(NSMutableArray *)subViewArray{
    _subViewArray = subViewArray;
    [_mainScrollView setContentSize:CGSizeMake(self.width*subViewArray.count, self.height)];
    CGFloat x = 0;
    for(UIView *view in subViewArray) {
        [view setX:x];
        [_mainScrollView addSubview:view];
        x = x + SCREEN_WIDTH;
    }
}

-(CGSize)getSubviewContentSize{
    return _subViewArray[_selectedIndex].contentSize;
}

-(StationDetailView*)getCurrentCollectionView{
    return _subViewArray[_selectedIndex];
}

-(OffsetType)getSubviewOffset{
    return _subViewArray[_selectedIndex].offsetType;
}


-(void)scrollToIndex:(NSInteger)index{
    if(_mainScrollView.contentSize.width > index * SCREEN_WIDTH){
        __weak typeof(self) wkSelf = self;
        [UIView animateWithDuration:0.25f delay:0 options:0 animations:^{
            wkSelf.mainScrollView.contentOffset = CGPointMake(index*SCREEN_WIDTH, 0);
        } completion:nil];
    }
}

#pragma mark *** other ***
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return YES;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x/SCREEN_WIDTH;
    if(index!=_selectedIndex){
        if(self.moveTabToIndex) self.moveTabToIndex(index, _selectedIndex);
        _selectedIndex = index;
    }
}
@end
