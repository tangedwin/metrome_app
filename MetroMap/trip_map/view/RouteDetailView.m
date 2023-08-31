//
//  RouteDetailView.m
//  MetroMap
//
//  Created by edwin on 2019/10/12.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "RouteDetailView.h"

@interface RouteDetailView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, retain) UICollectionViewFlowLayout *fallLayout;
@property (nonatomic, retain) RouteModel *routeInfo;

@end


static NSString * const route_info_collection_id = @"route_info_collection";
@implementation RouteDetailView


-(instancetype)initWithFrame:(CGRect)frame route:(RouteModel*)routeInfo{
    // 创建布局
    _fallLayout = [[UICollectionViewFlowLayout alloc]init];
    _fallLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _fallLayout.estimatedItemSize = CGSizeMake(SCREEN_WIDTH-view_margin*4, 10);
    self = [super initWithFrame:frame collectionViewLayout:_fallLayout];
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:route_info_collection_id];
    self.dataSource = self;
    self.delegate = self;
    self.allowsSelection = NO;
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
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadData) name:UIApplicationDidBecomeActiveNotification object:nil];
    return self;
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //根据注册标记查找cell
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:route_info_collection_id forIndexPath:indexPath];
    if(cell.contentView.subviews) for(UIView *sview in cell.contentView.subviews) [sview removeFromSuperview];
    [self createViewInCell:cell indexPath:indexPath];
    return cell;
}


-(void)createViewInCell:(UICollectionViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    if(_routeInfo.segments.count*2-1<=indexPath.item) return;

    if(indexPath.item%2==0){
        RouteSegmentModel *segment = _routeInfo.segments[indexPath.item/2];
        LineModel *line = segment.line;
        UIView *segmentView = [self createSegmentView:line segment:segment cell:cell];
        [cell.contentView addSubview:segmentView];
        segmentView.mas_key = [NSString stringWithFormat:@"segmentView_%ld",(long)indexPath.item];
        cell.mas_key = [NSString stringWithFormat:@"cell_%ld",(long)indexPath.item];
        cell.contentView.mas_key = [NSString stringWithFormat:@"cell_content_%ld",(long)indexPath.item];
        [cell.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(segmentView).priorityHigh();
        }];
        [cell mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(segmentView).priorityHigh();
        }];
    }else{
        RouteSegmentModel *segment = _routeInfo.segments[indexPath.item/2+1];
        LineModel *line = segment.line;
        UIView *transforView = [self createTransforView:line segment:segment cell:cell];
        [cell.contentView addSubview:transforView];
        transforView.mas_key = [NSString stringWithFormat:@"transforView_%ld",(long)indexPath.item];
        cell.mas_key = [NSString stringWithFormat:@"cell_%ld",(long)indexPath.item];
        cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, transforView.frame.size.width, transforView.frame.size.height);
        [cell.contentView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(0);
            make.width.height.mas_equalTo(transforView).priorityHigh();
        }];
        [cell mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(transforView).priorityHigh();
            make.width.mas_equalTo(transforView).priorityHigh();
        }];
    }
}

-(UIView *)createTransforView:(LineModel *)line segment:(RouteSegmentModel*)segment cell:(UICollectionViewCell*)cell{
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.width, fitFloat(26))];
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

-(UIView *)createSegmentView:(LineModel *)line segment:(RouteSegmentModel*)segment cell:(UICollectionViewCell*)cell{
    UIView *mainView = [[UIView alloc] init];
    
    CGFloat timeViewWidth = (fitFloat(32)+48)*2+24;
    CGFloat maxLineNameWidth = cell.width-timeViewWidth-12-6;
    NSString *lineName = line.code?[line.nameCn stringByReplacingOccurrencesOfString:line.code withString:[NSString stringWithFormat:@"%@ ",line.code]]:line.nameCn;
    CGSize lineNameSize = [lineName sizeWithAttributes:@{NSFontAttributeName:main_font_small}];
    UILabel *lineNameLabel = [[UILabel alloc] initWithFrame: CGRectMake(18, 0, ceil(lineNameSize.width)>maxLineNameWidth?maxLineNameWidth:ceil(lineNameSize.width), fitFloat(20))];
    lineNameLabel.font = main_font_small;
    lineNameLabel.textColor = main_color_black;
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
    
    UILabel *firstName = [[UILabel alloc] initWithFrame: CGRectMake(firstView.x+firstView.width+6, fitFloat(1.5), fitFloat(32), fitFloat(17))];
    firstName.font = sub_font_middle;
    firstName.textColor = dynamic_color_gray;
    firstName.text = segment.firstTime;
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
    
    UILabel *endName = [[UILabel alloc] initWithFrame: CGRectMake(endView.x+endView.width+6, fitFloat(2), fitFloat(32), fitFloat(17))];
    endName.font = sub_font_middle;
    endName.textColor = dynamic_color_gray;
    endName.text = segment.lastTime;
    [mainView addSubview:endName];
    
    UILabel *directionName = [[UILabel alloc] initWithFrame: CGRectMake(18, fitFloat(26), cell.width, fitFloat(17))];
    directionName.font = sub_font_middle;
    directionName.textColor = dynamic_color_gray;
    NSString *directionStr = segment.directionName;
    directionName.text = [NSString stringWithFormat:@"%@ 方向 (下一站 %@)",directionStr,segment.stationsByWay[1].nameCn];
    [mainView addSubview:directionName];
    
    CGFloat y = fitFloat(48);
    for(int i=0; i<segment.stationsByWay.count; i++){
        StationModel *station = segment.stationsByWay[i];
        UIFont *font = (i==0 || i==segment.stationsByWay.count-1)?sub_font_middle:sub_font_small;
        UIColor *textColor = (i==0 || i==segment.stationsByWay.count-1)?main_color_black:dynamic_color_gray;
        CGSize stationNameSize = [station.nameCn sizeWithAttributes:@{NSFontAttributeName:font}];
        UILabel *stationName = [[UILabel alloc] initWithFrame: CGRectMake(18, y, stationNameSize.width, stationNameSize.height)];
        stationName.font = font;
        stationName.textColor = textColor;
        stationName.text = station.nameCn;
        [mainView addSubview:stationName];
        
        if(i==segment.stationsByWay.count-1 && segment.costTime){
            NSString *costTime = [NSString stringWithFormat:@"%d 分钟", segment.costTime/60];
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
    mainView.frame = CGRectMake(0, 0, cell.width, ceil(y));
    
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


- (UIImage*)getImageWithCustomRect{
    return [self scrollViewCutter:view_margin*2 right:view_margin*2 top:0 bottom:view_margin];
}

-(void)collectRouteInfo{
    if(!_routeInfo || !_routeInfo.startStation || !_routeInfo.endStation){
        return;
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:[_routeInfo yy_modelToJSONString] forKey:@"routeJsonStr"];
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

//设置cell的尺寸
//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    return CGSizeMake(SCREEN_WIDTH-view_margin*4, fitFloat(26));
//}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

//设置section间隔
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    //分别为上、左、下、右
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

//返回列表分组数，默认为1
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

//返回列表每个分组section拥有cell行数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _routeInfo.segments.count*2-1;
}

@end
