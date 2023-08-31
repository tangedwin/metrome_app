//
//  FeedbackTitleCellView.m
//  MetroMap
//
//  Created by edwin on 2019/11/25.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "FeedbackTitleCellView.h"

@implementation FeedbackTitleCellView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _view = [[UIView alloc] init];
        _view.layer.cornerRadius = 6;
        _view.layer.masksToBounds = YES;
        _view.layer.borderColor = dynamic_color_gray.CGColor;
        _view.layer.borderWidth = 0.5;
        _label = [[UILabel alloc] init];
        _label.textColor = dynamic_color_gray;
        _label.textAlignment = NSTextAlignmentCenter;
        _label.font = main_font_small;

        [_view addSubview:_label];
        [self.contentView addSubview:_view];
        
        [_view mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.mas_equalTo(self.contentView).priorityHigh();
            make.width.mas_equalTo(self.label).offset(view_margin*2).priorityHigh();
        }];
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.view).offset(view_margin).priorityHigh();
            make.top.mas_equalTo(self.view).offset((30-fitFloat(20))/2).priorityHigh();
        }];
        [self.contentView mas_makeConstraints:^(MASConstraintMaker*make) {
            make.left.top.mas_equalTo(0).priorityHigh();
            make.height.mas_equalTo(30).priorityHigh();
            make.width.mas_equalTo(self.view.mas_width).priorityHigh();
        }];
    }
    return self;
}

-(void)loadCell:(NSString*)title indexPath:(NSIndexPath*)indexPath selected:(BOOL)selected{
    
    CGSize lineNameSize = [title sizeWithAttributes:@{NSFontAttributeName:main_font_small}];
    CGFloat labelWidth = ceil(lineNameSize.width);
    _label.frame = CGRectMake(0, 0, labelWidth, fitFloat(20));
    _label.text = title;
    if(selected){
        _view.layer.borderWidth = 0;
        CAGradientLayer *gl1 = [CAGradientLayer layer];
        gl1.frame = CGRectMake(0,0,labelWidth+view_margin*2,30);
        gl1.startPoint = CGPointMake(0, 0);
        gl1.endPoint = CGPointMake(1, 1);
        gl1.colors = gradual_color_pink;
        gl1.locations = @[@(0), @(1.0f)];
        [_view.layer insertSublayer:gl1 atIndex:0];
//        [_view.layer addSublayer:gl1];
        _label.textColor = main_color_white;
    }else{
        if(_view.layer.sublayers){
            NSMutableArray *layers = [NSMutableArray new];
            for(CALayer *layer in _view.layer.sublayers) if([layer isKindOfClass:CAGradientLayer.class]) [layers addObject:layer];
            for(CALayer *layer in layers) [layer removeFromSuperlayer];
        }
        _view.layer.borderWidth = 0.5;
        _view.backgroundColor = [UIColor clearColor];
        _label.textColor = dynamic_color_gray;
    }
        
}


- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [self setNeedsLayout];
    [self layoutIfNeeded];
    CGSize size = [self.contentView systemLayoutSizeFittingSize:layoutAttributes.size];
    CGRect cellFrame = layoutAttributes.frame;
    cellFrame.size.width = size.width;
    layoutAttributes.frame = cellFrame;
    return layoutAttributes;
}

@end
