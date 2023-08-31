//
//  RHPhotoBrowser.h
//  MetroMap
//
//  Created by edwin on 2019/11/26.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PrefixHeader.h"

typedef NS_ENUM(NSUInteger, ImageSourceType) {
    
    ImageSourceTypeImage     = 0,
    ImageSourceTypeUrl       = 1,
    ImageSourceTypeFilePath  = 2,
    ImageSourceTypeFileName  = 3
};
@interface ImageBrowserHelper : NSObject

+ (ImageBrowserHelper *)shared;

- (void)browseImageWithType:(ImageSourceType)type imageArr:(NSArray *)imageArr selectIndex:(NSInteger)selectIndex pushByController:(UINavigationController*)controller;
@end
