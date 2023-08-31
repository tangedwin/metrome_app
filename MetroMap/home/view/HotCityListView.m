//
//  HotCityListView.m
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "HotCityListView.h"

@interface HotCityListView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, retain) UICollectionViewFlowLayout *fallLayout;
@property (nonatomic, retain) NSMutableArray *dataCityList;
@property (nonatomic, retain) MetroMapHelper *metroMapHelper;

@end

static NSString * const hot_city_list_id = @"hot_city_list";
@implementation HotCityListView


-(instancetype)initWithFrame:(CGRect)frame{
    // 创建布局
    _fallLayout = [[UICollectionViewFlowLayout alloc]init];
    _fallLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    self = [super initWithFrame:frame collectionViewLayout:_fallLayout];
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:hot_city_list_id];
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
    _metroMapHelper = [MetroMapHelper new];
    //加载图片
    [self loadCities];
    return self;
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //根据注册标记查找cell
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:hot_city_list_id forIndexPath:indexPath];
    if(cell.contentView.subviews) for(UIView *view in cell.contentView.subviews) [view removeFromSuperview];
    if(self.dataCityList && indexPath.item<self.dataCityList.count){
        CityModel *cityInfo = self.dataCityList[indexPath.item];
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, fitFloat(117), fitFloat(88))];
        imgView.layer.cornerRadius = 6;
        imgView.layer.masksToBounds = YES;
        if(cityInfo.hotCityImage){
            NSCharacterSet *encode_set= [NSCharacterSet URLUserAllowedCharacterSet];
            NSString * hotCityImage = [cityInfo.hotCityImage stringByAddingPercentEncodingWithAllowedCharacters:encode_set];
            if (@available(iOS 13.0, *)) {
                if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark && cityInfo.hotCityImageDark){
                    hotCityImage = [cityInfo.hotCityImageDark stringByAddingPercentEncodingWithAllowedCharacters:encode_set];
                }
            }
            hotCityImage = [hotCityImage stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
            NSURL *imageUrl = [NSURL URLWithString:[NSString stringWithFormat:@"%@/%@/%@", Base_URL,request_cityIcon, hotCityImage]];
            [imgView yy_setImageWithURL:imageUrl placeholder:nil options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation completion:^(UIImage * _Nullable image, NSURL * _Nonnull url, YYWebImageFromType from, YYWebImageStage stage, NSError * _Nullable error) {
                if(!image) [imgView setImage:[UIImage imageNamed:@"default_news"]];
            }];
        }else{
            [imgView setImage:[UIImage imageNamed:@"default_news"]];
        }
        
        UIView *backgroundView = [[UIView alloc] initWithFrame:imgView.frame];
        [backgroundView setBackgroundColor:dynamic_color_lightwhite];
        backgroundView.layer.cornerRadius = 6;
        backgroundView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05].CGColor;
        backgroundView.layer.shadowOffset = CGSizeMake(0,3);
        backgroundView.layer.shadowOpacity = 1;
        backgroundView.layer.shadowRadius = 6;
        backgroundView.layer.cornerRadius = 6;
        backgroundView.layer.masksToBounds = NO;
        [cell.contentView addSubview:backgroundView];
        [cell.contentView addSubview:imgView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(loadCityMap:)];
        imgView.tag = indexPath.item;
        imgView.userInteractionEnabled = YES;
        [imgView addGestureRecognizer:tap];
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, fitFloat(88)+6, fitFloat(117), fitFloat(20))];
        title.font = main_font_small;
        title.textColor = dynamic_color_black;
        title.textAlignment = NSTextAlignmentCenter;
        NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@",cityInfo.nameCn] attributes:@{NSKernAttributeName:@10.f}];
        [title setAttributedText:attributedString];
        [cell.contentView addSubview:title];
    }
    
    return cell;
}

-(void)loadCityMap:(UITapGestureRecognizer*)tap{
    if(tap.view.tag<_dataCityList.count){
        CityModel *city = _dataCityList[tap.view.tag];
        __weak typeof(self) wkSelf = self;
        [_metroMapHelper loadMetroMap:city success:^{
            if(wkSelf.reloadCityData) wkSelf.reloadCityData();
        }];
    }
}

//返回collection的section数量
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //如果photo数量为0则不显示底部刷新条
    return _dataCityList.count;
}

// 设置UIcollectionView整体的内边距（这样item不贴边显示）
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    // 上 左 下 右
    return UIEdgeInsetsMake(5,view_margin,0,view_margin);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 12;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(fitFloat(117), fitFloat(88)+6+fitFloat(20));
}

//刷新图片
//- (void)loadCities{
//    _dataCityList = [NSMutableArray new];
//    [_dataCityList addObject:[CityModel createFakeModel]];
//    [_dataCityList addObject:[CityModel createFakeModel]];
//    [_dataCityList addObject:[CityModel createFakeModel]];
//    [_dataCityList addObject:[CityModel createFakeModel]];
//}


//远程获取城市列表
- (void)loadCities{
    __weak typeof(self) wkSelf = self;
    [[HttpHelper new] findList:request_city_list params:nil page:0 progress:nil success:^(NSMutableDictionary *responseDic) {
        NSMutableArray *cityArray = (NSMutableArray *)[responseDic mutableArrayValueForKey:@"list"];
        if(cityArray) {
            wkSelf.dataCityList = [NSMutableArray new];
            for(NSDictionary *dict in cityArray){
//                CityModel *city = [CityModel yy_modelWithJSON:dict];
                CityModel *city = [CityModel parseCity:dict];
                if(city.priority>=500 && city.hotCityImage){
                    [wkSelf.dataCityList addObject:city];
                }
            }
            NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"priority" ascending:NO];
            // 排序结果
            wkSelf.dataCityList = [NSMutableArray arrayWithArray:[wkSelf.dataCityList sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]]];
            [wkSelf reloadData];
        }
    } failure:^(NSString *errorInfo) {
    }];
}
@end
