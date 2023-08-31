//
//  LinesCollectionView.m
//  MetroMap
//
//  Created by edwin on 2019/10/22.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "LinesCollectionView.h"

@interface LinesCollectionView()<UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (nonatomic, retain) UICollectionViewFlowLayout *fallLayout;
@property (nonatomic, retain) NSMutableArray *dataLines;
@property (nonatomic, retain) CityModel *city;
@property (nonatomic, retain) LineModel *selectedLine;

@end

static NSString * const lines_collection_id = @"lines_collection";
@implementation LinesCollectionView


-(instancetype)initWithFrame:(CGRect)frame city:(CityModel*)city lines:(NSMutableArray*)lines{
    // 创建布局
    _fallLayout = [[UICollectionViewFlowLayout alloc]init];
    _fallLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _fallLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _fallLayout.minimumLineSpacing = 0;
    _fallLayout.minimumInteritemSpacing = 0;
    self = [super initWithFrame:frame collectionViewLayout:_fallLayout];
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:lines_collection_id];
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
    self.backgroundColor = dynamic_color_white;
    self.showsHorizontalScrollIndicator = NO;
    _city = city;
    _dataLines = lines;
    if(_dataLines && _dataLines.count>0) _selectedLine = _dataLines[0];
    return self;
}


#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //根据注册标记查找cell
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:lines_collection_id forIndexPath:indexPath];
    if(cell.contentView.subviews) for(UIView *view in cell.contentView.subviews) [view removeFromSuperview];
    LineModel *line = _dataLines[indexPath.item];
    [self createCellTable:line cell:cell indexPath:indexPath];
    return cell;
}

-(void)createCellTable:(LineModel*)line cell:(UICollectionViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    StationCollectionView *sview = [[StationCollectionView alloc] initWithFrame:CGRectMake(0, cell.y, cell.width, cell.height) city:_city line:line];
    [cell.contentView addSubview:sview];
    __weak typeof(self) wkSelf = self;
    [sview setShowStationInfo:^(CityModel *city, StationModel *station) {
        if(wkSelf.showStationInfo) wkSelf.showStationInfo(city, wkSelf.dataLines[indexPath.item], station);
    }];
}


-(void)selectLine:(NSInteger)index{
    if(index>=_dataLines.count) return;
    _selectedLine = _dataLines[index];
    [self scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
}

//返回collection的section数量
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //如果photo数量为0则不显示底部刷新条
    return _dataLines.count;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT-49);
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger index = scrollView.contentOffset.x/SCREEN_WIDTH;
    if(index<_dataLines.count){
        if(!_selectedLine || _dataLines[index]!=_selectedLine){
            _selectedLine = _dataLines[index];
            if(self.selectLine) self.selectLine(index);
        }
    }
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSInteger index = scrollView.contentOffset.x/SCREEN_WIDTH;
//    if(index<_dataLines.count){
//        if(!_selectedLine || _dataLines[index]!=_selectedLine){
//            _selectedLine = _dataLines[index];
//            if(self.selectLine) self.selectLine(index);
//        }
//    }
//}
@end
