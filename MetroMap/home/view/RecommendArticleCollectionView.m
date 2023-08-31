//
//  HotCityListView.m
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "RecommendArticleCollectionView.h"

@interface RecommendArticleCollectionView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, retain) UICollectionViewFlowLayout *fallLayout;
@property (nonatomic, retain) NSMutableArray *dataNewsList;
@property (nonatomic, retain) NSString *newsCityName;

@end

static NSString * const recommend_article_collection_id = @"recommend_article_collection";
@implementation RecommendArticleCollectionView


-(instancetype)initWithFrame:(CGRect)frame{
    // 创建布局
    _fallLayout = [[UICollectionViewFlowLayout alloc]init];
    _fallLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self = [super initWithFrame:frame collectionViewLayout:_fallLayout];
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:recommend_article_collection_id];
    self.dataSource = self;
    self.delegate = self;
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.scrollEnabled = NO;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    self.backgroundColor = dynamic_color_white;
    //加载图片
    [self loadRecommendNews];
    return self;
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //根据注册标记查找cell
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:recommend_article_collection_id forIndexPath:indexPath];
    if(cell.contentView.subviews) for(UIView *view in cell.contentView.subviews) [view removeFromSuperview];
    if(self.dataNewsList && indexPath.item<self.dataNewsList.count){
        NewsModel *newsInfo = self.dataNewsList[indexPath.item];
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
        
        
//        NSString *commentedSumStr = [NSString stringWithFormat:@"%ld",(long)newsInfo.commentSum];
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
//
//        NSString *likedSumStr = [NSString stringWithFormat:@"%ld",(long)newsInfo.likeSum];
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
        [cell.contentView addSubview:view];
    }
    
    return cell;
}

-(void) showNewsDetail:(UITapGestureRecognizer*)tap{
    if(tap.view.tag < _dataNewsList.count){
        NewsModel *newsInfo = _dataNewsList[tap.view.tag];
        if(self.showNewsDetail) self.showNewsDetail(newsInfo);
    }
}

//返回collection的section数量
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //如果photo数量为0则不显示底部刷新条
    if(_dataNewsList.count<4) {
        self.frame = CGRectMake(self.origin.x, self.origin.y, self.size.width, fitFloat(129)*_dataNewsList.count + view_margin);
    }else{
        self.frame = CGRectMake(self.origin.x, self.origin.y, self.size.width, fitFloat(129)*4 + view_margin);
    }
    return _dataNewsList.count;
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
    return CGSizeMake(SCREEN_WIDTH, fitFloat(119));
}

//刷新图片
- (void)loadRecommendNews{
    __weak typeof(self) wkSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSString *cityId = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_CITY_ID_KEY];
    NSString *newsCityName = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_CITY_NAME_KEY];
    if(newsCityName && _newsCityName && [newsCityName isEqualToString:_newsCityName]){
        return;
    }else{
        _newsCityName = newsCityName;
    }
    
    if(!cityId) cityId = @"1";
    [params setObject:cityId forKey:@"cityId"];
    [[HttpHelper new] findList:request_news_recommend_list params:params page:0 progress:nil success:^(NSMutableDictionary *responseDic) {
        NSMutableArray *newsArray = (NSMutableArray *)[responseDic mutableArrayValueForKey:@"list"];
        if(newsArray && newsArray.count>0) {
            if(!wkSelf.dataNewsList) wkSelf.dataNewsList = [NSMutableArray new];
            for(NSDictionary *dict in newsArray){
                NewsModel *news = [NewsModel yy_modelWithJSON:dict];
                [wkSelf.dataNewsList addObject:news];
                if(wkSelf.dataNewsList.count>=4) break;
            }
            [wkSelf reloadData];
        }
    } failure:^(NSString *errorInfo) {
    }];
}

-(void)comment:(UITapGestureRecognizer*)tap{
    
}
-(void)doUnlikes:(UITapGestureRecognizer*)tap{
    
}
-(void)doLikes:(UITapGestureRecognizer*)tap{
    
}
@end
