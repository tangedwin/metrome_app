//
//  MineViewController.m
//  MetroMap
//
//  Created by edwin on 2019/10/8.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "MineViewController.h"

@interface MineViewController ()<MineSettingViewDeleaget>

@property(nonatomic, retain) MineSettingView *mineSettingView;
@property(nonatomic, assign) NSInteger messageCount;

@end

@implementation MineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = dynamic_color_white;
    [self addMineCollectionView];
    [self.view addSubview:self.messageButton];
    [self.view addSubview:self.settingButton];
    [self queryNotificationCount];
}

-(void)addMineCollectionView{
    _mineSettingView = [[MineSettingView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-[self mTabbarHeight])];
    _mineSettingView.viewDelegate = self;
    [self.view addSubview:_mineSettingView];
    
    __weak typeof(self) wkSelf = self;
    [_mineSettingView setEditCommenAddress:^(NSMutableArray *addressArray) {
        CommenAddressViewController *caVC = [[CommenAddressViewController alloc] initWithAddressArray:addressArray];
        caVC.hidesBottomBarWhenPushed = YES;
        [wkSelf.navigationController pushViewController:caVC animated:YES];
    }];
}

-(void)showSettingView:(UITapGestureRecognizer*)tap{
    UserSettingViewController *userSettingViewController = [UserSettingViewController new];
    userSettingViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:userSettingViewController animated:YES];
}

-(void)pushViewController:(BaseViewController *)vc animated:(BOOL)animated{
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)showMessageView:(UITapGestureRecognizer*)tap {
    MessageViewController *messageViewController = [MessageViewController new];
    messageViewController.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:messageViewController animated:YES];
}


-(void)queryNotificationCount{
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSString *registerId = [[NSUserDefaults standardUserDefaults] objectForKey:USER_MESSAGE_REGISTER_ID_KEY];
    if(registerId) [params setObject:registerId forKey:@"registerId"];
    __weak typeof(self) wkSelf = self;
    [[HttpHelper new] findDetail:request_message_count params:params progress:^(NSProgress *progress) {
        
    } success:^(NSMutableDictionary *responseDic) {
        if(responseDic && [responseDic isKindOfClass:[NSNumber class]]){
            NSNumber *num = (NSNumber*)responseDic;
            wkSelf.messageCount = [num integerValue];
            if(wkSelf.messageButton){
                [wkSelf.messageButton removeFromSuperview];
                [wkSelf reloadMessageButton:wkSelf.messageCount];
                [wkSelf.view addSubview:wkSelf.messageButton];
            }
        }
    } failure:^(NSString *errorInfo) {
        
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [self queryNotificationCount];
    if(_mineSettingView) {
        [_mineSettingView reloadAddressData];
        [_mineSettingView reloadUserData];
    }
}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    __weak typeof(self) wkSelf = self;
    // trait发生了改变
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            if(wkSelf.mineSettingView) [wkSelf.mineSettingView reloadData];
        }
    } else {
    }
}
@end
