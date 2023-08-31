//
//  HotCityListView.m
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "StationNearByView.h"

@interface StationNearByView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, retain) UICollectionViewFlowLayout *fallLayout;
@property (nonatomic, retain) StationModel *nearbyStation;
@property (nonatomic, assign) NSInteger distance;

@property(nonatomic, retain) NSMutableArray *layers;

@end

static NSString * const station_nearby_id = @"station_nearby";
@implementation StationNearByView


-(instancetype)initWithFrame:(CGRect)frame nearbyStation:(StationModel*)station distance:(NSInteger)distance{
    // 创建布局
    _fallLayout = [[UICollectionViewFlowLayout alloc]init];
    _fallLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _fallLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _fallLayout.minimumLineSpacing = 0;
    _fallLayout.minimumInteritemSpacing = 0;
    self = [super initWithFrame:frame collectionViewLayout:_fallLayout];
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:station_nearby_id];
    self.dataSource = self;
    self.delegate = self;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.pagingEnabled = YES;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    self.backgroundColor = dynamic_color_white;
    _nearbyStation = station;
    _distance = distance;
    
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTimetable:)];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:tap1];
    return self;
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //根据注册标记查找cell
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:station_nearby_id forIndexPath:indexPath];
    if(cell.contentView.subviews) for(UIView *view in cell.contentView.subviews) [view removeFromSuperview];
    if(self.nearbyStation.lineModels && indexPath.item<self.nearbyStation.lineModels.count){
        LineModel *line = self.nearbyStation.lineModels[indexPath.item];
        UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(view_margin, 6, SCREEN_WIDTH-view_margin*2, 142)];
        mainView.backgroundColor = dynamic_color_lightwhite;
        mainView.layer.cornerRadius = 12;
        mainView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05].CGColor;
        mainView.layer.shadowOffset = CGSizeMake(0,3);
        mainView.layer.shadowOpacity = 1;
        mainView.layer.shadowRadius = 6;
        
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"locationed"]];
        icon.frame = CGRectMake(8, 11, 15, 15);
        [mainView addSubview:icon];
        UILabel *nameTitle = [[UILabel alloc] initWithFrame:CGRectMake(27, 6, 324, 25)];
        nameTitle.font = main_font_big;
        nameTitle.textColor = main_color_blue;
        nameTitle.text = _nearbyStation.nameCn;
        [mainView addSubview:nameTitle];
        UILabel *startName = [[UILabel alloc] initWithFrame:CGRectMake(36, 37, fitFloat(30), 14)];
        startName.font = sub_font_small;
        startName.textColor = dynamic_color_gray;
        startName.text = @"终点站";
        [mainView addSubview:startName];
        UILabel *endName = [[UILabel alloc] initWithFrame:CGRectMake(mainView.width-36-fitFloat(30), 37, fitFloat(30), 14)];
        endName.font = sub_font_small;
        endName.textColor = dynamic_color_gray;
        endName.text = @"终点站";
        [mainView addSubview:endName];
        UILabel *startTitle = [[UILabel alloc] initWithFrame:CGRectMake(36, 54, (mainView.width-120)/2-36, 20)];
        startTitle.font = main_font_small;
        startTitle.textColor = dynamic_color_black;
        startTitle.text = line.startStation.nameCn;
        [mainView addSubview:startTitle];
        UILabel *endTitle = [[UILabel alloc] initWithFrame:CGRectMake(mainView.width-(mainView.width-120)/2, 54, (mainView.width-120)/2-36, 20)];
        endTitle.font = main_font_small;
        endTitle.textColor = dynamic_color_black;
        endTitle.text = line.endStation.nameCn;
        endTitle.textAlignment = NSTextAlignmentRight;
        [mainView addSubview:endTitle];
        
//        UIView *lineImage = [[UIView alloc] initWithFrame:CGRectMake((mainView.width-120)/2, 61, 120, 6)];
        CAGradientLayer *gl = [CAGradientLayer layer];
        gl.frame = CGRectMake((mainView.width-120)/2, 62, 120, 3);
        gl.startPoint = CGPointMake(0, 0.5);
        gl.endPoint = CGPointMake(1, 0.5);
        gl.colors = @[(__bridge id)[ColorUtils colorWithHexString:line.color alpha:0].CGColor, (__bridge id)[ColorUtils colorWithHexString:line.color].CGColor, (__bridge id)[ColorUtils colorWithHexString:line.color].CGColor, (__bridge id)[ColorUtils colorWithHexString:line.color alpha:0].CGColor];
        gl.locations = @[@(0), @(0.25f), @(0.75f), @(1.0f)];
        [mainView.layer addSublayer:gl];
        
        UILabel *lineName = [[UILabel alloc] init];
        UIFont *lineNameFont = [UIFont fontWithName:@"DIN-Black" size:13];
        CGSize lineNameSize = [line.nameCn sizeWithAttributes:@{NSFontAttributeName:lineNameFont}];
        NSMutableAttributedString *lineNameStr = [[NSMutableAttributedString alloc] initWithString:line.nameCn];
        [lineNameStr addAttribute:NSFontAttributeName value:lineNameFont range:NSMakeRange(0, line.code.length)];
        [lineNameStr addAttribute:NSFontAttributeName value:sub_font_small range:NSMakeRange(line.code.length, line.nameCn.length-line.code.length)];
        [lineNameStr addAttribute:NSBaselineOffsetAttributeName value:@(1) range:NSMakeRange(line.code.length, line.nameCn.length-line.code.length)];
        [lineNameStr addAttribute:NSForegroundColorAttributeName value:main_color_white range:NSMakeRange(0, line.nameCn.length)];
        lineName.attributedText = lineNameStr;
        lineName.textAlignment = NSTextAlignmentCenter;
        lineName.frame = CGRectMake(0, 0, ceil(lineNameSize.width) + 8, fitFloat(15));
        UIView *lineNameView = [[UIView alloc] initWithFrame:CGRectMake((mainView.width-lineName.width)/2, 56, lineName.width, fitFloat(15))];
        lineNameView.layer.cornerRadius = 6;
        lineNameView.layer.masksToBounds = YES;
        lineNameView.backgroundColor = [ColorUtils colorWithHexString:line.color];
        [lineNameView addSubview:lineName];
        [mainView addSubview:lineNameView];
        
        CAShapeLayer *lineLayer = [CAShapeLayer layer];
        lineLayer.strokeColor = dynamic_color_lightgray.CGColor;
        lineLayer.fillColor = [UIColor clearColor].CGColor;
        lineLayer.lineWidth = 1;
        UIBezierPath *linePath = [UIBezierPath bezierPath];
        [linePath moveToPoint:CGPointMake(0, 103)];
        [linePath addLineToPoint:CGPointMake(mainView.width, 103)];
        lineLayer.path = linePath.CGPath;
        //虚线的间隔
        lineLayer.lineDashPattern = @[@6, @6];
        [mainView.layer addSublayer:lineLayer];
        if(!_layers) _layers = [NSMutableArray new];
        [_layers addObject:lineLayer];
        
        UIView *buttonView = [self createStationButtons:CGRectMake(0, 104, mainView.width, 38)];
        [mainView addSubview:buttonView];
        
        if(_nearbyStation.lineModels.count>1){
            ScrollSignView *scrollSignView = [[ScrollSignView alloc] initWithFrame:CGRectMake(nameTitle.width+view_margin+27, (25-6)/2+6, mainView.width-nameTitle.width-view_margin*2-27, 6) sum:_nearbyStation.lineModels.count selected:indexPath.item align:SignAlignRight];
            [mainView addSubview:scrollSignView];
        }
        
        
        [cell.contentView addSubview:mainView];
    }
    return cell;
}


-(UIView*)createStationButtons:(CGRect)frame{
    UIView *view = [[UIView alloc] initWithFrame:frame];
    UIView *timetable = [[UIView alloc] initWithFrame:CGRectMake(0, 0, view.width/3, view.height)];
    UIImageView *timetableIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"timetable_icon"]];
    timetableIcon.frame = CGRectMake((timetable.width-46)/2, 15, 10, 10);
    [timetable addSubview:timetableIcon];
    UILabel *timetableTitle = [[UILabel alloc] initWithFrame:CGRectMake(timetableIcon.x+16, 12, 30, 14)];
    timetableTitle.font = sub_font_small;
    timetableTitle.textColor = dynamic_color_gray;
    timetableTitle.text = @"时刻表";
    [timetableTitle sizeToFit];
    [timetable addSubview:timetableTitle];
    [view addSubview:timetable];
//    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTimetable:)];
//    timetable.userInteractionEnabled = YES;
//    [timetable addGestureRecognizer:tap1];
    
    UIView *stationInfo = [[UIView alloc] initWithFrame:CGRectMake(view.width/3, 0, view.width/3, view.height)];
    UIImageView *stationInfoIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"station_info"]];
    stationInfoIcon.frame = CGRectMake((stationInfo.width-56)/2, 15, 10, 10);
    [stationInfo addSubview:stationInfoIcon];
    UILabel *stationInfoTitle = [[UILabel alloc] initWithFrame:CGRectMake(stationInfoIcon.x+16, 12, 40, 14)];
    stationInfoTitle.font = sub_font_small;
    stationInfoTitle.textColor = dynamic_color_gray;
    stationInfoTitle.text = @"站点信息";
    [stationInfoTitle sizeToFit];
    [stationInfo addSubview:stationInfoTitle];
    [view addSubview:stationInfo];
//    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showStationInfo:)];
//    stationInfo.userInteractionEnabled = YES;
//    [stationInfo addGestureRecognizer:tap2];
    
    UIView *exit = [[UIView alloc] initWithFrame:CGRectMake(view.width/3*2, 0, view.width/3, view.height)];
    UIImageView *exitIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"exit_icon"]];
    exitIcon.frame = CGRectMake((exit.width-46)/2, 15, 10, 10);
    [exit addSubview:exitIcon];
    UILabel *exitTitle = [[UILabel alloc] initWithFrame:CGRectMake(exitIcon.x+16, 12, 30, 14)];
    exitTitle.font = sub_font_small;
    exitTitle.textColor = dynamic_color_gray;
    exitTitle.text = @"出入口";
    [exitTitle sizeToFit];
    [exit addSubview:exitTitle];
    [view addSubview:exit];
//    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showExit:)];
//    exit.userInteractionEnabled = YES;
//    [exit addGestureRecognizer:tap3];
    
    return view;
}

//返回collection的section数量
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //如果photo数量为0则不显示底部刷新条
    return _nearbyStation.lineModels.count;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(SCREEN_WIDTH, 157);
}


-(void)showTimetable:(UITapGestureRecognizer *)tap{
    if(self.showTimetable) self.showTimetable(_nearbyStation);
}
-(void)showStationInfo:(UITapGestureRecognizer *)tap{
    if(self.showStationInfo) self.showStationInfo(_nearbyStation);
}
-(void)showExit:(UITapGestureRecognizer *)tap{
    if(self.showExit) self.showExit(_nearbyStation);
}


-(void)updateCGColors{
    if(self.layers) for(CALayer *layer in self.layers){
        if([layer isKindOfClass:CAShapeLayer.class]){
            CAShapeLayer *clayer = (CAShapeLayer*)layer;
            clayer.strokeColor = dynamic_color_lightgray.CGColor;
        }
    }
}
@end
