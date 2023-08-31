//
//  ImageReview.m
//  MetroMap
//
//  Created by edwin on 2019/11/26.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "ImageBrowserController.h"
#import "ImageBrowserCell.h"

#define cell_image_browser   @"cell_image_browser"
#define imageSpace          10        // 图片间距
@interface ImageBrowserController () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (nonatomic, retain) UICollectionView *collectionView;
//@property (nonatomic, retain) UICollectionViewFlowLayout *fallLayout;
@property (nonatomic, strong) UIPageControl * pageControl;

@property (nonatomic, strong) NSMutableArray * dataArr;
@property (nonatomic, assign) ImageSourceType type;
@property (nonatomic, assign) NSInteger selectIndex;

@property (nonatomic, assign) CGFloat panCenterX;
@property (nonatomic, assign) CGFloat startOffsetX;

@property (nonatomic, assign) CGFloat offsetX;
@property (nonatomic, assign) CGFloat panX;
@end

@implementation ImageBrowserController

- (instancetype)initWithType:(ImageSourceType)type imageArr:(NSArray *)imageArr selectIndex:(NSInteger)selectIndex {
    self = [super init];
    // 创建布局
//    _fallLayout = [[UICollectionViewFlowLayout alloc]init];
//    _fallLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
//    _fallLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
//    _fallLayout.minimumLineSpacing = 0;
//    _fallLayout.minimumInteritemSpacing = 0;
//    _collectionView = [UICollectionView initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT) collectionViewLayout:_fallLayout];
//    [_collectionView registerClass:[ImageBrowserCell class] forCellWithReuseIdentifier:cell_image_browser];
//    _collectionView.dataSource = self;
//    _collectionView.delegate = self;
//    _collectionView.allowsSelection = YES;
//    _collectionView.alwaysBounceHorizontal = YES;
//    _collectionView.pagingEnabled = YES;
//    if (@available(iOS 11.0, *)) {
//        _collectionView.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentNever;
//    } else {
//        // Fallback on earlier versions
//    }
//    _collectionView.backgroundColor = dynamic_color_white;
//    _collectionView.showsHorizontalScrollIndicator = NO;
    if (self) {
        [self.dataArr removeAllObjects];
        [self.dataArr addObjectsFromArray:imageArr];
        _type = type;
        _selectIndex = selectIndex;
    }
    return self;
}
-(void)viewDidLoad{
    [super viewDidLoad];
    
    [self.view addSubview:self.naviMask];
    [self.naviMask addSubview:self.backButton];
    [self.view setBackgroundColor:dynamic_color_white];
    
    [self.view addSubview:self.collectionView];
    [self.view addSubview:self.pageControl];
    [self makeConstraintsForUI];
}

- (void)makeConstraintsForUI {
//    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.left.right.bottom.mas_equalTo(0).priorityHigh();
//    }];
//    [_pageControl mas_makeConstraints:^(MASConstraintMaker *make) {
////        make.left.right.mas_equalTo(0).priorityHigh();
//        make.bottom.mas_equalTo(-fitFloat(50)).priorityHigh();
//        make.height.mas_equalTo(20).priorityHigh();
//    }];
    
    [self performSelector:@selector(setCollectionContentOffset) withObject:nil afterDelay:0.1];
}

- (void)setCollectionContentOffset {
    
    __weak typeof(self)wkSelf =self;
    dispatch_async(dispatch_get_main_queue(), ^{
        [wkSelf.collectionView setContentOffset:CGPointMake((SCREEN_WIDTH + imageSpace) * wkSelf.selectIndex, 0) animated:NO];
        wkSelf.pageControl.numberOfPages = wkSelf.dataArr.count;
        wkSelf.pageControl.currentPage = wkSelf.selectIndex;
        wkSelf.pageControl.frame = CGRectMake((SCREEN_WIDTH-wkSelf.pageControl.width)/2, SCREEN_HEIGHT-30-SAFE_AREA_INSERTS_BOTTOM, wkSelf.pageControl.width, wkSelf.pageControl.height);
    });
    _startOffsetX = self.collectionView.contentOffset.x;
}

#pragma mark - GestureRecognizer event

- (void)panCollection:(UIPanGestureRecognizer *)pan {
    
    _panCenterX = [pan translationInView:self.collectionView].x;
    if (pan.state == UIGestureRecognizerStateBegan) {
        
        _startOffsetX = self.collectionView.contentOffset.x;
        _offsetX = 0;
        _panX = 0;
    }
    if (_selectIndex == 0) {
        
        if (_panCenterX > 0) {
            
            CGFloat s = (SCREEN_WIDTH - _panCenterX) / SCREEN_WIDTH;
            _offsetX += (_panCenterX - _panX) * s;
            _panX = _panCenterX;
            [self.collectionView setContentOffset:CGPointMake(-_offsetX, 0) animated:NO];
        } else {
            
            if (self.dataArr.count == 1) {
                
                CGFloat s = (SCREEN_WIDTH + _panCenterX) / SCREEN_WIDTH;
                _offsetX += (_panCenterX - _panX) * s;
                _panX = _panCenterX;
                [self.collectionView setContentOffset:CGPointMake(-_offsetX, 0) animated:NO];
            } else {
                
                [self.collectionView setContentOffset:CGPointMake(_startOffsetX - _panCenterX, 0) animated:NO];
            }
        }
    } else if (_selectIndex == self.dataArr.count - 1) {
        
        if (_panCenterX < 0) {
            
            CGFloat s = (SCREEN_WIDTH + _panCenterX) / SCREEN_WIDTH;
            _offsetX += (_panCenterX - _panX) * s;
            _panX = _panCenterX;
            [self.collectionView setContentOffset:CGPointMake(_startOffsetX - _offsetX, 0) animated:NO];
        } else {
            
            [self.collectionView setContentOffset:CGPointMake(_startOffsetX - _panCenterX, 0) animated:NO];
        }
    } else {
        
        [self.collectionView setContentOffset:CGPointMake(_startOffsetX - _panCenterX, 0) animated:NO];
    }
    if (pan.state == UIGestureRecognizerStateEnded) {
        
        if ([self absoluteValue:_panCenterX] > SCREEN_WIDTH/3) {
            
            if (_panCenterX < 0) {
                
                _selectIndex += 1;
            } else {
                
                _selectIndex -= 1;
            }
            if (_selectIndex == self.dataArr.count) {
                
                _selectIndex = self.dataArr.count - 1;
            } else if (_selectIndex == -1) {
                
                _selectIndex = 0;
            }
            [self.collectionView setContentOffset:CGPointMake((SCREEN_WIDTH + imageSpace) * _selectIndex, 0) animated:YES];
            self.pageControl.currentPage = _selectIndex;
        } else {
            
            [self.collectionView setContentOffset:CGPointMake(_startOffsetX, 0) animated:YES];
        }
    }
}

- (void)swipeCollection:(UISwipeGestureRecognizer *)swipe {
    
    if (swipe.direction == UISwipeGestureRecognizerDirectionLeft) {
        
        _selectIndex += 1;
    } else if (swipe.direction == UISwipeGestureRecognizerDirectionRight) {
        
        _selectIndex -= 1;
    }
    if (_selectIndex == self.dataArr.count) {
        
        _selectIndex = self.dataArr.count - 1;
    } else if (_selectIndex == -1) {
        
        _selectIndex = 0;
    }
    self.pageControl.currentPage = _selectIndex;
    [self.collectionView setContentOffset:CGPointMake((SCREEN_WIDTH + imageSpace) * _selectIndex, 0) animated:YES];
}

// 返回value的绝对值
- (CGFloat)absoluteValue:(CGFloat)value {
    
    if (value < 0) {
        
        return -value;
    }
    return value;
}
#pragma mark - collection delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.dataArr.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    ImageBrowserCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:cell_image_browser forIndexPath:indexPath];
    if (indexPath.row < self.dataArr.count) {
        
        if (_type == ImageSourceTypeImage) {
            
            UIImage * image = [self.dataArr objectAtIndex:indexPath.row];
            [cell configCellWithImage:image];
        } else if (_type == ImageSourceTypeUrl) {
            
            NSString * url = [self.dataArr objectAtIndex:indexPath.row];
            [cell configCellWithUrl:url];
        } else if (_type == ImageSourceTypeFilePath) {
            
            NSString * filePath = [self.dataArr objectAtIndex:indexPath.row];
            [cell configCellWithFilePath:filePath];
        } else if (_type == ImageSourceTypeFileName) {
            
            NSString * fileName = [self.dataArr objectAtIndex:indexPath.row];
            [cell configCellWithFileName:fileName];
        }
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    return CGSizeMake(SCREEN_WIDTH, self.collectionView.height);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    
    return imageSpace;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    
    return 0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        
        UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        UICollectionView * cv = [[UICollectionView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT) collectionViewLayout:layout];
        cv.backgroundColor = dynamic_color_white;
        cv.delegate = self;
        cv.dataSource = self;
        cv.showsHorizontalScrollIndicator = NO;
        [cv registerClass:[ImageBrowserCell class] forCellWithReuseIdentifier:cell_image_browser];
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panCollection:)];
        [cv addGestureRecognizer:pan];
        UISwipeGestureRecognizer * swipeL = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeCollection:)];
        swipeL.direction = UISwipeGestureRecognizerDirectionLeft;
        [cv addGestureRecognizer:swipeL];
        UISwipeGestureRecognizer * swipeR = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeCollection:)];
        swipeR.direction = UISwipeGestureRecognizerDirectionRight;
        [cv addGestureRecognizer:swipeR];
        _collectionView = cv;
    }
    return _collectionView;
}



- (UIPageControl *)pageControl {
    
    if (!_pageControl) {
        
        UIPageControl * pageControl = [[UIPageControl alloc] init];
        pageControl.pageIndicatorTintColor = [dynamic_color_gray colorWithAlphaComponent:0.9];
        pageControl.currentPageIndicatorTintColor = main_color_blue;
        pageControl.userInteractionEnabled = NO;
        _pageControl = pageControl;
    }
    return _pageControl;
}

- (NSMutableArray *)dataArr {
    
    if (!_dataArr) {
        
        _dataArr = [NSMutableArray array];
    }
    return _dataArr;
}

@end
