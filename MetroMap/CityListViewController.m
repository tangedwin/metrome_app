//
//  StationDetailViewController.m
//  MetroMap
//
//  Created by edwin on 2019/6/24.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "CityListViewController.h"

@implementation CityListViewController

-(void) viewDidLoad{
    [super viewDidLoad];
    _viewSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height);
    if(_viewSize.height>_viewSize.width){
        //竖屏
        _navBarHeight = kNavBarAndStatusBarHeight;
    }else{
        _navBarHeight = kNavBarHeight;
    }
    
    //背景图
    UIView *barBackground = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _viewSize.width, _navBarHeight)];
    [barBackground setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:barBackground];
    
    //展示城市列表菜单
    if(![_data checkCities]) return;
    CGRect menuFrame = CGRectMake(0, _navBarHeight, _viewSize.width, _viewSize.height-_navBarHeight);
    _cityMenu = [[FMenuAlert alloc] initWithFrame:menuFrame withType:11 withMaxHeight:menuFrame.size.height];
    
    [_cityMenu setArrMDataSource:_data.cities];
    
    __weak typeof (self) wkSelf = self;
    [_cityMenu setDidSelectedCallback:^(NSInteger index, NSObject *content) {
        //切换城市
        CityInfo *cinfo = wkSelf.data.cities[index];
        ViewController *mainView= [wkSelf.navigationController.viewControllers objectAtIndex:wkSelf.navigationController.viewControllers.count-2];
        [mainView setCityInfo:cinfo];
        [wkSelf.navigationController popToViewController:mainView animated:YES];
    }];
    [_cityMenu setPreviewMap:^(NSInteger index, NSString *pdfName) {
        //预览
        CityInfo *cinfo = wkSelf.data.cities[index];
        PreviewController *previewController = [[PreviewController alloc] init];
        [previewController setCinfo:cinfo];
        previewController.hidesBottomBarWhenPushed = YES;
        [wkSelf.navigationController pushViewController:previewController animated:YES];
    }];
    [self.view addSubview:_cityMenu];
    
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didChangeRotate:) name:UIApplicationDidChangeStatusBarFrameNotification object:nil];
    
}
    
- (void)didChangeRotate:(NSNotification*)notice {
    if ([[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortrait
        || [[UIDevice currentDevice] orientation] == UIInterfaceOrientationPortraitUpsideDown) {
        //竖屏
    } else {
        //横屏
    }
}
    
    
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    // 延时一下 获得的高度才正确，要不然是转屏前的宽高
    __weak typeof(self) wkSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [wkSelf reloadView:size];
    });
}
    
-(void)reloadView:(CGSize)size{
    self.viewSize = size;
    if(size.height>size.width){
        //竖屏
        self.navBarHeight = kNavBarAndStatusBarHeight;
    }else{
        self.navBarHeight = kNavBarHeight;
    }
    
    if(_cityMenu!=nil){
        [_cityMenu removeFromSuperview];
        _cityMenu = nil;
    }
    
    //展示城市列表菜单
    if(![_data checkCities]) return;
    CGRect menuFrame = CGRectMake(0, _navBarHeight, _viewSize.width, _viewSize.height-_navBarHeight);
    _cityMenu = [[FMenuAlert alloc] initWithFrame:menuFrame withType:11 withMaxHeight:menuFrame.size.height];
    
    [_cityMenu setArrMDataSource:_data.cities];
    
    __weak typeof (self) wkSelf = self;
    [_cityMenu setDidSelectedCallback:^(NSInteger index, NSObject *content) {
        //切换城市
        CityInfo *cinfo = wkSelf.data.cities[index];
        ViewController *mainView= [wkSelf.navigationController.viewControllers objectAtIndex:wkSelf.navigationController.viewControllers.count-2];
        [mainView setCityInfo:cinfo];
        [wkSelf.navigationController popToViewController:mainView animated:YES];
    }];
    [_cityMenu setPreviewMap:^(NSInteger index, NSString *pdfName) {
        //预览
        CityInfo *cinfo = wkSelf.data.cities[index];
        PreviewController *previewController = [[PreviewController alloc] init];
        [previewController setCinfo:cinfo];
        previewController.hidesBottomBarWhenPushed = YES;
        [wkSelf.navigationController pushViewController:previewController animated:YES];
    }];
    [self.view addSubview:_cityMenu];
}

@end
