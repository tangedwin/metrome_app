//
//  LinesCollectionView.m
//  MetroMap
//
//  Created by edwin on 2019/10/22.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "StationTimetableView.h"

@interface StationTimetableView()<UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (nonatomic, retain) UICollectionViewFlowLayout *fallLayout;
@property (nonatomic, retain) NSMutableArray *dataLines;
@property (nonatomic, retain) StationModel *station;
@property (nonatomic, retain) CityModel *city;
//@property (nonatomic, retain) NSMutableDictionary *timetable;

@end

static NSString * const station_timetable_id = @"station_timetable";
@implementation StationTimetableView


-(instancetype)initWithFrame:(CGRect)frame station:(StationModel*)station lines:(NSMutableArray*)lines city:(CityModel*)city{
    // 创建布局
    _fallLayout = [[UICollectionViewFlowLayout alloc]init];
    _fallLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _fallLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
    _fallLayout.minimumLineSpacing = 0;
    _fallLayout.minimumInteritemSpacing = 0;
    _fallLayout.estimatedItemSize = CGSizeMake(SCREEN_WIDTH, 52*2);
    self = [super initWithFrame:frame collectionViewLayout:_fallLayout];
    [self registerClass:[StationTimetableCellView class] forCellWithReuseIdentifier:station_timetable_id];
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
    _station = station;
    _dataLines = lines;
    _city = city;
//    if(_dataLines && _dataLines.count>0) [self selectLine:0];
    return self;
}

-(void)setSelectedLine:(LineModel *)selectedLine{
    for(int i=0; i<_dataLines.count; i++){
        LineModel *line = _dataLines[i];
        if(selectedLine == line){
            _selectedLine = selectedLine;
            [self selectLine:i];
            break;
        }
    }
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //根据注册标记查找cell
    StationTimetableCellView * cell = [collectionView dequeueReusableCellWithReuseIdentifier:station_timetable_id forIndexPath:indexPath];
    if(cell.contentView.subviews) for(UIView *view in cell.contentView.subviews) [view removeFromSuperview];
    LineModel *line = _dataLines[indexPath.item];
    [cell loadCellView:_station.timetable line:line city:_city];
    return cell;
}

//返回collection的section数量
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //如果photo数量为0则不显示底部刷新条
    return _dataLines.count;
}


//- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
//    return CGSizeMake(SCREEN_WIDTH, 52*2);
//}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    NSInteger index = scrollView.contentOffset.x/SCREEN_WIDTH;
    if(index<_dataLines.count){
        if(!_selectedLine || _dataLines[index]!=_selectedLine){
            _selectedLine = _dataLines[index];
            [self resetHeightByCell:[NSIndexPath indexPathForItem:index inSection:0]];
            if(self.selectLine) self.selectLine(index);
        }
    }
}


-(void)selectLine:(NSInteger)index{
    if(index>=_dataLines.count) return;
    _selectedLine = _dataLines[index];
//    [self loadDirection:_selectedLine item:0 section:0];
    [self scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:YES];
    [self performSelector:@selector(resetHeightByCell:) withObject:[NSIndexPath indexPathForItem:index inSection:0] afterDelay:.5f];
}

-(void)resetHeightByCell:(NSIndexPath*)indexPath{
    StationTimetableCellView * stc = (StationTimetableCellView*)[self cellForItemAtIndexPath:indexPath];
    if(self.resetTimetableHeight && stc.cellheight>0) {
        self.resetTimetableHeight(stc.cellheight);
        __weak typeof(self) wkSelf = self;
        [UIView animateWithDuration:.5f animations:^{
            wkSelf.frame = CGRectMake(wkSelf.frame.origin.x, wkSelf.frame.origin.y, wkSelf.frame.size.width, stc.cellheight);
        }];
    }
}

@end
