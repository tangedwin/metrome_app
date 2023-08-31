//
//  RouteDetailScrollView.m
//  MetroMap
//
//  Created by edwin on 2019/11/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "RouteDetailScrollView.h"

@interface RouteDetailScrollView()<UIScrollViewDelegate>

@property (nonatomic, retain) RouteModel *routeInfo;

@end

@implementation RouteDetailScrollView

-(instancetype)initWithFrame:(CGRect)frame route:(RouteModel*)routeInfo{
    self = [super initWithFrame:frame];
    self.delegate = self;
    self.directionalLockEnabled = YES;
    self.alwaysBounceHorizontal = NO;
    self.alwaysBounceVertical = YES;
    self.pagingEnabled = NO;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    self.backgroundColor = [UIColor clearColor];
    self.showsHorizontalScrollIndicator = NO;
    _routeInfo = routeInfo;
    
    [self initUI];
    return self;
}


-(void)initUI{
    CGFloat y = view_margin;
    for(int i=0; i<_routeInfo.segments.count; i++){
        RouteSegmentModel *segment = _routeInfo.segments[i];
        
        LineModel *line = segment.line;
        UIView *segmentView = [self createSegmentView:line segment:segment offsetY:y];
        [self addSubview:segmentView];
        y = y + segmentView.height;
        
        if(i!=_routeInfo.segments.count-1){
            RouteSegmentModel *segment = _routeInfo.segments[i];
            LineModel *line = segment.line;
            UIView *transforView = [self createTransforView:line segment:segment offsetY:y];
            [self addSubview:transforView];
            y = y + transforView.height;
        }
    }
    self.contentSize = CGSizeMake(SCREEN_WIDTH, y+view_margin*2);
}


- (UIImage*)getImageWithCustomRect{
    return [self scrollViewCutter:0 right:0 top:0 bottom:0];
}

-(void)collectRouteInfo{
    if(!_routeInfo || !_routeInfo.startStation || !_routeInfo.endStation){
        return;
    }
    NSMutableDictionary *routeInfo = [NSMutableDictionary new];
    NSMutableDictionary *startStation = [self copyStation:_routeInfo.startStation];
    NSMutableDictionary *endStation = [self copyStation:_routeInfo.endStation];
    if(startStation) [routeInfo setObject:startStation forKey:@"startStation"];
    if(endStation) [routeInfo setObject:endStation forKey:@"endStation"];
    
    if(_routeInfo.costTime) [routeInfo setObject:@(_routeInfo.costTime) forKey:@"costTime"];
    if(_routeInfo.countStop) [routeInfo setObject:@(_routeInfo.countStop) forKey:@"countStop"];
    if(_routeInfo.countTransfor) [routeInfo setObject:@(_routeInfo.countTransfor) forKey:@"countTransfor"];
    if(_routeInfo.transforTime) [routeInfo setObject:@(_routeInfo.transforTime) forKey:@"transforTime"];
    if(_routeInfo.costPrice) [routeInfo setObject:@(_routeInfo.costPrice) forKey:@"costPrice"];
    if(_routeInfo.distance) [routeInfo setObject:@(_routeInfo.distance) forKey:@"distance"];
    if(_routeInfo.distanceTransfor) [routeInfo setObject:@(_routeInfo.distanceTransfor) forKey:@"distanceTransfor"];
    
    NSMutableArray *segments = [NSMutableArray new];
    for(RouteSegmentModel *segment in _routeInfo.segments){
        NSMutableDictionary *nsegment = [NSMutableDictionary new];
        if(segment.identifyCode) [nsegment setObject:@(segment.identifyCode) forKey:@"identifyCode"];
        NSMutableDictionary *sStation = [self copyStation:segment.startStation];
        NSMutableDictionary *eStation = [self copyStation:segment.endStation];
        NSMutableDictionary *seStation = [self copyStation:segment.secondStation];
        if(sStation) [nsegment setObject:sStation forKey:@"startStation"];
        if(eStation) [nsegment setObject:eStation forKey:@"endStation"];
        if(seStation) [nsegment setObject:seStation forKey:@"secondStation"];
        
        NSMutableDictionary *direction = [self copyDirection:segment.direction];
        if(direction) [nsegment setObject:direction forKey:@"direction"];
        NSMutableDictionary *line = [self copyLine:segment.line];
        if(line) [nsegment setObject:line forKey:@"line"];
        
        if(segment.directionName) [nsegment setObject:segment.directionName forKey:@"directionName"];
        if(segment.transforType) [nsegment setObject:segment.transforType forKey:@"transforType"];
        if(segment.transforTime) [nsegment setObject:@(segment.transforTime) forKey:@"transforTime"];
        if(segment.firstTime) [nsegment setObject:segment.firstTime forKey:@"firstTime"];
        if(segment.lastTime) [nsegment setObject:segment.lastTime forKey:@"lastTime"];
        if(segment.costTime) [nsegment setObject:@(segment.costTime) forKey:@"costTime"];
        if(segment.countStop) [nsegment setObject:@(segment.countStop) forKey:@"countStop"];
        NSMutableArray *stations = [NSMutableArray new];
        for(StationModel *station in segment.stationsByWay){
            NSMutableDictionary *s = [self copyStation:station];
            if(s) [stations addObject:s];
        }
        if(stations) [nsegment setObject:stations forKey:@"stationsByWay"];
        [segments addObject:nsegment];
    }
    if(segments) [routeInfo setObject:segments forKey:@"segments"];
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:[routeInfo yy_modelToJSONString] forKey:@"routeJsonStr"];
    [params setObject:@(_routeInfo.startStation.identifyCode) forKey:@"startStation"];
    [params setObject:@(_routeInfo.endStation.identifyCode) forKey:@"endStation"];
    [params setObject:@"地铁" forKey:@"type"];
    
    [[HttpHelper new] submit:request_trip_collect params:params progress:^(NSProgress *progress) {
    } success:^(NSMutableDictionary *responseDic) {
        [MBProgressHUD showInfo:@"保存成功" detail:nil image:nil inView:nil];
    } failure:^(NSString *errorInfo) {
        [MBProgressHUD showInfo:@"异常" detail:errorInfo image:nil inView:nil];
    }];
}

-(NSMutableDictionary*)copyStation:(StationModel*)station{
    if(!station) return nil;
    NSMutableDictionary *nstation = [NSMutableDictionary new];
    if(station.identifyCode) [nstation setObject:@(station.identifyCode) forKey:@"identifyCode"];
    if(station.nameCn) [nstation setObject:station.nameCn forKey:@"nameCn"];
    return nstation;
}
-(NSMutableDictionary*)copyLine:(LineModel*)line{
    if(!line) return nil;
    NSMutableDictionary *nline = [NSMutableDictionary new];
    if(line.identifyCode) [nline setObject:@(line.identifyCode) forKey:@"identifyCode"];
    if(line.nameCn) [nline setObject:line.nameCn forKey:@"nameCn"];
    if(line.code) [nline setObject:line.code forKey:@"code"];
    if(line.nameSimple) [nline setObject:line.nameSimple forKey:@"nameSimple"];
    if(line.color) [nline setObject:line.color forKey:@"color"];
    return nline;
}
-(NSMutableDictionary*)copyDirection:(DirectionModel*)direction{
    if(!direction) return nil;
    NSMutableDictionary *ndirection = [NSMutableDictionary new];
    if(direction.identifyCode) [ndirection setObject:@(direction.identifyCode) forKey:@"identifyCode"];
    if(direction.name) [ndirection setObject:direction.name forKey:@"name"];
    return ndirection;
}


-(UIView *)createTransforView:(LineModel *)line segment:(RouteSegmentModel*)segment offsetY:(CGFloat)offsetY{
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(view_margin*2, offsetY, self.width-view_margin*4, fitFloat(26))];
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.strokeColor = dynamic_color_gray.CGColor;
    lineLayer.fillColor = [UIColor clearColor].CGColor;
    lineLayer.lineWidth = 1;
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(3, -fitFloat(20)/2+3)];
    [linePath addLineToPoint:CGPointMake(3, fitFloat(26)+fitFloat(20)/2-3)];
    lineLayer.path = linePath.CGPath;
    //虚线的间隔
    lineLayer.lineDashPattern = @[@3, @6];
    [mainView.layer addSublayer:lineLayer];
    
    NSString *transforType = [NSString stringWithFormat:@"%@ 换乘", segment.transforType];
    CGSize transforTypeSize = [transforType sizeWithAttributes:@{NSFontAttributeName:sub_font_small}];
    UILabel *transforTypeName = [[UILabel alloc] initWithFrame: CGRectMake(18, fitFloat(6), transforTypeSize.width, transforTypeSize.height)];
    transforTypeName.font = sub_font_small;
    transforTypeName.textColor = dynamic_color_gray;
    transforTypeName.text = transforType;
    [mainView addSubview:transforTypeName];
    
    if(segment.transforTime){
        NSString *costTime = [NSString stringWithFormat:@"%ld分钟", segment.transforTime>60?(segment.transforTime/60):1];
        CGSize costTimeSize = [costTime sizeWithAttributes:@{NSFontAttributeName:sub_font_small}];
        UILabel *costTimeTitle = [[UILabel alloc] initWithFrame: CGRectMake(transforTypeSize.width+18+12, fitFloat(6), costTimeSize.width, costTimeSize.height)];
        costTimeTitle.font = sub_font_small;
        costTimeTitle.textColor = dynamic_color_gray;
        costTimeTitle.text = costTime;
        [mainView addSubview:costTimeTitle];
    }
    
    return mainView;
}

-(UIView *)createSegmentView:(LineModel *)line segment:(RouteSegmentModel*)segment offsetY:(CGFloat)offsetY{
    UIView *mainView = [[UIView alloc] init];
    
    CGFloat timeViewWidth = (fitFloat(32)+48)*2+24;
    CGFloat maxLineNameWidth = self.width-view_margin*4-timeViewWidth-12-6;
    NSString *lineName = line.code?[line.nameCn stringByReplacingOccurrencesOfString:line.code withString:[NSString stringWithFormat:@"%@ ",line.code]]:line.nameCn;
    CGSize lineNameSize = [lineName sizeWithAttributes:@{NSFontAttributeName:main_font_small}];
    UILabel *lineNameLabel = [[UILabel alloc] initWithFrame: CGRectMake(18, 0, ceil(lineNameSize.width)>maxLineNameWidth?maxLineNameWidth:ceil(lineNameSize.width), fitFloat(20))];
    lineNameLabel.font = main_font_small;
    lineNameLabel.textColor = dynamic_color_black;
    lineNameLabel.text = lineName;
    [mainView addSubview:lineNameLabel];
    
    UIView *firstView = [[UIView alloc] initWithFrame:CGRectMake(lineNameLabel.x+lineNameLabel.width+12, 0, 48, fitFloat(20))];
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = CGRectMake(0,0,48,fitFloat(20));
    gl.startPoint = CGPointMake(0, 0);
    gl.endPoint = CGPointMake(1, 1);
    gl.colors = gradual_color_blue;
    gl.locations = @[@(0), @(1.0f)];
    gl.cornerRadius = 3;
    [firstView.layer addSublayer:gl];
    UILabel *firstTitle = [[UILabel alloc] initWithFrame: CGRectMake((firstView.width-fitFloat(36))/2, (firstView.height-fitFloat(17))/2, fitFloat(36), fitFloat(17))];
    firstTitle.font = sub_font_middle;
    firstTitle.textColor = main_color_white;
    firstTitle.text = @"首班车";
    [firstView addSubview:firstTitle];
    [mainView addSubview:firstView];
    
    NSString *firstTime = segment.firstTime?segment.firstTime:@"-";
    CGSize startSize = [firstTime sizeWithAttributes:@{NSFontAttributeName:sub_font_middle}];
    CGFloat startWidth = ceil(startSize.width)>fitFloat(32)?ceil(startSize.width):fitFloat(32);
    UILabel *firstName = [[UILabel alloc] initWithFrame: CGRectMake(firstView.x+firstView.width+6, fitFloat(1.5), startWidth, fitFloat(17))];
    firstName.font = sub_font_middle;
    firstName.textColor = dynamic_color_gray;
    firstName.text = firstTime;
    [mainView addSubview:firstName];
    
    UIView *endView = [[UIView alloc] initWithFrame:CGRectMake(firstName.x+firstName.width+12, 0, 48, fitFloat(20))];
    CAGradientLayer *glEnd = [CAGradientLayer layer];
    glEnd.frame = CGRectMake(0,0,48,fitFloat(20));
    glEnd.startPoint = CGPointMake(0, 0);
    glEnd.endPoint = CGPointMake(1, 1);
    glEnd.colors = gradual_color_pink;
    glEnd.locations = @[@(0), @(1.0f)];
    glEnd.cornerRadius = 3;
    [endView.layer addSublayer:glEnd];
    UILabel *endTitle = [[UILabel alloc] initWithFrame: CGRectMake((endView.width-fitFloat(36))/2, (endView.height-fitFloat(17))/2, fitFloat(36), fitFloat(17))];
    endTitle.font = sub_font_middle;
    endTitle.textColor = main_color_white;
    endTitle.text = @"末班车";
    [endView addSubview:endTitle];
    [mainView addSubview:endView];
    
    NSString *lastTime = segment.lastTime?segment.lastTime:@"-";
    CGSize endSize = [lastTime sizeWithAttributes:@{NSFontAttributeName:sub_font_middle}];
    CGFloat endWidth = ceil(endSize.width)>fitFloat(32)?ceil(endSize.width):fitFloat(32);
    UILabel *endName = [[UILabel alloc] initWithFrame: CGRectMake(endView.x+endView.width+6, fitFloat(2), endWidth, fitFloat(17))];
    endName.font = sub_font_middle;
    endName.textColor = dynamic_color_gray;
    endName.text = lastTime;
    [mainView addSubview:endName];
    
    UILabel *directionName = [[UILabel alloc] initWithFrame: CGRectMake(18, fitFloat(26), self.width-view_margin*4, fitFloat(17))];
    directionName.font = sub_font_middle;
    directionName.textColor = dynamic_color_gray;
    NSString *directionStr = segment.directionName;
    directionName.text = [NSString stringWithFormat:@"%@ 方向 (下一站 %@)",directionStr,segment.stationsByWay[1].nameCn];
    [mainView addSubview:directionName];
    
    CGFloat y = fitFloat(48);
    for(int i=0; i<segment.stationsByWay.count; i++){
        StationModel *station = segment.stationsByWay[i];
        UIFont *font = (i==0 || i==segment.stationsByWay.count-1)?sub_font_middle:sub_font_small;
        UIColor *textColor = (i==0 || i==segment.stationsByWay.count-1)?dynamic_color_black:dynamic_color_gray;
        CGSize stationNameSize = [station.nameCn sizeWithAttributes:@{NSFontAttributeName:font}];
        UILabel *stationName = [[UILabel alloc] initWithFrame: CGRectMake(18, y, stationNameSize.width, stationNameSize.height)];
        stationName.font = font;
        stationName.textColor = textColor;
        stationName.text = station.nameCn;
        [mainView addSubview:stationName];
        
        if(i==segment.stationsByWay.count-1 && segment.costTime){
            NSString *costTime = [NSString stringWithFormat:@"%ld 分钟", segment.costTime/60];
            CGSize costTimeSize = [costTime sizeWithAttributes:@{NSFontAttributeName:sub_font_middle}];
            UILabel *costTimeTitle = [[UILabel alloc] initWithFrame: CGRectMake(stationNameSize.width+18+12, y, costTimeSize.width, costTimeSize.height)];
            costTimeTitle.font = sub_font_middle;
            costTimeTitle.textColor = dynamic_color_gray;
            costTimeTitle.text = costTime;
            [mainView addSubview:costTimeTitle];
        }
        if(i==0 && segment.stationsByWay.count==2) y = y + stationNameSize.height + fitFloat(6);
        else if(i==segment.stationsByWay.count-1) y = y + stationNameSize.height;
        else y = y + stationNameSize.height + fitFloat(3);
    }
    mainView.frame = CGRectMake(view_margin*2, offsetY, self.width-view_margin*4, ceil(y));
    
    UIView *startSign = [[UIView alloc] initWithFrame:CGRectMake(0, lineNameLabel.height/2-3, 6, 6)];
    startSign.backgroundColor = [ColorUtils colorWithHexString:line.color];
    startSign.layer.cornerRadius = 3;
    UIView *endSign = [[UIView alloc] initWithFrame:CGRectMake(0, mainView.height-fitFloat(7)-6, 6, 6)];
    endSign.backgroundColor = [ColorUtils colorWithHexString:line.color];
    endSign.layer.cornerRadius = 3;
    CAShapeLayer *lineLayer = [CAShapeLayer layer];
    lineLayer.strokeColor = [ColorUtils colorWithHexString:line.color].CGColor;
    lineLayer.fillColor = [UIColor clearColor].CGColor;
    lineLayer.lineWidth = 1;
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(3, lineNameLabel.height/2+6)];
    [linePath addLineToPoint:CGPointMake(3, mainView.height-fitFloat(7)-6)];
    lineLayer.path = linePath.CGPath;
    //虚线的间隔
    lineLayer.lineDashPattern = @[@3, @6];
    [mainView.layer addSublayer:lineLayer];
    [mainView addSubview:startSign];
    [mainView addSubview:endSign];
    return mainView;
}


@end
