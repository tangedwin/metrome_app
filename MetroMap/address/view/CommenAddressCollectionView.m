//
//  CommenAddressCollectionView.m
//  MetroMap
//
//  Created by edwin on 2019/10/30.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "CommenAddressCollectionView.h"


@interface CommenAddressCollectionView()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, retain) UICollectionViewFlowLayout *fallLayout;
@property (nonatomic, retain) NSMutableArray *addressData;

@end

static NSString * const commen_address_collection_id = @"commen_address_collection";
@implementation CommenAddressCollectionView


-(instancetype)initWithFrame:(CGRect)frame{
    // 创建布局
    _fallLayout = [[UICollectionViewFlowLayout alloc]init];
    _fallLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self = [super initWithFrame:frame collectionViewLayout:_fallLayout];
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:commen_address_collection_id];
    self.dataSource = self;
    self.delegate = self;
    self.allowsSelection = NO;
    self.alwaysBounceVertical = YES;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    self.backgroundColor = dynamic_color_white;
    self.showsVerticalScrollIndicator = NO;
    
    return self;
}

-(void)loadAddressArray:(NSMutableArray*)addressArray{
    _addressData = addressArray;
    [self reloadData];
}

#pragma mark - UICollectionViewDataSource
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //根据注册标记查找cell
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:commen_address_collection_id forIndexPath:indexPath];
    if(cell.contentView.subviews) for(UIView *sview in cell.contentView.subviews) [sview removeFromSuperview];
    
    if(indexPath.item==0){
        AddressModel *addressModel = nil;
        if(_addressData) for(AddressModel *address in _addressData){
            if([home_type isEqualToString:address.type]) addressModel = address;
        }
        [self createTableWithAddress:addressModel cell:cell indexPath:indexPath];
    }else if(indexPath.item==1){
        AddressModel *addressModel = nil;
        if(_addressData) for(AddressModel *address in _addressData){
            if([company_type isEqualToString:address.type]) addressModel = address;
        }
        [self createTableWithAddress:addressModel cell:cell indexPath:indexPath];
    }
    cell.backgroundColor = dynamic_color_lightwhite;
    return cell;
}

-(void)createTableWithAddress:(AddressModel*)address cell:(UICollectionViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(view_margin, 0, SCREEN_WIDTH-view_margin, 52)];
    
    
    CGFloat maxTitleWidth = (view.width-21*2-view_margin)/2;
    UILabel *titleLabel = [[UILabel alloc] init];
    if(address){
        titleLabel.font = main_font_small;
        titleLabel.textColor = dynamic_color_black;
        titleLabel.text = address.addressName;
        CGSize titleSize = [address.addressName sizeWithAttributes:@{NSFontAttributeName:main_font_small}];
        CGFloat width = maxTitleWidth>titleSize.width?titleSize.width:maxTitleWidth;
        titleLabel.frame = CGRectMake(indexPath.item<2?21:0, 16, ceil(width), 20);
    }else{
        titleLabel.font = main_font_small;
        titleLabel.textColor = dynamic_color_gray;
        titleLabel.text = indexPath.item==0?@"填写家庭住址":@"填写公司住址";
        titleLabel.frame = CGRectMake(indexPath.item<2?21:0, 16, maxTitleWidth*2, 20);
    }
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [view addSubview:titleLabel];
    
    if(address){
        UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(titleLabel.x+titleLabel.width+view_margin, (52-17)/2, maxTitleWidth*2-titleLabel.width, 17)];
        addressLabel.font = sub_font_middle;
        addressLabel.textColor = dynamic_color_gray;
        addressLabel.text = address.address;
        addressLabel.textAlignment = NSTextAlignmentLeft;
        [view addSubview:addressLabel];
    }
    
    if(indexPath.item==0){
        UIImageView *homeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"home_big"]];
        homeIcon.frame = CGRectMake(0, (52-15)/2, 15, 15);
        [view addSubview:homeIcon];
    }else if(indexPath.item==1){
        UIImageView *companyIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"company_big"]];
        companyIcon.frame = CGRectMake(0, (52-15)/2, 15, 15);
        [view addSubview:companyIcon];
    }
    
    UIImageView *nextButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"navi_right_big"]];
    nextButton.frame = CGRectMake(view.width-view_margin-15, (52-15)/2, 15, 15);
    [view addSubview:nextButton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectAddress:)];
    view.tag = indexPath.item;
    view.userInteractionEnabled = YES;
    [view addGestureRecognizer:tap];
    
    [cell.contentView addSubview:view];
}

-(void)selectAddress:(UITapGestureRecognizer*)tap{
    if(tap.view.tag<_addressData.count || tap.view.tag<2){
        if(self.searchAddress) {
            if(tap.view.tag<_addressData.count) self.searchAddress(tap.view.tag, _addressData[tap.view.tag]);
            else self.searchAddress(tap.view.tag, nil);
        }
    }
}

//设置cell的尺寸
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return CGSizeMake(SCREEN_WIDTH, 52);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

//设置section间隔
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    //分别为上、左、下、右
    return UIEdgeInsetsMake(6, 0, 0, 0);
}

//返回列表分组数，默认为1
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

//返回列表每个分组section拥有cell行数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _addressData.count<2?2:_addressData.count;
}



@end
