//
//  LineNameCollectionView.m
//  MetroMap
//
//  Created by edwin on 2019/10/22.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "LineNameCollectionView.h"

@interface LineNameCollectionView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, retain) UICollectionViewFlowLayout *fallLayout;
@property (nonatomic, retain) NSMutableArray *dataLines;
@end

static NSString * const lines_name_collection_id = @"lines_name_collection";
@implementation LineNameCollectionView


-(instancetype)initWithFrame:(CGRect)frame lines:(NSMutableArray*)lines{
    // 创建布局
    _fallLayout = [[UICollectionViewFlowLayout alloc]init];
    _fallLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _fallLayout.estimatedItemSize = CGSizeMake(50, 30);
    self = [super initWithFrame:frame collectionViewLayout:_fallLayout];
    [self registerClass:[LineNameCellView class] forCellWithReuseIdentifier:lines_name_collection_id];
    self.dataSource = self;
    self.delegate = self;
    self.allowsSelection = NO;
    self.alwaysBounceHorizontal = YES;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    self.backgroundColor = dynamic_color_white;
    self.showsHorizontalScrollIndicator = NO;
    _dataLines = lines;
    
    if(!_selectedLine && _dataLines && _dataLines.count>0) _selectedLine = _dataLines[0];
    
    return self;
}


#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //根据注册标记查找cell
    LineNameCellView * cell = [collectionView dequeueReusableCellWithReuseIdentifier:lines_name_collection_id forIndexPath:indexPath];
    LineModel *line = _dataLines[indexPath.item];
    
    [cell loadCell:line indexPath:indexPath selected:(_selectedLine && _selectedLine==line)];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedLine:)];
    [cell addGestureRecognizer:tap];
    cell.tag = indexPath.item;
    cell.userInteractionEnabled = YES;
    return cell;
}

-(void)showHidedView:(UIView*)view{
    if ([NSThread isMainThread]) {
        view.alpha = 1;
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            view.alpha = 1;
        });
    }
}

-(void)selectedLine:(UITapGestureRecognizer*)tap{
    [self selectLine:tap.view.tag];
    if(self.selectLine) self.selectLine(tap.view.tag);
}
-(void)selectLine:(NSInteger)index{
    if(index >= _dataLines.count) return;
    
    NSIndexPath *prevIndex = [_dataLines indexOfObject:_selectedLine]!=NSNotFound?[NSIndexPath indexPathForItem:[_dataLines indexOfObject:_selectedLine] inSection:0]:nil;
    NSIndexPath *curIndex = [NSIndexPath indexPathForItem:index inSection:0];
    LineModel *prevLine = _selectedLine;
    _selectedLine = _dataLines[index];
    
    LineNameCellView *prevCell = (LineNameCellView*)[self cellForItemAtIndexPath:prevIndex];
    LineNameCellView *curCell = (LineNameCellView*)[self cellForItemAtIndexPath:curIndex];
    [prevCell loadCell:prevLine indexPath:prevIndex selected:NO];
    [curCell loadCell:_selectedLine indexPath:curIndex selected:YES];
    
    [self scrollToItemAtIndexPath:curIndex atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:YES];
}

//设置section间隔
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    //分别为上、左、下、右
    return UIEdgeInsetsMake(11, view_margin, 7, 0);
}


- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return view_margin;
}

//返回collection的section数量
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //如果photo数量为0则不显示底部刷新条
    return _dataLines.count;
}


@end
