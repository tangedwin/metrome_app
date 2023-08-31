//
//  FeedbackTitleView.m
//  MetroMap
//
//  Created by edwin on 2019/11/25.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "FeedbackTitleView.h"

@interface FeedbackTitleView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, retain) UICollectionViewFlowLayout *fallLayout;
@property (nonatomic, retain) NSMutableArray *dataTitles;
@end

static NSString * const feedback_name_collection_id = @"feedback_name_collection";
@implementation FeedbackTitleView

-(instancetype)initWithFrame:(CGRect)frame titles:(NSMutableArray*)titles selected:(NSMutableArray*)selected{
    // 创建布局
    _fallLayout = [[UICollectionViewFlowLayout alloc]init];
    _fallLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    _fallLayout.estimatedItemSize = CGSizeMake(50, 30);
    self = [super initWithFrame:frame collectionViewLayout:_fallLayout];
    [self registerClass:[FeedbackTitleCellView class] forCellWithReuseIdentifier:feedback_name_collection_id];
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
    _dataTitles = titles;
    _selectedTitles = selected?selected:[NSMutableArray new];
    return self;
}


#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //根据注册标记查找cell
    FeedbackTitleCellView * cell = [collectionView dequeueReusableCellWithReuseIdentifier:feedback_name_collection_id forIndexPath:indexPath];
    NSString *title = _dataTitles[indexPath.item];
    
    [cell loadCell:title indexPath:indexPath selected:(_selectedTitles && [_selectedTitles containsObject:title])];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapSelectTitle:)];
    [cell addGestureRecognizer:tap];
    cell.tag = indexPath.item;
    cell.userInteractionEnabled = YES;
    return cell;
}

-(void)tapSelectTitle:(UITapGestureRecognizer*)tap{
    NSInteger index = tap.view.tag;
    if(index >= _dataTitles.count) return;
    if([_selectedTitles containsObject:_dataTitles[index]]) [_selectedTitles removeObject:_dataTitles[index]];
    else [_selectedTitles addObject: _dataTitles[index]];
//    [self reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
    [self reloadData];
}

-(void)selectTitle:(NSInteger)index{
    if(index >= _dataTitles.count) return;
    [_selectedTitles addObject: _dataTitles[index]];
//    [self reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]]];
    [self reloadData];
}

//设置section间隔
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    //分别为上、左、下、右
    return UIEdgeInsetsMake(7, view_margin, 7, 0);
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
    return _dataTitles.count;
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    // trait发生了改变
    __weak typeof(self) wkSelf = self;
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            [wkSelf reloadData];
        }
    } else {
    }
}
@end
