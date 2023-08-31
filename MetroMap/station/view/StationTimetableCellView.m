//
//  StationTimetableCellView.m
//  MetroMap
//
//  Created by edwin on 2019/11/3.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "StationTimetableCellView.h"

@interface StationTimetableCellView()
//嘉定北-迪士尼和迪士尼-嘉定北为一组，花桥-迪士尼和迪士尼-花桥为一组
@property (nonatomic, retain) LineModel *selectedLine;
@property (nonatomic, retain) NSMutableArray *timetable;
@property (nonatomic, retain) NSMutableArray *directionSection;
@property (nonatomic, assign) NSInteger curSection;
@property (nonatomic, assign) NSInteger curItem;
@property (nonatomic, retain) DirectionModel *selectedDirection;
@property (nonatomic, retain) CityModel *city;

@property(nonatomic, retain) NSMutableArray *layers;

@end

@implementation StationTimetableCellView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    return self;
}

-(CGFloat)loadCellView:(NSMutableArray*)timetable line:(LineModel*)line city:(CityModel*)city{
    if(self.contentView.subviews) for(UIView *view in self.contentView.subviews) [view removeFromSuperview];
    if(line) _selectedLine = line;
    if(timetable) _timetable = timetable;
    if(city) _city = city;
    if(line || timetable) {
        _directionSection = nil;
        [self loadDirection:_selectedLine item:0 section:0];
    }
    CGFloat height = 0;
    for(int i=0; i<_directionSection.count; i++){
        NSMutableArray *directions = _directionSection[i];
        UIView *view = [self createLineTitleView:CGRectMake(view_margin, 52*i, self.width-view_margin, 52) direction:_curSection==i?directions[_curItem]:directions[0] index:i];
        if(view){
            [self.contentView addSubview:view];
            height += view.height;
        }
    }
    UIView *view = nil;
    for(StationTimetableModel *stModel in _timetable){
        if(stModel.directionId == _selectedDirection.identifyCode){
            view = [self createTimetableView:CGRectMake(view_margin, 52*_directionSection.count, self.width-view_margin, 52) start:[stModel findFirstTime] end:[stModel findLastTime]];
            if(view) {
                [self.contentView addSubview:view];
                height += view.height;
                break;
            }
        }
    }
    if(!view){
        view = [self createTimetableView:CGRectMake(view_margin, 52*_directionSection.count, self.width-view_margin, 52) start:nil end:nil];
        if(view) {
            [self.contentView addSubview:view];
            height += view.height;
        }
    }
    [self.contentView mas_makeConstraints:^(MASConstraintMaker*make) {
        make.left.top.mas_equalTo(0).priorityHigh();
        make.width.mas_equalTo(SCREEN_WIDTH).priorityHigh();
        make.height.mas_equalTo(height).priorityHigh();
    }];
    _cellheight = height;
    return height;
}

-(UIView *)createLineTitleView:(CGRect)frame direction:(DirectionModel*)direction index:(NSInteger)index{
    UIView *titleView = [[UIView alloc] initWithFrame:frame];
    CALayer *viewBorder = [CALayer layer];
    viewBorder.frame = CGRectMake(0, titleView.height-1, titleView.width, 1);
    viewBorder.backgroundColor = dynamic_color_lightgray.CGColor;
    [titleView.layer addSublayer:viewBorder];
    if(!_layers) _layers = [NSMutableArray new];
    [_layers addObject:viewBorder];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, titleView.width, titleView.height)];
    label.textColor = dynamic_color_gray;
    label.font = main_font_small;
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"线路格式异常";
    
    BOOL selected = (index==_curSection);
    
    if(!direction.name && !direction.directionName){
        [titleView addSubview:label];
        return titleView;
    }
    
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
        NSArray *array = [nameTitle componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"-"]];
        if(array.count<2) {
            [titleView addSubview:label];
            return titleView;
        }

        CGFloat maxTitleWidth = (titleView.width-12-15-42-5*12)/2;
        CGSize startSize = [array[0] sizeWithAttributes:@{NSFontAttributeName:main_font_small}];
        CGSize endSize = [array[array.count-1] sizeWithAttributes:@{NSFontAttributeName:main_font_small}];
        CGFloat startWidth = startSize.width<maxTitleWidth?startSize.width:maxTitleWidth;
        CGFloat endWidth = endSize.width<maxTitleWidth?endSize.width:maxTitleWidth;
        UILabel *startStationName = [[UILabel alloc] initWithFrame:CGRectMake(18, (52-startSize.height)/2, startWidth, startSize.height)];
        startStationName.font = main_font_small;
        startStationName.textColor = selected?dynamic_color_black:dynamic_color_gray;
        startStationName.textAlignment = NSTextAlignmentLeft;
        startStationName.text = array[0];
        [titleView addSubview:startStationName];
        UILabel *endStationName = [[UILabel alloc] initWithFrame:CGRectMake(18+startStationName.width+12+42+12+18, (52-endSize.height)/2, endWidth, endSize.height)];
        endStationName.font = main_font_small;
        endStationName.textColor = selected?dynamic_color_black:dynamic_color_gray;
        endStationName.textAlignment = NSTextAlignmentLeft;
        endStationName.text = array[array.count-1];
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

-(UIView *) createTimetableView:(CGRect)frame start:(NSString*)startTime end:(NSString*)endTime{
    UIView *timetableView = [[UIView alloc] initWithFrame:frame];
    CALayer *tviewBorder = [CALayer layer];
    tviewBorder.frame = CGRectMake(0, timetableView.height-1, timetableView.width, 1);
    tviewBorder.backgroundColor = dynamic_color_lightgray.CGColor;
    tviewBorder.opacity = 0.5;
    [timetableView.layer addSublayer:tviewBorder];
    if(!_layers) _layers = [NSMutableArray new];
    [_layers addObject:tviewBorder];
    
    UIView *firstView = [[UIView alloc] initWithFrame:CGRectMake(0, (timetableView.height-fitFloat(20))/2, 48, fitFloat(20))];
    CAGradientLayer *gl2 = [CAGradientLayer layer];
    gl2.frame = CGRectMake(0,0,48,fitFloat(20));
    gl2.startPoint = CGPointMake(0, 0);
    gl2.endPoint = CGPointMake(1, 1);
    gl2.colors = gradual_color_blue;
    gl2.locations = @[@(0), @(1.0f)];
    gl2.cornerRadius = 3;
    [firstView.layer addSublayer:gl2];
    UILabel *firstTitle = [[UILabel alloc] initWithFrame: CGRectMake((firstView.width-fitFloat(36))/2, (firstView.height-fitFloat(17))/2, fitFloat(36), fitFloat(17))];
    firstTitle.font = sub_font_middle;
    firstTitle.textColor = main_color_white;
    firstTitle.text = @"首班车";
    [firstView addSubview:firstTitle];
    [timetableView addSubview:firstView];
    
    startTime = startTime?startTime:@"-";
    CGSize startSize = [startTime sizeWithAttributes:@{NSFontAttributeName:sub_font_middle}];
    CGFloat startWidth = ceil(startSize.width)>fitFloat(32)?ceil(startSize.width):fitFloat(32);
    UILabel *firstName = [[UILabel alloc] initWithFrame: CGRectMake(firstView.x+firstView.width+6, (timetableView.height-fitFloat(17))/2, startWidth, fitFloat(17))];
    firstName.font = sub_font_middle;
    firstName.textColor = dynamic_color_gray;
    firstName.text = startTime?startTime:@"-";
    [timetableView addSubview:firstName];
    
    UIView *endView = [[UIView alloc] initWithFrame:CGRectMake(firstName.x+firstName.width+12, (timetableView.height-fitFloat(20))/2, 48, fitFloat(20))];
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
    [timetableView addSubview:endView];
    
    endTime = endTime?endTime:@"-";
    CGSize endSize = [endTime sizeWithAttributes:@{NSFontAttributeName:sub_font_middle}];
    CGFloat endWidth = ceil(endSize.width)>fitFloat(32)?ceil(endSize.width):fitFloat(32);
    UILabel *endName = [[UILabel alloc] initWithFrame: CGRectMake(endView.x+endView.width+6, (timetableView.height-fitFloat(20))/2, endWidth, fitFloat(17))];
    endName.font = sub_font_middle;
    endName.textColor = dynamic_color_gray;
    endName.text = endTime;
    [timetableView addSubview:endName];
    timetableView.frame = CGRectMake(timetableView.frame.origin.x, timetableView.frame.origin.y, endName.x+endName.width+12, timetableView.frame.size.height);
    return timetableView;
}

-(void)switchDirection:(UITapGestureRecognizer*)tap{
//    [self loadCellView:nil line:nil];
    if(tap.view.tag<_directionSection.count && tap.view.tag==_curSection){
        [self loadDirection:_selectedLine item:(_curItem+1)%2 section:_curSection];
        [self loadCellView:nil line:nil city:nil];
    }else if(tap.view.tag<_directionSection.count){
        _curSection = tap.view.tag;
        [self loadDirection:_selectedLine item:0 section:_curSection];
        [self loadCellView:nil line:nil city:nil];
    }
}

-(void)loadDirection:(LineModel*)line item:(NSInteger)item section:(NSInteger)section{
    //方向分组
    if(!_directionSection){
        _directionSection = [NSMutableArray new];
        NSMutableArray *temp = [NSMutableArray new];
        for(DirectionModel *direction1 in line.directions){
            BOOL direction1InTimetable = NO;
            for(StationTimetableModel *t in _timetable){
                if(t.directionId == direction1.identifyCode){
                    direction1InTimetable = YES;
                    break;
                }
            }
            if(!direction1InTimetable || [temp containsObject:direction1]) continue;
            for(DirectionModel *direction2 in line.directions){
                BOOL direction2InTimetable = NO;
                for(StationTimetableModel *t in _timetable){
                    if(t.directionId == direction2.identifyCode){
                        direction2InTimetable = YES;
                        break;
                    }
                }
                if(!direction2InTimetable) continue;
                if(direction1.identifyCode==direction2.reverseDirectionId || direction2.identifyCode==direction1.reverseDirectionId){
                    [_directionSection addObject:@[direction1, direction2]];
                    [temp addObject:direction1];
                    [temp addObject:direction2];
                    break;
                }
            }
        }
        NSMutableSet *set1 = [NSMutableSet setWithArray:line.directions];
        NSMutableSet *set2 = [NSMutableSet setWithArray:temp];
        [set1 minusSet:set2];
        for(DirectionModel *direction in set1){
            for(StationTimetableModel *t in _timetable){
                if(t.directionId == direction.identifyCode){
                    [_directionSection addObject:@[direction]];
                    break;
                }
            }
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
}

- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    [self setNeedsLayout];
    [self layoutIfNeeded];
    CGSize size = [self.contentView systemLayoutSizeFittingSize:layoutAttributes.size];
    CGRect cellFrame = layoutAttributes.frame;
    cellFrame.size.height = size.height;
    layoutAttributes.frame = cellFrame;
    return layoutAttributes;
}


-(void)updateCGColors{
    if(self.layers) for(CALayer *layer in self.layers){
        layer.backgroundColor = dynamic_color_lightgray.CGColor;
    }
}
@end
