//
//  ScrollSignView.h
//  MetroMap
//
//  Created by edwin on 2019/10/11.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrefixHeader.h"

@interface ScrollSignView : UIView

typedef NS_ENUM(NSInteger, SignAlign) {
    SignAlignCenter,
    SignAlignLeft,
    SignAlignRight,
};
-(instancetype)initWithFrame:(CGRect)frame sum:(NSInteger)sum selected:(NSInteger)selected align:(SignAlign)align;
-(void)switchSelected:(NSInteger)selected;
@end

