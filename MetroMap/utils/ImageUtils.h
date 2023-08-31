//
//  ImageUtils.h
//  pet-photo
//
//  Created by edwin on 2019/7/4.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ImageUtils : NSObject

+ (UIImage *)fixOrientation:(UIImage *)aImage;
+(UIImage *) getImageFromURL:(NSString *)fileURL;
+(CGSize)getImageSizeWithURL:(id)imageURL;
+(CGSize)getPNGImageSizeWithRequest:(NSMutableURLRequest*)request;
+(CGSize)getGIFImageSizeWithRequest:(NSMutableURLRequest*)request;
+(CGSize)getJPGImageSizeWithRequest:(NSMutableURLRequest*)request;

+ (NSData *)compressQualityWithImage:(UIImage*)image maxLength:(NSInteger)maxLength;

@end

