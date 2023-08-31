//
//  CityCollectionView.m
//  MetroMap
//
//  Created by edwin on 2019/10/8.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "CityCollectionView.h"
#import "DSCollectionViewIndex.h"

@interface CityCollectionView()<UICollectionViewDelegate, UICollectionViewDataSource, DSCollectionViewIndexDelegate>


@property (nonatomic, retain) UICollectionViewFlowLayout *fallLayout;

@property (nonatomic, retain) CityModel *currentCity;
@property (nonatomic, retain) NSString *currentCityName;
@property (nonatomic, retain) NSMutableArray *dataHotCityList;
@property (nonatomic, retain) NSMutableArray<NSArray*> *dataCityArrayList;
@property (nonatomic, retain) NSMutableArray *dataCityList;
@property (nonatomic, retain) NSMutableArray *dataFirstLetters;

@property (nonatomic, retain) NSMutableDictionary *localCityDict;
//@property (nonatomic, retain) NSMutableArray<NSArray*> *localCityArrayList;
//@property (nonatomic, retain) NSMutableArray *localFirstLetters;


@property (nonatomic, retain) DSCollectionViewIndex *collectionViewIndex;   //右边索引条
@property (nonatomic, retain) UILabel  *flotageLabel;     //中间显示的背景框
@property (nonatomic, retain) UIView *flotageView;    //选中字母改变背景


@property (nonatomic, retain) MetroMapHelper *metroMapHelper;

@property(nonatomic, retain) NSMutableArray *layers;

@end

static NSString * const city_collection_id = @"city_collection";
static NSString * const city_collection_header_id = @"city_collection_header";
@implementation CityCollectionView


-(instancetype)initWithFrame:(CGRect)frame{
    // 创建布局
    _fallLayout = [[UICollectionViewFlowLayout alloc]init];
    _fallLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _fallLayout.sectionHeadersPinToVisibleBounds = YES;
    self = [super initWithFrame:frame collectionViewLayout:_fallLayout];
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:city_collection_id];
    [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:city_collection_header_id];
    self.dataSource = self;
    self.delegate = self;
    self.showsVerticalScrollIndicator = YES;
    self.showsHorizontalScrollIndicator = NO;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    self.backgroundColor = dynamic_color_white;
    _metroMapHelper = [MetroMapHelper new];
    //请求网络城市列表
//    [self loadRemoteCityList];
    return self;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:city_collection_header_id forIndexPath:indexPath];

    if(reusableView.subviews) for(UIView *sview in reusableView.subviews) [sview removeFromSuperview];
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(view_margin, 12, SCREEN_WIDTH-view_margin*2-20, 25)];
        label.font = main_font_big;
        label.textColor = dynamic_color_black;
        [reusableView addSubview:label];
        if(indexPath.section==0 && !_withoutHeader) label.text = @"当前城市";
        else if(indexPath.section==1 && !_withoutHeader && _dataHotCityList && _dataHotCityList.count>0) label.text = @"热门城市";
        else{
            NSInteger indexOffset = (_dataHotCityList && _dataHotCityList.count>0)?2:1;
            if(_withoutHeader) indexOffset = 0;
            if(indexPath.section>=indexOffset && indexPath.section<_dataFirstLetters.count+indexOffset){
                label.height = 20;
                label.font = main_font_middle;
                label.text = _dataFirstLetters[indexPath.section-indexOffset];
            }
        }
        reusableView.backgroundColor = dynamic_color_white;
    }
    //如果是头视图
    return reusableView;
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //根据注册标记查找cell
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:city_collection_id forIndexPath:indexPath];
    if(cell.contentView.subviews) for(UIView *view in cell.contentView.subviews) [view removeFromSuperview];
    if(indexPath.section==0 && !_withoutHeader){
        UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"locationed"]];
        icon.frame = CGRectMake(0, 0, 15, 15);
        [self loadCurrentCity];
        NSString *cityName = _currentCity?_currentCity.nameCn:_currentCityName;
        [self createHotCity:cityName?cityName:@"点击定位" city:_currentCity icon:icon cell:cell index:indexPath];
        cell.contentView.backgroundColor = dynamic_color_lightwhite;
    }else if(indexPath.section==1 && !_withoutHeader && indexPath.item<_dataHotCityList.count){
        CityModel *cityInfo = _dataHotCityList[indexPath.item];
        [self createHotCity:cityInfo.nameCn city:cityInfo icon:nil cell:cell index:indexPath];
        cell.contentView.backgroundColor = dynamic_color_lightwhite;
    }else{
        NSArray *array = nil;
        if(!_withoutHeader && _dataHotCityList && _dataHotCityList.count>0) array = _dataCityArrayList[indexPath.section-2];
        else if(!_withoutHeader) array = _dataCityArrayList[indexPath.section-1];
        else array = _dataCityArrayList[indexPath.section];
        if(array.count>indexPath.item){
            CityModel *cityInfo = array[indexPath.item];
            [self createCityCell:cityInfo cell:cell index:indexPath];
        }
        cell.contentView.backgroundColor = [UIColor clearColor];
    }
    return cell;
}

-(void)createHotCity:(NSString*)titleName city:(CityModel*)city icon:(UIImageView*)icon cell:(UICollectionViewCell*)cell index:(NSIndexPath*)indexPath{
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, (cell.height-20)/2, cell.width, 20)];
    title.font = main_font_small;
    title.textColor = dynamic_color_black;
    
    if(!icon){
        title.textAlignment = NSTextAlignmentCenter;
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",titleName] attributes:@{NSKernAttributeName:@12.f}];
        if(titleName.length>2){
            attributedString = [[NSMutableAttributedString alloc] initWithString:titleName];
        }
        [title setAttributedText:attributedString];
        [cell.contentView addSubview:title];
    }else{
        CGSize titleSize = [titleName sizeWithAttributes:@{NSFontAttributeName:title.font}];
        NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:titleName];
        CGFloat width = ceil(titleSize.width) + icon.width + 4;
        icon.frame = CGRectMake((cell.width-width)/2, (cell.height-icon.height)/2, icon.width, icon.height);
        title.frame = CGRectMake((cell.width-width)/2 + icon.width + 4, (cell.height-20)/2, cell.width, 20);
        [title setAttributedText:attributedString];
        [cell.contentView addSubview:icon];
        [cell.contentView addSubview:title];
    }
    
    cell.contentView.layer.cornerRadius = 6;
    cell.contentView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05].CGColor;
    cell.contentView.layer.shadowOffset = CGSizeMake(0,3);
    cell.contentView.layer.shadowOpacity = 1;
    cell.contentView.layer.shadowRadius = 6;
    
    if(city){
        if(indexPath.section==0){
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadCurrentCityMap)];
            title.userInteractionEnabled = YES;
            [title addGestureRecognizer:tap];
        }else{
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadHotCityMap:)];
            title.userInteractionEnabled = YES;
            title.tag = indexPath.item;
            [title addGestureRecognizer:tap];
        }
    }else if([@"点击定位" isEqualToString:titleName]){
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updateLocation)];
        title.userInteractionEnabled = YES;
        [title addGestureRecognizer:tap];
    }else{
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadMapWithoutData)];
        title.userInteractionEnabled = YES;
        [title addGestureRecognizer:tap];
    }
}

-(void)createCityCell:(CityModel*)cityInfo cell:(UICollectionViewCell*)cell index:(NSIndexPath*)indexPath{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(view_margin, 0, SCREEN_WIDTH-view_margin, 52)];
    UILabel *titleName = [[UILabel alloc] init];
    CGSize titleSize = [cityInfo.nameCn sizeWithAttributes:@{NSFontAttributeName:main_font_small, NSKernAttributeName:@8.f}];
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:cityInfo.nameCn attributes:@{NSKernAttributeName:@8.f}];
    if(cityInfo.nameCn.length>2){
        titleSize = [cityInfo.nameCn sizeWithAttributes:@{NSFontAttributeName:main_font_small}];
        attributedString = [[NSMutableAttributedString alloc] initWithString:cityInfo.nameCn];
    }
    titleName.frame = CGRectMake(0, 16, titleSize.width, 20);
    titleName.font = main_font_small;
    titleName.textColor = dynamic_color_black;
    titleName.attributedText = attributedString;
    [view addSubview:titleName];
    
    UILabel *updateName = [[UILabel alloc] initWithFrame:CGRectMake(titleName.width+12, 16, fitFloat(80), 20)];
    updateName.font = main_font_small;
    updateName.textColor = main_color_pink;
    updateName.text = @"下载离线";
    updateName.textAlignment = NSTextAlignmentLeft;
    BOOL downloadMap = YES;
    if(_localCityDict && _localCityDict[[NSString stringWithFormat:@"%ld",(long)cityInfo.identifyCode]]){
        CityModel *localCity = _localCityDict[[NSString stringWithFormat:@"%ld",(long)cityInfo.identifyCode]];
        if(localCity.version >= cityInfo.version) {
            updateName.text = @"";
            downloadMap = NO;
        }
        else if(localCity.version < cityInfo.version) {
            updateName.text = @"可更新";
            updateName.textColor = main_color_blue;
        }
    }
    [view addSubview:updateName];
    
    UILabel *updateTime = [[UILabel alloc] initWithFrame:CGRectMake(view.width-view_margin-32-80, 12, 80, 14)];
    updateTime.font = sub_font_small;
    updateTime.textColor = dynamic_color_black;
    updateTime.text = cityInfo.updateTime;
    updateTime.textAlignment = NSTextAlignmentRight;
    [view addSubview:updateTime];
    
    UILabel *contentSize = [[UILabel alloc] initWithFrame:CGRectMake(view.width-view_margin-32-80, view.height-27, 80, 15)];
    contentSize.font = [UIFont fontWithName:@"DIN-Bold" size:12];
    contentSize.textColor = dynamic_color_gray;
    if(cityInfo.contentSize/1024/1024>1) contentSize.text = [NSString stringWithFormat:@"%.2f M",cityInfo.contentSize/1024/1024];
    else contentSize.text = [NSString stringWithFormat:@"%.2f KB",cityInfo.contentSize/1024];
    contentSize.textAlignment = NSTextAlignmentRight;
    [view addSubview:contentSize];
    [cell.contentView addSubview:view];
    
    CALayer *viewBorder = [CALayer layer];
    viewBorder.frame = CGRectMake(0, view.height, view.width, 1);
    viewBorder.backgroundColor = dynamic_color_lightgray.CGColor;
    viewBorder.opacity = 0.5;
    [view.layer addSublayer:viewBorder];
    if(!_layers) _layers = [NSMutableArray new];
    [_layers addObject:viewBorder];
    
    cell.contentView.layer.cornerRadius = 0;
    cell.contentView.layer.shadowOpacity = 0;
    cell.contentView.layer.shadowRadius = 0;
    
    if(downloadMap){
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(downloadMap:)];
        NSInteger index = [_dataCityList indexOfObject:cityInfo];
        view.tag = index;
        view.userInteractionEnabled = YES;
        [view addGestureRecognizer:tap];
    }else{
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadMap:)];
        NSInteger index = [_dataCityList indexOfObject:cityInfo];
        view.tag = index;
        view.userInteractionEnabled = YES;
        [view addGestureRecognizer:tap];
    }
}

//返回collection的section数量
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if(_dataHotCityList && _dataHotCityList.count>0 && !_withoutHeader) return 2+_dataCityArrayList.count;
    else if(!_withoutHeader) return 1+_dataCityArrayList.count;
    else return _dataCityArrayList.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(section==0 && !_withoutHeader) return 1;
    else if(section==1 && !_withoutHeader && _dataHotCityList && _dataHotCityList.count>0) return _dataHotCityList.count;
    else if(_dataHotCityList && _dataHotCityList.count>0) return _dataCityArrayList[section-2].count;
    else if(!_withoutHeader) return _dataCityArrayList[section-1].count;
    else return _dataCityArrayList[section].count;
}

// 设置UIcollectionView整体的内边距（这样item不贴边显示）
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // 上 左 下 右
    return UIEdgeInsetsMake(6,view_margin,6,view_margin);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if(section==0 && !_withoutHeader) return CGSizeMake(SCREEN_WIDTH, 40);
    else if(section==1 && !_withoutHeader && _dataHotCityList && _dataHotCityList.count>0) return CGSizeMake(SCREEN_WIDTH-1, 40);
    else return CGSizeMake(SCREEN_WIDTH, 35);
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    NSInteger indexOffset = (_dataHotCityList && _dataHotCityList.count>0)?2:1;
    if(_withoutHeader) indexOffset = 0;
    if(section==_dataCityArrayList.count+indexOffset-1) return CGSizeMake(SCREEN_WIDTH-1, SAFE_AREA_INSERTS_BOTTOM);
    else return CGSizeZero;
}

//section盖住滚动条解决
- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    view.layer.zPosition = 0.0;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0 && !_withoutHeader) return CGSizeMake((SCREEN_WIDTH-view_margin*2-12)/3, 44);
    else if(indexPath.section==1 && !_withoutHeader && _dataHotCityList && _dataHotCityList.count>0) return CGSizeMake((SCREEN_WIDTH-view_margin*2-12)/3, 44);
    else return CGSizeMake(SCREEN_WIDTH-view_margin*2, 53);
}

-(void)downloadMap:(UITapGestureRecognizer*)tap{
    if(tap.view.tag<_dataCityList.count){
        MBProgressHUD *hud = [MBProgressHUD showWaitingWithText:@"正在加载" image:nil inView:nil];
        __weak typeof(self) wkSelf = self;
        CityModel *city = _dataCityList[tap.view.tag];
        [CityZipUtils downloadZip:[NSString stringWithFormat:@"%@%@/%ld",Base_URL,request_data_download,(long)city.identifyCode] city:city success:^{
            wkSelf.localCityDict = [CityZipUtils readCityLatestVersionWithCityId];
            if ([NSThread isMainThread]) {
                [wkSelf reloadData];
                [hud hideAnimated:YES];
            } else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [wkSelf reloadData];
                    [hud hideAnimated:YES];
                });
            }
        }];
    }
}

-(void)loadMap:(UITapGestureRecognizer*)tap{
    if(tap.view.tag<_dataCityList.count){
//        MBProgressHUD *hud = [MBProgressHUD showWaitingWithText:@"正在加载" image:nil inView:nil];
//        CityModel *selectedCity = _dataCityList[tap.view.tag];
//        NSInteger cityId =selectedCity.identifyCode;
//        CityModel *city = [CityZipUtils parseFileToCityModel:cityId];
//        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",(long)city.identifyCode] forKey:SELECTED_CITY_ID_KEY];
//        [[NSUserDefaults standardUserDefaults] setObject:city.nameCn forKey:SELECTED_CITY_NAME_KEY];
//        if(self.reloadCityData) self.reloadCityData();
//        [hud hideAnimated:YES];
        CityModel *selectedCity = _dataCityList[tap.view.tag];
        __weak typeof(self) wkSelf = self;
        [_metroMapHelper loadMetroMap:selectedCity success:^{
            if(wkSelf.reloadCityData) wkSelf.reloadCityData();
        }];
    }
}

-(void)loadCurrentCity{
    _currentCityName = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_CITY_NAME_KEY];
    NSString *cityId = [[NSUserDefaults standardUserDefaults] objectForKey:CURRENT_CITY_ID_KEY];
    if(cityId) {
        for(CityModel *city in _dataCityList){
            if(city.identifyCode == [cityId integerValue]){
                _currentCity = city;
                return;
            }
        }
    }
}


-(void)updateLocation{
    __weak typeof(self) wkSelf = self;
    [_metroMapHelper updateLocation:^{
        if(wkSelf.reloadCityData) wkSelf.reloadCityData();
    } loadData:YES showAlert:YES forceAlert:YES];
}
-(void)loadMapWithoutData{
    //没有匹配到城市时弹出提示
    [_metroMapHelper loadMapWithoutData];
}
-(void)loadHotCityMap:(UITapGestureRecognizer*)tap{
    if(_dataHotCityList && tap.view.tag<_dataHotCityList.count){
        CityModel *city = _dataHotCityList[tap.view.tag];
        __weak typeof(self) wkSelf = self;
        [_metroMapHelper loadMetroMap:city success:^{
            if(wkSelf.reloadCityData) wkSelf.reloadCityData();
        }];
    }
}
-(void)loadCurrentCityMap{
    CityModel *city = _currentCity;
    __weak typeof(self) wkSelf = self;
    [_metroMapHelper loadMetroMap:city success:^{
        if(wkSelf.reloadCityData) wkSelf.reloadCityData();
    }];
}


//远程获取城市列表
- (void)loadRemoteCityList{
    MBProgressHUD *hud = [MBProgressHUD showWaitingWithText:@"正在加载" image:nil inView:nil];
    __weak typeof(self) wkSelf = self;
    if(_onlyLocal){
        [self loadLocalCityList];
        [hud hideAnimated:YES];
        return;
    }
    [[HttpHelper new] findList:request_city_list params:nil page:0 progress:nil success:^(NSMutableDictionary *responseDic) {
        NSMutableArray *cityArray = (NSMutableArray *)[responseDic mutableArrayValueForKey:@"list"];
        if(cityArray) {
            //城市列表
            [wkSelf sortByGroupCityArray:cityArray];
        }
        [wkSelf loadLocalCityList];
        [hud hideAnimated:YES];
    } failure:^(NSString *errorInfo) {
        [wkSelf loadLocalCityList];
        [hud hideAnimated:YES];
    }];
}
//获取本地城市列表
-(void) loadLocalCityList{
    _localCityDict = [CityZipUtils readCityLatestVersionWithCityId];
    if(!_dataCityArrayList) [self sortByGroupCityArray:[_localCityDict allValues]];
    [self createCollectionViewIndex];
    [self reloadData];
}

-(void)sortByGroupCityArray:(NSArray*)cityList{
    //热门城市
    _dataHotCityList = [NSMutableArray new];
    for(int i=0; i<cityList.count; i++){
        CityModel *city = cityList[i];
        if(![cityList[i] isKindOfClass:[CityModel class]]){
            city = [CityModel parseCity:cityList[i]];
        }
        if(!_dataCityList) _dataCityList = [NSMutableArray new];
        [_dataCityList addObject:city];
        if(city.priority>=500 && !_withoutHeader){
            if(!_dataHotCityList) _dataHotCityList = [NSMutableArray new];
            [_dataHotCityList addObject:city];
        }
    }
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:NO];
    // 排序结果
    _dataHotCityList = [NSMutableArray arrayWithArray:[_dataHotCityList sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
    //根据拼音首字母分组
    _dataCityArrayList = [NSMutableArray new];
    _dataFirstLetters = [NSMutableArray new];
    NSMutableArray *noPyList = [NSMutableArray new];
    NSMutableArray *tempList = nil;
    NSString *tempLetter = nil;
    NSArray *sortArray = [_dataCityList sortedArrayUsingComparator:^NSComparisonResult(CityModel *city1, CityModel *city2) {
        return [city1.nameFirstLetter compare:city2.nameFirstLetter options:NSNumericSearch];
    }];
    for(CityModel *city in sortArray){
        if(!city.nameFirstLetter) [noPyList addObject:city];
        else if(!tempLetter || ![city.nameFirstLetter isEqualToString:tempLetter]){
            if(tempList) {
                [_dataCityArrayList addObject:tempList];
                [_dataFirstLetters addObject:tempLetter];
            }
            tempLetter = city.nameFirstLetter;
            tempList = [NSMutableArray new];
            [tempList addObject:city];
        }else{
            [tempList addObject:city];
        }
    }
    if(tempList) {
        [_dataCityArrayList addObject:tempList];
        [_dataFirstLetters addObject:tempLetter];
    }
    if(noPyList.count>0) {
        [_dataCityArrayList addObject:noPyList];
        [_dataFirstLetters addObject:@"#"];
    }
}



-(void)beforeDisappear{
    if(_collectionViewIndex) [_collectionViewIndex removeFromSuperview];
}

#pragma mark 索引条
- (void)createCollectionViewIndex{
    _collectionViewIndex = [[DSCollectionViewIndex alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-20,0, 16, SCREEN_HEIGHT)];    //创建索引条
    [self.superview addSubview:_collectionViewIndex];   //添加到视图上
    
    _collectionViewIndex.titleIndexes = _dataFirstLetters;   //设置数组
    CGRect rect = _collectionViewIndex.frame;
    rect.size.height = _collectionViewIndex.titleIndexes.count * 16;
    rect.origin.y = (_collectionViewIndex.height - rect.size.height) / 2;
    _collectionViewIndex.frame = rect;
    _collectionViewIndex.isFrameLayer = NO;    //是否有边框线
    _collectionViewIndex.collectionDelegate = self;
    
    //中间显示的背景框
    _flotageLabel = [[UILabel alloc] initWithFrame:(CGRect){(SCREEN_WIDTH - 64 ) / 2,(SCREEN_HEIGHT - 64) / 2,64,64}];
    CGRect flotageRect = _flotageLabel.frame;
    flotageRect.origin.y = (SCREEN_HEIGHT - flotageRect.size.height) / 2;
    _flotageLabel.frame = flotageRect;
    _flotageLabel.backgroundColor = dynamic_color_gray;
    _flotageLabel.hidden = YES;
    _flotageLabel.textAlignment = NSTextAlignmentCenter;
    _flotageLabel.textColor = [UIColor whiteColor];
    _flotageLabel.layer.cornerRadius = 8;
    if (@available(iOS 11.0, *)) {
        _flotageLabel.layer.maskedCorners = YES;
    } else {
        // Fallback on earlier versions
    }
    _flotageLabel.alpha = 0.8;
    [self.superview addSubview:_flotageLabel];
    
    //选中字母改变背景
    _flotageView = [[UIView alloc] init];
    _flotageView.frame = CGRectMake(0, 0, _collectionViewIndex.frame.size.width, 16);
    _flotageView.hidden = YES;
    _flotageView.alpha = 0.5;
    _flotageView.layer.cornerRadius = 8;
    _flotageView.layer.masksToBounds = YES;
    _flotageView.backgroundColor = dynamic_color_gray;
    [_collectionViewIndex addSubview:_flotageView];
}
#pragma mark- 索引条代理DSCollectionViewIndexDelegate
-(void)collectionViewIndex:(DSCollectionViewIndex *)collectionViewIndex didselectionAtIndex:(NSInteger)index withTitle:(NSString *)title{
    NSInteger indexOffset = (_dataHotCityList && _dataHotCityList.count>0)?2:1;
    [self scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:index+indexOffset] atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
    _flotageLabel.text = title;
    CGRect rect = _flotageView.frame;
    rect.origin.y = index * 16;
    _flotageView.frame = rect;
}

-(void)collectionViewIndexTouchesBegan:(DSCollectionViewIndex *)collectionViewIndex{
    _flotageLabel.alpha = 1;
    _flotageLabel.hidden = NO;
    _flotageView.hidden = NO;
}

-(void)collectionViewIndexTouchesEnd:(DSCollectionViewIndex *)collectionViewIndex{
    __weak typeof(self) wkSelf = self;
    void (^animation)(void) = ^{
        wkSelf.flotageLabel.alpha = 0;
        wkSelf.flotageView.hidden = YES;
    };
    
    [UIView animateWithDuration:0.4 animations:animation completion:^(BOOL finished) {
        wkSelf.flotageLabel.hidden = YES;
    }];
}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    __weak typeof(self) wkSelf = self;
    // trait发生了改变
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            if(self.layers) for(CALayer *layer in self.layers){
                layer.backgroundColor = dynamic_color_lightgray.CGColor;
            }        }
    } else {
    }
}
@end
