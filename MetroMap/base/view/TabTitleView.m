//
//  TabTitleView.m
//  ipet-photo
//
//  Created by edwin on 2019/9/16.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "TabTitleView.h"

@interface TabTitleView()

@property(nonatomic, retain) NSMutableArray *titles;
@property(nonatomic, assign) SegmentTabType type;
@property(nonatomic, retain) UIScrollView *mainScrollView;
@property(nonatomic, retain) UIView *tabCursor;

@property(nonatomic, retain) NSMutableArray *titleViews;
@property(nonatomic, retain) NSMutableArray *titleWidths;
@property(nonatomic, retain) NSMutableArray *titleViewRect;


@property(nonatomic, assign) BOOL loadedTabTitle;

@end

@implementation TabTitleView

-(instancetype)initWithFrame:(CGRect)frame titles:(NSMutableArray*)titles type:(SegmentTabType)type{
    self = [super initWithFrame:frame];
    self.type = type;
    self.titles = titles;
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    self.backgroundColor = dynamic_color_white;
    if(!_loadedTabTitle) [self initUI];
}


-(void)initUI{
    if(!_titles || _titles.count==0) return;
    _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    _titleViews = [NSMutableArray new];
    _titleWidths = [NSMutableArray new];
    _titleViewRect = [NSMutableArray new];
    
    if(_type==SegmentTabTypeByAverage){
        [_mainScrollView setContentSize:self.frame.size];
        CGFloat titleWidth = _mainScrollView.width/_titles.count;
        NSInteger index = 0;
        for(NSString *title in _titles){
            [self createTitleView:title frame:CGRectMake(index*titleWidth, 0, titleWidth, self.height) index:index];
            index++;
        }
    }else if(_type==SegmentTabTypeByTitleLength){
        NSInteger index = 0;
        CGFloat view_x = view_margin;
        for(NSString *title in _titles){
            CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName:main_font_big}];
            [self createTitleView:title frame:CGRectMake(view_x, 0, titleSize.width+24, self.height) index:index];
            view_x = view_x+titleSize.width+24;
            index++;
        }
    }
    
    if(!_withoutCursor) [self createCursor];
    [self addSubview:_mainScrollView];
    [self selected:0 from:0];
    _loadedTabTitle = YES;
}

-(void)selected:(NSInteger)index from:(NSInteger)fromIndex{
    if(index<0 || index>=_titleViews.count) return;
    UIFont *font = _textFont?_textFont:sub_font_big;
    UIFont *fontSelected = _textSelectedFont?_textSelectedFont:main_font_big;
    UIColor *color = _textColor?_textColor:dynamic_color_gray;
    UIColor *colorSelected = _textSelectedColor?_textSelectedColor:main_color_blue;
    CGRect cursorFrame = _tabCursor?_tabCursor.frame:CGRectNull;
    if(index == fromIndex){
        UIView *titleView = _titleViews[index];
        CGFloat titleWidth = [_titleWidths[index] floatValue];
        if(_tabCursor){
            cursorFrame = CGRectMake(titleView.x+(titleView.width-titleWidth)/2, _tabCursor.y, titleWidth, _tabCursor.height);
            _tabCursor.frame = cursorFrame;
            [_mainScrollView addSubview:_tabCursor];
        }
        
        if(titleView && titleView.subviews) for(UIView *sview in titleView.subviews){
            if([sview isKindOfClass:UILabel.class]){
                UILabel *label = (UILabel*)sview;
                if(label) label.font = fontSelected;
                if(label) label.textColor = colorSelected;
                [sview removeFromSuperview];
                [titleView addSubview:label];
            }
        }
        if(_tabCursor && _tabCursor.layer.sublayers) for(CALayer *layer in _tabCursor.layer.sublayers){
            if([layer isKindOfClass:CAGradientLayer.class]){
                CAGradientLayer *cursorLayer = (CAGradientLayer*)layer;
                if(cursorLayer) cursorLayer.frame = CGRectMake(0, 0, cursorFrame.size.width, 3);
            }
        }
    }else{
        CGFloat toWidth = [_titleWidths[index] floatValue];
        CGRect toRect = CGRectFromString(_titleViewRect[index]);
        
        CGFloat toX = toRect.origin.x + (toRect.size.width-toWidth)/2;
        UIView *fromView = _titleViews[fromIndex];
        UIView *toView = _titleViews[index];
        UILabel *fromLabel = nil;
        UILabel *toLabel = nil;
        CAGradientLayer *cursorLayer = nil;
        if(fromView && fromView.subviews) for(UIView *sview in fromView.subviews){
            if([sview isKindOfClass:UILabel.class]) fromLabel = (UILabel*)sview;
        }
        if(toView && toView.subviews) for(UIView *sview in toView.subviews){
            if([sview isKindOfClass:UILabel.class]) toLabel = (UILabel*)sview;
        }
        if(_tabCursor.layer.sublayers) for(CALayer *layer in _tabCursor.layer.sublayers){
            if([layer isKindOfClass:CAGradientLayer.class]) cursorLayer = (CAGradientLayer*)layer;
        }
        
        [UIView animateWithDuration:0.25f delay:0 options:0 animations:^{
            self.tabCursor.frame = CGRectMake(toX, self.tabCursor.y, toWidth, self.tabCursor.height);
            if(cursorLayer) cursorLayer.frame = CGRectMake(0, 0, toWidth, 3);
            if(fromLabel) fromLabel.font = font;
            if(fromLabel) fromLabel.textColor = color;
            if(toLabel) toLabel.font = fontSelected;
            if(toLabel) toLabel.textColor = colorSelected;
        } completion:^(BOOL finished) {
        }];
    }
}

-(void)createCursor{
    _tabCursor = [[UIView alloc] initWithFrame:CGRectMake(0, self.height-3, 0, 3)];
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = CGRectMake(0, 0, 0, 3);
    gl.startPoint = CGPointMake(0, 0.5);
    gl.endPoint = CGPointMake(1, 0.5);
    gl.colors = gradual_color_blue;
    gl.locations = @[@(0), @(1.0f)];
    [_tabCursor.layer addSublayer:gl];
    _tabCursor.layer.cornerRadius = 1.5;
    _tabCursor.layer.masksToBounds = YES;
}

-(void)createTitleView:(NSString*)title frame:(CGRect)frame index:(NSInteger)index{
    UIFont *font = _textFont?_textFont:sub_font_big;
    UIFont *fontSelected = _textSelectedFont?_textSelectedFont:main_font_big;
    UIColor *color = _textColor?_textColor:dynamic_color_gray;
    UIView *view = [[UIView alloc] initWithFrame:frame];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 13, view.width, 18)];
    NSMutableAttributedString *titleStr = [[NSMutableAttributedString alloc] initWithString:title];
    [titleStr addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, title.length)];
    [titleStr addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, title.length)];
    titleLabel.attributedText = titleStr;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [view addSubview:titleLabel];
    [view setUserInteractionEnabled:YES];
    [view setTag: index];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(scrollToIndex:)];
    [view addGestureRecognizer:tap];
    [_titleViews addObject:view];
    
    CGSize titleSize = [title sizeWithAttributes:@{NSFontAttributeName:fontSelected}];
    [_titleWidths addObject:[NSString stringWithFormat:@"%.2f",titleSize.width>view.width?view.width:titleSize.width]];
    [_titleViewRect addObject:NSStringFromCGRect(view.frame)];
    [_mainScrollView addSubview:view];
}

-(void)scrollToIndex:(UITapGestureRecognizer*)tap{
    if(_titleViews && _titleViews.count > tap.view.tag){
        if(self.scrollToIndex) self.scrollToIndex(tap.view.tag);
    }
}
@end
