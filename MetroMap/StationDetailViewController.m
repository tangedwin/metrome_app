//
//  StationDetailViewController.m
//  MetroMap
//
//  Created by edwin on 2019/6/24.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "StationDetailViewController.h"

@implementation StationDetailViewController

-(void) viewDidLoad{
    [super viewDidLoad];
    
    self.title = _sinfo.stationName;
    _viewSize = self.view.frame.size;
    if(_viewSize.height>_viewSize.width){
        //竖屏
        _navBarHeight = kNavBarAndStatusBarHeight;
    }else{
        _navBarHeight = kNavBarHeight;
    }
    
    CGRect frame = CGRectMake(0, _navBarHeight, _viewSize.width, _viewSize.height-_navBarHeight);
    _stationInfoView = [[FMenuAlert alloc] initWithFrame:frame withType:3 withMaxHeight:0];
    
    
    RouteUtils *rutils = [RouteUtils new];
    NSDictionary *stationTimes = [rutils queryStationTime:_data.metroInfo.baiduUid withStationUid:[_sinfo.baiduUids allKeys].firstObject];
    NSMutableDictionary *lineUids = [NSMutableDictionary new];
    for(MetroLineInfo *line in _data.metroInfo.lines){
        [lineUids addEntriesFromDictionary:line.baiduUids];
    }
    
    _lineStationTimes = [NSMutableDictionary new];
    NSArray *stationLineUids = [stationTimes allKeys];
    for(NSString *lineUid in stationLineUids){
        //单个方向的时间
        NSMutableDictionary *dicTime = [stationTimes objectForKey:lineUid];
        NSString *lineName = [dicTime objectForKey:@"lineName"];
        //单条线路的时间
        NSMutableDictionary *lineTimes = [_lineStationTimes objectForKey:lineName];
        if(lineTimes==nil){
            lineTimes = [NSMutableDictionary new];
            [lineTimes setObject:[NSMutableArray new] forKey:@"times"];
            [_lineStationTimes setObject:lineTimes forKey:lineName];
        }
        
        for(MetroLineInfo *line in _data.metroInfo.lines){
            if([line.baiduUids objectForKey:lineUid]!=nil){
                [dicTime setObject:[line.baiduUids objectForKey:lineUid] forKey:@"directionName"];
                [lineTimes setObject:line forKey:@"line"];
            }
        }
        NSMutableArray *array = [lineTimes objectForKey:@"times"];
        [array addObject:dicTime];
        [lineTimes setObject:array forKey:@"times"];
    }
    [_stationInfoView setArrMDataSource:[[NSMutableArray alloc] initWithArray: _lineStationTimes.allValues]];
    
    [self.view addSubview:_stationInfoView];
    
    
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
    
    if(_stationInfoView!=nil){
        [_stationInfoView removeFromSuperview];
        _stationInfoView = nil;
    }
    
    CGRect frame = CGRectMake(0, _navBarHeight, _viewSize.width, _viewSize.height-_navBarHeight);
    _stationInfoView = [[FMenuAlert alloc] initWithFrame:frame withType:3 withMaxHeight:0];
    
    [_stationInfoView setArrMDataSource:[[NSMutableArray alloc] initWithArray: _lineStationTimes.allValues]];
    
    [self.view addSubview:_stationInfoView];
}

    
@end
