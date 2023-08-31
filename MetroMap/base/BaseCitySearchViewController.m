//
//  BaseCItySearchViewController.m
//  MetroMap
//
//  Created by edwin on 2019/10/9.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "BaseCitySearchViewController.h"

@interface BaseCitySearchViewController ()<UITextFieldDelegate>

@property(nonatomic, retain) CityCollectionView *cityCollectionView;
@property(nonatomic, retain) CitySearchView *citySearchView;
@property(nonatomic, assign) CGRect searchBarInitRect;
@property(nonatomic, assign) CGRect searchBarSearchingRect;
@property(nonatomic, retain) NSMutableArray *viewList;

@end

@implementation BaseCitySearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.searchBar.delegate = self;
    self.viewList = [NSMutableArray new];
    [self.viewList addObject:self.view];
}

-(void)switchCityData{
    [self loadCityPickerButton];
    [self naviBackActionToRoot:YES];
    self.tabBarController.selectedIndex = 1;
}

-(void)cityPicker:(UITapGestureRecognizer*)tap {
    if(![self checkTapEnable]) return;
    _searchBarInitRect = self.searchBar.frame;
    _searchBarSearchingRect = CGRectMake(view_margin+28, self.searchBar.y, SCREEN_WIDTH-view_margin*2-28, self.searchBar.height);
    self.backButton.alpha = 0;
    [self.naviMask addSubview:self.backButton];
    
    _cityCollectionView = [[CityCollectionView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT)];
    _cityCollectionView.alpha = 0;
    [self.view addSubview:_cityCollectionView];
    [_cityCollectionView loadRemoteCityList];
    __weak typeof(self) wkSelf = self;
    [_cityCollectionView setReloadCityData:^(void) {
        [wkSelf switchCityData];
    }];
    
    [self.viewList addObject:_cityCollectionView];
    
    if(![self.tabBarController.tabBar isHidden]){
        [self.tabBarController.tabBar setHidden:YES];
    }
    [UIView animateWithDuration:.5f animations:^{
        self.searchBar.frame = self.searchBarSearchingRect;
        self.backButton.alpha = 1;
        self.cityCollectionView.alpha = 1;
        self.cityPickerButton.alpha = 0;
    } completion:^(BOOL finished) {
        [self.cityPickerButton removeFromSuperview];
        NSString *text = @"输入城市/站点名称";
        NSMutableAttributedString *fieldText = [[NSMutableAttributedString alloc] initWithString:text];
        [fieldText addAttribute:NSFontAttributeName value:sub_font_middle range:NSMakeRange(0, text.length)];
        [fieldText addAttribute:NSForegroundColorAttributeName value:dynamic_color_gray range:NSMakeRange(0, text.length)];
        [self.searchBar setAttributedPlaceholder:fieldText];
    }];
}

- (void)naviBack:(UITapGestureRecognizer*)tap {
    [self naviBackActionToRoot:NO];
}

-(void)naviBackActionToRoot:(BOOL)toRoot{
    [self.searchBar setText:@""];
    [self.searchBar endEditing:YES];
    if(self.view == _viewList.lastObject){
        return;
    }
    [_viewList removeLastObject];
    if(self.view == _viewList.lastObject || toRoot){
        NSString *text = @"搜索";
        NSMutableAttributedString *fieldText = [[NSMutableAttributedString alloc] initWithString:text];
        [fieldText addAttribute:NSFontAttributeName value:sub_font_middle range:NSMakeRange(0, text.length)];
        [fieldText addAttribute:NSForegroundColorAttributeName value:dynamic_color_gray range:NSMakeRange(0, text.length)];
        [self.searchBar setAttributedPlaceholder:fieldText];
        self.cityPickerButton.alpha = 0;
        [self.naviMask addSubview:self.cityPickerButton];
        
        if(self.mapTabbarHide != [self.tabBarController.tabBar isHidden]){
            [self switchMapTabBar:self.mapTabbarHide duration:.5f];
        }
        [self.cityCollectionView beforeDisappear];
        [UIView animateWithDuration:.5f animations:^{
            self.searchBar.frame = self.searchBarInitRect;
            self.backButton.alpha = 0;
            self.cityPickerButton.alpha = 1;
            if(self.cityCollectionView) self.cityCollectionView.alpha = 0;
            if(self.citySearchView) self.citySearchView.alpha = 0;
        } completion:^(BOOL finished) {
            [self.backButton removeFromSuperview];
            if(self.cityCollectionView) {
                [self.cityCollectionView removeFromSuperview];
                self.cityCollectionView = nil;
            }
            if(self.citySearchView) {
                [self.citySearchView removeFromSuperview];
                self.citySearchView = nil;
            }
            [self viewDidAppear:YES];
        }];
    }else{
        [UIView animateWithDuration:.5f animations:^{
            if(self.citySearchView) self.citySearchView.alpha = 0;
        } completion:^(BOOL finished) {
            if(self.citySearchView) {
                [self.citySearchView removeFromSuperview];
                self.citySearchView = nil;
            }
        }];
    }
}

#pragma mark *** UITextFieldDelegate ***
// 获得焦点
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if(![self checkTapEnable]) return NO;
    if(_citySearchView) return YES;
    _citySearchView= [[CitySearchView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT)];
    _citySearchView.alpha = 0;
    [self.view addSubview:_citySearchView];
    
    BOOL hideSelf = _viewList.lastObject == self.view;
    if(hideSelf){
        _searchBarInitRect = self.searchBar.frame;
        _searchBarSearchingRect = CGRectMake(view_margin+28, self.searchBar.y, SCREEN_WIDTH-view_margin*2-28, self.searchBar.height);
        self.backButton.alpha = 0;
        [self.naviMask addSubview:self.backButton];
    }
    
    [self.viewList addObject:_citySearchView];
    
    if(![self.tabBarController.tabBar isHidden]){
        [self.tabBarController.tabBar setHidden:YES];
    }
    [UIView animateWithDuration:.5f animations:^{
        self.citySearchView.alpha = 1;
        if(hideSelf){
            self.searchBar.frame = self.searchBarSearchingRect;
            self.backButton.alpha = 1;
            self.cityPickerButton.alpha = 0;
        }
    } completion:^(BOOL finished) {
        if(hideSelf){
            [self.cityPickerButton removeFromSuperview];
            NSString *text = @"输入城市/站点名称";
            NSMutableAttributedString *fieldText = [[NSMutableAttributedString alloc] initWithString:text];
            [fieldText addAttribute:NSFontAttributeName value:sub_font_middle range:NSMakeRange(0, text.length)];
            [fieldText addAttribute:NSForegroundColorAttributeName value:dynamic_color_gray range:NSMakeRange(0, text.length)];
            [self.searchBar setAttributedPlaceholder:fieldText];
        }
    }];
    
    
    __weak typeof(self) wkSelf = self;
    [_citySearchView setReloadCityData:^(void) {
        [wkSelf switchCityData];
    }];
    [_citySearchView setReloadCityDataWithStation:^(StationModel *station) {
        [wkSelf switchCityData];
        BaseCitySearchViewController *vc = wkSelf.tabBarController.viewControllers[1].childViewControllers[0];
        [vc setDefaultStation:station forStart:NO forEnd:NO];
    }];
    
    
    return YES;
}

-(void)setDefaultStation:(StationModel *)defaultStation forStart:(BOOL)start forEnd:(BOOL)end{
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    NSInteger cityId = [[[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_CITY_ID_KEY] integerValue];
    if(!cityId) cityId = 1;
    if(_cityId != cityId){
        [self loadCityPickerButton];
    }
}

// 失去焦点
- (void)textFieldDidEndEditing:(UITextField *)textField{
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField endEditing:YES];
    if(textField == self.searchBar){
        if(textField.text.length<1){
            [MBProgressHUD showInfo:@"未输入内容" detail:nil image:nil inView:nil];
        }else{
            [self.citySearchView searchCityAndStations:textField.text];
        }
        return NO;
    }
    return YES;
}

- (void)switchMapTabBar:(BOOL)hide duration:(float)duration{
    
}


-(BOOL)checkTapEnable{
    return YES;
}
@end
