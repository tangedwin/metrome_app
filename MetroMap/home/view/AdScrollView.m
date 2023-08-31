//
//  AdScrollView.m
//  MetroMap
//
//  Created by edwin on 2019/10/29.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "AdScrollView.h"

static NSTimer * mv_timer;
@interface AdScrollView()<UIScrollViewDelegate>

@property(nonatomic, retain) NSArray *views;
@property(nonatomic, assign) CGFloat viewWidth;


@property(nonatomic, assign) float timerSpace;
@property(nonatomic, assign) float animationTime;

@end

@implementation AdScrollView

-(instancetype) initWithFrame:(CGRect)frame viewArray:(NSArray*)viewArray{
    self = [super initWithFrame:frame];
    _viewWidth = frame.size.width;
    _views = viewArray;
    _timerSpace = 3.f;
    _animationTime = .5f;
    self.scrollEnabled = YES;
    self.delegate = self;
    self.scrollEnabled = YES;
    self.bounces = YES;
    self.pagingEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.directionalLockEnabled = YES;
    [self initView];
    return self;
}

-(void) initView{
    CGFloat x = 0;
    CGFloat height = 0;
    if(_views) for(UIView *view in _views){
        x = x + view_margin;
        if(height<view.bounds.size.height) height = view.bounds.size.height;
        view.frame = CGRectMake(x, 0, view.bounds.size.width, view.bounds.size.height);
        view.layer.cornerRadius = 12;
        view.layer.masksToBounds = YES;
        [self addSubview:view];
        x = x + view.bounds.size.width + view_margin;
    }
    self.contentSize = CGSizeMake(x, height);
    self.pageControl.numberOfPages = self.views.count;
    self.pageControl.currentPage = 0;
    self.contentOffset = CGPointMake(0, 0);
    [self addTimer];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    //判断是否有定时器
    if (mv_timer) {
        [mv_timer setFireDate:[NSDate dateWithTimeIntervalSinceNow:_timerSpace]];
    }
    /// 当UIScrollView滑动到第一位停止时，将UIScrollView的偏移位置改变
    if (scrollView.contentOffset.x < 0) {
        scrollView.contentOffset = CGPointMake((self.views.count-1) * _viewWidth, 0);
        self.pageControl.currentPage = self.views.count-1;
    /// 当UIScrollView滑动到最后一位停止时，将UIScrollView的偏移位置改变
    } else if (scrollView.contentOffset.x > (self.views.count-1)* _viewWidth) {
        scrollView.contentOffset = CGPointMake(0, 0);
        self.pageControl.currentPage = 0;
    } else {
        self.pageControl.currentPage = scrollView.contentOffset.x / _viewWidth;
    }
//    self.pageControl.currentPage = scrollView.contentOffset.x / _viewWidth;
}
/**
 滚动视图开始手动拖拽时出发
 */
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    //判断是否有定时器
    if (mv_timer) {
        [mv_timer setFireDate:[NSDate distantFuture]];
    }
}

- (void)addTimer{
    mv_timer = [NSTimer scheduledTimerWithTimeInterval:_timerSpace target:self selector:@selector(timerFUNC:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:mv_timer forMode:NSRunLoopCommonModes];
}

- (void)timerFUNC:(NSTimer *)timer{
    __weak typeof(self) wkSelf = self;
    CGFloat currentX = self.contentOffset.x;
    CGFloat nextX = currentX + _viewWidth;
    if (nextX >= self.views.count * _viewWidth) {
        [UIView animateWithDuration:_animationTime animations:^{
            wkSelf.contentOffset = CGPointMake(0, 0);
        } completion:^(BOOL finished) {
            wkSelf.pageControl.currentPage = 0;
        }];
    }else{
        [UIView animateWithDuration:_animationTime animations:^{
            wkSelf.contentOffset = CGPointMake(nextX, 0);
        } completion:^(BOOL finished) {
            wkSelf.pageControl.currentPage = wkSelf.contentOffset.x / wkSelf.viewWidth;
        }];
    }
}

-(UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(self.x, self.height-26, self.width, 20)];
        _pageControl.userInteractionEnabled = NO;
        _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:17/255.0 green:148/255.0 blue:246/255.0 alpha:0.3];
        _pageControl.currentPageIndicatorTintColor = main_color_white;
    }
    return _pageControl;
}

-(void)dealloc{
    //  清理定时器
    [mv_timer invalidate];
    mv_timer = nil;
}
@end
