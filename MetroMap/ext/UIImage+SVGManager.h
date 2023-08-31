//
//  UIImage+SVGManager.h
//  test-metro
//
//  Created by edwin on 2019/6/18.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SVGKit.h"
#import "SVGKImage.h"
#import "SVGKParser.h"


@interface UIImage (SVGManager)
+ (UIImage *)svgImageNamed:(NSString *)name size:(CGSize)size;
@end

