//
//  WSLPhotoZoom.h
//  WSLPictureBrowser
//

#import <UIKit/UIKit.h>
#import "PrefixHeader.h"
//#import "UIImageView+GIF.h"

@interface WSLPhotoZoom : UIScrollView <UIScrollViewDelegate>

@property(nonatomic, copy) void(^updateScale)(float scale);

@property (nonatomic, strong) UIImageView * imageView;

@property (assign, nonatomic) CGFloat minScale;
@property (assign, nonatomic) CGFloat maxScale;

@property (assign, nonatomic) CGFloat curScale;
//@property (assign, nonatomic) CGFloat contentOffsetY;

//默认是屏幕的宽和高
@property (assign, nonatomic) CGFloat imageNormalWidth; // 图片未缩放时宽度
@property (assign, nonatomic) CGFloat imageNormalHeight; // 图片未缩放时高度

- (void)setImageNormalWidth:(CGFloat)imageNormalWidth imageNormalHeight:(CGFloat)imageNormalHeight;

//缩放方法，共外界调用
- (void)pictureZoomWithScale:(CGFloat)zoomScale point:(CGPoint)point;
-(void)setImageView:(UIImageView *)imageView withScale:(float)scale withMinScale:(float)minScale withMaxScale: (float)maxScale;

- (void)pictureZoomWithScale:(CGFloat)zoomScale;
-(void)setMinimunZoomScaleWithWidth:(CGFloat)width frameSize:(CGSize)frameSize imageSize:(CGSize)imageSize;

@end
