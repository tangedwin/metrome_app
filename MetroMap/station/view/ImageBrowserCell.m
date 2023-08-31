//
//  ImageBrowserCell.m
//  MetroMap
//
//  Created by edwin on 2019/11/26.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "ImageBrowserCell.h"
#import "WSLPhotoZoom.h"

@interface ImageBrowserCell()

@property (nonatomic, retain) WSLPhotoZoom *photoZoomView;
@property (nonatomic, retain) UIImageView *imgView;

@end

@implementation ImageBrowserCell

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    _imgView = [[UIImageView alloc] init];
    return self;
}

-(void)configCellWithImage:(UIImage*)image{
    
}
-(void)configCellWithUrl:(NSString*)imageUrl{
    _photoZoomView = [[WSLPhotoZoom alloc] initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    [self.contentView addSubview:_photoZoomView];
    __weak typeof(self) wkSelf = self;
    imageUrl = [NSString stringWithFormat:@"%@%@%@",Base_URL,request_image,imageUrl];
    imageUrl = [imageUrl stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    imageUrl = [imageUrl stringByReplacingOccurrencesOfString:@"%5C" withString:@""];
    [_imgView yy_setImageWithURL:[NSURL URLWithString:imageUrl]
    placeholder:nil
     options: YYWebImageOptionShowNetworkActivity
    progress:^(NSInteger receivedSize, NSInteger expectedSize) {
    }
    transform:^UIImage *(UIImage *image, NSURL *url) {
         return image;
    }
    completion:^(UIImage *image, NSURL *url, YYWebImageFromType from, YYWebImageStage stage, NSError *error) {
        if (from == YYWebImageFromDiskCache) {
            NSLog(@"load from disk cache");
        }
        if(!NSThread.currentThread.isMainThread){
            dispatch_async(dispatch_get_main_queue(), ^{
                [wkSelf loadImageInZoomView:image.size.width height:image.size.height];
            });
        }else{
            [wkSelf loadImageInZoomView:image.size.width height:image.size.height];
        }
    }];
}
-(void)configCellWithFilePath:(NSString*)filePath{
    
}
-(void)configCellWithFileName:(NSString*)fileName{
    
}


-(void)loadImageInZoomView:(CGFloat)width height:(CGFloat)height{
    float minScale = _photoZoomView.width/width<_photoZoomView.height/height?_photoZoomView.width/width:_photoZoomView.height/height;
    _imgView.frame = CGRectMake((_photoZoomView.width-width*minScale)/2, (_photoZoomView.height-height*minScale)/2, width, height);
    _photoZoomView.imageNormalWidth = CGRectGetWidth(_imgView.frame);
    _photoZoomView.imageNormalHeight = CGRectGetHeight(_imgView.frame);
    [_photoZoomView setImageView:_imgView withScale:minScale withMinScale:minScale withMaxScale:(minScale>1?minScale:1)*1.5];
}
@end
