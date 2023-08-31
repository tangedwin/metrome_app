//
//  MessageCollectionView.m
//  MetroMap
//
//  Created by edwin on 2019/10/30.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "MessageCollectionView.h"
#import <MobPush/MobPush.h>

@interface MessageCollectionView()<UICollectionViewDelegate, UICollectionViewDataSource>


@property (nonatomic, retain) UICollectionViewFlowLayout *fallLayout;

@property (nonatomic, retain) MessageHelper *messageHelper;
@property (nonatomic, assign) BOOL showAlert;
@property (nonatomic, retain) UIView *noDataView;

@property(nonatomic, retain) NSMutableArray *layers;


@end

static NSString * const message_collection_id = @"message_collection";
static NSString * const message_collection_header_id = @"message_collection_header";
@implementation MessageCollectionView

-(instancetype)initWithFrame:(CGRect)frame{
    // 创建布局
    _fallLayout = [[UICollectionViewFlowLayout alloc]init];
    _fallLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _fallLayout.sectionHeadersPinToVisibleBounds = YES;
    self = [super initWithFrame:frame collectionViewLayout:_fallLayout];
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:message_collection_id];
    [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:message_collection_header_id];
    self.dataSource = self;
    self.delegate = self;
    self.alwaysBounceVertical = YES;
    self.showsVerticalScrollIndicator = YES;
    self.showsHorizontalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    self.backgroundColor = dynamic_color_white;
    _messageHelper = [[MessageHelper alloc] init];
    _messageHelper.uri = request_message_list;
    NSString *registerId = [[NSUserDefaults standardUserDefaults] objectForKey:USER_MESSAGE_REGISTER_ID_KEY];
    if(registerId){
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setObject:registerId forKey:@"registerId"];
        _messageHelper.parameters = params;
    }
    [self checkNotified];
//    [self loadMessageList];
    [self setupRefresh];
    [self.mj_header beginRefreshing];
    return self;
}


-(void)checkNotified{
    __weak typeof(self) wkSelf = self;
    if(@available(iOS 10.0, *)){
        [[UNUserNotificationCenter currentNotificationCenter] getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            if ([NSThread isMainThread]) {
                if(settings.authorizationStatus == UNAuthorizationStatusAuthorized){
                    wkSelf.showAlert = NO;
                    [wkSelf reloadData];
                }else{
                    wkSelf.showAlert = YES;
                    [wkSelf reloadData];
                }
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if(settings.authorizationStatus == UNAuthorizationStatusAuthorized){
                        wkSelf.showAlert = NO;
                        [wkSelf reloadData];
                    }else{
                        wkSelf.showAlert = YES;
                        [wkSelf reloadData];
                    }
                });
            }
        }];
    }
}


#pragma mark - UICollectionViewDataSource
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:message_collection_header_id forIndexPath:indexPath];
    
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        if(reusableView.subviews) for(UIView *sview in reusableView.subviews) [sview removeFromSuperview];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        CAGradientLayer *gl = [CAGradientLayer layer];
        gl.frame = CGRectMake(0,0,SCREEN_WIDTH,30);
        gl.startPoint = CGPointMake(0, 0.5);
        gl.endPoint = CGPointMake(1, 0.5);
        gl.colors = gradual_color_blue;
        gl.locations = @[@(0), @(1.0f)];
        [view.layer addSublayer:gl];
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(view_margin, 7, 230, 17)];
        titleLabel.font = sub_font_middle;
        titleLabel.textColor = main_color_white;
        titleLabel.text = @"不再错过重要消息，赶紧去开启通知吧";
        titleLabel.textAlignment = NSTextAlignmentLeft;
        [view addSubview:titleLabel];
        
        UILabel *openButton = [[UILabel alloc] initWithFrame:CGRectMake(view_margin*2+titleLabel.width, 6, 42, 18)];
        openButton.font = sub_font_small;
        openButton.textColor = main_color_blue;
        openButton.text = @"开启";
        openButton.backgroundColor = main_color_white;
        openButton.textAlignment = NSTextAlignmentCenter;
        openButton.layer.cornerRadius = 9;
        openButton.layer.masksToBounds = YES;
        [view addSubview:openButton];
        UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openNotification:)];
        openButton.userInteractionEnabled = YES;
        [openButton addGestureRecognizer:tap1];
        
        UIImageView *closeButton = [[UIImageView alloc] initWithFrame:CGRectMake(view.width-25, (30-15)/2, 15, 15)];
        [closeButton setImage:[UIImage imageNamed:@"close_icon"]];
        [view addSubview:closeButton];
        UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeHeader:)];
        closeButton.userInteractionEnabled = YES;
        [closeButton addGestureRecognizer:tap2];
        
        reusableView.backgroundColor = dynamic_color_white;
        [reusableView addSubview:view];
    }
    //如果是头视图
    return reusableView;
}

-(void) openNotification:(UITapGestureRecognizer*)tap{
    _showAlert = NO;
    [self reloadData];
    UIApplication *application = [UIApplication sharedApplication];
    NSURL *URL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
    [application openURL:URL options:@{} completionHandler:nil];
}
-(void) closeHeader:(UITapGestureRecognizer*)tap{
    _showAlert = NO;
    [self reloadData];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //根据注册标记查找cell
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:message_collection_id forIndexPath:indexPath];
    if(cell.contentView.subviews) for(UIView *view in cell.contentView.subviews) [view removeFromSuperview];
    MessageModel *message = _messageHelper.messageList[indexPath.item];
    [self createTableLabel:message line:YES cell:cell indexPath:indexPath];
    return cell;
}

-(void)createTableLabel:(MessageModel*)message line:(BOOL)showLine cell:(UICollectionViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    CGFloat width = SCREEN_WIDTH-view_margin;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(view_margin, 0, width, 52)];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 16, view.width-100-view_margin*3-15, 20)];
    if(!message.readed){
        titleLabel.font = main_font_middle_small;
        titleLabel.textColor = dynamic_color_black;
    }else{
        titleLabel.font = main_font_small;
        titleLabel.textColor = dynamic_color_gray;
    }
    titleLabel.text = message.title;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [view addSubview:titleLabel];
    
    UILabel *dataLabel = [[UILabel alloc] initWithFrame:CGRectMake(view.width-100-view_margin*2-15, 16, 100, 20)];
    dataLabel.font = main_font_small;
    dataLabel.textColor = dynamic_color_gray;
    dataLabel.text = message.publishTime;
    dataLabel.textAlignment = NSTextAlignmentRight;
    [view addSubview:dataLabel];
    
    UIImageView *nextButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navi_right_big"]];
    nextButton.frame = CGRectMake(view.width-view_margin-15, (52-15)/2, 15, 15);
    [view addSubview:nextButton];
    [cell.contentView addSubview:view];
    
    if(showLine){
        CALayer *viewBorder = [CALayer layer];
        viewBorder.frame = CGRectMake(0, view.height, view.width, 1);
        viewBorder.backgroundColor = dynamic_color_lightgray.CGColor;
        viewBorder.opacity = 1;
        [view.layer addSublayer:viewBorder];
        if(!_layers) _layers = [NSMutableArray new];
        [_layers addObject:viewBorder];
    }
    
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showMessage:)];
    view.userInteractionEnabled = YES;
    view.tag = indexPath.item;
    [view addGestureRecognizer:tap];
}

-(void)showMessage:(UITapGestureRecognizer*)tap{
    if(_messageHelper.messageList.count>tap.view.tag && self.showMessageDetail){
        MessageModel *message = _messageHelper.messageList[tap.view.tag];
        message.readed = YES;
        self.showMessageDetail(message);
    }
}

//返回collection的section数量
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _messageHelper.messageList.count;
}

// 设置UIcollectionView整体的内边距（这样item不贴边显示）
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // 上 左 下 右
    return UIEdgeInsetsMake(6,0,6,0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(SCREEN_WIDTH, 52);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if(_showAlert) return CGSizeMake(SCREEN_WIDTH, 30);
    else return CGSizeZero;
}

//section盖住滚动条解决
- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    view.layer.zPosition = 0.0;
}

- (void)setupRefresh{
//    self.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNews)];
    MJChiBaoZiHeader *header = [MJChiBaoZiHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadMessageList)];
    self.mj_header = header;
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    self.mj_header.backgroundColor = [UIColor clearColor];
    self.mj_footer.hidden = NO;
    
    self.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreMessageList)];
    self.mj_footer.backgroundColor = [UIColor clearColor];
    self.mj_footer.hidden = YES;
}

-(void)showNoDataView:(NSString*)title type:(int)type{
    if(_noDataView){
        [_noDataView removeFromSuperview];
        _noDataView = nil;
    }
    _noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    
    NSString *iconName = @"no_message";
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



- (void)loadMessageList{
    __weak typeof(self) wkSelf = self;
    [_messageHelper loadMessages:^(NSInteger count) {
        [wkSelf reloadData];
        [wkSelf.mj_header endRefreshing];
        if(count>9) wkSelf.mj_footer.hidden = NO;
        if(count<=0) [wkSelf showNoDataView:@"您还没有收到任何消息~ " type:0];
        else [wkSelf removeNoDataView];
    } failure:^(NSString *errorInfo) {
        [wkSelf.mj_header endRefreshing];
        [wkSelf showNoDataView:@"网络出错! 看来您驶向了无人区" type:1];
    }];
}
-(void) loadMoreMessageList{
    __weak typeof(self) wkSelf = self;
    [_messageHelper moreMessages:^(NSInteger count) {
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
            if(wkSelf.layers) for(CALayer *layer in wkSelf.layers){
                layer.backgroundColor = dynamic_color_lightgray.CGColor;
            }

            MJChiBaoZiHeader *header = [MJChiBaoZiHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadMessageList)];
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
