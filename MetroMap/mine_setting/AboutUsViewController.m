//
//  AboutUsViewController.m
//  MetroMap
//
//  Created by edwin on 2019/10/9.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "AboutUsViewController.h"

@interface AboutUsViewController ()

@property (nonatomic, retain) UIScrollView *mainScrollView;

@end

@implementation AboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT)];
    _mainScrollView.alwaysBounceVertical = YES;
    [self.view addSubview:_mainScrollView];
    [self createLogoView];
    [self createMainView];
    [self.view setBackgroundColor:dynamic_color_white];
    
    [self.view addSubview:self.backButton];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, STATUS_BAR_HEIGHT+10, 200, 25)];
    title.font = main_font_big;
    title.textColor = dynamic_color_black;
    title.text = @"关于我们";
    title.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:title];
}

-(void)createLogoView{
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-88)/2, 60, 88, 88)];
    [imageView setImage:[UIImage imageNamed:@"main_logo"]];
    
    imageView.layer.cornerRadius = 24;
    imageView.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05].CGColor;
    imageView.layer.shadowOffset = CGSizeMake(0,3);
    imageView.layer.shadowOpacity = 1;
    imageView.layer.shadowRadius = 6;
    [_mainScrollView addSubview:imageView];
    
    UILabel *version = [[UILabel alloc] initWithFrame:CGRectMake(0, imageView.y+imageView.height+6, SCREEN_WIDTH, 25)];
    version.font = main_font_big;
    version.textColor = dynamic_color_black;
    version.textAlignment = NSTextAlignmentCenter;
    version.text = @"V.2.0.1";
    [_mainScrollView addSubview:version];
}

-(void)createMainView{
    NSString *content = @"地铁迷 - MetroMe APP，全国地铁出行必备，提供最新地铁图及路线查询。致力于打造最优雅的地铁线路查询与周边服务。 \n\n由于时间及经费有限，地铁迷存在一定的不合理之处或 bug。如您在使用中遇到问题，可以通过 APP “我的” - “问题反馈”功能上报故障和问题；您也可以通过下方联系方式向我们反馈。 \n\n如果您也喜欢我们的 APP，您可以前往 App Store 给我们的应用五星好评；也可以打赏我们一杯咖啡☕️/奶茶🍵 \n\n有需要商务合作的朋友可以联系我们洽谈~ \n\n最后，感谢您的理解和支持！\n\n";
    CGRect rect = [content boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-view_margin*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:sub_font_middle} context:nil];
    UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(view_margin, 205, SCREEN_WIDTH-view_margin*2, rect.size.height+80)];
    mainLabel.font = sub_font_middle;
    mainLabel.textColor = dynamic_color_gray;
    mainLabel.numberOfLines = 0;
    mainLabel.text = content;
    [_mainScrollView addSubview:mainLabel];
    
    
    UILabel *contactType = [[UILabel alloc] initWithFrame:CGRectMake(view_margin, mainLabel.y+mainLabel.height, SCREEN_WIDTH-view_margin*2, 20)];
    contactType.font = sub_font_middle;
    contactType.textColor = dynamic_color_gray;
    contactType.text = @"联系方式";
    [_mainScrollView addSubview:contactType];
    
    NSMutableAttributedString *qqText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"QQ 群: %@", qqNumber]];
    [qqText addAttribute:NSForegroundColorAttributeName value:main_color_blue range:NSMakeRange(6, qqText.length-6)];
    UILabel *contactQQ = [[UILabel alloc] initWithFrame:CGRectMake(view_margin, mainLabel.y+mainLabel.height+50, SCREEN_WIDTH-view_margin*2, 20)];
    contactQQ.font = sub_font_middle;
    contactQQ.textColor = dynamic_color_gray;
    contactQQ.attributedText = qqText;
    [_mainScrollView addSubview:contactQQ];
//    __weak typeof(self) wkSelf = self;
    [contactQQ onTapRangeActionWithString:@[qqText.string] tapClicked:^(NSString *string, NSRange range, NSInteger index){
        NSString *urlStr = [NSString stringWithFormat:@"mqqapi://card/show_pslcard?src_type=internal&version=1&uin=%@&key=%@&card_type=group&source=external", qqNumber, qqKey];
            NSURL *url = [NSURL URLWithString:urlStr];
            if([[UIApplication sharedApplication] canOpenURL:url]){
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success){
                    
                }];
            }
     }];
    
    NSMutableAttributedString *emailText = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"邮箱: %@", email]];
    [emailText addAttribute:NSForegroundColorAttributeName value:main_color_blue range:NSMakeRange(4, emailText.length-4)];
    UILabel *contactEmail = [[UILabel alloc] initWithFrame:CGRectMake(view_margin, mainLabel.y+mainLabel.height+100, SCREEN_WIDTH-view_margin*2, 20)];
    contactEmail.font = sub_font_middle;
    contactEmail.textColor = dynamic_color_gray;
    contactEmail.attributedText = emailText;
    [_mainScrollView addSubview:contactEmail];
//   __weak typeof(self) wkSelf = self;
    [contactEmail onTapRangeActionWithString:@[emailText.string] tapClicked:^(NSString *string, NSRange range, NSInteger index){
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat: @"mailto:%@",email]] options:@{} completionHandler:^(BOOL success) {
        }];
    }];
    
    _mainScrollView.contentSize = CGSizeMake(SCREEN_WIDTH, contactEmail.y+contactEmail.height + view_margin*4);
}

//- (void)viewWillAppear:(BOOL)animated{
//    self.tabBarController.tabBar.hidden = YES;
//}
//
//- (void)viewWillDisappear:(BOOL)animated{
//  self.tabBarController.tabBar.hidden = NO;
//}

- (BOOL)joinGroup:(NSString *)groupUin key:(NSString *)key{
    NSString *urlStr = [NSString stringWithFormat:@"mqqapi://card/show_pslcard?src_type=internal&version=1&uin=%@&key=%@&card_type=group&source=external", @"41016576",@"64ac0b398e6c6239bf33ac08eef9f7988f8d5f772e90771719da7cec3dc7b7da"];
        NSURL *url = [NSURL URLWithString:urlStr];
        if([[UIApplication sharedApplication] canOpenURL:url]){
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:^(BOOL success){
                
            }];
        return YES;
    }
    else return NO;
}

@end
