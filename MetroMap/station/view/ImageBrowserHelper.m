//
//  RHPhotoBrowser.m
//  MetroMap
//
//  Created by edwin on 2019/11/26.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "ImageBrowserHelper.h"
#import "ImageBrowserController.h"

@implementation ImageBrowserHelper

+ (ImageBrowserHelper *)shared {
    
    static ImageBrowserHelper * helper = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        helper = [[ImageBrowserHelper alloc] init];
    });
    return helper;
}

- (void)browseImageWithType:(ImageSourceType)type imageArr:(NSArray *)imageArr selectIndex:(NSInteger)selectIndex pushByController:(UINavigationController*)controller{
    
    if (selectIndex > imageArr.count - 1) {
        
        selectIndex = 0;
    }
//    UIViewController * rootVC = [UIApplication sharedApplication].delegate.window.rootViewController;
    ImageBrowserController * browser = [[ImageBrowserController alloc] initWithType:type imageArr:imageArr selectIndex:selectIndex];
//    browser.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    browser.modalPresentationStyle = UIModalPresentationFullScreen;
//  [rootVC.navigationController presentViewController:browser animated:YES completion:nil];
    [controller pushViewController:browser animated:YES];
}
@end
