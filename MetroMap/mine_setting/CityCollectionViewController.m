//
//  CityCollectionViewController.m
//  MetroMap
//
//  Created by edwin on 2019/10/29.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "CityCollectionViewController.h"

@interface CityCollectionViewController ()
@property(nonatomic, retain) CityCollectionView *cityCollectionView;

@end

@implementation CityCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.naviMask];
    [self.naviMask addSubview:self.backButton];
    
    _cityCollectionView = [[CityCollectionView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT)];
    _cityCollectionView.withoutHeader = YES;
    if(_type==2) _cityCollectionView.onlyLocal = YES;
    self.view.backgroundColor = dynamic_color_white;
    [self.view addSubview:_cityCollectionView];
    [_cityCollectionView loadRemoteCityList];
    __weak typeof(self) wkSelf = self;
    [_cityCollectionView setReloadCityData:^(void) {
        [wkSelf loadCityPickerButton];
        wkSelf.tabBarController.selectedIndex = 1;
        [wkSelf.navigationController popToRootViewControllerAnimated:YES];
    }];
}


//- (void)viewWillAppear:(BOOL)animated{
//    self.tabBarController.tabBar.hidden = YES;
//}
//
//- (void)viewWillDisappear:(BOOL)animated{
//  self.tabBarController.tabBar.hidden = NO;
//}
@end
