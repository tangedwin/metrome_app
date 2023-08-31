//
//  MBProgressHUDCustomView.m
//  ipet-photo
//
//  Created by edwin on 2019/9/21.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "MBProgressHUDCustomView.h"

@implementation MBProgressHUDCustomView

- (CGSize)intrinsicContentSize {
    CGFloat contentViewH = self.height;
    CGFloat contentViewW = self.width;
    return CGSizeMake(contentViewW, contentViewH);
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.layer.cornerRadius = 8;
    self.layer.masksToBounds = YES;
    return self;
}
@end
