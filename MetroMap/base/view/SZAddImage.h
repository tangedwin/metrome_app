//
//  SZAddImage.h
//  pet-photo
//
//  Created by edwin on 2019/7/13.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>
#import "BaseUtils.h"
#import "PrefixHeader.h"
#import "ImageUtils.h"
#import "HttpHelper.h"

#import "AlertUtils.h"
#import "MBProgressHUD+Customer.h"

@interface SZAddImage : UIScrollView

/**
 *  存储所有的照片(UIImage)
 */
@property (nonatomic, strong) NSMutableArray *tempImages;
@property (nonatomic, strong) NSMutableArray *imageInfos;

@property (nonatomic, strong) NSString *uploadUrl;

-(void)uploadImage:(NSMutableDictionary *)imageInfo image:(UIImage*)image block:(void(^)(BOOL success))block;

@end
