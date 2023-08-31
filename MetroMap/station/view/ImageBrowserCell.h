//
//  ImageBrowserCell.h
//  MetroMap
//
//  Created by edwin on 2019/11/26.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PrefixHeader.h"
#import "YYWebImage.h"
#import "HttpHelper.h"

@interface ImageBrowserCell : UICollectionViewCell

-(void)configCellWithImage:(UIImage*)image;
-(void)configCellWithUrl:(NSString*)imageUrl;
-(void)configCellWithFilePath:(NSString*)filePath;
-(void)configCellWithFileName:(NSString*)fileName;
@end

