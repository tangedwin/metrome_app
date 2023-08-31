//
//  ScrollSignView.m
//  MetroMap
//
//  Created by edwin on 2019/10/11.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "ScrollSignView.h"

@interface ScrollSignView()
//0居中，1左对齐，2右对齐
@property(nonatomic, assign) SignAlign align;
@property(nonatomic, assign) NSInteger sum;
@property(nonatomic, assign) NSInteger selected;
@property(nonatomic, retain) NSMutableArray *signList;
@end

@implementation ScrollSignView

-(instancetype)initWithFrame:(CGRect)frame sum:(NSInteger)sum selected:(NSInteger)selected align:(SignAlign)align{
    self = [super initWithFrame:frame];
    _sum = sum;
    _selected = (selected>=sum || selected<0)?0:selected;
    _signList = [NSMutableArray new];
    _align = align;
    [self initUI];
    return self;
}

-(void)initUI{
    if(_sum<=0) return;
    
    CGFloat width = 6*_sum + 5*(_sum-1);
    CGFloat x = _align==SignAlignLeft?0:(_align==SignAlignRight?(self.width-width):(self.width-width)/2);
    
    for(int i=0; i<_sum; i++){
        UIView *subSelectedIcon = [[UIView alloc] initWithFrame:CGRectMake(x+11*i, 0, 6, 6)];
        if(_selected==i){
            CAGradientLayer *gl = [CAGradientLayer layer];
            gl.frame = CGRectMake(0,0,6,6);
            gl.startPoint = CGPointMake(0, 0);
            gl.endPoint = CGPointMake(1, 1);
            gl.colors = gradual_color_blue;
            gl.locations = @[@(0), @(1.0f)];
            [subSelectedIcon.layer addSublayer:gl];
        }else{
            subSelectedIcon.backgroundColor = main_color_lightgray;
        }
        subSelectedIcon.layer.cornerRadius = 3;
        subSelectedIcon.layer.masksToBounds = YES;
        [self addSubview:subSelectedIcon];
        [_signList addObject:subSelectedIcon];
    }
}

-(void)switchSelected:(NSInteger)selected{
    if(selected == _selected) return;
    else if(!_signList || _signList.count<=selected || selected<0) return;
    
    UIView *prevView = _signList[_selected];
    UIView *selectedView = _signList[selected];
    if(prevView.layer.sublayers) for(CALayer *layer in prevView.layer.sublayers){
        if([layer isKindOfClass:CAGradientLayer.class]){
            [layer removeFromSuperlayer];
            break;
        }
    }
    prevView.backgroundColor = main_color_lightgray;
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = CGRectMake(0,0,6,6);
    gl.startPoint = CGPointMake(0, 0);
    gl.endPoint = CGPointMake(1, 1);
    gl.colors = gradual_color_blue;
    gl.locations = @[@(0), @(1.0f)];
    [selectedView.layer addSublayer:gl];
    _selected = selected;
}

@end
