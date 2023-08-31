//
//  MessageViewController.m
//  MetroMap
//
//  Created by edwin on 2019/10/30.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "MessageViewController.h"

@interface MessageViewController ()
@property (nonatomic, retain) MessageCollectionView *mcView;

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:dynamic_color_white];
    [self.view addSubview:self.naviMask];
    [self.naviMask addSubview:self.backButton];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, STATUS_BAR_HEIGHT+10, 200, 25)];
    title.font = main_font_big;
    title.textColor = dynamic_color_black;
    title.text = @"消息中心";
    title.textAlignment = NSTextAlignmentCenter;
    [self.naviMask addSubview:title];
    
    _mcView = [[MessageCollectionView alloc] initWithFrame:CGRectMake(0, STATUS_BAR_HEIGHT+NAVIGATION_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-STATUS_BAR_HEIGHT-NAVIGATION_BAR_HEIGHT)];
    __weak typeof(self) wkSelf = self;
    [_mcView setShowMessageDetail:^(MessageModel *message) {
        MessageDetailViewController *mdVC = [[MessageDetailViewController alloc] initWithMessage:message];
        mdVC.hidesBottomBarWhenPushed = YES;
        [wkSelf.navigationController pushViewController:mdVC animated:YES];
    }];
    [self.view addSubview:_mcView];
}

- (void)viewWillAppear:(BOOL)animated{
//    self.tabBarController.tabBar.hidden = YES;
    if(_mcView) [_mcView reloadData];
}

//- (void)viewWillDisappear:(BOOL)animated{
//  self.tabBarController.tabBar.hidden = NO;
//}

@end
