//
//  ArticleCollectionView.m
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "ArticleCollectionView.h"
#import "GDTNativeExpressAd.h"
#import "GDTNativeExpressAdView.h"

@interface ArticleCollectionView()<UICollectionViewDelegate, UICollectionViewDataSource, GDTNativeExpressAdDelegete>

@property (nonatomic, retain) UICollectionViewFlowLayout *fallLayout;
//@property (nonatomic, retain) NSMutableArray *dataNewsList;

@property (nonatomic, strong) GDTNativeExpressAd *nativeExpressAd;

@property (nonatomic, retain) UIView *noDataView;

@end

static NSString * const article_collection_id = @"article_collection";
@implementation ArticleCollectionView


-(instancetype)initWithFrame:(CGRect)frame{
    // 创建布局
    _fallLayout = [[UICollectionViewFlowLayout alloc]init];
    _fallLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self = [super initWithFrame:frame collectionViewLayout:_fallLayout];
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:article_collection_id];
    self.dataSource = self;
    self.delegate = self;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    self.backgroundColor = dynamic_color_white;
    
    // 支持视频广告的 PlacementId 会混出视频与图片广告
    CGFloat width = SCREEN_WIDTH-view_margin*2;
    CGFloat height = width/375*87;
    self.nativeExpressAd = [[GDTNativeExpressAd alloc] initWithAppId:GDT_APP_ID placementId:GDT_NATIVE_ARTICLE_AD_ID adSize:CGSizeMake(width, height)];
    self.nativeExpressAd.delegate = self;
    
    [self setupRefresh];
    return self;
}


#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //根据注册标记查找cell
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:article_collection_id forIndexPath:indexPath];
    if(cell.contentView.subviews) for(UIView *view in cell.contentView.subviews) [view removeFromSuperview];
    if(self.newsHelper.newsList && indexPath.item<self.newsHelper.newsList.count){
        NewsModel *newsInfo = self.newsHelper.newsList[indexPath.item];
        if(!newsInfo.identifyCode){
            //广告位
            UIView *view  = [_newsHelper getRenderAdViewAt:indexPath.item];
            view.frame =CGRectMake(view_margin, 0, view.bounds.size.width, view.bounds.size.height);
            view.backgroundColor = dynamic_color_lightwhite;
            view.layer.cornerRadius = 12;
            view.layer.masksToBounds = YES;
            
            UIView *subView = [[UIView alloc] initWithFrame:CGRectMake(view_margin, 0, view.bounds.size.width, view.bounds.size.height)];
            subView.backgroundColor = dynamic_color_lightwhite;
            subView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05].CGColor;
            subView.layer.shadowOffset = CGSizeMake(0,3);
            subView.layer.shadowOpacity = 1;
            subView.layer.shadowRadius = 6;
            subView.layer.shadowRadius = 6;
            subView.layer.cornerRadius = 12;
            if(view){
                [cell.contentView addSubview:subView];
                [cell.contentView addSubview:view];
            }
        }else{
            UIView *view = [self createNewsCell:newsInfo indexPath:indexPath];
            [cell.contentView addSubview:view];
        }
    }
    return cell;
}

-(UIView*) createNewsCell:(NewsModel*)newsInfo indexPath:(NSIndexPath*)indexPath{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(view_margin, 0, SCREEN_WIDTH-view_margin*2, fitFloat(119))];
    view.backgroundColor = dynamic_color_lightwhite;
    view.layer.cornerRadius = 12;
    view.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05].CGColor;
    view.layer.shadowOffset = CGSizeMake(0,3);
    view.layer.shadowOpacity = 1;
    view.layer.shadowRadius = 6;
            
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(view.width-fitFloat(119), 0, fitFloat(119), fitFloat(119))];
    [imgView setImage:[UIImage imageNamed:@"default_news"]];
    imgView.contentMode = UIViewContentModeScaleAspectFill;
    if(newsInfo.innerUrls){
        if(newsInfo.innerUrls.count>3) [imgView yy_setImageWithURL:[NSURL URLWithString:newsInfo.innerUrls[2]] placeholder:nil options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            if(!image) [imgView setImage:[UIImage imageNamed:@"default_news"]];
        }];
        else if(newsInfo.innerUrls.count>1) [imgView yy_setImageWithURL:[NSURL URLWithString:newsInfo.innerUrls[1]] placeholder:nil options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            if(!image) [imgView setImage:[UIImage imageNamed:@"default_news"]];
        }];
        else if(newsInfo.innerUrls.count>0) [imgView yy_setImageWithURL:[NSURL URLWithString:newsInfo.innerUrls[0]] placeholder:nil options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
            if(!image) [imgView setImage:[UIImage imageNamed:@"default_news"]];
        }];
    }
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect: imgView.bounds byRoundingCorners:UIRectCornerTopRight | UIRectCornerBottomRight cornerRadii:CGSizeMake(12,12)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = imgView.bounds;
    maskLayer.path = maskPath.CGPath;
    imgView.layer.mask = maskLayer;
    [view addSubview:imgView];

//        CGSize titleSize = [articleInfo.title sizeWithAttributes:@{NSFontAttributeName:main_font_middle}];
    CGRect rect = [newsInfo.title boundingRectWithSize:CGSizeMake(view.width-imgView.width-view_margin*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:main_font_middle} context:nil];
    CGFloat titleHeight = rect.size.height>fitFloat(46)?fitFloat(46):rect.size.height;
    titleHeight = titleHeight<fitFloat(24)?fitFloat(24):titleHeight;
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(view_margin, 6, view.width-imgView.width-view_margin*2, titleHeight)];
    title.font = main_font_middle;
    title.textColor = dynamic_color_black;
    title.text = newsInfo.title;
    title.numberOfLines = 0;
    [view addSubview:title];
    
    UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(view_margin, 6+title.height, view.width-imgView.width-view_margin*2, view.height-32-6-title.height)];
    content.font = sub_font_middle;
    content.textColor = dynamic_color_gray;
    content.text = newsInfo.summary;
    content.numberOfLines = 0;
    [view addSubview:content];
            
    UILabel *dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(view_margin, view.height-12-14, fitFloat(62), 14)];
    dateLabel.font = sub_font_small;
    dateLabel.textColor = dynamic_color_black;
    dateLabel.text = newsInfo.publishedTime;
    [view addSubview:dateLabel];
            
            
//        NSString *commentedSumStr = [NSString stringWithFormat:@"%ld",newsInfo.commentSum];
//        CGSize commentSize = [commentedSumStr sizeWithAttributes:@{NSFontAttributeName:sub_font_small}];
//        CGFloat commentWidth = commentSize.width<fitFloat(17)?fitFloat(17):commentSize.width;
//        UILabel *commentLabel = [[UILabel alloc] initWithFrame:CGRectMake(view.width-imgView.width-view_margin-commentWidth, view.height-12-fitFloat(14), commentWidth, fitFloat(14))];
//        commentLabel.font = sub_font_small;
//        commentLabel.textColor = main_color_gray;
//        commentLabel.textAlignment = NSTextAlignmentLeft;
//        commentLabel.text = commentedSumStr;
//        [view addSubview:commentLabel];
//
//        UIImageView *commentButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"message_button"]];
//        commentButton.frame = CGRectMake(view.width-imgView.width-view_margin-commentWidth-3-15, view.height-12-15, 15, 15);
//        commentButton.tag = indexPath.item;
//        UITapGestureRecognizer *comment = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(comment:)];
//        commentButton.userInteractionEnabled = YES;
//        [commentButton addGestureRecognizer:comment];
//        [view addSubview:commentButton];
            
//        NSString *likedSumStr = [NSString stringWithFormat:@"%ld",newsInfo.likeSum];
//        CGSize likeSize = [likedSumStr sizeWithAttributes:@{NSFontAttributeName:sub_font_small}];
//        CGFloat likeWidth = likeSize.width<fitFloat(33)?fitFloat(33):likeSize.width;
//        UILabel *likesSum = [[UILabel alloc] initWithFrame:CGRectMake(view.width-imgView.width-view_margin-commentWidth-3-15-4-likeWidth, view.height-12-fitFloat(14), likeWidth, fitFloat(14))];
//        likesSum.font = sub_font_small;
//        likesSum.textColor = main_color_gray;
//        likesSum.textAlignment = NSTextAlignmentLeft;
//        likesSum.text = likedSumStr;
//        [view addSubview:likesSum];
//
//        if(newsInfo.liked){
//            UIImageView *likedButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"liked_icon"]];
//            likedButton.frame = CGRectMake(view.width-imgView.width-view_margin-commentWidth-3-15-4-likeWidth-3-15, view.height-27, 15, 15);
//            likedButton.tag = indexPath.item;
//            UITapGestureRecognizer *unlike = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doUnlikes:)];
//            likedButton.userInteractionEnabled = YES;
//            [likedButton addGestureRecognizer:unlike];
//            [view addSubview:likedButton];
//        }else{
//            UIImageView *waitLikeButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"like_icon"]];
//            waitLikeButton.frame = CGRectMake(view.width-imgView.width-view_margin-commentWidth-3-15-4-likeWidth-3-15, view.height-27, 15, 15);
//            waitLikeButton.tag = indexPath.item;
//            UITapGestureRecognizer *like = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doLikes:)];
//            waitLikeButton.userInteractionEnabled = YES;
//            [waitLikeButton addGestureRecognizer:like];
//            [view addSubview:waitLikeButton];
//        }
            
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showNewsDetail:)];
    [view addGestureRecognizer:tap];
    view.userInteractionEnabled = YES;
    view.tag = indexPath.item;
    return view;
}

-(void) showNewsDetail:(UITapGestureRecognizer*)tap{
    if(tap.view.tag < _newsHelper.newsList.count){
        NewsModel *newsInfo = _newsHelper.newsList[tap.view.tag];
        if(self.showNewsDetail) self.showNewsDetail(newsInfo);
    }
}

//返回collection的section数量
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //如果photo数量为0则不显示底部刷新条
    return _newsHelper.newsList.count;
}

// 设置UIcollectionView整体的内边距（这样item不贴边显示）
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // 上 左 下 右
    return UIEdgeInsetsMake(6,0,6,0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 16;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 6;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.item>=_newsHelper.newsList.count) return CGSizeZero;
    NewsModel *newsModel = _newsHelper.newsList[indexPath.item];
    if(!newsModel.identifyCode)
        return CGSizeMake(SCREEN_WIDTH, (SCREEN_WIDTH-view_margin*2)/375*87);
    else return CGSizeMake(SCREEN_WIDTH, fitFloat(119));
}



- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd*)nativeExpressAd views:(NSArray<__kindof GDTNativeExpressAdView *> *)views{
   if (views.count) {
       [views enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
           GDTNativeExpressAdView *expressView = (GDTNativeExpressAdView *)obj;
           expressView.controller = [BaseUtils viewController:self];
           [expressView render];
       }];
       [_newsHelper addRenderAdViewArray:views];
       // 广告位 render 后刷新 tableView
       [self reloadData];
   }
}
-(void)nativeExpressAdViewClosed:(GDTNativeExpressAdView *)nativeExpressAdView{
    [_newsHelper removeRenderAdView:nativeExpressAdView];
    [self reloadData];
}

#pragma mark --MJRefresh
//设置页头页尾和更新数据的方法
- (void)setupRefresh{
//    self.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNews)];
    MJChiBaoZiHeader *header = [MJChiBaoZiHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNews)];
    self.mj_header = header;
    header.lastUpdatedTimeLabel.hidden = YES;
    header.stateLabel.hidden = YES;
    self.mj_header.backgroundColor = [UIColor clearColor];
    self.mj_footer.hidden = NO;
    
    self.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(moreNews)];
    self.mj_footer.backgroundColor = [UIColor clearColor];
    self.mj_footer.hidden = YES;
}

-(void)showNoDataView:(NSString*)title type:(int)type{
    if(_noDataView){
        [_noDataView removeFromSuperview];
        _noDataView = nil;
    }
    _noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    
    NSString *iconName = @"no_network";
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

- (void)loadNewsCollection:(BOOL)mjRefresh{
    if(mjRefresh) [self.mj_header beginRefreshing];
    else [self loadNews];
}

- (void)loadNews{
    __weak typeof(self) wkSelf = self;
    [_newsHelper loadNews:^(NSInteger count) {
        if(wkSelf.newsHelper.curPageAdCount>0) [wkSelf.nativeExpressAd loadAd:wkSelf.newsHelper.curPageAdCount];
        [wkSelf reloadData];
        [wkSelf.mj_header endRefreshing];
        if(count>8) wkSelf.mj_footer.hidden = NO;
        if(count<=0) [wkSelf showNoDataView:@"没有检索到内容! 看来您驶向了无人区" type:0];
        else [wkSelf removeNoDataView];
    } failure:^(NSString *errorInfo) {
        [wkSelf.mj_header endRefreshing];
        [wkSelf showNoDataView:@"网络出错! 看来您驶向了无人区" type:0];
    }];
}

-(void)moreNews{
    __weak typeof(self) wkSelf = self;
    [_newsHelper moreNews:^(NSInteger count) {
        if(wkSelf.newsHelper.curPageAdCount>0) [wkSelf.nativeExpressAd loadAd:wkSelf.newsHelper.curPageAdCount];
        [wkSelf reloadData];
        if(count>0) {
            [wkSelf.mj_footer endRefreshing];
            [wkSelf removeNoDataView];
        }else {
            [wkSelf.mj_footer endRefreshingWithNoMoreData];
            [wkSelf performSelector:@selector(endRefreshing) withObject:nil afterDelay:2.f];
        }
    } failure:^(NSString *errorInfo) {
        [wkSelf.mj_footer endRefreshing];
    }];
}
-(void)endRefreshing{
    [self.mj_footer setHidden:YES];
}

-(void)comment:(UITapGestureRecognizer*)tap{
    
}
-(void)doUnlikes:(UITapGestureRecognizer*)tap{
    
}
-(void)doLikes:(UITapGestureRecognizer*)tap{
    
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    __weak typeof(self) wkSelf = self;
    // trait发生了改变
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            MJChiBaoZiHeader *header = [MJChiBaoZiHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNews)];
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
