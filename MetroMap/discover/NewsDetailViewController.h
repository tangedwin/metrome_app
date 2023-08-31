//
//  NewsDetailViewController.h
//  MetroMap
//
//  Created by edwin on 2019/10/26.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "BaseViewController.h"
#import "NewsModel.h"
#import "HttpHelper.h"

@interface NewsDetailViewController : BaseViewController

-(void)loadNewsInfo:(NewsModel*)news;

@end
