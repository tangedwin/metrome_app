//
//  UserSettingViewController.m
//  MetroMap
//
//  Created by edwin on 2019/10/8.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "UserSettingViewController.h"

@interface UserSettingViewController ()<UserSettingViewDeleaget>

@property(nonatomic, retain) UserSettingView *userSettingView;

@end

@implementation UserSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self addUserSettingCollectionView];
    [self.view addSubview:self.naviMask];
    [self.naviMask addSubview:self.backButton];
    self.view.backgroundColor = dynamic_color_white;
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, STATUS_BAR_HEIGHT+10, 200, 25)];
    title.font = main_font_big;
    title.textColor = dynamic_color_black;
    title.text = @"设置";
    title.textAlignment = NSTextAlignmentCenter;
    [self.naviMask addSubview:title];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadSettingData) name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

-(void)addUserSettingCollectionView{
    _userSettingView = [[UserSettingView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT)];
    [self.view addSubview:_userSettingView];
    _userSettingView.viewDelegate = self;
}

-(void)reloadSettingData{
    if(_userSettingView) [_userSettingView reloadSettingData];
}

- (void)viewWillAppear:(BOOL)animated{
//    self.tabBarController.tabBar.hidden = YES;
    [self reloadSettingData];
}

//- (void)viewWillDisappear:(BOOL)animated{
//  self.tabBarController.tabBar.hidden = NO;
//}

-(void)pushViewController:(BaseViewController *)vc animated:(BOOL)animated{
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}



- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    __weak typeof(self) wkSelf = self;
    // trait发生了改变
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            if(wkSelf.userSettingView) [wkSelf.userSettingView reloadData];
        }
    } else {
    }
}
@end
