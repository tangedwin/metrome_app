//
//  StationInfoAlert.m
//  MetroMap
//
//  Created by edwin on 2019/10/10.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "StationInfoAlert.h"


@interface StationInfoAlert()

@property(nonatomic, retain) StationModel *station;
@property(nonatomic, retain) NSMutableArray *lines;
@property(nonatomic, assign) CGFloat width;
@property(nonatomic, assign) CGFloat height;


@property(nonatomic, retain) NSMutableArray *layers;
@end

@implementation StationInfoAlert

-(instancetype)initWithFrame:(CGRect)frame station:(StationModel*)station lines:(NSMutableArray*)lines{
    self = [super initWithFrame:frame];
    _lines = lines;
    _station = station;
    _width = fitFloat(147+42);
    _height = fitFloat(86);
//    self.frame = CGRectMake(self.frame.origin.x-_width/2, self.frame.origin.y-_height-12, _width, _height+12);
    [self createStationAlert:station];
    self.frame = CGRectMake(self.frame.origin.x-_width/2, self.frame.origin.y-_height-12, _width, _height+12);
    return self;
}

-(void)createStationAlert:(StationModel*)station{
    _station = station;

    UIView *lineView;
    CGFloat width = 0;
    if(_lines){
        lineView = [[UIView alloc] init];
        for(int i=0; i<_lines.count; i++){
            LineModel *line = _lines[i];
            UILabel *lView = [self createLineView:line];
            [lView setX:width];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLine:)];
            lView.tag = i;
            lView.userInteractionEnabled = YES;
            [lView addGestureRecognizer:tap];
            width = width + lView.width + fitFloat(6);
            [lineView addSubview:lView];
        }
        lineView.frame = CGRectMake(fitFloat(12), ceil((_height/2-fitFloat(20))/2), width, fitFloat(20));
        width = width + fitFloat(12);
    }
    CGSize stationNameSize = [station.nameCn sizeWithAttributes:@{NSFontAttributeName:main_font_big}];
    UILabel *stationNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(width, (_height/2-fitFloat(25))/2, ceil(stationNameSize.width), fitFloat(25))];
    stationNameLabel.textColor = main_color_white;
    stationNameLabel.text = station.nameCn;
    stationNameLabel.font = main_font_big;
    width = width + stationNameLabel.width + fitFloat(12) + 21;
    
    _width = _width>width?_width:width;
    _width = _width>(SCREEN_WIDTH-fitFloat(20))?(SCREEN_WIDTH-fitFloat(20)):_width;
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _width, _height+12)];
//    mainView.backgroundColor = dynamic_color_white;
    CAGradientLayer*gradient = [CAGradientLayer layer];
    gradient.frame= (CGRect){{0,0},mainView.frame.size};
    gradient.startPoint = CGPointMake(0, 0);
    gradient.endPoint = CGPointMake(1, 1);
    gradient.colors = gradual_color_black;
    gradient.locations = @[@(0), @(1.0f)];
    [mainView.layer addSublayer:gradient];
    mainView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05].CGColor;
    mainView.layer.shadowOffset = CGSizeMake(0,3);
    mainView.layer.shadowOpacity = 1;
    mainView.layer.shadowRadius = 6;
    
    CAShapeLayer *lineLayer1 = [CAShapeLayer layer];
    lineLayer1.strokeColor = main_color_lightgray.CGColor;
    lineLayer1.fillColor = [UIColor clearColor].CGColor;
    lineLayer1.lineWidth = 1;
    UIBezierPath *linePath1 = [UIBezierPath bezierPath];
    [linePath1 moveToPoint:CGPointMake(fitFloat(12), _height/2)];
    [linePath1 addLineToPoint:CGPointMake(mainView.width-fitFloat(12), _height/2)];
    [linePath1 moveToPoint:CGPointMake(mainView.width/2, _height/2+8)];
    [linePath1 addLineToPoint:CGPointMake(mainView.width/2, _height-8)];
    lineLayer1.path = linePath1.CGPath;
    [mainView.layer addSublayer:lineLayer1];
    if(!_layers) _layers = [NSMutableArray new];
    [_layers addObject:lineLayer1];
    
    
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.strokeColor = main_color_lightgray.CGColor;
    lineLayer.fillColor = main_color_lightgray.CGColor;
//    lineLayer.fillColor = [UIColor clearColor].CGColor;
    lineLayer.lineWidth = 1;
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(_width/2, 0)];
    [linePath addLineToPoint:CGPointMake(_width-6, 0)];
    [linePath addQuadCurveToPoint:CGPointMake(_width, 6) controlPoint:CGPointMake(_width, 0)];
    [linePath addLineToPoint:CGPointMake(_width, _height-6)];
    [linePath addQuadCurveToPoint:CGPointMake(_width-6, _height) controlPoint:CGPointMake(_width, _height)];
    [linePath addLineToPoint:CGPointMake((_width-16)/2+16, _height)];
    [linePath addQuadCurveToPoint:CGPointMake((_width-16)/2+14, _height+2) controlPoint:CGPointMake((_width-16)/2+15, _height)];
    [linePath addLineToPoint:CGPointMake((_width-16)/2+9, _height+10)];
    [linePath addQuadCurveToPoint:CGPointMake((_width-16)/2+7, _height+10) controlPoint:CGPointMake((_width-16)/2+8, _height+12)];
    [linePath addLineToPoint:CGPointMake((_width-16)/2+2, _height+2)];
    [linePath addQuadCurveToPoint:CGPointMake((_width-16)/2, _height) controlPoint:CGPointMake((_width-16)/2+1, _height)];
    [linePath addLineToPoint:CGPointMake(6, _height)];
    [linePath addQuadCurveToPoint:CGPointMake(0, _height-6) controlPoint:CGPointMake(0, _height)];
    [linePath addLineToPoint:CGPointMake(0, 6)];
    [linePath addQuadCurveToPoint:CGPointMake(6, 0) controlPoint:CGPointMake(0, 0)];
    [linePath closePath];
    lineLayer.path = linePath.CGPath;
    mainView.layer.mask = lineLayer;
    if(!_layers) _layers = [NSMutableArray new];
    [_layers addObject:lineLayer];
    
    CGFloat labelWidth = fitFloat(56)+12;
    CGFloat labelX = (_width/2-labelWidth-fitFloat(12))/2;
    
    UIView *subStartIcon = [[UIView alloc] initWithFrame:CGRectMake((labelX<6?0:labelX)+fitFloat(12), _height/2+(_height/2-6)/2, 6, 6)];
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = CGRectMake(0,0,6,6);
    gl.startPoint = CGPointMake(0, 0);
    gl.endPoint = CGPointMake(1, 1);
    gl.colors = gradual_color_blue;
    gl.locations = @[@(0), @(1.0f)];
    [subStartIcon.layer addSublayer:gl];
    subStartIcon.layer.cornerRadius = 3;
    subStartIcon.layer.masksToBounds = YES;
    [mainView addSubview:subStartIcon];
    UIView *subEndIcon = [[UIView alloc] initWithFrame:CGRectMake(mainView.width/2+(labelX<6?6:labelX), _height/2+(_height/2-6)/2, 6, 6)];
    CAGradientLayer *gl1 = [CAGradientLayer layer];
    gl1.frame = CGRectMake(0,0,6,6);
    gl1.startPoint = CGPointMake(0, 0);
    gl1.endPoint = CGPointMake(1, 1);
    gl1.colors = gradual_color_pink;
    gl1.locations = @[@(0), @(1.0f)];
    [subEndIcon.layer addSublayer:gl1];
    subEndIcon.layer.cornerRadius = 3;
    subEndIcon.layer.masksToBounds = YES;
    [mainView addSubview:subEndIcon];
    
    UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake((labelX<6?0:labelX)+fitFloat(24), _height/2+(_height/2-fitFloat(17))/2, fitFloat(56), fitFloat(17))];
    startLabel.font = sub_font_big;
    startLabel.textColor = main_color_white;
    startLabel.text = @"设为起点";
    [mainView addSubview:startLabel];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setStartStation:)];
    startLabel.userInteractionEnabled = YES;
    [startLabel addGestureRecognizer:tap1];
    
    UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(mainView.width/2+fitFloat(12)+(labelX<6?6:labelX), _height/2+(_height/2-fitFloat(17))/2, fitFloat(56), fitFloat(17))];
    endLabel.font = sub_font_big;
    endLabel.textColor = main_color_white;
    endLabel.text = @"设为终点";
    [mainView addSubview:endLabel];
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(setEndStation:)];
    endLabel.userInteractionEnabled = YES;
    [endLabel addGestureRecognizer:tap2];
    
    UIImageView *stationInfo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navi_right_white"]];
    stationInfo.frame = CGRectMake(mainView.width-fitFloat(15+12), (_height/2-fitFloat(15))/2, fitFloat(15), fitFloat(15));
    [mainView addSubview:stationInfo];
    [self addSubview:mainView];
    
    
    if(lineView) [mainView addSubview:lineView];
    [mainView addSubview:stationNameLabel];
    
    UITapGestureRecognizer *tapdetail = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showStationDetail:)];
    mainView.userInteractionEnabled = YES;
    [mainView addGestureRecognizer:tapdetail];
}

-(void)showStationDetail:(UITapGestureRecognizer*)tap{
    _station.lineModels = _lines;
    if(self.showStationDetail) self.showStationDetail(_station);
}

-(UILabel *)createLineView:(LineModel*)line{
    CGSize lineCodeSize = [line.nameSimple sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"DIN-Black" size:14]}];
    CGFloat lineCodeWidth = lineCodeSize.width<fitFloat(20)?fitFloat(20):(lineCodeSize.width+10);
    UILabel *llabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, lineCodeWidth, fitFloat(20))];
    llabel.backgroundColor = [ColorUtils colorWithHexString:line.color];
    llabel.textColor = main_color_white;
    llabel.text = line.nameSimple;
    llabel.textAlignment = NSTextAlignmentCenter;
    llabel.font = [UIFont fontWithName:@"DIN-Black" size:14];
    llabel.layer.cornerRadius = fitFloat(20)/2;
    llabel.layer.masksToBounds = YES;
    return llabel;
}


-(void)showLine:(UITapGestureRecognizer*)tap{
    if(tap.view.tag<_lines.count){
        if(self.showLine) self.showLine(_lines[tap.view.tag]);
    }
}
-(void)setStartStation:(UITapGestureRecognizer*)tap{
    if(self.signStation) self.signStation(_station, 1);
}
-(void)setEndStation:(UITapGestureRecognizer*)tap{
    if(self.signStation) self.signStation(_station, 2);
}


-(void)updateCGColors{
//    if(self.layers) for(CALayer *layer in self.layers){
//        if([layer isKindOfClass:CAShapeLayer.class]){
//            CAShapeLayer *clayer = (CAShapeLayer*)layer;
//            clayer.strokeColor = dynamic_color_lightgray.CGColor;
//        }
//    }
}
@end
