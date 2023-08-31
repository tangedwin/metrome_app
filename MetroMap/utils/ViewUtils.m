//
//  ViewUtils.m
//  MetroMap
//
//  Created by edwin on 2019/8/28.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "ViewUtils.h"

@implementation ViewUtils

    //创建label
+(UILabel*)createLabel:(NSString*)text color:(UIColor*)color fontSize:(float)fontSize bcolor:(UIColor*)bcolor frame:(CGRect)frame{
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    label.backgroundColor = bcolor==nil?[UIColor darkGrayColor]:bcolor;
    if(color!=nil){
        label.textColor = color;
    }else if([BaseUtils isLighterColor:label.backgroundColor]){
        label.textColor = [UIColor blackColor];
    }else{
        label.textColor = [UIColor whiteColor];
    }
    
    label.font = [UIFont systemFontOfSize:fontSize];
    label.text = text;
    return label;
}

@end
