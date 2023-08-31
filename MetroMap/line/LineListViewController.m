//
//  LineListViewController.m
//  MetroMap
//
//  Created by edwin on 2019/10/22.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "LineListViewController.h"

@interface LineListViewController ()

@property(nonatomic, retain) LinesCollectionView *linesCollectionView;
@property(nonatomic, retain) LineNameCollectionView *lineNameCollectionView;
@end

@implementation LineListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.naviMask];
    [self.naviMask addSubview:self.backButton];
    
    NSString *text = @"线路列表";
    CGSize titleSize = [text sizeWithAttributes:@{NSFontAttributeName:main_font_big}];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(48, STATUS_BAR_HEIGHT+(NAVIGATION_BAR_HEIGHT-ceil(titleSize.height))/2, SCREEN_WIDTH-48*2, ceil(titleSize.height))];
    title.textColor = dynamic_color_black;
    title.font = main_font_big;
    title.textAlignment = NSTextAlignmentCenter;
    title.text = text;
    [self.naviMask addSubview:title];
    
    
    
    NSInteger cityId = [[[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_CITY_ID_KEY] integerValue];
    if(!cityId) cityId = 1;
    CityModel *city = [CityZipUtils parseFileToCityModel:cityId];
    NSMutableArray *lines = city?city.lines:[NSMutableArray new];
    
    
    _lineNameCollectionView = [[LineNameCollectionView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT, SCREEN_WIDTH, 49) lines:lines];
    [self.view addSubview:_lineNameCollectionView];
    
    _linesCollectionView= [[LinesCollectionView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT+49, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT-49) city:city lines:lines];
    [self.view addSubview:_linesCollectionView];
    
    __weak typeof(self) wkSelf = self;
    [_lineNameCollectionView setSelectLine:^(NSInteger index) {
        [wkSelf.linesCollectionView selectLine:index];
    }];
    [_linesCollectionView setSelectLine:^(NSInteger index) {
        [wkSelf.lineNameCollectionView selectLine:index];
    }];
    [_linesCollectionView setShowStationInfo:^(CityModel *city, LineModel *line, StationModel *station) {
        [wkSelf showStationWithDetailInfo:station city:city line:line];
    }];
}


-(void)showStationWithDetailInfo:(StationModel*)station city:(CityModel*)city line:(LineModel*)line{
    StationInfoViewController *stationVC = [[StationInfoViewController alloc] initWithCity:city lines:nil selectedLine:line station:station];
    stationVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:stationVC animated:YES];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    __weak typeof(self) wkSelf = self;
    // trait发生了改变
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            if(wkSelf.linesCollectionView) [wkSelf.linesCollectionView reloadData];
        }
    } else {
    }
}
@end
