//
//  StationAlert.m
//  MetroMap
//
//  Created by edwin on 2019/9/3.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "StationAlert.h"

@interface StationAlert()

@property(nonatomic, assign) NSInteger type;
@property(nonatomic, retain) StationInfo *station;
@property(nonatomic, retain) NSMutableArray *lines;

@end

@implementation StationAlert

-(instancetype)initWithStation:(StationInfo*)station lines:(NSMutableArray*)lines type:(NSInteger)type{
    if(self = [super init]){
        self.type = type;
        self.station = station;
        self.lines = lines;
        [self showStationInfoView];
    }
    return self;
}
    
//展示站点菜单
-(void)showStationInfoView{
    CGFloat viewWidth = 200;
    CGFloat viewHeight = 60;
    CGFloat height = 0;
    CGFloat width = 10;
    NSMutableArray *linePoints1 = [[NSMutableArray alloc] initWithObjects:NSStringFromCGPoint(CGPointMake(5, 30)), NSStringFromCGPoint(CGPointMake(195, 30)), nil];
    NSMutableArray *linePoints2 = [[NSMutableArray alloc] initWithObjects:NSStringFromCGPoint(CGPointMake(70, 35)), NSStringFromCGPoint(CGPointMake(70, 55)), nil];
    NSMutableArray *linePoints3 = [[NSMutableArray alloc] initWithObjects:NSStringFromCGPoint(CGPointMake(130, 35)), NSStringFromCGPoint(CGPointMake(130, 55)), nil];
    ViewWithDraw *salertView = [[ViewWithDraw alloc] initWithFrame:CGRectMake(0, 0, viewWidth, viewHeight) withLinePoints:[[NSMutableArray alloc] initWithObjects:linePoints1, linePoints2, linePoints3, nil] lineWidth:1 lineColor:[UIColor lightGrayColor] pathPoints:nil pathWidth:0 pathColor:nil];
    
    salertView.backgroundColor = [UIColor darkGrayColor];
    salertView.layer.cornerRadius = 8;
    
    //站点logo
    if(_station.iconUrl){
//        UIImage *stationLogoImage = [UIImage imageNamed:_station.iconUrl];
//        UIImageView *stationLogo = [[UIImageView alloc] initWithImage:stationLogoImage];
//        [stationLogo setFrame:CGRectMake(width, height, 28, 28)];
//        [salertView addSubview:stationLogo];
//        width += 30;
    }
    
    //站名
    UILabel *lineNameLabel = [ViewUtils createLabel:_station.nameCn color:nil fontSize:14 bcolor:nil frame:CGRectMake(width, height, 20, 28)];
    [salertView addSubview:lineNameLabel];
    lineNameLabel.numberOfLines = 0;//根据最大行数需求来设置
    lineNameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    CGSize maximumLabelSize = CGSizeMake(100, 9999);//labelsize的最大值
    CGSize expectSize = [lineNameLabel sizeThatFits:maximumLabelSize];
    expectSize.width = expectSize.width>150?150:expectSize.width;
    //别忘了把frame给回label，如果用xib加了约束的话可以只改一个约束的值
    lineNameLabel.frame = CGRectMake(width, 0, expectSize.width, 28);
    [salertView addSubview:lineNameLabel];
    width += expectSize.width;
    
    //线路名
    if(_lines && _lines.count>0){
        CGFloat lnameWith = 2;
        UIScrollView *lineNamesView = [[UIScrollView alloc] initWithFrame:CGRectMake(width+2, height, viewWidth-width-8, 28)];
        for(int i=0; i<_lines.count; i++){
            LineInfo *line = _lines[i];
            NSString *lineName = line.nameCn;
            UIColor *bcolor = nil;
            if(line.bgcolor) bcolor = [ColorUtils colorWithHexString:line.bgcolor];
            UILabel *lineNameView = [ViewUtils createLabel:lineName color:nil fontSize:12 bcolor:bcolor frame:CGRectMake(lnameWith, 8, 20, 30)];
            lineNameView.layer.cornerRadius = 8;
            lineNameView.numberOfLines = 0;//根据最大行数需求来设置
            lineNameView.lineBreakMode = NSLineBreakByTruncatingTail;
            CGSize maximumLabelSize = CGSizeMake(100, 9999);//labelsize的最大值
            CGSize expectSize = [lineNameView sizeThatFits:maximumLabelSize];
            //别忘了把frame给回label，如果用xib加了约束的话可以只改一个约束的值
            lineNameView.frame = CGRectMake(lnameWith, 8, expectSize.width, expectSize.height);
            [lineNamesView addSubview:lineNameView];
            lineNameView.userInteractionEnabled = YES;
            lineNameView.tag = i;
            UITapGestureRecognizer *lineTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showLine:)];
            [lineNameView addGestureRecognizer:lineTap];
            lnameWith += expectSize.width+2;
        }
        [lineNamesView setContentSize:CGSizeMake(lnameWith, height)];
        [lineNamesView setShowsVerticalScrollIndicator:NO];
        [lineNamesView setShowsHorizontalScrollIndicator:NO];
        [salertView addSubview:lineNamesView];
    }
    
    
    width = 0;
    height += 32;
    UILabel *startLabel = [ViewUtils createLabel:@"设为起点" color:nil fontSize:12 bcolor:nil frame:CGRectMake(width+15, height, 50, 28)];
    [salertView addSubview:startLabel];
    
    width += 75;
    UILabel *endLabel = [ViewUtils createLabel:@"设为终点" color:nil fontSize:12 bcolor:nil frame:CGRectMake(width, height, 50, 28)];
    [salertView addSubview:endLabel];
    
    width += 60;
    UILabel *detailLabel = [ViewUtils createLabel:@"站点详情" color:nil fontSize:12 bcolor:nil frame:CGRectMake(width, height, 50, 28)];
    [salertView addSubview:detailLabel];
    
    UITapGestureRecognizer *viewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapStationInfoButton:)];
    [salertView addGestureRecognizer:viewTap];
    
    NSMutableArray *pathPoints1 = nil;
    if(_type==1){
        //显示在站点下方
        [self setFrame:CGRectMake(0, 0, salertView.width, salertView.height+10)];
        pathPoints1 = [[NSMutableArray alloc] initWithObjects:NSStringFromCGPoint(CGPointMake(100, 0)), NSStringFromCGPoint(CGPointMake(95, 10)), NSStringFromCGPoint(CGPointMake(105, 10)), nil];
        salertView.y = 10;
    }else if(_type==2){
        //显示在站点上方
        [self setFrame:CGRectMake(0, 0, salertView.width, salertView.height+10)];
        pathPoints1 = [[NSMutableArray alloc] initWithObjects:NSStringFromCGPoint(CGPointMake(100, 70)), NSStringFromCGPoint(CGPointMake(95, 60)), NSStringFromCGPoint(CGPointMake(105, 60)), nil];
    }else if(_type==3){
        //显示在站点左侧
        [self setFrame:CGRectMake(0, 0, salertView.width+10, salertView.height)];
        pathPoints1 = [[NSMutableArray alloc] initWithObjects:NSStringFromCGPoint(CGPointMake(210, 30)), NSStringFromCGPoint(CGPointMake(200, 25)), NSStringFromCGPoint(CGPointMake(200, 35)), nil];
    }else if(_type==4){
        //显示在站点右侧
        [self setFrame:CGRectMake(0, 0, salertView.width+10, salertView.height)];
        pathPoints1 = [[NSMutableArray alloc] initWithObjects:NSStringFromCGPoint(CGPointMake(0, 30)), NSStringFromCGPoint(CGPointMake(10, 25)), NSStringFromCGPoint(CGPointMake(10, 35)), nil];
        salertView.x = 10;
    }
    self.pathPoints = [[NSMutableArray alloc] initWithObjects:pathPoints1, nil];
    self.pathColor = [UIColor darkGrayColor];
    self.pathWidth = 2.0;
    self.backgroundColor = [UIColor clearColor];
    
    [self addSubview:salertView];
}

-(void)tapStationInfoButton:(UIGestureRecognizer*)gestureRecognizer{
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    if(point.y>30 && point.y<60 && point.x>15 && point.x<65){
        //设置起点
        if(self.signStation) self.signStation(_station, 1);
    }else if(point.y>30 && point.y<60 && point.x>75 && point.x<125){
        //设置终点
        if(self.signStation) self.signStation(_station, 2);
    }else if(point.y>30 && point.y<60 && point.x>135 && point.x<185){
        //详情
        if(self.showStationDetail) self.showStationDetail(_station);
    }
}

-(void)showLine:(UIGestureRecognizer*)gestureRecognizer{
    NSInteger tag = gestureRecognizer.view.tag;
    LineInfo *line = _lines[tag];
    if(self.showLine) self.showLine(line);
}
@end
