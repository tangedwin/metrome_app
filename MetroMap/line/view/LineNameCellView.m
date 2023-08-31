//
//  LineNameCellView.m
//  MetroMap
//
//  Created by edwin on 2019/11/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "LineNameCellView.h"

@implementation LineNameCellView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _view = [[UIView alloc] init];
        _view.layer.cornerRadius = 6;
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

-(void)loadCell:(LineModel*)line indexPath:(NSIndexPath*)indexPath selected:(BOOL)selected{
    
    CGSize lineNameSize = [line.nameCn sizeWithAttributes:@{NSFontAttributeName:main_font_small}];
    CGFloat labelWidth = ceil(lineNameSize.width);
    _label.frame = CGRectMake(0, 0, labelWidth, fitFloat(20));
    _label.text = line.nameCn;
    if(selected){
        _view.layer.borderWidth = 0;
        _view.backgroundColor = [ColorUtils colorWithHexString:line.color];
        _label.textColor = main_color_white;
    }else{
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
