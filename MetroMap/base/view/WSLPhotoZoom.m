//
//  WSLPhotoZoom.m
//  WSLPictureBrowser
//

#import "WSLPhotoZoom.h"

@implementation WSLPhotoZoom

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.delegate = self;
        self.minimumZoomScale = 1.0f;
        self.maximumZoomScale = 2.0f;
        _imageNormalHeight = frame.size.height;
        _imageNormalWidth = frame.size.width;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior =  UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
        
    }
    return self;
}

-(void)setImageView:(UIImageView *)imageView withScale:(float)scale withMinScale:(float)minScale withMaxScale: (float)maxScale{
    _imageView = imageView;
    _curScale = scale;
//    self.imageView.contentMode = UIViewContentModeScaleToFill;
    self.minimumZoomScale = minScale;
    self.maximumZoomScale = maxScale;
    self.imageView.userInteractionEnabled = YES;
    self.imageView.clipsToBounds = YES;
    [self addSubview:self.imageView];
    self.zoomScale = _curScale;
}

- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
}

-(void)setMinimunZoomScaleWithWidth:(CGFloat)width frameSize:(CGSize)frameSize imageSize:(CGSize)imageSize{
    //计算图片详情页的图片尺寸
    float imgWidth = imageSize.width;
    float imgHeight = imageSize.height;
    if(imgWidth<=0 && imgHeight>0) imgWidth = imgHeight;
    else if(imgWidth>0 && imgHeight<=0) imgHeight = imgWidth;
    
    float rate = frameSize.width/imgWidth<frameSize.height/imgHeight ? frameSize.width/imgWidth : frameSize.height/imgHeight;
    imgWidth = imgWidth * rate;
    self.minimumZoomScale = imgWidth/width;
}

- (void)pictureZoomWithScale:(CGFloat)zoomScale{
    // 延中心点缩放
    CGFloat imageScaleWidth = self.imageNormalWidth*_curScale;
    CGFloat imageScaleHeight = self.imageNormalHeight*_curScale;
    CGPoint point = CGPointMake(imageScaleWidth/2, imageScaleHeight/2);
    [self pictureZoomWithScale:zoomScale point:point];
}

- (void)pictureZoomWithScale:(CGFloat)zoomScale point:(CGPoint)point{
    point = CGPointMake(point.x/_curScale*zoomScale, point.y/_curScale*zoomScale);
    // 延中心点缩放
    CGFloat imageScaleWidth = zoomScale * self.imageNormalWidth;
    CGFloat imageScaleHeight = zoomScale * self.imageNormalHeight;
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    CGFloat offsetX = point.x-self.frame.size.width/2;
    CGFloat offsetY = point.y-self.frame.size.height/2;
    offsetX = offsetX<0 ? 0 : offsetX;
    offsetY = offsetY<0 ? 0 : offsetY;
    offsetX = imageScaleWidth-offsetX<self.frame.size.width ? imageScaleWidth-self.frame.size.width : offsetX;
    offsetY = imageScaleHeight-offsetY<self.frame.size.height ? imageScaleHeight-self.frame.size.height : offsetY;
    
    if (imageScaleWidth < self.frame.size.width) {
        imageX = floorf((self.frame.size.width - imageScaleWidth) / 2.0);
        offsetX = 0;
    }
    if (imageScaleHeight < self.frame.size.height) {
        imageY = floorf((self.frame.size.height - imageScaleHeight) / 2.0);
        offsetY = 0;
    }
    
    __weak typeof(self) wkSelf = self;
    [UIView animateWithDuration:0.5 delay:0 options:0 animations:^{
        if(wkSelf.updateScale){
            wkSelf.updateScale(zoomScale);
        }
        self.imageView.frame = CGRectMake(imageX, imageY, imageScaleWidth, imageScaleHeight);
        self.contentSize = CGSizeMake(imageScaleWidth,imageScaleHeight);
        self.contentOffset = CGPointMake(offsetX, offsetY);
    } completion:^(BOOL finished) {
        wkSelf.curScale = zoomScale;
    }];
}



#pragma mark -- Setter

- (void)setImageNormalWidth:(CGFloat)imageNormalWidth{
    _imageNormalWidth = imageNormalWidth;
    self.imageView.frame = CGRectMake(0, 0, _imageNormalWidth, _imageNormalHeight);
    self.imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}

- (void)setImageNormalHeight:(CGFloat)imageNormalHeight{
    _imageNormalHeight = imageNormalHeight;
    self.imageView.frame = CGRectMake(0, 0, _imageNormalWidth, _imageNormalHeight);
    self.imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
}


- (void)setImageNormalWidth:(CGFloat)imageNormalWidth imageNormalHeight:(CGFloat)imageNormalHeight{
    _imageNormalWidth = imageNormalWidth;
    _imageNormalHeight = imageNormalHeight;
    self.imageView.frame = CGRectMake(0, 0, _imageNormalWidth, _imageNormalHeight);
//    self.imageView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
//    self.contentSize = CGSizeMake(_imageNormalWidth*self.maximumZoomScale, _imageNormalHeight*self.maximumZoomScale);
    self.contentOffset = CGPointMake((_imageNormalWidth-self.width)/2, (_imageNormalHeight-self.height)/2);
}

#pragma mark -- UIScrollViewDelegate

//返回需要缩放的视图控件 缩放过程中
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.imageView;
}

//开始缩放
- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view{
//    NSLog(@"开始缩放");
    _curScale = scrollView.zoomScale;
}
//结束缩放
- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
//    NSLog(@"结束缩放");
    _curScale = scrollView.zoomScale;
}

//缩放中
- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    // 延中心点缩放
    CGFloat imageScaleWidth = scrollView.zoomScale * self.imageNormalWidth;
    CGFloat imageScaleHeight = scrollView.zoomScale * self.imageNormalHeight;
    CGFloat imageX = 0;
    CGFloat imageY = 0;
    if (imageScaleWidth < self.frame.size.width) {
        imageX = floorf((self.frame.size.width - imageScaleWidth) / 2.0);
    }
    if (imageScaleHeight < self.frame.size.height) {
        imageY = floorf((self.frame.size.height - imageScaleHeight) / 2.0);
    }
    self.imageView.frame = CGRectMake(imageX, imageY, imageScaleWidth, imageScaleHeight);
    _curScale = scrollView.zoomScale;
    if(self.updateScale){
        self.updateScale(scrollView.zoomScale);
    }
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    if(_curScale!=self.minimumZoomScale || [gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) return NO;
    return YES;
}
@end
