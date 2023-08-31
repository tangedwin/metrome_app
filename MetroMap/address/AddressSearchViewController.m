//
//  AddressSearchViewController.m
//  MetroMap
//
//  Created by edwin on 2019/10/31.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "AddressSearchViewController.h"
#import "CommenAddressViewController.h"

@interface AddressSearchViewController ()<UITextFieldDelegate>
@property(nonatomic, retain) AddressSearchView *addressSearchView;
@property(nonatomic, retain) UILabel *searchButton;
@property(nonatomic, assign) NSInteger index;

@end

@implementation AddressSearchViewController


-(instancetype)initWithIndex:(NSInteger)index{
    self = [super init];
    _index = index;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createAddressSearchButton];
    [self.view setBackgroundColor:dynamic_color_white];
    [self.view addSubview:self.naviMask];
    [self.naviMask addSubview:self.backButton];
    [self.naviMask addSubview:self.searchButton];
    self.searchBar.frame = CGRectMake(view_margin+28, self.searchBar.y, SCREEN_WIDTH-view_margin*3-28-_searchButton.width, self.searchBar.height);
    NSString *text = @"输入站点名/地址";
    NSMutableAttributedString *fieldText = [[NSMutableAttributedString alloc] initWithString:text];
    [fieldText addAttribute:NSFontAttributeName value:sub_font_middle range:NSMakeRange(0, text.length)];
    [fieldText addAttribute:NSForegroundColorAttributeName value:dynamic_color_gray range:NSMakeRange(0, text.length)];
    [self.searchBar setAttributedPlaceholder:fieldText];
    [self.naviMask addSubview:self.searchBar];
    self.searchBar.delegate = self;
    
    _addressSearchView= [[AddressSearchView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT)];
    [self.view addSubview:_addressSearchView];
    
    __weak typeof(self) wkSelf = self;
    [_addressSearchView setSelectedAddress:^(AddressModel *address, CityModel *city) {
        UIViewController *vc = wkSelf.navigationController.viewControllers[wkSelf.navigationController.viewControllers.count-2];
        if([vc isKindOfClass:[CommenAddressViewController class]]){
            CommenAddressViewController *cvc = (CommenAddressViewController*)vc;
            [cvc setAddress:address city:city forIndex:wkSelf.index];
            [wkSelf.navigationController popViewControllerAnimated:YES];
        }
    }];
    
    [self.searchBar addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
    [self searchStations:nil];
}


//- (void)viewWillAppear:(BOOL)animated{
//    self.tabBarController.tabBar.hidden = YES;
//}
//
//- (void)viewWillDisappear:(BOOL)animated{
//  self.tabBarController.tabBar.hidden = NO;
//}


-(void)createAddressSearchButton{
    NSString *searchName = @"搜索";
    CGSize searchButtonSize = [searchName sizeWithAttributes:@{NSFontAttributeName:main_font_small}];
    _searchButton = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-view_margin-ceil(searchButtonSize.width), (self.searchBar.height-ceil(searchButtonSize.height))/2+STATUS_BAR_HEIGHT+2, ceil(searchButtonSize.width), ceil(searchButtonSize.height))];
    _searchButton.font = main_font_small;
    _searchButton.textColor = main_color_blue;
    _searchButton.text = searchName;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchStationsTap:)];
    _searchButton.userInteractionEnabled = YES;
    [_searchButton addGestureRecognizer:tap];
}


#pragma mark *** UITextFieldDelegate ***

- (void)textFieldTextDidChange:(UITextField *)textField{
    if(textField.markedTextRange==nil) {
        [self searchStations:textField.text];
//        NSLog(@"文字改变：%@",textField.text);
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField endEditing:YES];
    if(textField == self.searchBar){
        if(textField.text.length<1){
            [MBProgressHUD showInfo:@"未输入内容" detail:nil image:nil inView:nil];
            return NO;
        }else{
            [self searchStations:textField.text];
        }
    }
    return YES;
}

-(void) searchStationsTap:(UITapGestureRecognizer*)tap{
    if(self.searchBar){
        if(self.searchBar.text.length<1){
            [MBProgressHUD showInfo:@"未输入内容" detail:nil image:nil inView:nil];
        }else{
            [self searchStations:self.searchBar.text];
        }
    }
    [self.searchBar endEditing:YES];
}


-(void) searchStations:(NSString*)keywords{
    [_addressSearchView searchMap:keywords forStation:NO];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    __weak typeof(self) wkSelf = self;
    // trait发生了改变
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            if(wkSelf.addressSearchView) [wkSelf.addressSearchView reloadData];
        }
    } else {
    }
}
@end
