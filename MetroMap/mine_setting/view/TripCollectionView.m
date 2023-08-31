//
//  TripCollectionView.m
//  MetroMap
//
//  Created by edwin on 2019/10/9.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "TripCollectionView.h"

@interface TripCollectionView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, retain) UICollectionViewFlowLayout *fallLayout;
@property (nonatomic, retain) NSMutableArray *dataTrips;
@property (nonatomic, retain) RouteCollectsHelper *routeCollectsHelper;
@property (nonatomic, retain) UIView *noDataView;

@end


static NSString * const trip_collection_id = @"trip_collection";
@implementation TripCollectionView

-(instancetype)initWithFrame:(CGRect)frame{
    // 创建布局
    _fallLayout = [[UICollectionViewFlowLayout alloc]init];
    _fallLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self = [super initWithFrame:frame collectionViewLayout:_fallLayout];
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:trip_collection_id];
    self.dataSource = self;
    self.delegate = self;
    self.allowsSelection = NO;
    self.alwaysBounceVertical = YES;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    self.backgroundColor = dynamic_color_white;
    self.showsVerticalScrollIndicator = YES;
    [self setupRefresh];
    [self.mj_header beginRefreshing];
    return self;
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //根据注册标记查找cell
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:trip_collection_id forIndexPath:indexPath];
    if(cell.contentView.subviews) for(UIView *sview in cell.contentView.subviews) [sview removeFromSuperview];
    if(indexPath.item<_routeCollectsHelper.routeList.count){
        RouteModel *routeModel = _routeCollectsHelper.routeList[indexPath.item];
        [self createCellTable:routeModel cell:cell indexPath:indexPath];
    }
    return cell;
}

-(void)createCellTable:(RouteModel*)routeModel cell:(UICollectionViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    UIView *mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, cell.width, cell.height)];
    mainView.backgroundColor = dynamic_color_white;
    mainView.layer.cornerRadius = 12;
    mainView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05].CGColor;
    mainView.layer.shadowOffset = CGSizeMake(0,3);
    mainView.layer.shadowOpacity = 1;
    mainView.layer.shadowRadius = 6;
    
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(view_margin, 12, fitFloat(100), 14)];
    dateLabel.font = sub_font_small;
    dateLabel.textColor = dynamic_color_gray;
    dateLabel.text = routeModel.routeTime;
    [mainView addSubview:dateLabel];
    
    UILabel *typeLabel = [[UILabel alloc] initWithFrame:CGRectMake(mainView.width-view_margin-fitFloat(20), 12, fitFloat(20), 14)];
    typeLabel.font = sub_font_small;
    typeLabel.textColor = dynamic_color_gray;
    typeLabel.text = routeModel.routeType;
    [mainView addSubview:typeLabel];
    
    NSString *tripName = [NSString stringWithFormat:@"%ld 站 · 换乘 %ld 次 · %@ 元 %d 分钟", (long)routeModel.countStop, (long)routeModel.countTransfor, [BaseUtils decimalString:((float)routeModel.costPrice/100) maxNum:2], routeModel.costTime/60];
    UILabel *tripNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(view_margin, 32, mainView.width-view_margin*2, 20)];
    tripNameLabel.font = main_font_small;
    tripNameLabel.textColor = dynamic_color_black;
    tripNameLabel.text = tripName;
    [mainView addSubview:tripNameLabel];
    
    NSString *directionName = [NSString stringWithFormat:@"%@ → %@", routeModel.startStation.nameCn, routeModel.endStation.nameCn];
    UILabel *directionNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(view_margin, 58, mainView.width-view_margin*2, 20)];
    directionNameLabel.font = sub_font_small;
    directionNameLabel.textColor = dynamic_color_gray;
    directionNameLabel.text = directionName;
    [mainView addSubview:directionNameLabel];
    
    cell.backgroundColor = dynamic_color_lightwhite;
    [cell.contentView addSubview:mainView];
}


//设置cell的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(SCREEN_WIDTH-view_margin*2, fitFloat(84));
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 12;
}

//设置section间隔
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    //分别为上、左、下、右
    return UIEdgeInsetsMake(12, 12, 12, 12);
}

//返回列表分组数，默认为1
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

//返回列表每个分组section拥有cell行数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _routeCollectsHelper.routeList.count;
}


//刷新图片
//- (void)loadTrips{
//    _dataTrips = [NSMutableArray new];
//    [_dataTrips addObject:[RouteModel createFakeModel]];
//    [_dataTrips addObject:[RouteModel createFakeModel]];
//    [_dataTrips addObject:[RouteModel createFakeModel]];
//    [_dataTrips addObject:[RouteModel createFakeModel]];
//}

#pragma mark --MJRefresh
//设置页头页尾和更新数据的方法
- (void)setupRefresh{
//    self.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNews)];
    MJChiBaoZiHeader *header = [MJChiBaoZiHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadTrips)];
    self.mj_header = header;
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    self.mj_header.backgroundColor = [UIColor clearColor];
    self.mj_footer.hidden = NO;
    
    self.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(moreTrips)];
    self.mj_footer.backgroundColor = [UIColor clearColor];
    self.mj_footer.hidden = YES;
}


-(void)showNoDataView:(NSString*)title type:(int)type{
    if(_noDataView){
        [_noDataView removeFromSuperview];
        _noDataView = nil;
    }
    _noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    
    NSString *iconName = @"no_trip";
    if(type==1) iconName = @"no_network";
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconName]];
    icon.frame = CGRectMake((self.width-88)/2, self.height/3, 88, 88);
    [_noDataView addSubview:icon];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, self.height/3+88, self.width, 17)];
    label.font = sub_font_small;
    label.textColor = dynamic_color_gray;
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    [_noDataView addSubview:label];
    [self addSubview:_noDataView];
}

-(void)removeNoDataView{
    if(_noDataView){
        [_noDataView removeFromSuperview];
        _noDataView = nil;
    }
}

-(void)loadTrips{
    if(!_routeCollectsHelper){
        _routeCollectsHelper = [RouteCollectsHelper new];
        _routeCollectsHelper.uri = request_trip_collect_list;
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setObject:@"地铁" forKey:@"type"];
        _routeCollectsHelper.parameters = params;
    }
    __weak typeof(self) wkSelf = self;
    [_routeCollectsHelper loadRoutes:^(NSInteger count) {
        [wkSelf reloadData];
        [wkSelf.mj_header endRefreshing];
        if(count>9) wkSelf.mj_footer.hidden = NO;
        if(count<=0) [wkSelf showNoDataView:@"您暂时还没有行程记录哦~ 下次记得添加吧" type:0];
        else [wkSelf removeNoDataView];
    } failure:^(NSString *errorInfo) {
        [wkSelf.mj_header endRefreshing];
        [wkSelf showNoDataView:@"网络出错! 看来您驶向了无人区" type:1];
    }];
}
-(void)moreTrips{
    __weak typeof(self) wkSelf = self;
    [_routeCollectsHelper moreRoutes:^(NSInteger count) {
        [wkSelf reloadData];
        if(count>0) [wkSelf.mj_footer endRefreshing];
        else {
            [wkSelf.mj_footer endRefreshingWithNoMoreData];
            [wkSelf performSelector:@selector(endRefreshing) withObject:nil afterDelay:2.f];
        }
        [wkSelf removeNoDataView];
    } failure:^(NSString *errorInfo) {
        [wkSelf.mj_footer endRefreshing];
        [wkSelf removeNoDataView];
    }];
}

-(void)endRefreshing{
    [self.mj_footer setHidden:YES];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    __weak typeof(self) wkSelf = self;
    // trait发生了改变
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            MJChiBaoZiHeader *header = [MJChiBaoZiHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadTrips)];
            self.mj_header = header;
            header.lastUpdatedTimeLabel.hidden = YES;
            header.stateLabel.hidden = YES;
            self.mj_header.backgroundColor = [UIColor clearColor];
            self.mj_footer.hidden = NO;
        }
    } else {
    }
}
@end
