//
//  ViewController.h
//  MetroMap
//
//  Created by edwin on 2019/6/22.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScreenSize.h"
#import "MetroData.h"
#import "FMenuAlert.h"
#import "CustomerView.h"
#import "PreviewController.h"
#import "StationDetailViewController.h"
#import "CityListViewController.h"
#import "ColorUtils.h"
#import "BaseUtils.h"
#import "LXPositionView.h"
#import "MBProgressHUD.h"
#import "CityInfo.h"


@interface ViewController : UIViewController

@property(nonatomic,retain)MetroData *data;
@property(nonatomic,retain)MetroData *prevData;
@property(nonatomic,retain)CityInfo *cityInfo;

//导航栏控件
@property(nonatomic,retain)UIBarButtonItem *barBtnLeft;
@property(nonatomic,retain)UIBarButtonItem *barBtnRight;
@property(nonatomic,retain)UISearchBar *searchBar;
@property(nonatomic,retain)UIView *barBackground;

//view控件
@property(nonatomic,retain)UIImage *mainImage;
@property(nonatomic,retain)UIImageView *mainImageView;
@property(nonatomic,retain)SVGKLayeredImageView *svgImageView;

@property(nonatomic,retain)UIScrollView *scrollView;
//@property(nonatomic,retain)FMenuAlert *cityMenu;
@property(nonatomic,retain)FMenuAlert *stationMenu;
@property(nonatomic,retain)UIView *stationInfoView;
@property(nonatomic,retain)UIVisualEffectView *routeInfoView;
//开始结束站点标记
@property(nonatomic,retain)UIImageView *startStationSign;
@property(nonatomic,retain)UIImageView *endStationSign;
@property(nonatomic,retain)UIImageView *stationSign;
//线路查询站点标记
@property(nonatomic,retain)NSMutableArray<UIView*> *stationSignArray;

//控件size
@property(nonatomic,assign)CGSize viewSize;
@property(nonatomic,assign)CGSize mainImageSize;
@property(nonatomic,assign)CGSize scrollSize;

@property (nonatomic, retain) MBProgressHUD *progressHUD;

//图片缩放比例
@property(nonatomic,assign)float curScale;
@property(nonatomic,assign)CGPoint stationInfoOffset;
@property(nonatomic)BOOL zoomOut_In;


//@property(nonatomic)BOOL cityMenuShowing;
@property(nonatomic)BOOL stationMenuShowing;
//显示站点
@property(nonatomic)BOOL stationInfoShowing;
@property(nonatomic)BOOL stationDetailShowing;
//显示路线0没有查询路线，不展示；1展示；2查询路线但不展示
@property(nonatomic)int routeDetailStatus;
    
@property(nonatomic,assign)float navBarHeight;

@end

