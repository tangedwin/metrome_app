//
//  StationDetailViewController.h
//  MetroMap
//
//  Created by edwin on 2019/6/24.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FMenuAlert.h"
#import "ScreenSize.h"
#import "MetroData.h"
#import "ViewController.h"
#import "PreviewController.h"


@interface CityListViewController : UIViewController
    
@property(nonatomic,retain)MetroData *data;
@property(nonatomic,retain)MetroData *prevData;
@property(nonatomic,retain)FMenuAlert* cityMenu;
    
@property(nonatomic,assign)CGSize viewSize;
@property(nonatomic,assign)float navBarHeight;

@end
