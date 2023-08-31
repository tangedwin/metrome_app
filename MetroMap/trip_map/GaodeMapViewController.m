//
//  GaodeMapViewController.m
//  MetroMap
//
//  Created by edwin on 2019/10/24.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "GaodeMapViewController.h"

@interface GaodeMapViewController ()
@property(nonatomic, retain) StationModel *station;

@property(nonatomic, retain) MAMapView *maMapView;
@end

@implementation GaodeMapViewController

-(instancetype)initWithStation:(StationModel*)station{
    self = [super init];
    _station = station;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:dynamic_color_white];
    [self.view addSubview:self.naviMask];
    [self.naviMask addSubview:self.backButton];
    [self createGaodeMap:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT)];
}

//- (void)viewWillAppear:(BOOL)animated{
//    self.tabBarController.tabBar.hidden = YES;
//}
//
//- (void)viewWillDisappear:(BOOL)animated{
//  self.tabBarController.tabBar.hidden = NO;
//}

-(void)createGaodeMap:(CGRect)frame{
    [AMapServices sharedServices].enableHTTPS = YES;
    _maMapView = [[MAMapView alloc] initWithFrame:frame];
    [_maMapView setShowsScale:NO];
    [_maMapView setShowsCompass:NO];

    NSInteger cityId = [[[NSUserDefaults standardUserDefaults] objectForKey:SELECTED_CITY_ID_KEY] integerValue];
    if(!cityId) cityId = 1;
    CityModel *city = [CityZipUtils parseFileToCityModel:cityId];
    
    if(_station && _station.latitude>0 && _station.longitude>0){
        [_maMapView setZoomLevel:17];
        [_maMapView setCenterCoordinate:CLLocationCoordinate2DMake(_station.latitude, _station.longitude)];
    }else{
        [_maMapView setZoomLevel:12];
        if(city && city.longitude>0 && city.latitude>0) [_maMapView setCenterCoordinate:CLLocationCoordinate2DMake(city.latitude, city.longitude)];
        else [_maMapView setCenterCoordinate:CLLocationCoordinate2DMake(39.9086334, 116.397421)];
    }
    
    [_maMapView setAllowsBackgroundLocationUpdates:NO];
    [_maMapView setRotateEnabled:NO];
    [_maMapView setRotateCameraEnabled:NO];
    _maMapView.showsUserLocation = YES;
    NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"gaode_map_light_style" ofType:@"data"];
    if (@available(iOS 13.0, *)) {
        if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
            urlStr = [[NSBundle mainBundle] pathForResource:@"gaode_map_dark_style" ofType:@"data"];
        }
    }
    NSData *data = [NSData dataWithContentsOfFile:urlStr];
    [_maMapView setCustomMapStyleEnabled:YES];
    MAMapCustomStyleOptions *options = [[MAMapCustomStyleOptions alloc] init];
    options.styleData = data;
    [_maMapView setCustomMapStyleOptions:options];
    [self.view addSubview:_maMapView];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    __weak typeof(self) wkSelf = self;
    // trait发生了改变
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            if(wkSelf.maMapView){
                NSString *urlStr = [[NSBundle mainBundle] pathForResource:@"gaode_map_light_style" ofType:@"data"];
                if (@available(iOS 13.0, *)) {
                    if(UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark){
                        urlStr = [[NSBundle mainBundle] pathForResource:@"gaode_map_dark_style" ofType:@"data"];
                    }
                }
                NSData *data = [NSData dataWithContentsOfFile:urlStr];
                [wkSelf.maMapView setCustomMapStyleEnabled:YES];
                MAMapCustomStyleOptions *options = [[MAMapCustomStyleOptions alloc] init];
                options.styleData = data;
                [wkSelf.maMapView setCustomMapStyleOptions:options];
            }
        }
    } else {
    }
}
@end
