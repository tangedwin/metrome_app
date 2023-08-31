//
//  CustomerView.m
//  MetroMap
//
//  Created by edwin on 2019/6/23.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "CustomerView.h"

@implementation CustomerView

-(instancetype)initWithFrame:(CGRect)frame withType:(int)type{
    if (self = [super initWithFrame:frame]) {
        _type = type;
        [self setAllCorner];
    }
    return self;
}

- (void)setAllCorner {
    UIBezierPath *maskPath;
    maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:8.0];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

- (void)drawRect:(CGRect)rect {
    if(_type==1){
        // 获取当前的图形上下文
        CGContextRef context = UIGraphicsGetCurrentContext();
        // 设置绘制的颜色
        [[UIColor lightGrayColor] setStroke];
        // 设置线条的宽度
        CGContextSetLineWidth(context, 1);
        // 设置线条绘制的起始点
        CGContextMoveToPoint(context, 5, 30);
        // 添加线条路径
        CGContextAddLineToPoint(context, 195, 30);
        // 设置线条绘制的起始点
        CGContextMoveToPoint(context, 70, 35);
        // 添加线条路径
        CGContextAddLineToPoint(context, 70, 55);        
        // 设置线条绘制的起始点
        CGContextMoveToPoint(context, 130, 35);
        // 添加线条路径
        CGContextAddLineToPoint(context, 130, 55);
        // 执行绘制路径操作
        CGContextStrokePath(context);
    }else if(_type==2){
        CGContextRef context = UIGraphicsGetCurrentContext();
        [[UIColor darkGrayColor] setStroke];
        [[UIColor darkGrayColor] setFill];
        CGContextSetLineWidth(context, 2.0);
        // 创建一个可变路径
        CGMutablePathRef pathRef = CGPathCreateMutable();
        // 添加三个绘制坐标
        CGPathMoveToPoint(pathRef, nil, 0, 30);
        CGPathAddLineToPoint(pathRef, nil, 10, 25);
        CGPathAddLineToPoint(pathRef, nil, 10, 35);
        // 将路径添加到上下文
        CGContextAddPath(context, pathRef);
        // 执行图形的绘制
        CGContextDrawPath(context, kCGPathFillStroke);
    }else if(_type==3){
        CGContextRef context = UIGraphicsGetCurrentContext();
        [[UIColor darkGrayColor] setStroke];
        [[UIColor darkGrayColor] setFill];
        CGContextSetLineWidth(context, 2.0);
        // 创建一个可变路径
        CGMutablePathRef pathRef = CGPathCreateMutable();
        // 添加三个绘制坐标
        CGPathMoveToPoint(pathRef, nil, 210, 30);
        CGPathAddLineToPoint(pathRef, nil, 200, 25);
        CGPathAddLineToPoint(pathRef, nil, 200, 35);
        // 将路径添加到上下文
        CGContextAddPath(context, pathRef);
        // 执行图形的绘制
        CGContextDrawPath(context, kCGPathFillStroke);
    }else if(_type==4){
        CGContextRef context = UIGraphicsGetCurrentContext();
        [[UIColor darkGrayColor] setStroke];
        [[UIColor darkGrayColor] setFill];
        CGContextSetLineWidth(context, 2.0);
        // 创建一个可变路径
        CGMutablePathRef pathRef = CGPathCreateMutable();
        // 添加三个绘制坐标
        CGPathMoveToPoint(pathRef, nil, 100, 0);
        CGPathAddLineToPoint(pathRef, nil, 95, 10);
        CGPathAddLineToPoint(pathRef, nil, 105, 10);
        // 将路径添加到上下文
        CGContextAddPath(context, pathRef);
        // 执行图形的绘制
        CGContextDrawPath(context, kCGPathFillStroke);
    }else if(_type==5){
        CGContextRef context = UIGraphicsGetCurrentContext();
        [[UIColor darkGrayColor] setStroke];
        [[UIColor darkGrayColor] setFill];
        CGContextSetLineWidth(context, 2.0);
        // 创建一个可变路径
        CGMutablePathRef pathRef = CGPathCreateMutable();
        // 添加三个绘制坐标
        CGPathMoveToPoint(pathRef, nil, 100, 70);
        CGPathAddLineToPoint(pathRef, nil, 95, 60);
        CGPathAddLineToPoint(pathRef, nil, 105, 60);
        // 将路径添加到上下文
        CGContextAddPath(context, pathRef);
        // 执行图形的绘制
        CGContextDrawPath(context, kCGPathFillStroke);
    }else if(_type==6){
        CGContextRef context = UIGraphicsGetCurrentContext();
        [[UIColor lightGrayColor] setStroke];
        [[UIColor lightGrayColor] setFill];
        CGContextSetLineWidth(context, 2.0);
        // 创建一个可变路径
        CGMutablePathRef pathRef = CGPathCreateMutable();
        CGPathMoveToPoint(pathRef, nil, 0, 0);
        CGPathAddLineToPoint(pathRef, nil, 0, 22);
        CGPathAddLineToPoint(pathRef, nil, rect.size.width, 22);
        CGPathAddLineToPoint(pathRef, nil, rect.size.width, 0);
        
        CGContextAddPath(context, pathRef);
        CGContextDrawPath(context, kCGPathFillStroke);
    }
}

@end
