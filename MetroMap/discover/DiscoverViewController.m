//
//  DiscoverViewController.m
//  MetroMap
//
//  Created by edwin on 2019/10/8.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "DiscoverViewController.h"
#import "SegmentWithTabView.h"
#import "TabTitleView.h"

@interface DiscoverViewController ()<UITextFieldDelegate>

//@property(nonatomic, retain) ArticleCollectionView *discoverView;
//@property(nonatomic, retain) ArticleCollectionView *newsView;
//@property(nonatomic, retain) ArticleCollectionView *metroCultureView;

@property(nonatomic, retain) ArticleCollectionView *newsSearchView;

@property(nonatomic, retain) NSMutableArray<NewsTypeModel*> *newsTypeArray;
@property(nonatomic, retain) NSMutableArray *articleList;
@property(nonatomic, retain) NSMutableArray<NSString*> *typeTitleList;

@property (nonatomic, retain) SegmentWithTabView *segmentWithTabView;
@property(nonatomic, retain) TabTitleView *tabTitleView;
@property(nonatomic, assign) CGRect searchBarInitRect;
@property(nonatomic, assign) CGRect searchBarSearchingRect;

@property(nonatomic, assign) NSInteger pageLoaded;
@property (nonatomic, retain) NSString *newsCityName;
@property (nonatomic, retain) UIView *noDataView;
@property (nonatomic, assign) BOOL newsTypeLoading;

@end

@implementation DiscoverViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.naviMask];
    [self.searchBar setX:view_margin];
    [self.view addSubview:self.searchBar];
    self.searchBar.delegate = self;
    
    [self.view setBackgroundColor:dynamic_color_white];
//    [self.naviMask addSubview:self.menuButton];
    
    _searchBarInitRect = self.searchBar.frame;
    _searchBarSearchingRect = CGRectMake(view_margin+28, self.searchBar.y, SCREEN_WIDTH-view_margin*2-28, self.searchBar.height);
    
    [self loadTypes];
}

-(void)viewWillAppear:(BOOL)animated{
    if(self.newsSearchView){
        [self.tabBarController.tabBar setHidden:YES];
    }
    NSString *newsCityName = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_CITY_NAME_KEY];
    if(newsCityName && _newsCityName && [newsCityName isEqualToString:_newsCityName]){
        return;
    }else{
        _newsCityName = newsCityName;
        [self loadTypes];
    }
    
}

-(void)loadNewsCollection{
    __weak typeof(self) wkSelf = self;
    CGFloat height = SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT-[self mTabbarHeight];
    //tab页面
    _segmentWithTabView = [[SegmentWithTabView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT, SCREEN_WIDTH, height)];
    [_segmentWithTabView setMoveTabToIndex:^(NSInteger toIndex, NSInteger fromIndex) {
        if(wkSelf.tabTitleView) [wkSelf.tabTitleView selected:toIndex from:fromIndex];
        if((wkSelf.pageLoaded&(NSInteger)pow(2, toIndex)) == 0){
            [wkSelf.articleList[toIndex] loadNewsCollection:YES];
            wkSelf.pageLoaded = wkSelf.pageLoaded + pow(2, toIndex);
        }
    }];
    
    _articleList = [NSMutableArray new];
    for(NewsTypeModel *newsType in _newsTypeArray){
        NSMutableDictionary *params = [NSMutableDictionary new];
        NSString *cityId = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_CITY_ID_KEY];
        if(!cityId) cityId = @"1";
        [params setObject:cityId forKey:@"cityId"];
        [params setObject:[NSString stringWithFormat:@"%ld", (long)newsType.identifyCode] forKey:@"typeId"];
        [params setObject:@(15) forKey:@"pageSize"];
        ArticleCollectionView *collectionView = [[ArticleCollectionView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, height)];
        NewsHelper *newsHelper = [NewsHelper new];
        newsHelper.uri = request_news_search_list;
        newsHelper.parameters = params;
        collectionView.newsHelper = newsHelper;
        [_articleList addObject:collectionView];
        [collectionView setShowNewsDetail:^(NewsModel *newsInfo) {
            NewsDetailViewController *detailVC = [[NewsDetailViewController alloc] init];
            [detailVC loadNewsInfo:newsInfo];
            detailVC.hidesBottomBarWhenPushed = YES;
            [wkSelf.navigationController pushViewController:detailVC animated:YES];
        }];
    }
    [_segmentWithTabView setSubViewArray:_articleList];
    [self.view addSubview:_segmentWithTabView];
    if(_articleList.count>0) {
        [_articleList[0] loadNewsCollection:NO];
        if((wkSelf.pageLoaded&(NSInteger)pow(2, 0)) == 0){
            _pageLoaded = _pageLoaded + pow(2, 0);
        }
    }
    
    //tab标签
    _tabTitleView = [[TabTitleView alloc] initWithFrame:CGRectMake(self.searchBar.width+view_margin, STATUS_BAR_HEIGHT, SCREEN_WIDTH-24-self.searchBar.width-view_margin*2, 40) titles:_typeTitleList type:SegmentTabTypeByTitleLength];
    [_tabTitleView setScrollToIndex:^(NSInteger toIndex) {
        if(wkSelf.segmentWithTabView) [wkSelf.segmentWithTabView scrollToIndex:toIndex];
    }];
    [self.naviMask addSubview:_tabTitleView];
}


-(void)showNoDataView:(NSString*)title type:(int)type{
    if(_noDataView){
        [_noDataView removeFromSuperview];
        _noDataView = nil;
    }
    _noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.width, self.view.height)];
    
    NSString *iconName = @"no_network";
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:iconName]];
    icon.frame = CGRectMake((self.view.width-88)/2, (self.view.height-88-17)/2, 88, 88);
    [_noDataView addSubview:icon];
    icon.contentMode = UIViewContentModeScaleAspectFit;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadTypes)];
    icon.userInteractionEnabled = YES;
    [icon addGestureRecognizer:tap];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, (self.view.height-88-17)/2+88, self.view.width, 17)];
    label.font = sub_font_small;
    label.textColor = dynamic_color_gray;
    label.text = title;
    label.textAlignment = NSTextAlignmentCenter;
    [_noDataView addSubview:label];
    [self.view addSubview:_noDataView];
}

-(void)removeNoDataView{
    if(_noDataView){
        [_noDataView removeFromSuperview];
        _noDataView = nil;
    }
}


-(void)loadTypes{
    if(_newsTypeLoading) return;
    else _newsTypeLoading = YES;
    [self removeNoDataView];
    MBProgressHUD *hud = [MBProgressHUD showWaitingWithText:@"正在加载" image:nil inView:nil];
    __weak typeof(self) wkSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSString *cityId = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_CITY_ID_KEY];
    if(!cityId) cityId = @"1";
    [params setObject:cityId forKey:@"cityId"];
    
    [[HttpHelper new] findList:request_news_type_list params:params page:0 progress:nil success:^(NSMutableDictionary *responseDic) {
        NSMutableArray *newsTypeArray = (NSMutableArray *)[responseDic mutableArrayValueForKey:@"list"];
        if(!newsTypeArray) return;
        wkSelf.newsTypeArray = [NSMutableArray new];
        wkSelf.typeTitleList = [NSMutableArray new];
        if(newsTypeArray && newsTypeArray.count>0) {
            for(int i=0; i<newsTypeArray.count; i++){
                NewsTypeModel *newsType = [NewsTypeModel yy_modelWithJSON:newsTypeArray[i]];
                [wkSelf.newsTypeArray addObject:newsType];
                [wkSelf.typeTitleList addObject:newsType.name];
            }
            [wkSelf removeNoDataView];
        } else {
            [wkSelf showNoDataView:@"网络出错! 看来您驶向了无人区" type:1];
        }
        [wkSelf loadNewsCollection];
        wkSelf.newsTypeLoading = NO;
        [hud hideAnimated:YES];
    } failure:^(NSString *errorInfo) {
        [wkSelf showNoDataView:@"网络出错! 看来您驶向了无人区" type:1];
        wkSelf.newsTypeLoading = NO;
        [hud hideAnimated:YES];
    }];
}

// 获得焦点
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(_newsSearchView) return YES;
    
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSString *cityId = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_CITY_ID_KEY];
    if(!cityId) cityId = @"1";
    [params setObject:cityId forKey:@"cityId"];
    [params setObject:@"新闻" forKey:@"keywords"];
    [params setObject:@(15) forKey:@"pageSize"];
    NewsHelper *newsHelper = [NewsHelper new];
    newsHelper.uri = request_news_search_list;
    newsHelper.parameters = params;
    
    _newsSearchView= [[ArticleCollectionView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT)];
    _newsSearchView.newsHelper = newsHelper;
    __weak typeof(self) wkSelf = self;
    [_newsSearchView setShowNewsDetail:^(NewsModel *newsInfo) {
        NewsDetailViewController *detailVC = [[NewsDetailViewController alloc] init];
        [detailVC loadNewsInfo:newsInfo];
        detailVC.hidesBottomBarWhenPushed = YES;
        [wkSelf.navigationController pushViewController:detailVC animated:YES];
    }];
    
    _newsSearchView.alpha = 0;
    [self.view addSubview:_newsSearchView];
    self.backButton.alpha = 0;
    [self.view addSubview:self.backButton];
    [self.tabBarController.tabBar setHidden:YES];
    [self.view bringSubviewToFront:self.searchBar];
    
    [UIView animateWithDuration:.5f animations:^{
        self.searchBar.frame = self.searchBarSearchingRect;
        self.newsSearchView.alpha = 1;
        self.backButton.alpha = 1;
        if(self.tabTitleView) self.tabTitleView.alpha = 0;
    } completion:^(BOOL finished) {
//        NSString *text = @"搜索";
//        NSMutableAttributedString *fieldText = [[NSMutableAttributedString alloc] initWithString:text];
//        [fieldText addAttribute:NSFontAttributeName value:sub_font_middle range:NSMakeRange(0, text.length)];
//        [fieldText addAttribute:NSForegroundColorAttributeName value:main_color_gray range:NSMakeRange(0, text.length)];
//        [self.searchBar setAttributedPlaceholder:fieldText];
    }];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField endEditing:YES];
    if(textField == self.searchBar){
        if(textField.text.length<1){
            [MBProgressHUD showInfo:@"未输入内容" detail:nil image:nil inView:nil];
            return NO;
        }else{
            if(self.newsSearchView && self.newsSearchView.newsHelper){
                NSMutableDictionary *params = self.newsSearchView.newsHelper.parameters;
                [params setObject:textField.text forKey:@"keywords"];
                [self.newsSearchView loadNewsCollection:YES];
            }
            return YES;
        }
    }
    return YES;
}

- (void)naviBack:(UITapGestureRecognizer*)tap {
    if(_newsSearchView){
        [self.tabBarController.tabBar setHidden:NO];
        self.searchBar.text = @"";
        [self.searchBar endEditing:YES];
        [UIView animateWithDuration:.5f animations:^{
            self.searchBar.frame = self.searchBarInitRect;
            self.newsSearchView.alpha = 0;
            self.backButton.alpha = 0;
            if(self.tabTitleView) self.tabTitleView.alpha = 1;
        } completion:^(BOOL finished) {
            [self.newsSearchView removeFromSuperview];
            self.newsSearchView = nil;
            [self.backButton removeFromSuperview];
        }];
    }else{
        [super naviBack:tap];
    }
}
@end
