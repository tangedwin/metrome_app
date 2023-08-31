//
//  ShowImageViewController.m
//  ScreenShotTest
//
//  Created by 张雷 on 14/10/26.
//  Copyright (c) 2014年 zhanglei. All rights reserved.
//

#import "ShowImageViewController.h"

@interface ShowImageViewController ()
@property (nonatomic,strong)UIScrollView *scrollView;
@property (nonatomic,strong)UIImageView *imageView;
@end

@implementation ShowImageViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self initView];
}

#pragma mark - 初始化视图
-(void)initView{
    self.view.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    
    CGFloat scrollWidth = self.view.bounds.size.width - 40;
    CGFloat scrollHeight = self.view.bounds.size.height - 50;
    CGFloat imageWidth = scrollWidth;
    CGFloat imageHeight = _image.size.height*scrollWidth/_image.size.width;
    CGFloat maxHeight = scrollHeight;
    scrollHeight = scrollHeight>imageHeight?imageHeight:scrollHeight;
    
    CGFloat scrollY = 25+(maxHeight-scrollHeight);
    if(maxHeight-scrollHeight>=50){
        scrollY = -25+(maxHeight-scrollHeight);
    }
    
    //UIScrollView
    _scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(20, scrollY, scrollWidth, scrollHeight)];
    _scrollView.contentSize = CGSizeMake(imageWidth, imageHeight);
    _scrollView.layer.cornerRadius = 8;
    _scrollView.layer.masksToBounds = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_scrollView];
    
    //UIImageView
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, imageWidth, imageHeight)];
    _imageView.image = _image;
    _imageView.backgroundColor = [UIColor lightGrayColor];
    _imageView.layer.masksToBounds = YES;
    _imageView.layer.cornerRadius = 8;
    [_scrollView addSubview:_imageView];
    
    //UIButton
    UIButton *shareBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [shareBtn setTitle:@"分享图片" forState:UIControlStateNormal];
    shareBtn.frame = CGRectMake(20+12, self.view.bounds.size.height-63, (scrollWidth-24-24)/3, 24);
    shareBtn.backgroundColor = main_color_blue;
    shareBtn.layer.cornerRadius = 5;
    shareBtn.alpha = 0.7;
    [shareBtn setTitleColor:main_color_white forState:UIControlStateNormal];
    [shareBtn addTarget:self action:@selector(shareBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareBtn];
    
    UIButton *shareTextBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [shareTextBtn setTitle:@"分享文字" forState:UIControlStateNormal];
    shareTextBtn.frame = CGRectMake((scrollWidth-24-24)/3+24+20, self.view.bounds.size.height-63, (scrollWidth-24-24)/3, 24);
    shareTextBtn.backgroundColor = main_color_blue;
    shareTextBtn.layer.cornerRadius = 5;
    shareTextBtn.alpha = 0.7;
    [shareTextBtn setTitleColor:main_color_white forState:UIControlStateNormal];
    [shareTextBtn addTarget:self action:@selector(shareTextBtn) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareTextBtn];
    
    UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    cancelBtn.frame = CGRectMake((scrollWidth-24-24)*2/3+36+20, self.view.bounds.size.height-63, (scrollWidth-24-24)/3, 24);
    [cancelBtn addTarget:self action:@selector(cancelBtn) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn.backgroundColor = main_color_pink;
    cancelBtn.layer.cornerRadius = 5;
    cancelBtn.alpha = 0.6;
    [cancelBtn setTitleColor:main_color_white forState:UIControlStateNormal];
    [self.view addSubview:cancelBtn];
}

#pragma mark - 保存图片到相册
-(void)shareBtn{
    if(self.shareImage) self.shareImage();
//    UIImageWriteToSavedPhotosAlbum(_image, nil, nil, nil);  //保存到相册中
//    //1 保存照片到沙盒目录
//    NSData *imageData = UIImagePNGRepresentation(_image);
//
//    //创建文件夹  createIntermediates该参数bool类型,是否创建文件夹路径中没有的文件夹目录
//    NSString *documentsDirectory = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"ScreenShot"];
//    [[NSFileManager defaultManager] createDirectoryAtPath:documentsDirectory withIntermediateDirectories:YES attributes:nil error:nil];
//
//    NSInteger seconds = [[NSDate date] timeIntervalSince1970];
//    NSString *pictureName= [NSString stringWithFormat:@"%ld.png",(long)seconds];
//    NSString *savedImagePath = [documentsDirectory stringByAppendingPathComponent:pictureName];
//    [imageData writeToFile:savedImagePath atomically:YES];
//
//    //2 保存图片到照片库
//    UIImageWriteToSavedPhotosAlbum(_image, nil, nil, nil);
//
//    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)shareTextBtn{
    if(self.shareText) self.shareText();
}

#pragma mark - 取消
-(void)cancelBtn{
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
