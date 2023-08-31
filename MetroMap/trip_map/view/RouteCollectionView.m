//
//  RouteCollectionView.m
//  MetroMap
//
//  Created by edwin on 2019/10/11.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "RouteCollectionView.h"

@interface RouteCollectionView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, retain) UICollectionViewFlowLayout *fallLayout;
@property (nonatomic, retain) NSMutableArray<RouteModel*> *routesList;

@property (nonatomic, assign) NSInteger curIndex;
@property (nonatomic, assign) BOOL hideDetail;
@property (nonatomic, assign) CGFloat viewHeight;
@property (nonatomic, assign) CGFloat mainViewHeight;
@property (nonatomic, assign) CGFloat initViewHeight;
@property (nonatomic, assign) CGFloat initMainViewHeight;

@end

static NSString * const route_collection_id = @"route_collection";
@implementation RouteCollectionView

-(instancetype)initWithFrame:(CGRect)frame routes:(NSMutableArray*)routes{
    // 创建布局
    _fallLayout = [[UICollectionViewFlowLayout alloc]init];
    _fallLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self = [super initWithFrame:frame collectionViewLayout:_fallLayout];
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:route_collection_id];
    self.dataSource = self;
    self.delegate = self;
    self.allowsSelection = NO;
    self.alwaysBounceHorizontal = YES;
    self.pagingEnabled = YES;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    _initViewHeight = ceil(SCREEN_HEIGHT/3);
    _viewHeight = _initViewHeight;
    _initMainViewHeight = self.height;
    _mainViewHeight = _initMainViewHeight;
    self.backgroundColor = [UIColor clearColor];
    self.showsHorizontalScrollIndicator = NO;
    _routesList = routes;
    return self;
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //根据注册标记查找cell
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:route_collection_id forIndexPath:indexPath];
    if(cell.contentView.subviews) for(UIView *sview in cell.contentView.subviews) [sview removeFromSuperview];
    [self createViewInCell:cell indexPath:indexPath];
    return cell;
}

-(void)hideDetailView:(BOOL)hide{
    if(_hideDetail!=hide){
        _hideDetail = hide;
        [self reloadData];
    }
}
-(void)resetViewHeight:(CGFloat)height{
    if(_viewHeight != height){
        CGFloat mainViewHeight = height + _initMainViewHeight - _initViewHeight;
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, mainViewHeight);
        _mainViewHeight = mainViewHeight;
        _viewHeight = height;
        [self reloadData];
    }
}

-(void)createViewInCell:(UICollectionViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    if(!_routesList || _routesList.count<=indexPath.item) return;
    RouteModel *routeModel = _routesList[indexPath.item];
    UIView *guideView = [self guideView:routeModel.segments];
    guideView.tag = 1000 + indexPath.item;
    [cell.contentView addSubview:guideView];
    guideView.backgroundColor = dynamic_color_white;
    
    NSString *tripName = [NSString stringWithFormat:@"%ld 站 · 换乘 %ld 次 · %@ 元 · %ld 分钟", (long)routeModel.countStop, (long)routeModel.countTransfor, [BaseUtils decimalString:((float)routeModel.costPrice/100) maxNum:2], routeModel.costTime/60];
    UILabel *tripNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(view_margin*2, fitFloat(52)+20, self.width-view_margin*4, 14)];
    tripNameLabel.font = sub_font_small;
    tripNameLabel.textColor = dynamic_color_gray;
    tripNameLabel.textAlignment = NSTextAlignmentCenter;
    tripNameLabel.text = tripName;
    tripNameLabel.tag = 2000 + indexPath.item;
    [cell.contentView addSubview:tripNameLabel];
    tripNameLabel.backgroundColor = dynamic_color_white;
    
    NSString *lineLast = routeModel.segmentLast?routeModel.segmentLast.line.nameCn:@"-";
    NSString *lastTimeName = [NSString stringWithFormat:@"预计 %@ 后进站会错过 %@ 末班车, 请留意列车时刻", routeModel.lastTime?routeModel.lastTime:@"-", lineLast];
    UILabel *lastTimeNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(view_margin*2, fitFloat(52)+20+26, self.width-view_margin*4, 14)];
    lastTimeNameLabel.font = sub_font_small;
    lastTimeNameLabel.textColor = dynamic_color_gray;
    lastTimeNameLabel.textAlignment = NSTextAlignmentCenter;
    lastTimeNameLabel.text = lastTimeName;
    lastTimeNameLabel.tag = 3000 + indexPath.item;
    [cell.contentView addSubview:lastTimeNameLabel];
    lastTimeNameLabel.backgroundColor = dynamic_color_white;
    
    if(!_hideDetail){
//        RouteDetailView *detailView = [[RouteDetailView alloc] initWithFrame:CGRectMake(view_margin*2, 116, self.width-view_margin*4, _viewHeight) route:routeModel];
        RouteDetailScrollView *detailView = [[RouteDetailScrollView alloc] initWithFrame:CGRectMake(0, fitFloat(116+26), self.width, _viewHeight) route:routeModel];
        detailView.backgroundColor = dynamic_color_white;
        [cell.contentView addSubview:detailView];
//        [self performSelector:@selector(reloadDetailView:) withObject:detailView afterDelay:.1f];
    }
}

//-(void)reloadDetailView:(RouteDetailView*)detailView{
//    [detailView reloadData];
//}

-(UIView*)guideView:(NSMutableArray*)segments{
    UIView *guideView = [[UIView alloc] initWithFrame:CGRectMake(view_margin*2, 0, SCREEN_WIDTH-view_margin*4, 52)];
    NSInteger count = !segments?0:segments.count;
    if(count==0) return guideView;
    else if(count==1){
        RouteSegmentModel *segment = segments[0];
        UIView *subLineView = [self createLineView:segment.line withName:YES maxWidth:SCREEN_WIDTH-view_margin*4];
        subLineView.frame = CGRectMake((guideView.frame.size.width-subLineView.frame.size.width)/2, (guideView.frame.size.height-subLineView.frame.size.height)/2, subLineView.frame.size.width, subLineView.frame.size.height);
        [guideView addSubview:subLineView];
    }else if(count == 2){
        RouteSegmentModel *segment1 = segments[0];
        RouteSegmentModel *segment2 = segments[1];
        CGFloat maxWidth = (guideView.frame.size.width-fitFloat(15)-24)/2;
        UIView *subLineView1 = [self createLineView:segment1.line withName:YES maxWidth:maxWidth];
        UIView *subLineView2 = [self createLineView:segment2.line withName:YES maxWidth:maxWidth];
        CGFloat width1 = subLineView1.frame.size.width>maxWidth ? maxWidth : subLineView1.frame.size.width;
        CGFloat width2 = subLineView2.frame.size.width>maxWidth ? maxWidth : subLineView2.frame.size.width;
        subLineView1.frame = CGRectMake(0, (guideView.frame.size.height-subLineView1.frame.size.height)/2, width1, subLineView1.frame.size.height);
        subLineView2.frame = CGRectMake(guideView.frame.size.width-width2, (guideView.frame.size.height-subLineView2.frame.size.height)/2, width2, subLineView2.frame.size.height);
        [guideView addSubview:subLineView1];
        [guideView addSubview:subLineView2];
        UIImageView *guideIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navi_right"]];
        guideIcon.frame = CGRectMake((guideView.frame.size.width-fitFloat(15))/2, (52-fitFloat(15))/2, fitFloat(15), fitFloat(15));
        [guideView addSubview:guideIcon];
    }else if(count == 3){
        RouteSegmentModel *segment1 = segments[0];
        RouteSegmentModel *segment2 = segments[1];
        RouteSegmentModel *segment3 = segments[2];
        CGFloat maxWidth = (guideView.width-fitFloat(15)*2-24*2)/3;
        UIView *subLineView1 = [self createLineView:segment1.line withName:YES maxWidth:maxWidth];
        UIView *subLineView2 = [self createLineView:segment2.line withName:YES maxWidth:maxWidth];
        UIView *subLineView3 = [self createLineView:segment3.line withName:YES maxWidth:maxWidth];
        CGFloat width1 = subLineView1.frame.size.width>maxWidth ? maxWidth : subLineView1.frame.size.width;
        CGFloat width2 = subLineView2.frame.size.width>maxWidth ? maxWidth : subLineView2.frame.size.width;
        CGFloat width3 = subLineView3.frame.size.width>maxWidth ? maxWidth : subLineView3.frame.size.width;
        subLineView1.frame = CGRectMake(0, (guideView.frame.size.height-subLineView1.frame.size.height)/2, width1, subLineView1.frame.size.height);
        subLineView2.frame = CGRectMake((guideView.frame.size.width-width2)/2, (guideView.frame.size.height-subLineView2.frame.size.height)/2, width2, subLineView2.frame.size.height);
        subLineView3.frame = CGRectMake(guideView.frame.size.width-width3, (guideView.frame.size.height-subLineView3.frame.size.height)/2, width3, subLineView3.frame.size.height);
        [guideView addSubview:subLineView1];
        [guideView addSubview:subLineView2];
        [guideView addSubview:subLineView3];
        UIImageView *guideIcon1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navi_right"]];
        guideIcon1.frame = CGRectMake(guideView.frame.size.width*2/3-fitFloat(15)/2, (52-fitFloat(15))/2, fitFloat(15), fitFloat(15));
        UIImageView *guideIcon2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navi_right"]];
        guideIcon2.frame = CGRectMake(guideView.frame.size.width/3-fitFloat(15)/2, (52-fitFloat(15))/2, fitFloat(15), fitFloat(15));
        [guideView addSubview:guideIcon1];
        [guideView addSubview:guideIcon2];
    }else{
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, guideView.width-26, 52)];
        CGFloat x=0;
        for(int i=0; i<count; i++){
            RouteSegmentModel *segment = segments[i];
            CGFloat maxWidth = (guideView.width-fitFloat(15)*2-24*2)/count;
            UIView *subLineView = [self createLineView:segment.line withName:NO maxWidth:maxWidth];
            subLineView.frame = CGRectMake(x, (guideView.height-subLineView.height)/2, subLineView.width, subLineView.height);
            x = x + subLineView.width + 12;
            [scrollView addSubview:subLineView];
            if(i<count-1){
                UIImageView *guideIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navi_right"]];
                guideIcon.frame = CGRectMake(x, (52-fitFloat(15))/2, fitFloat(15), fitFloat(15));
                x = x + guideIcon.width + 12;
                [scrollView addSubview:guideIcon];
            }
        }
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(guideView.width-23, 19, fitFloat(20), fitFloat(14))];
        _detailLabel.font = sub_font_small;
        _detailLabel.textColor = dynamic_color_gray;
        _detailLabel.text = @"展开";
        UITapGestureRecognizer *showDetail = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showRouteDetail:)];
        _detailLabel.userInteractionEnabled = YES;
        [_detailLabel addGestureRecognizer:showDetail];
        [guideView addSubview:scrollView];
        [guideView addSubview:_detailLabel];
    }
    return guideView;
}

-(void)showRouteDetail:(UITapGestureRecognizer*)tap{
    if(self.showRouteDetail) self.showRouteDetail(_curIndex);
}

-(UIView *)createLineView:(LineModel*)line withName:(BOOL)withName maxWidth:(CGFloat)maxWidth{
    CGSize lineCodeSize = [line.nameSimple sizeWithAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"DIN-Black" size:14]}];
    CGFloat lineCodeWidth = lineCodeSize.width<fitFloat(20)?fitFloat(20):(lineCodeSize.width+10);
    lineCodeWidth = lineCodeWidth>maxWidth?maxWidth:lineCodeWidth;
    UILabel *llabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, lineCodeWidth, fitFloat(20))];
    llabel.backgroundColor = [ColorUtils colorWithHexString:line.color];
    llabel.textColor = main_color_white;
    llabel.text = line.nameSimple;
    llabel.textAlignment = NSTextAlignmentCenter;
    llabel.font = [UIFont fontWithName:@"DIN-Black" size:14];
    llabel.layer.cornerRadius = fitFloat(20)/2;
    llabel.layer.masksToBounds = YES;
    if(!withName) return llabel;
    
    UIView *subLineView = [[UIView alloc] init];
    NSString *lineName = line.code?[line.nameCn stringByReplacingOccurrencesOfString:line.code withString:[NSString stringWithFormat:@"%@ ",line.code]]:line.nameCn;
    CGSize lineNameSize = [lineName sizeWithAttributes:@{NSFontAttributeName:main_font_small}];
    UILabel *lineNameLabel = [[UILabel alloc] init];
    lineNameLabel.font = main_font_small;
    lineNameLabel.textColor = dynamic_color_black;
    lineNameLabel.text = lineName;
    [subLineView addSubview:lineNameLabel];
    [subLineView addSubview:llabel];
    
    CGFloat maxSubWidth = maxWidth-(llabel.width+12);
    CGFloat subWidth = maxSubWidth<0?0:(maxSubWidth<lineNameSize.width?maxSubWidth:lineNameSize.width);
    lineNameLabel.frame = CGRectMake(llabel.width+12, 0, subWidth, fitFloat(20));
    subLineView.frame = CGRectMake(0, (52-fitFloat(20))/2, subWidth+12+llabel.width, fitFloat(20));
    return subLineView;
}

//设置cell的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(SCREEN_WIDTH, _mainViewHeight);
}

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
    return _routesList.count;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    int curIndex = round(scrollView.contentOffset.x /scrollView.bounds.size.width);
    if(_curIndex != curIndex){
        _curIndex = curIndex;
        if(self.switchSelected) self.switchSelected(curIndex);
    }
}

- (RouteModel*) getCurentRouteInfo{
    return _routesList[_curIndex];
}
- (UIImage*)getImageWithCustomRect{
    UICollectionViewCell * cell = [self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_curIndex inSection:0]];
    UIImage *detail,*title,*summary;
    if(cell && cell.contentView && cell.contentView.subviews) for(UIView *view in cell.contentView.subviews){
//        if([view isKindOfClass:[RouteDetailView class]]){
//            RouteDetailView *dview = (RouteDetailView*)view;
//            detail = [dview getImageWithCustomRect];
        if([view isKindOfClass:[RouteDetailScrollView class]]){
            RouteDetailScrollView *dview = (RouteDetailScrollView*)view;
            detail = [dview getImageWithCustomRect];
        }else if(view.tag/1000==1){
//            UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, view.height+view_margin)];
//            if(!view.backgroundColor || [view.backgroundColor isEqual:[UIColor clearColor]])
//                titleView.backgroundColor = [UIColor whiteColor];
//            else titleView.backgroundColor = view.backgroundColor;
//            NSData *tempArchive = [NSKeyedArchiver archivedDataWithRootObject:view];
//            UIView *tempView = [NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
//            tempView.frame = CGRectMake((SCREEN_WIDTH-view.width)/2, view_margin, view.width, view.height);
//            [titleView addSubview:tempView];
//            title = [titleView viewCutter];
            title = [view viewCutter];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:title];
            imageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, view.height);
            imageView.backgroundColor = dynamic_color_white;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            title = [imageView viewCutter];
        }else if(view.tag/1000==2){
//            UIView *summaryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, view.height+view_margin)];
//            if(!view.backgroundColor || [view.backgroundColor isEqual:[UIColor clearColor]])
//                summaryView.backgroundColor = [UIColor whiteColor];
//            else summaryView.backgroundColor = view.backgroundColor;
//            NSData *tempArchive = [NSKeyedArchiver archivedDataWithRootObject:view];
//            UIView *tempView = [NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
//            tempView.frame = CGRectMake((SCREEN_WIDTH-view.width)/2, view_margin/3, view.width, view.height);
//            [summaryView addSubview:tempView];
//            summary = [summaryView viewCutter];
            summary = [view viewCutter];
            UIImageView *imageView = [[UIImageView alloc] initWithImage:summary];
            imageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, view.height);
            imageView.backgroundColor = dynamic_color_white;
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            summary = [imageView viewCutter];
        }
    }
    
    if(title || summary) title = [BaseUtils combineImageUpImage:title DownImage:summary];
    if(title || detail) title = [BaseUtils combineImageUpImage:title DownImage:detail];
    return title;
}


-(void)collectRouteInfo{
    UICollectionViewCell * cell = [self cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_curIndex inSection:0]];
    if(cell && cell.contentView && cell.contentView.subviews) for(UIView *view in cell.contentView.subviews){
//        if([view isKindOfClass:[RouteDetailView class]]){
//            RouteDetailView *dview = (RouteDetailView*)view;
//            [dview collectRouteInfo];
//            return;
//        }
        if([view isKindOfClass:[RouteDetailScrollView class]]){
            RouteDetailScrollView *dview = (RouteDetailScrollView*)view;
            [dview collectRouteInfo];
            return;
        }
    }
    [MBProgressHUD showInfo:@"数据异常，添加失败" detail:nil image:nil inView:nil];
}
@end
