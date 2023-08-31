//
//  AddressListViewController.m
//  MetroMap
//
//  Created by edwin on 2019/10/22.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "AddressListViewController.h"
#import "MainMapViewController.h"

@interface AddressListViewController ()<UITextFieldDelegate>
@property(nonatomic, retain) AddressSearchView *addressSearchView;
@property(nonatomic, retain) UILabel *searchButton;
@property(nonatomic, retain) AddressCollectsView *addressCollectsView;

@property(nonatomic, assign) CGRect searchBarInitRect;
@property(nonatomic, assign) CGRect searchBarSearchingRect;

//1起点站 2终点站 3详情页
@property(nonatomic, assign) NSInteger stationFor;

@end

@implementation AddressListViewController

-(instancetype)initWithStationFor:(NSInteger)type{
    self = [super init];
    _stationFor = type;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.naviMask];
    [self.naviMask addSubview:self.backButton];
    
    if(_stationFor!=3){
        self.searchBar.frame = CGRectMake(view_margin+28, self.searchBar.y, SCREEN_WIDTH-view_margin*2-28, self.searchBar.height);
        NSString *text = @"输入站点名/地址";
        NSMutableAttributedString *fieldText = [[NSMutableAttributedString alloc] initWithString:text];
        [fieldText addAttribute:NSFontAttributeName value:sub_font_middle range:NSMakeRange(0, text.length)];
        [fieldText addAttribute:NSForegroundColorAttributeName value:dynamic_color_gray range:NSMakeRange(0, text.length)];
        [self.searchBar setAttributedPlaceholder:fieldText];
        _searchBarInitRect = self.searchBar.frame;
        [self.naviMask addSubview:self.searchBar];
        self.searchBar.delegate = self;
        [self.searchBar addTarget:self action:@selector(textFieldTextDidChange:) forControlEvents:UIControlEventEditingChanged];
        
        [self createAddressSearchButton];
    }
    
    _addressCollectsView = [[AddressCollectsView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT) withCommenAddress:_stationFor!=3];
    [self.view addSubview:_addressCollectsView];
    __weak typeof(self)wkSelf = self;
    [_addressCollectsView setEditCommenAddress:^(NSMutableArray *addressArray) {
        CommenAddressViewController *caVC = [[CommenAddressViewController alloc] initWithAddressArray:addressArray];
        caVC.hidesBottomBarWhenPushed = YES;
        [wkSelf.navigationController pushViewController:caVC animated:YES];
    }];
    [_addressCollectsView setSelectedStation:^(StationModel *station) {
        if(wkSelf.stationFor!=3){
            NSString *curCityId = [[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_CITY_ID_KEY];
            if(!curCityId || [curCityId integerValue]!=station.city.identifyCode){
                [[AlertUtils new] showTipsView:@"该站点非当前城市" seconds:1.f];
            }else{
                [wkSelf selectStation:station];
            }
        }else{
            [wkSelf showStationDetail:station];
        }
    }];
}

-(void)showStationDetail:(StationModel*)station{
    if(!station) return;
    __weak typeof(self) wkSelf = self;
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:@(station.identifyCode) forKey:@"stationId"];
    [[HttpHelper new] findDetail:request_station_detail params:params progress:^(NSProgress *progress) {
    } success:^(NSMutableDictionary *responseDic) {
        StationModel *stationDetail = [StationModel yy_modelWithJSON:responseDic];
        StationInfoViewController *sVC = [[StationInfoViewController alloc] initWithCity:stationDetail.city lines:stationDetail.lineModels selectedLine:nil station:stationDetail];
        sVC.hidesBottomBarWhenPushed = YES;
        [wkSelf.navigationController pushViewController:sVC animated:YES];
    } failure:^(NSString *errorInfo) {
        
    }];
}

- (void)viewWillAppear:(BOOL)animated{
//    self.tabBarController.tabBar.hidden = YES;
    if(_addressCollectsView && _stationFor!=3) [_addressCollectsView reloadAddressData];
}
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
    _searchButton.alpha = 0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(searchStationsTap:)];
    _searchButton.userInteractionEnabled = YES;
    [_searchButton addGestureRecognizer:tap];
    _searchBarSearchingRect = CGRectMake(self.searchBar.x, self.searchBar.y, self.searchBar.width-view_margin-_searchButton.width, self.searchBar.height);
}


#pragma mark *** UITextFieldDelegate ***
// 获得焦点
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    _addressSearchView= [[AddressSearchView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT)];
    _addressSearchView.alpha = 0;
    [self.view addSubview:_addressSearchView];
    
    if(_searchButton) [self.naviMask addSubview:_searchButton];
    else {
        [self createAddressSearchButton];
        [self.naviMask addSubview:_searchButton];
    }
    
    [UIView animateWithDuration:.5f animations:^{
        self.addressSearchView.alpha = 1;
        self.searchBar.frame = self.searchBarSearchingRect;
        self.searchButton.alpha = 1;
    } completion:^(BOOL finished) {
    }];
    
    __weak typeof(self) wkSelf = self;
    [_addressSearchView setSelectedStation:^(StationModel *station, CityModel *city) {
        [wkSelf selectStation:station];
    }];
    
    return YES;
}
//
//-(void)textFieldDidChangeSelection:(UITextField *)textField{
//    NSLog(@"------>%@", textField.text);
//}
- (void)textFieldTextDidChange:(UITextField *)textField{
    if(textField.markedTextRange==nil) {
        if(textField.text.length>0) [self searchStations:textField.text];
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
    [_addressSearchView searchMap:keywords forStation:YES];
}


-(void)selectStation:(StationModel*)station{
    UIViewController *vc = self.navigationController.viewControllers[self.navigationController.viewControllers.count-2];
    if([vc isKindOfClass:[MainMapViewController class]]){
        MainMapViewController *mvc = (MainMapViewController*)vc;
        [mvc setDefaultStation:station forStart:_stationFor==1 forEnd:_stationFor==2];
        [self.navigationController popViewControllerAnimated:YES];
    }
}



- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    __weak typeof(self) wkSelf = self;
    // trait发生了改变
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            if(wkSelf.addressSearchView) [wkSelf.addressSearchView reloadData];
            if(wkSelf.addressCollectsView) [wkSelf.addressCollectsView reloadData];
        }
    } else {
    }
}
@end
