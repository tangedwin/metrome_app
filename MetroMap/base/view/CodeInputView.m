//
//  CodeInputView.m
//  JDZBorrower
//
//  Created by WangXueqi on 2018/4/20.
//  Copyright © 2018年 JingBei. All rights reserved.
//

#import "CodeInputView.h"

//#define K_W 59.5
//#define K_Screen_Width               [UIScreen mainScreen].bounds.size.width
//#define K_Screen_Height              [UIScreen mainScreen].bounds.size.height

@interface CodeInputView()<UITextViewDelegate>
@property(nonatomic,strong)UITextView * textView;
@property(nonatomic,strong)NSMutableArray <CAShapeLayer *> * lines;
@property(nonatomic,strong)NSMutableArray <UILabel *> * labels;

@property(nonatomic,assign)CGFloat labelWidth;
@property(nonatomic,assign)CGFloat labelInterval;

@property(nonatomic, retain) NSMutableArray *layers;

@end

@implementation CodeInputView

- (instancetype)initWithFrame:(CGRect)frame inputType:(NSInteger)inputNum selectCodeBlock:(SelectCodeBlock)CodeBlock {
    self = [super initWithFrame:frame];
    if (self) {
        self.CodeBlock = CodeBlock;
        self.inputNum = inputNum;
        self.labelWidth = 42;
        self.labelInterval = 24;
        [self initSubviews];
    }
    return self;
}

-(void)updateCGColors{
    if(_layers) for(CALayer *layer in _layers){
        //虚线的颜色
        layer.backgroundColor = dynamic_color_middlegray.CGColor;
    }
}

- (void)initSubviews {
    [self addSubview:self.textView];
    self.textView.frame = CGRectMake(0, 0, self.width, self.height);
    //默认编辑第一个.
//    [self beginEdit];
    for (int i = 0; i < _inputNum; i ++) {
        UIView *subView = [UIView new];
        subView.frame = CGRectMake(self.textView.x+(_labelWidth+_labelInterval)*i, 0, _labelWidth, self.height);
        subView.userInteractionEnabled = NO;
        [self addSubview:subView];
        CALayer * layer = [[CALayer alloc]init];
        layer.frame = CGRectMake(0, self.height-1, _labelWidth, 1);
        layer.backgroundColor = dynamic_color_middlegray.CGColor;
        [subView.layer addSublayer:layer];
        if(!_layers) _layers = [NSMutableArray new];
        [_layers addObject:layer];
        
        //Label
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake(0, 0, _labelWidth, self.height);
        label.textAlignment = NSTextAlignmentCenter;
        label.textColor = [UIColor darkGrayColor];
        label.font = [UIFont fontWithName:@"DIN-Bold" size:24];
        [subView addSubview:label];
        //光标
        UIBezierPath *path = [UIBezierPath bezierPathWithRect:CGRectMake(_labelWidth / 2, (self.height-24)/2, 2, 24)];
        CAShapeLayer *line = [CAShapeLayer layer];
        line.path = path.CGPath;
        line.fillColor =  [UIColor blueColor].CGColor;
        [subView.layer addSublayer:line];
        if (i == 0) {
            [line addAnimation:[self opacityAnimation] forKey:@"kOpacityAnimation"];
            //高亮颜色
            line.hidden = YES;
        }else {
            line.hidden = YES;
        }
        //把光标对象和label对象装进数组
        [self.lines addObject:line];
        [self.labels addObject:label];
    }
}
#pragma mark - UITextViewDelegate
-(void)textViewDidEndEditing:(UITextView *)textView{
    for (int i = 0; i < _labels.count; i ++) {
        [self changeViewLayerIndex:i linesHidden:YES];
    }
}
-(void)textViewDidBeginEditing:(UITextView *)textView{
    if(textView.text.length<=0) [self changeViewLayerIndex:0 linesHidden:NO];
}

- (void)textViewDidChange:(UITextView *)textView {
    NSString *verStr = textView.text;
    if (verStr.length > _inputNum) {
        textView.text = [textView.text substringToIndex:_inputNum];
    }
    //大于等于最大值时, 结束编辑
    if (verStr.length >= _inputNum) {
        [self endEdit];
    }
    if (self.CodeBlock) {
        self.CodeBlock(textView.text);
    }
    for (int i = 0; i < _labels.count; i ++) {
        UILabel *bgLabel = _labels[i];
        
        if (i < verStr.length) {
            [self changeViewLayerIndex:i linesHidden:YES];
            bgLabel.text = [verStr substringWithRange:NSMakeRange(i, 1)];
        }else {
            [self changeViewLayerIndex:i linesHidden:i == verStr.length ? NO : YES];
            //textView的text为空的时候
            if (!verStr && verStr.length == 0) {
                [self changeViewLayerIndex:0 linesHidden:NO];
            }
            bgLabel.text = @"";
        }
    }
}
//设置光标显示隐藏
- (void)changeViewLayerIndex:(NSInteger)index linesHidden:(BOOL)hidden {
    CAShapeLayer *line = self.lines[index];
    if (hidden) {
        [line removeAnimationForKey:@"kOpacityAnimation"];
    }else{
        [line addAnimation:[self opacityAnimation] forKey:@"kOpacityAnimation"];
    }
    [UIView animateWithDuration:0.25 animations:^{
        line.hidden = hidden;
    }];
}
//开始编辑
- (void)beginEdit{
    [self.textView becomeFirstResponder];
}
//结束编辑
- (void)endEdit{
    [self.textView resignFirstResponder];
}
//闪动动画
- (CABasicAnimation *)opacityAnimation {
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @(1.0);
    opacityAnimation.toValue = @(0.0);
    opacityAnimation.duration = 0.9;
    opacityAnimation.repeatCount = HUGE_VALF;
    opacityAnimation.removedOnCompletion = YES;
    opacityAnimation.fillMode = kCAFillModeForwards;
    opacityAnimation.timingFunction=[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    return opacityAnimation;
}
//对象初始化
- (NSMutableArray *)lines {
    if (!_lines) {
        _lines = [NSMutableArray array];
    }
    return _lines;
}
- (NSMutableArray *)labels {
    if (!_labels) {
        _labels = [NSMutableArray array];
    }
    return _labels;
}
- (UITextView *)textView {
    if (!_textView) {
        _textView = [UITextView new];
        _textView.tintColor = [UIColor clearColor];
        _textView.backgroundColor = [UIColor clearColor];
        _textView.textColor = [UIColor clearColor];
        _textView.delegate = self;
        _textView.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _textView;
}

@end
