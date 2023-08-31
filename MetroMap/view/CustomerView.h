//
//  CustomerView.h
//  MetroMap
//
//  Created by edwin on 2019/6/23.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerView : UIView
@property(nonatomic, assign) int type;

-(instancetype)initWithFrame:(CGRect)frame withType:(int)type;

@end
