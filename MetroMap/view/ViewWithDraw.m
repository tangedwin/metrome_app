//
//  ViewWithDraw.m
//  MetroMap
//
//  Created by edwin on 2019/9/3.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "ViewWithDraw.h"

@interface ViewWithDraw()
    
@end


@implementation ViewWithDraw

-(instancetype)initWithFrame:(CGRect)frame withLinePoints:(NSMutableArray<NSMutableArray<NSString*>*>*)linePoints lineWidth:(CGFloat)lineWidth lineColor:(UIColor*)lineColor pathPoints:(NSMutableArray<NSMutableArray<NSString*>*>*)pathPoints pathWidth:(CGFloat)pathWidth pathColor:(UIColor*)pathColor {
    if (self = [super initWithFrame:frame]) {
        _linePoints = linePoints;
        _lineWidth = lineWidth;
        _lineColor = lineColor;
        _pathPoints = pathPoints;
        _pathWidth = pathWidth;
        _pathColor = pathColor;
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
    // 获取当前的图形上下文
    CGContextRef context = UIGraphicsGetCurrentContext();
    if(_linePoints){
        [_lineColor setStroke];
        // 设置线条的宽度
        CGContextSetLineWidth(context, _lineWidth);
        for(NSMutableArray<NSString*>* lines in _linePoints){
            for(int i=0; i<lines.count; i++){
                CGPoint point = CGPointFromString(lines[i]);
                // 设置线条绘制的起始点
                if(i==0) CGContextMoveToPoint(context, point.x, point.y);
                // 添加线条路径
                else CGContextAddLineToPoint(context, point.x, point.y);
            }
        }
        // 执行绘制路径操作
        CGContextStrokePath(context);
    }
    if(_pathPoints){
        // 设置绘制的颜色
        [_pathColor setStroke];
        [_pathColor setFill];
        // 设置线条的宽度
        CGContextSetLineWidth(context, _pathWidth);
        // 创建一个可变路径
        CGMutablePathRef pathRef = CGPathCreateMutable();
        for(NSMutableArray<NSString*>* path in _pathPoints){
            for(int i=0; i<path.count; i++){
                CGPoint point = CGPointFromString(path[i]);
                // 设置线条绘制的起始点
                if(i==0) CGPathMoveToPoint(pathRef, nil, point.x, point.y);
                // 添加线条路径
                else CGPathAddLineToPoint(pathRef, nil, point.x, point.y);
            }
        }
        // 将路径添加到上下文
        CGContextAddPath(context, pathRef);
        // 执行图形的绘制
        CGContextDrawPath(context, kCGPathFillStroke);
    }
}

@end
