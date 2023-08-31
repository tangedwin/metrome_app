//
//  MessageDetailViewController.m
//  MetroMap
//
//  Created by edwin on 2019/10/30.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "MessageDetailViewController.h"

@interface MessageDetailViewController ()

@property(nonatomic, retain) MessageModel *message;
@property (nonatomic, retain) UIScrollView *mainScrollView;

@end

@implementation MessageDetailViewController

-(instancetype) initWithMessage:(MessageModel*)message{
    self = [super init];
    _message = message;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:dynamic_color_white];
    [self.view addSubview:self.naviMask];
    [self.naviMask addSubview:self.backButton];
    
    _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT)];
    [self createMainView];
    [self.view addSubview:_mainScrollView];
    [self requestService];
}

-(void)createMainView{
    NSString *title = _message.title;
    CGRect titleRect = [title boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-view_margin*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:main_font_big} context:nil];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(view_margin, view_margin, SCREEN_WIDTH-view_margin*2, titleRect.size.height)];
    titleLabel.font = main_font_big;
    titleLabel.textColor = dynamic_color_black;
    titleLabel.numberOfLines = 0;
    titleLabel.text = title;
    [_mainScrollView addSubview:titleLabel];
    
    NSString *content = _message.content;
    CGRect rect = [content boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-view_margin*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:main_font_small} context:nil];
    UILabel *mainLabel = [[UILabel alloc] initWithFrame:CGRectMake(view_margin, titleLabel.height+view_margin*2, SCREEN_WIDTH-view_margin*2, rect.size.height)];
    mainLabel.font = main_font_small;
    mainLabel.textColor = dynamic_color_gray;
    mainLabel.numberOfLines = 0;
    mainLabel.text = content;
    [_mainScrollView addSubview:mainLabel];
    
}


-(void)requestService{
    NSMutableDictionary *params = [NSMutableDictionary new];
    [params setObject:[NSString stringWithFormat:@"%ld",(long)_message.identifyCode] forKey:@"messageId"];
    NSString *registerId = [[NSUserDefaults standardUserDefaults] objectForKey:USER_MESSAGE_REGISTER_ID_KEY];
    if(registerId){
        [params setObject:registerId forKey:@"registerId"];
    }
    [[HttpHelper new] submit:request_message_read params:params progress:^(NSProgress *progress) {
        
    } success:^(NSMutableDictionary *responseDic) {

    } failure:^(NSString *errorInfo) {

    }];
}

//- (void)viewWillAppear:(BOOL)animated{
//    self.tabBarController.tabBar.hidden = YES;
//}
//
//- (void)viewWillDisappear:(BOOL)animated{
//  self.tabBarController.tabBar.hidden = NO;
//}

@end
