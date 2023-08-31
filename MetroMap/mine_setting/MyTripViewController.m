//
//  MyTripViewController.m
//  MetroMap
//
//  Created by edwin on 2019/10/9.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "MyTripViewController.h"

@interface MyTripViewController ()
@property (nonatomic, retain) TripCollectionView *tripCollectionView;
@end

@implementation MyTripViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addTripCollectionView];
    [self.view addSubview:self.naviMask];
    [self.naviMask addSubview:self.backButton];
    self.view.backgroundColor = dynamic_color_white;
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, STATUS_BAR_HEIGHT+10, 200, 25)];
    title.font = main_font_big;
    title.textColor = dynamic_color_black;
    title.text = @"我的行程";
    title.textAlignment = NSTextAlignmentCenter;
    [self.naviMask addSubview:title];
}

-(void)addTripCollectionView{
    _tripCollectionView = [[TripCollectionView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT)];
    [self.view addSubview:_tripCollectionView];
}
//- (void)viewWillAppear:(BOOL)animated{
//    self.tabBarController.tabBar.hidden = YES;
//}
//
//- (void)viewWillDisappear:(BOOL)animated{
//  self.tabBarController.tabBar.hidden = NO;
//}

@end
