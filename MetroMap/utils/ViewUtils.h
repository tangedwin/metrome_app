//
//  ViewUtils.h
//  MetroMap
//
//  Created by edwin on 2019/8/28.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseUtils.h"


@interface ViewUtils : UIView
    
+(UILabel*)createLabel:(NSString*)text color:(UIColor*)color fontSize:(float)fontSize bcolor:(UIColor*)bcolor frame:(CGRect)frame;
@end

