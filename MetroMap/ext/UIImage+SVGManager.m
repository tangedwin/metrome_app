//
//  UIImage+SVGManager.m
//  test-metro
//
//  Created by edwin on 2019/6/18.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "UIImage+SVGManager.h"

@implementation UIImage (SVGManager)

+ (UIImage *)svgImageNamed:(NSString *)name size:(CGSize)size {
    SVGKImage *svgImage = [SVGKImage imageNamed:name];
    svgImage.size = size;
    return svgImage.UIImage;
}

@end
