//
//  ViewWithDraw.h
//  MetroMap
//
//  Created by edwin on 2019/9/3.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewWithDraw : UIView
    
@property(nonatomic, retain) NSMutableArray<NSMutableArray<NSString*>*> *linePoints;
@property(nonatomic, retain) NSMutableArray<NSMutableArray<NSString*>*> *pathPoints;
@property(nonatomic, assign) CGFloat lineWidth;
@property(nonatomic, assign) CGFloat pathWidth;
@property(nonatomic, retain) UIColor *lineColor;
@property(nonatomic, retain) UIColor *pathColor;
    
-(instancetype)initWithFrame:(CGRect)frame withLinePoints:(NSMutableArray<NSMutableArray<NSString*>*>*)linePoints lineWidth:(CGFloat)lineWidth lineColor:(UIColor*)lineColor pathPoints:(NSMutableArray<NSMutableArray<NSString*>*>*)pathPoints pathWidth:(CGFloat)pathWidth pathColor:(UIColor*)pathColor;
    
@end
