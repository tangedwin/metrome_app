//
//  SZAddImage.m
//  pet-photo
//
//  Created by edwin on 2019/7/13.
//  Copyright © 2019 edwin. All rights reserved.
//

//#define imageH 100 // 图片高度
//#define imageW 75 // 图片宽度
//#define kMaxColumn 9 // 每行显示数量
#define MaxImageCount 9 // 最多显示图片个数
#define deleImageWH 15 // 删除按钮的宽高
#define kAdeleImage @"cancel_icon" // 删除按钮图片
#define kAddImage @"add_image" // 添加按钮图片



#import "SZAddImage.h"
@interface SZAddImage()<UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    // 标识被编辑的按钮 -1 为添加新的按钮
    NSInteger editTag;
    UIButton *addButton;
}
@end

@implementation SZAddImage

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        addButton = [self createButtonWithImage:kAddImage andSeletor:@selector(addNew:)];
        [self addSubview:addButton];
    }
    self.showsHorizontalScrollIndicator = NO;
    self.backgroundColor = [UIColor clearColor];
    return self;
}

-(NSMutableArray *)tempImages
{
    if (_tempImages == nil) {
        _tempImages = [NSMutableArray array];
    }
    return _tempImages;
}
-(NSMutableArray *)imageInfos
{
    if (_imageInfos == nil) {
        _imageInfos = [NSMutableArray array];
    }
    return _imageInfos;
}

// 添加新的控件
- (void)addNew:(UIButton *)btn
{
    // 标识为添加一个新的图片
    
    if (![self deleClose:btn]) {
        editTag = -1;
        [self callImagePicker];
    }
    
    
}

// 修改旧的控件
- (void)changeOld:(UIButton *)btn
{
    // 标识为修改(tag为修改标识)
    if (![self deleClose:btn]) {
        editTag = btn.tag;
        [self callImagePicker];
    }
}

// 删除"删除按钮"
- (BOOL)deleClose:(UIButton *)btn
{
//    if (btn.subviews.count == 2) {
//        [[btn.subviews lastObject] removeFromSuperview];
//        [self stop:btn];
//        return YES;
//    }
    
    return NO;
}

// 调用图片选择器
- (void)callImagePicker{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            dispatch_async(dispatch_get_main_queue(), ^{
                //没有授权
                if(status== PHAuthorizationStatusRestricted) {
                    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
                    NSString *appName  = [info objectForKey:@"CFBundleDisplayName"];
                    appName = appName ? appName : [info objectForKey:@"CFBundleName"];
                    NSString *message  = [NSString stringWithFormat:@"请在系统设置中允许“%@”访问照片!", appName];
                    [[AlertUtils new] alertWithConfirm:@"无法访问照片" content:message];
                }else if (status==PHAuthorizationStatusDenied) {
                    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
                    NSString *appName  = [info objectForKey:@"CFBundleDisplayName"];
                    appName = appName ? appName : [info objectForKey:@"CFBundleName"];
                    NSString *message  = [NSString stringWithFormat:@"请在系统设置中允许“%@”访问照片!", appName];
                    [[AlertUtils new] alertWithConfirm:@"无法访问照片" content:message];
                }
                else {
                    UIImagePickerController *pc = [[UIImagePickerController alloc] init];
                    pc.allowsEditing = NO;
                    pc.delegate = self;
                    pc.navigationBar.translucent=NO;
                    pc.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
                    [self.window.rootViewController presentViewController:pc animated:YES completion:nil];
                }
            });
        }];
    });
}


// 根据图片名称或者图片创建一个新的显示控件
- (UIButton *)createButtonWithImage:(id)imageNameOrImage andSeletor : (SEL)selector
{
    UIImage *addImage = nil;
    if ([imageNameOrImage isKindOfClass:[NSString class]]) {
        addImage = [UIImage imageNamed:imageNameOrImage];
    }
    else if([imageNameOrImage isKindOfClass:[UIImage class]])
    {
        addImage = imageNameOrImage;
    }
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [addBtn setImage:addImage forState:UIControlStateNormal];
    addBtn.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [addBtn addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    addBtn.tag = self.subviews.count;
    
    addBtn.layer.cornerRadius = 6;
    addBtn.layer.masksToBounds = YES;
    
    // 添加长按手势,用作删除.加号按钮不添加
    if(addBtn.tag != 0)
    {
//        UILongPressGestureRecognizer *gester = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
//        [addBtn addGestureRecognizer:gester];
    }
    
    addBtn.backgroundColor = [UIColor clearColor];
    return addBtn;
    
}



// 删除图片
- (void)deletePic : (UIButton *)btn{
    UIImage *deleImage = [(UIButton *)btn.superview imageForState:UIControlStateNormal];
    NSInteger index = [self.tempImages indexOfObject:deleImage];
    [self.tempImages removeObjectAtIndex:index];
    [self.imageInfos removeObjectAtIndex:index];
    [btn.superview removeFromSuperview];
//    if ([[self.subviews lastObject] isHidden]) {
//        [[self.subviews lastObject] setHidden:NO];
//    }

    NSInteger count = 0;
    if(self.subviews) for(UIView *view in self.subviews){
        if([view isKindOfClass:UIButton.class]) count++;
    }
    
    if (count <= MaxImageCount) {
        [self addSubview: addButton];
    }
    
    
}

// 对所有子控件进行布局
- (void)layoutSubviews
{
    [super layoutSubviews];
    NSMutableArray *subviews = [NSMutableArray new];
    if(self.subviews) for(UIView *view in self.subviews){
        if([view isKindOfClass:UIButton.class]) [subviews addObject:view];
    }
    
    CGFloat marginX = view_margin;
    CGFloat marginY = 6;
    CGFloat btnW = fitFloat(60);
    CGFloat btnH = fitFloat(60);
    CGFloat width = 0;
    for(int i=0; i<subviews.count; i++){
        UIButton *btn = subviews[i];
        CGFloat btnX = i * (marginX+btnW) + marginX;
        CGFloat btnY = marginY;
        btn.frame = CGRectMake(btnX, btnY, btnW, btnH);
        
        if(btn.tag!=0 && (!btn.subviews || btn.subviews.count<=1)){
            UIButton *dele = [UIButton buttonWithType:UIButtonTypeCustom];
            dele.bounds = CGRectMake(0, 0, deleImageWH, deleImageWH);
            [dele setImage:[UIImage imageNamed:kAdeleImage] forState:UIControlStateNormal];
            [dele addTarget:self action:@selector(deletePic:) forControlEvents:UIControlEventTouchUpInside];
            dele.frame = CGRectMake(btn.frame.size.width - dele.frame.size.width, 0, dele.frame.size.width, dele.frame.size.height);
            [btn addSubview:dele];
            
        }
        width = btnX + btnW + view_margin;
    }
    
    self.contentSize = CGSizeMake(SCREEN_WIDTH>width?SCREEN_WIDTH:width, self.height);
//    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
    
    
}

-(UIImage *)zipNSDataWithImage:(UIImage *)sourceImage{
    //进行图像尺寸的压缩
    CGSize imageSize = sourceImage.size;//取出要压缩的image尺寸
    CGFloat width = imageSize.width;    //图片宽度
    CGFloat height = imageSize.height;  //图片高度
    if(width>3000 || height>3000){
        if (width>height && height>800) {
            CGFloat scale = height/width;
            width = 3000;
            height = width*scale;
        }else if(width<height && width>800){
            CGFloat scale = width/height;
            height = 3000;
            width = height*scale;
        }
    } else if(width>4000 || height>4000){
        if (width>height && height>500) {
            CGFloat scale = height/width;
            width = 4000;
            height = width*scale;
        }else if(width<height && width>500){
            CGFloat scale = width/height;
            height = 4000;
            width = height*scale;
        }
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    [sourceImage drawInRect:CGRectMake(0,0,width,height)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //进行图像的画面质量压缩
    NSData *data=UIImageJPEGRepresentation(sourceImage, 1.0);
    if (data.length>100*1024) {
        if (data.length>20*1024*1024) {//20M以及以上
            data=UIImageJPEGRepresentation(newImage, 0.5);
        }else if (data.length>10*1024*1024) {//10M以及以上
            data=UIImageJPEGRepresentation(newImage, 0.7);
        }else if (data.length>5*1024*1024) {
            data=UIImageJPEGRepresentation(newImage, 0.9);
        }
    }
    return [UIImage imageWithData:data];
}

- (NSData *)compressQualityWithImage:(UIImage*)image maxLength:(NSInteger)maxLength {
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return data;
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    return data;
}

-(NSData*)writeExif:(NSDictionary *)exifDict toImage:(NSData*)imageData{
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    
    NSMutableDictionary *metaDataDic = [exifDict mutableCopy];
    NSMutableDictionary *exifDic =[[metaDataDic objectForKey:(NSString*)kCGImagePropertyExifDictionary]mutableCopy];
    NSMutableDictionary *GPSDic =[[metaDataDic objectForKey:(NSString*)kCGImagePropertyGPSDictionary]mutableCopy];
    [exifDic setObject:@"test" forKey:@"test"];
    
    if(exifDic) [metaDataDic setObject:exifDic forKey:(NSString*)kCGImagePropertyExifDictionary];
    if(GPSDic) [metaDataDic setObject:GPSDic forKey:(NSString*)kCGImagePropertyGPSDictionary];
    
    CFStringRef UTI = CGImageSourceGetType(imageSource);
    NSMutableData *newImageData = [NSMutableData data];
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)newImageData, UTI, 1,NULL);
    
    CGImageDestinationAddImageFromSource(destination, imageSource, 0, (__bridge CFDictionaryRef)metaDataDic);
    CGImageDestinationFinalize(destination);
    NSString *directoryDocuments =  NSTemporaryDirectory();
    [newImageData writeToFile: directoryDocuments atomically:YES];
    return newImageData;
}

#pragma mark - UIImagePickerController 代理方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    NSString *url;
    if (@available(iOS 11.0, *)) {
        url = info[UIImagePickerControllerImageURL];
    } else {
        // Fallback on earlier versions
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    
    NSString* mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    if([mediaType isEqualToString:(NSString*)kUTTypeImage]){
        UIImageOrientation imageOrientation=image.imageOrientation;
        if(imageOrientation!=UIImageOrientationUp){
            // 原始图片可以根据照相时的角度来显示，但UIImage无法判定，于是出现获取的图片会向左转９０度的现象。
            // 以下为调整图片角度的部分
            UIGraphicsBeginImageContext(image.size);
            [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
            image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            // 调整图片角度完毕
        }
    }
    image = [ImageUtils fixOrientation:image];
    NSData *imgData = [ImageUtils compressQualityWithImage:image maxLength:516*1024];
    image = [UIImage imageWithData:imgData];
    
    if(image){
        NSMutableDictionary *imageInfo = [NSMutableDictionary new];
        [imageInfo setObject:image forKey:@"image"];
        if(url) [imageInfo setObject:url forKey:@"path"];
        if (self->editTag == -1) {
            // 创建一个新的控件
            UIButton *btn = [self createButtonWithImage:image andSeletor:@selector(changeOld:)];
            NSInteger index = [self.subviews indexOfObject:addButton];
            index = index<0?0:index;
            index = index>self.subviews.count?self.subviews.count:index;
            [self insertSubview:btn atIndex:index];
            [self.tempImages addObject:image];
            [self.imageInfos addObject:imageInfo];
            [self uploadImage:imageInfo image:image block:nil];

            NSInteger count = 0;
            if(self.subviews) for(UIView *view in self.subviews){
                if([view isKindOfClass:UIButton.class]) count++;
            }
            
            if (count > MaxImageCount) {
                [addButton removeFromSuperview];
            }
        }
        else{
            // 根据tag修改需要编辑的控件
            UIButton *btn = (UIButton *)[self viewWithTag:self->editTag];
            NSInteger index = [self.tempImages indexOfObject:[btn imageForState:UIControlStateNormal]];
            [self.tempImages removeObjectAtIndex:index];
            [self.imageInfos removeObjectAtIndex:index];
            [btn setImage:image forState:UIControlStateNormal];
            [self.tempImages insertObject:image atIndex:index];
            [self.imageInfos insertObject:imageInfo atIndex:index];
            [self uploadImage:imageInfo image:image block:nil];
        }
    }else{
        [MBProgressHUD showInfo:@"添加图片失败" detail:nil image:nil inView:nil];
    }
}

-(void)uploadImage:(NSMutableDictionary *)imageInfo image:(UIImage*)image block:(void(^)(BOOL success))block{
    if(_uploadUrl && imageInfo && image){
        [imageInfo setObject:@(YES) forKey:@"uploading"];
        //上传照片
        [[HttpHelper http] uploadImage:image uri:_uploadUrl progress:nil success:^(NSMutableDictionary *responseDic) {
            NSString *imageUri = [responseDic objectForKey:@"filePath"];
            [imageInfo setObject:imageUri forKey:@"uri"];
            [imageInfo setObject:@(YES) forKey:@"uploaded"];
            [imageInfo removeObjectForKey:@"uploading"];
            if(block) block(YES);
        } failure:^(NSString *errorInfo) {
            [imageInfo removeObjectForKey:@"uploading"];
            if(block) block(NO);
        }];
    }
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    return NO;
}
@end
