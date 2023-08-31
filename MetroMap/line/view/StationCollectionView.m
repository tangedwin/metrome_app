//
//  StationCollectionView.m
//  MetroMap
//
//  Created by edwin on 2019/10/22.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "StationCollectionView.h"

@interface StationCollectionView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, retain) UICollectionViewFlowLayout *fallLayout;
@property (nonatomic, retain) NSMutableArray *dataStations;
@property (nonatomic, retain) CityModel *city;
@property (nonatomic, retain) LineModel *line;

//嘉定北-迪士尼和迪士尼-嘉定北为一组，花桥-迪士尼和迪士尼-花桥为一组
@property (nonatomic, retain) NSMutableArray *directionSection;
@property (nonatomic, assign) NSInteger curSection;
@property (nonatomic, assign) NSInteger curItem;
@property (nonatomic, retain) DirectionModel *selectedDirection;

@end

static NSString * const stations_collection_id = @"stations_collection";
static NSString * const stations_collection_header_id = @"stations_collection_header";
@implementation StationCollectionView


-(instancetype)initWithFrame:(CGRect)frame city:(CityModel*)city line:(LineModel*)line{
    // 创建布局
    _fallLayout = [[UICollectionViewFlowLayout alloc]init];
    _fallLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _fallLayout.sectionHeadersPinToVisibleBounds = YES;
    self = [super initWithFrame:frame collectionViewLayout:_fallLayout];
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:stations_collection_id];
    [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:stations_collection_header_id];
    self.dataSource = self;
    self.delegate = self;
    self.allowsSelection = NO;
    self.alwaysBounceHorizontal = YES;
    self.directionalLockEnabled = YES;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    self.backgroundColor = dynamic_color_white;
    self.showsVerticalScrollIndicator = YES;
    _city = city;
    _line = line;
    [self loadDirection:0 section:0];
    return self;
}

#pragma mark - UICollectionViewDataSource
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:stations_collection_header_id forIndexPath:indexPath];
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        if(reusableView.subviews) for(UIView *sview in reusableView.subviews) [sview removeFromSuperview];
        
        for(int i=0; i<_directionSection.count; i++){
            NSMutableArray *directions = _directionSection[i];
            UIView *view = [self createLineTitleView:CGRectMake(view_margin, 52*i, reusableView.width-view_margin, 52) direction:_curSection==i?directions[_curItem]:directions[0] index:i];
            if(view) [reusableView addSubview:view];
        }
        reusableView.backgroundColor = dynamic_color_white;
    }
    //如果是头视图
    return reusableView;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //根据注册标记查找cell
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:stations_collection_id forIndexPath:indexPath];
    if(cell.contentView.subviews) for(UIView *view in cell.contentView.subviews) [view removeFromSuperview];
    StationModel *staiton = _dataStations[indexPath.item];
    [self createCellTable:staiton cell:cell indexPath:indexPath];
    return cell;
}

-(UIView *)createLineTitleView:(CGRect)frame direction:(DirectionModel*)direction index:(NSInteger)index{
    UIView *titleView = [[UIView alloc] initWithFrame:frame];
    CALayer *viewBorder = [CALayer layer];
    viewBorder.frame = CGRectMake(0, titleView.height-1, titleView.width-view_margin, 1);
    viewBorder.backgroundColor = dynamic_color_lightgray.CGColor;
    [titleView.layer addSublayer:viewBorder];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, titleView.width, titleView.height)];
    label.textColor = dynamic_color_gray;
    label.font = main_font_small;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"线路格式异常";
    
    if(!direction || !direction.stations || direction.stations.count<=0) {
        [titleView addSubview:label];
        return titleView;
    }
    
    BOOL selected = (index==_curSection);
    
    NSString *nameTitle = direction.name?direction.name:direction.directionName;
    NSString *pattern = @".*(.*-.*-.*)";
    NSString *pattern1 = @".*(.*)";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pattern];
    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",pattern1];
    //环线
    BOOL circleName = [predicate evaluateWithObject:nameTitle];
    //环线末班车
    BOOL circleName1 = (![predicate evaluateWithObject:nameTitle] && [predicate1 evaluateWithObject:nameTitle] && ![nameTitle containsString:@"-"]);
    
    if(circleName || circleName1){
        if(circleName){
            if(![nameTitle containsString:@"方向"]) nameTitle = [nameTitle stringByReplacingOccurrencesOfString:@")" withString:@")方向全程"];
        }else{
            nameTitle = [nameTitle stringByReplacingOccurrencesOfString:@"(" withString:@"(终点站:"];
        }
        
        CGFloat maxTitleWidth = titleView.width;
        CGSize nameSize = [nameTitle sizeWithAttributes:@{NSFontAttributeName:main_font_small}];
        CGFloat nameWidth = nameSize.width<maxTitleWidth?nameSize.width:maxTitleWidth;
        UILabel *nameStationName = [[UILabel alloc] initWithFrame:CGRectMake(0, (52-nameSize.height)/2, nameWidth, nameSize.height)];
        nameStationName.font = main_font_small;
        nameStationName.textColor = selected?dynamic_color_black:dynamic_color_gray;
        nameStationName.textAlignment = NSTextAlignmentLeft;
        nameStationName.text = nameTitle;
        [titleView addSubview:nameStationName];
        
    }else{
    
        NSString *startStationId = direction.stations[0];
        NSString *endStationId = direction.stations[direction.stations.count-1];
        StationModel *startStation = _city.stationDicts[[NSString stringWithFormat:@"%@", startStationId]];
        StationModel *endStation = _city.stationDicts[[NSString stringWithFormat:@"%@", endStationId]];
        if(!startStation || !endStation) {
            [titleView addSubview:label];
            return titleView;
        }
        
        CGFloat maxTitleWidth = (titleView.width-12-15-42-5*12)/2;
        CGSize startSize = [startStation.nameCn sizeWithAttributes:@{NSFontAttributeName:main_font_small}];
        CGSize endSize = [endStation.nameCn sizeWithAttributes:@{NSFontAttributeName:main_font_small}];
        CGFloat startWidth = startSize.width<maxTitleWidth?startSize.width:maxTitleWidth;
        CGFloat endWidth = endSize.width<maxTitleWidth?endSize.width:maxTitleWidth;
        UILabel *startStationName = [[UILabel alloc] initWithFrame:CGRectMake(18, (52-startSize.height)/2, startWidth, startSize.height)];
        startStationName.font = main_font_small;
        startStationName.textColor = selected?dynamic_color_black:dynamic_color_gray;
        startStationName.textAlignment = NSTextAlignmentLeft;
        startStationName.text = startStation.nameCn;
        [titleView addSubview:startStationName];
        UILabel *endStationName = [[UILabel alloc] initWithFrame:CGRectMake(18+startStationName.width+12+42+12+18, (52-endSize.height)/2, endWidth, endSize.height)];
        endStationName.font = main_font_small;
        endStationName.textColor = selected?dynamic_color_black:dynamic_color_gray;
        endStationName.textAlignment = NSTextAlignmentLeft;
        endStationName.text = endStation.nameCn;
        [titleView addSubview:endStationName];
        
        UIImageView *movingIcon = [[UIImageView alloc] initWithFrame:CGRectMake(18+startStationName.width+12, (52-14)/2, 42, 14)];
        [movingIcon setImage:[UIImage imageNamed:@"moving_icon"]];
        [titleView addSubview:movingIcon];
        
        UIView *subStartIcon = [[UIView alloc] initWithFrame:CGRectMake(0, 24, 6, 6)];
        CAGradientLayer *gl = [CAGradientLayer layer];
        gl.frame = CGRectMake(0,0,6,6);
        gl.startPoint = CGPointMake(0, 0);
        gl.endPoint = CGPointMake(1, 1);
        gl.colors = gradual_color_blue;
        gl.locations = @[@(0), @(1.0f)];
        [subStartIcon.layer addSublayer:gl];
        subStartIcon.layer.cornerRadius = 3;
        subStartIcon.layer.masksToBounds = YES;
        [titleView addSubview:subStartIcon];
        
        UIView *subEndIcon = [[UIView alloc] initWithFrame:CGRectMake(18+startStationName.width+12+42+12, 24, 6, 6)];
        CAGradientLayer *gl1 = [CAGradientLayer layer];
        gl1.frame = CGRectMake(0,0,6,6);
        gl1.startPoint = CGPointMake(0, 0);
        gl1.endPoint = CGPointMake(1, 1);
        gl1.colors = gradual_color_pink;
        gl1.locations = @[@(0), @(1.0f)];
        [subEndIcon.layer addSublayer:gl1];
        subEndIcon.layer.cornerRadius = 3;
        subEndIcon.layer.masksToBounds = YES;
        [titleView addSubview:subEndIcon];
    }
    
    if(selected){
        NSArray *darray = _directionSection[_curSection];
        if(darray.count>1){
            UIImageView *switchDirectionButton = [[UIImageView alloc] initWithFrame:CGRectMake(titleView.width-17-view_margin, (52-15)/2, 15, 15)];
            [switchDirectionButton setImage:[UIImage imageNamed:@"switch_horizontal"]];
            [titleView addSubview:switchDirectionButton];
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchDirection:)];
            switchDirectionButton.tag = index;
            [switchDirectionButton addGestureRecognizer:tap];
            switchDirectionButton.userInteractionEnabled = YES;
        }
    }else{
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchDirection:)];
        titleView.tag = index;
        [titleView addGestureRecognizer:tap];
        titleView.userInteractionEnabled = YES;
        [titleView addGestureRecognizer:tap];
    }
    
    return titleView;
}

-(UIView *) createTimetableView:(CGRect)frame station:(StationModel*)station{
    UIView *timetableView = [[UIView alloc] initWithFrame:frame];
    
    NSString *firstTime = nil;
    NSString *lastTime = nil;
    if(station.timetable) for(StationTimetableModel *stModel in station.timetable){
        if(stModel.directionId == _selectedDirection.identifyCode){
            firstTime = [stModel findFirstTime];
            lastTime = [stModel findLastTime];
            break;
        }
    }
    
    UIView *firstView = [[UIView alloc] initWithFrame:CGRectMake(0, (timetableView.height-fitFloat(20))/2, 24, fitFloat(20))];
    CAGradientLayer *gl2 = [CAGradientLayer layer];
    gl2.frame = CGRectMake(0,0,24,fitFloat(20));
    gl2.startPoint = CGPointMake(0, 0);
    gl2.endPoint = CGPointMake(1, 1);
    gl2.colors = gradual_color_blue;
    gl2.locations = @[@(0), @(1.0f)];
    gl2.cornerRadius = 3;
    [firstView.layer addSublayer:gl2];
    UILabel *firstTitle = [[UILabel alloc] initWithFrame: CGRectMake((firstView.width-fitFloat(12))/2, (firstView.height-fitFloat(17))/2, fitFloat(12), fitFloat(17))];
    firstTitle.font = sub_font_middle;
    firstTitle.textColor = main_color_white;
    firstTitle.text = @"首";
    [firstView addSubview:firstTitle];
    [timetableView addSubview:firstView];
    
    firstTime = firstTime?firstTime:@"-";
    CGSize startSize = [firstTime sizeWithAttributes:@{NSFontAttributeName:sub_font_middle}];
    CGFloat startWidth = ceil(startSize.width)>fitFloat(32)?ceil(startSize.width):fitFloat(32);
    UILabel *firstName = [[UILabel alloc] initWithFrame: CGRectMake(firstView.x+firstView.width+6, (timetableView.height-fitFloat(17))/2, startWidth, fitFloat(17))];
    firstName.font = sub_font_middle;
    firstName.textColor = dynamic_color_gray;
    firstName.text = firstTime;
    [timetableView addSubview:firstName];
    
    UIView *endView = [[UIView alloc] initWithFrame:CGRectMake(firstName.x+firstName.width+12, (timetableView.height-fitFloat(20))/2, 24, fitFloat(20))];
    CAGradientLayer *glEnd = [CAGradientLayer layer];
    glEnd.frame = CGRectMake(0,0,24,fitFloat(20));
    glEnd.startPoint = CGPointMake(0, 0);
    glEnd.endPoint = CGPointMake(1, 1);
    glEnd.colors = gradual_color_pink;
    glEnd.locations = @[@(0), @(1.0f)];
    glEnd.cornerRadius = 3;
    [endView.layer addSublayer:glEnd];
    UILabel *endTitle = [[UILabel alloc] initWithFrame: CGRectMake((endView.width-fitFloat(12))/2, (endView.height-fitFloat(17))/2, fitFloat(12), fitFloat(17))];
    endTitle.font = sub_font_middle;
    endTitle.textColor = main_color_white;
    endTitle.text = @"末";
    [endView addSubview:endTitle];
    [timetableView addSubview:endView];
    
    lastTime = lastTime?lastTime:@"-";
    CGSize endSize = [lastTime sizeWithAttributes:@{NSFontAttributeName:sub_font_middle}];
    CGFloat endWidth = ceil(endSize.width)>fitFloat(32)?ceil(endSize.width):fitFloat(32);
    UILabel *endName = [[UILabel alloc] initWithFrame: CGRectMake(endView.x+endView.width+6, (timetableView.height-fitFloat(20))/2, endWidth, fitFloat(17))];
    endName.font = sub_font_middle;
    endName.textColor = dynamic_color_gray;
    endName.text = lastTime;
    [timetableView addSubview:endName];
    timetableView.frame = CGRectMake(timetableView.frame.origin.x, timetableView.frame.origin.y, endName.x+endName.width+12, timetableView.frame.size.height);
    return timetableView;
}


-(void)createCellTable:(StationModel*)station cell:(UICollectionViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(view_margin, 0, SCREEN_WIDTH-view_margin, 52)];
    
    UILabel *titleName = [[UILabel alloc] init];
    CGSize titleSize = [station.nameCn sizeWithAttributes:@{NSFontAttributeName:main_font_small}];
    titleName.frame = CGRectMake(0, 16, titleSize.width, 20);
    titleName.font = main_font_small;
    titleName.textColor = dynamic_color_black;
    titleName.text = station.nameCn;
    [view addSubview:titleName];
        
    CGFloat x = view_margin;
    for(NSInteger i=station.lines.count-1; i>=0; i--){
        NSString *lid = station.lines[i];
        if([lid integerValue] == _line.identifyCode) continue;
        LineModel *line = _city.lineDicts[[NSString stringWithFormat:@"%@",lid]];
        CGSize lineSize = [line.nameSimple sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"DIN-Black" size:14]}];
        CGFloat lineWidth = lineSize.width<fitFloat(20)?fitFloat(20):(lineSize.width+10);
        x = x+lineWidth+6;
        UILabel *llabel = [[UILabel alloc] initWithFrame:CGRectMake(view.width-x, (52-fitFloat(20))/2, lineWidth, fitFloat(20))];
        llabel.backgroundColor = [ColorUtils colorWithHexString:line.color];
        if(!llabel.backgroundColor) llabel.backgroundColor = dynamic_color_gray;
        llabel.textColor = main_color_white;
        llabel.text = line.nameSimple;
        llabel.textAlignment = NSTextAlignmentCenter;
        llabel.font = [UIFont fontWithName:@"DIN-Black" size:14];
//        if(llabel.text.length<2) llabel.font = [UIFont fontWithName:@"DIN-Black" size:14];
//        else if(llabel.text.length<3) llabel.font = [UIFont fontWithName:@"DIN-Black" size:10];
//        else llabel.font = [UIFont fontWithName:@"DIN-Black" size:7];
        llabel.layer.cornerRadius = fitFloat(20)/2;
        llabel.layer.masksToBounds = YES;
        [view addSubview:llabel];
    }
    
    CGFloat maxTimetableWidth = view.width-x-titleName.width-view_margin*2;
    UIView *timetable = [self createTimetableView:CGRectMake(titleName.x+titleName.width+12, 0, cell.width, 52) station:station];
    if(timetable && timetable.width <= maxTimetableWidth){
        [view addSubview:timetable];
    }
        
    CALayer *viewBorder = [CALayer layer];
    viewBorder.frame = CGRectMake(0, view.height, view.width, 1);
    viewBorder.backgroundColor = dynamic_color_lightgray.CGColor;
    [view.layer addSublayer:viewBorder];
    [cell.contentView addSubview:view];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showStationInfo:)];
    view.userInteractionEnabled = YES;
    view.tag = indexPath.item;
    [view addGestureRecognizer:tap];
}

-(void) showStationInfo:(UITapGestureRecognizer*)tap{
    if(tap.view.tag>=_dataStations.count) return;
    if(self.showStationInfo) self.showStationInfo(_city, _dataStations[tap.view.tag]);
}

-(void)switchDirection:(UITapGestureRecognizer*)tap{
    if(tap.view.tag<_directionSection.count && tap.view.tag==_curSection){
        if(_directionSection.count>_curSection){
            NSArray *array = _directionSection[_curSection];
            if(array.count>(_curItem+1)%2) [self loadDirection:(_curItem+1)%2 section:_curSection];
        }
    }else if(tap.view.tag<_directionSection.count){
        _curSection = tap.view.tag;
        [self loadDirection:0 section:tap.view.tag];
    }
}

//返回collection的section数量
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //如果photo数量为0则不显示底部刷新条
    return _dataStations.count;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(SCREEN_WIDTH, 52);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    return CGSizeMake(SCREEN_WIDTH, 52*_directionSection.count);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    return CGSizeMake(SCREEN_WIDTH, SAFE_AREA_INSERTS_BOTTOM);
}

//section盖住滚动条解决
- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    view.layer.zPosition = 0.0;
}

-(void)loadDirection:(NSInteger)item section:(NSInteger)section{
    if(!_directionSection){
        //方向分组
        _directionSection = [NSMutableArray new];
        NSMutableArray *temp = [NSMutableArray new];
        for(DirectionModel *direction1 in _line.directions){
            if([temp containsObject:direction1]) continue;
            for(DirectionModel *direction2 in _line.directions){
                if(direction1.identifyCode==direction2.reverseDirectionId || direction2.identifyCode==direction1.reverseDirectionId){
                    [_directionSection addObject:@[direction1, direction2]];
                    [temp addObject:direction1];
                    [temp addObject:direction2];
                    break;
                }
            }
        }
        NSMutableSet *set1 = [NSMutableSet setWithArray:_line.directions];
        NSMutableSet *set2 = [NSMutableSet setWithArray:temp];
        [set1 minusSet:set2];
        for(DirectionModel *direction in set1){
            [_directionSection addObject:@[direction]];
        }
    }
    
    //当前选中方向
    if(_directionSection.count>section){
        NSMutableArray *directions = _directionSection[section];
        if(directions.count>item){
            _curItem = item;
            _curSection = section;
            _selectedDirection = directions[item];
        }
    }
    
    if(_selectedDirection){
        _dataStations = [NSMutableArray new];
        if(_selectedDirection.stations) for(NSString *sid in _selectedDirection.stations){
            StationModel *station = _city.stationDicts[[NSString stringWithFormat:@"%@", sid]];
            if(station) [_dataStations addObject:station];
        }
    }
    [self reloadData];
}
@end
