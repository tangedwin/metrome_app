//
//  FeedbackViewController.m
//  MetroMap
//
//  Created by edwin on 2019/11/25.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "FeedbackViewController.h"
#import "SegmentWithTabView.h"
#import "TabTitleView.h"
#import "FeedbackView.h"

@interface FeedbackViewController ()<UIScrollViewDelegate>

@property (nonatomic, retain) SegmentWithTabView *segmentWithTabView;
@property(nonatomic, retain) TabTitleView *tabTitleView;
@property(nonatomic, retain) UIScrollView *detailScrollView;
@property(nonatomic, retain) NSMutableArray *segmentViewList;
@property(nonatomic, retain) NSMutableArray<NSString*> *segmentTitleList;
@property(nonatomic, retain) FeedbackModel *feedback;

@property(nonatomic, retain) NSMutableArray *layers;

@end

@implementation FeedbackViewController

-(instancetype)initWithFeedback:(FeedbackModel*)feedback{
    self = [super init];
    _feedback = feedback;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.naviMask];
    [self.naviMask addSubview:self.backButton];
    [self.view setBackgroundColor:dynamic_color_white];
    
    NSString *text = @"报错反馈";
    CGSize titleSize = [text sizeWithAttributes:@{NSFontAttributeName:main_font_big}];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(48, STATUS_BAR_HEIGHT+(NAVIGATION_BAR_HEIGHT-ceil(titleSize.height))/2, SCREEN_WIDTH-48*2, ceil(titleSize.height))];
    title.textColor = dynamic_color_black;
    title.font = main_font_big;
    title.textAlignment = NSTextAlignmentCenter;
    title.text = text;
    [self.naviMask addSubview:title];
    
    [self loadDetailView];
    
}

-(void)loadDetailView{
    _detailScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT)];
    
    [self createSegmentsView:CGRectMake(0, 0, SCREEN_WIDTH, _detailScrollView.height)];
    if(_tabTitleView) [_detailScrollView addSubview:_tabTitleView];
    if(_segmentWithTabView) [_detailScrollView addSubview:_segmentWithTabView];
    [self.view addSubview:_detailScrollView];
    _detailScrollView.delegate = self;
    _detailScrollView.showsVerticalScrollIndicator = NO;
    _detailScrollView.directionalLockEnabled = YES;
}



-(void)createSegmentsView:(CGRect)frame{
    __weak typeof(self) wkSelf = self;
    //tab页面
    _segmentWithTabView = [[SegmentWithTabView alloc] initWithFrame:CGRectMake(0, frame.origin.y+fitFloat(44), SCREEN_WIDTH, frame.size.height-fitFloat(44))];
    [_segmentWithTabView setMoveTabToIndex:^(NSInteger toIndex, NSInteger fromIndex) {
        if(wkSelf.tabTitleView) [wkSelf.tabTitleView selected:toIndex from:fromIndex];
        if(wkSelf.segmentViewList) for(FeedbackView *view in wkSelf.segmentViewList){
            [view viewTapped];
        }
    }];
    
    _segmentViewList = [NSMutableArray new];
    _segmentTitleList = [NSMutableArray new];
    [self createDetailInfoView:CGRectMake(0, 0, _segmentWithTabView.width, _segmentWithTabView.height)];
    if(_segmentViewList && _segmentViewList.count>0) [_segmentWithTabView setSubViewArray:_segmentViewList];
    else _segmentWithTabView = nil;
    
    if(_segmentTitleList && _segmentTitleList.count>0){
        //tab标签
        _tabTitleView = [[TabTitleView alloc] initWithFrame:CGRectMake(0, frame.origin.y, SCREEN_WIDTH, fitFloat(44)) titles:_segmentTitleList type:SegmentTabTypeByAverage];
        _tabTitleView.withoutCursor = YES;
        _tabTitleView.textColor = dynamic_color_gray;
        _tabTitleView.textFont = main_font_small;
        _tabTitleView.textSelectedColor = main_color_pink;
        _tabTitleView.textSelectedFont = main_font_middle;
        
        CALayer *viewBorder = [CALayer layer];
        viewBorder.frame = CGRectMake(0, _tabTitleView.height-1, _tabTitleView.width, 1);
        viewBorder.backgroundColor = dynamic_color_lightgray.CGColor;
        [_tabTitleView.layer addSublayer:viewBorder];
        if(!_layers) _layers = [NSMutableArray new];
        [_layers addObject:viewBorder];
        
        [_tabTitleView setScrollToIndex:^(NSInteger toIndex) {
            if(wkSelf.segmentWithTabView) [wkSelf.segmentWithTabView scrollToIndex:toIndex];
            if(wkSelf.segmentViewList) for(FeedbackView *view in wkSelf.segmentViewList){
                [view viewTapped];
            }
        }];
    }
    
    [self performSelector:@selector(initSelected) withObject:nil afterDelay:.2f];
}

-(void)initSelected{
    if(_feedback && _feedback.type && _feedback.type>1) {
        if(_feedback.type-1<_segmentViewList.count){
            __weak typeof(self) wkSelf = self;
            if(!NSThread.currentThread.isMainThread){
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wkSelf.segmentWithTabView scrollToIndex:wkSelf.feedback.type-1];
                    [wkSelf.segmentViewList[wkSelf.feedback.type-1] initSelectedData];
                });
            }else{
                [wkSelf.segmentWithTabView scrollToIndex:wkSelf.feedback.type-1];
                [wkSelf.segmentViewList[wkSelf.feedback.type-1] initSelectedData];
            }
        }
    }
}

-(void)createDetailInfoView:(CGRect)frame{
    FeedbackView *view1 = [self createDetailNormlView:1 frame:frame];
    [_segmentViewList addObject:view1];
    [_segmentTitleList addObject:@"APP问题"];
    
    FeedbackView *view2 = [self createDetailNormlView:2 frame:frame];
    [_segmentViewList addObject:view2];
    [_segmentTitleList addObject:@"出行问题"];
    
    [view1 setPopView:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [view2 setPopView:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}


-(FeedbackView*)createDetailNormlView:(NSInteger)type frame:(CGRect)frame{
    FeedbackModel *feedback = (_feedback && _feedback.type==type)?_feedback:[FeedbackModel new];
    FeedbackView *feedbackView = [[FeedbackView alloc] initWithFrame:frame type:type feedback:feedback];
    return feedbackView;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    __weak typeof(self) wkSelf = self;
    // trait发生了改变
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
//            if(_segmentViewList) for(FeedbackView *view in _segmentViewList){
//                [view updateCGColors];
//            }
            if(wkSelf.layers) for(CALayer *layer in wkSelf.layers){
                layer.backgroundColor = dynamic_color_lightgray.CGColor;
            }
        }
    } else {
    }
}
@end
