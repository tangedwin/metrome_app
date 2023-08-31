//
//  RewardUsViewController.m
//  MetroMap
//
//  Created by edwin on 2019/10/29.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "RewardUsViewController.h"

//沙盒测试环境验证
#define SANDBOX @"https://sandbox.itunes.apple.com/verifyReceipt"
//正式环境验证
#define AppStore @"https://buy.itunes.apple.com/verifyReceipt"
@interface RewardUsViewController ()<SKPaymentTransactionObserver, SKProductsRequestDelegate>
@property(nonatomic, retain) MBProgressHUD *myHud;

@property (nonatomic, retain) UIScrollView *mainScrollView;

@property (nonatomic, retain) NSString *productId;

@end

@implementation RewardUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.naviMask];
    [self.naviMask addSubview:self.backButton];
    [self.view setBackgroundColor:dynamic_color_white];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, STATUS_BAR_HEIGHT+10, 200, 25)];
    title.font = main_font_big;
    title.textColor = dynamic_color_black;
    title.text = @"赞助打赏";
    title.textAlignment = NSTextAlignmentCenter;
    [self.naviMask addSubview:title];
    
    // 添加购买监听
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    _mainScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT)];
    [self createMainView];
    [self.view addSubview:_mainScrollView];
}

//移除监听
-(void)dealloc{
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}


-(void)createMainView{
    NSString *title = @"地铁迷 - MetroMe 是一款个人开发的免费全国地铁出行导航 APP，提供最新地铁图及路线查询，致力于打造最优雅的地铁线路查询与周边服务。 \n\n  如您喜欢，可以选择支持赞助开发者。您的赞助将被投入到 APP 后续更新及开发中 \n\n ❤️ ❤️ ❤️ ❤️ ❤️ ❤️ ❤️ ❤️ ❤️ ❤️ ❤️ ❤️ ❤️ ❤️ \n ";
    CGRect titleRect = [title boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-view_margin*2, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:sub_font_middle} context:nil];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(view_margin, view_margin, SCREEN_WIDTH-view_margin*2, titleRect.size.height)];
    titleLabel.font = sub_font_middle;
    titleLabel.textColor = dynamic_color_gray;
    titleLabel.numberOfLines = 0;
    titleLabel.text = title;
    [_mainScrollView addSubview:titleLabel];
    
    NSString *subTitle = @"我要赞助";
    UILabel *subLabel = [[UILabel alloc] initWithFrame:CGRectMake(view_margin, titleLabel.x + titleLabel.height+view_margin*2, SCREEN_WIDTH-view_margin*2, 25)];
    subLabel.font = main_font_big;
    subLabel.textColor = dynamic_color_black;
    subLabel.text = subTitle;
    [_mainScrollView addSubview:subLabel];
    
    CGFloat x = view_margin;
    CGFloat y = view_margin/2 + subLabel.y + subLabel.height;
    CGFloat width = (SCREEN_WIDTH-view_margin*2-view_margin)/3;
    CGFloat height = 120;
    for(int i=0; i<5; i++){
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(x, y, width, height)];
        view.backgroundColor = dynamic_color_lightwhite;
        view.layer.cornerRadius = 12;
        view.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.05].CGColor;
        view.layer.shadowOffset = CGSizeMake(0,3);
        view.layer.shadowOpacity = 1;
        view.layer.shadowRadius = 6;
        
        NSString *priceTitle = @"";
        UIImageView *img = [[UIImageView alloc] initWithFrame:CGRectMake((width-60)/2, view_margin, 60, 60)];
        if(i==0) {
            img.image = [UIImage imageNamed:@"reward_100"];
            priceTitle = @"1";
        }else if(i==1) {
            img.image = [UIImage imageNamed:@"reward_600"];
            priceTitle = @"6";
        }else if(i==2) {
            img.image = [UIImage imageNamed:@"reward_1200"];
            priceTitle = @"12";
        }else if(i==3) {
            img.image = [UIImage imageNamed:@"reward_1800"];
            priceTitle = @"18";
        }else if(i==4) {
            img.image = [UIImage imageNamed:@"reward_3000"];
            priceTitle = @"30";
        }
        [view addSubview:img];

        UIFont *font = [UIFont fontWithName:@"DIN-Black" size: 24];
        CGRect priceRect = [priceTitle boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil];
        UILabel *priceLabel = [[UILabel alloc] initWithFrame:CGRectMake((width-priceRect.size.width-22)/2+22,78,priceRect.size.width, 30)];
        priceLabel.font = font;
        priceLabel.textColor = main_color_pink;;
        priceLabel.text = priceTitle;
        [view addSubview:priceLabel];
        
        UILabel *priceSignLabel = [[UILabel alloc] initWithFrame:CGRectMake((width-priceRect.size.width-22)/2,88,14, 20)];
        priceSignLabel.font = main_font_small;
        priceSignLabel.textColor = main_color_pink;;
        priceSignLabel.text = @"￥";
        [view addSubview:priceSignLabel];
        
        if(i%3==2){
            x = view_margin;
            y = y + view_margin/2 + height;
        }else{
            x = x + width + 6;
        }
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(reqeustProduction:)];
        view.tag = i;
        view.userInteractionEnabled = YES;
        [view addGestureRecognizer:tap];
        [_mainScrollView addSubview:view];
    }
}

-(void)reqeustProduction:(UITapGestureRecognizer*)tap{
    if(tap.view.tag == 0) [self buyProdution:@"reward_100"];
    else if(tap.view.tag == 1) [self buyProdution:@"reward_600"];
    else if(tap.view.tag == 2) [self buyProdution:@"reward_1200"];
    else if(tap.view.tag == 3) [self buyProdution:@"reward_1800"];
    else if(tap.view.tag == 4) [self buyProdution:@"reward_3000"];
}

- (void)buyProdution:(NSString *)productId{
    _productId = productId;
    if ([SKPaymentQueue canMakePayments]) {
        [self getProductInfo:productId];
    } else {
        [MBProgressHUD showInfo:@"失败" detail:@"用户禁止应用内付费购买" image:nil inView:nil];
    }
}

//从Apple查询用户点击购买的产品的信息
- (void)getProductInfo:(NSString *)productIdentifier {
    NSArray *product = [[NSArray alloc] initWithObjects:productIdentifier, nil];
    NSSet *set = [NSSet setWithArray:product];
    SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
    request.delegate = self;
    [request start];
    _myHud = [MBProgressHUD showWaitingWithText:@"正在请求，请稍后" image:nil inView:nil];
}

// 查询成功后的回调
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *myProduct = response.products;
    if (myProduct.count == 0) {
        [self hideHud];
        [MBProgressHUD showInfo:nil detail:@"无法获取信息，支付失败" image:nil inView:nil];
        return;
    }
    SKPayment * payment = [SKPayment paymentWithProduct:myProduct[0]];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

//查询失败后的回调
- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
    [self hideHud];
    [MBProgressHUD showInfo:nil detail:[error localizedDescription] image:nil inView:nil];
}


//购买操作后的回调
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
//        NSString *receipt;
        switch (transaction.transactionState){
            case SKPaymentTransactionStatePurchased://交易完成
                [self hideHud];
//                receipt = [[NSString alloc] initWithData:[NSData dataWithContentsOfURL:[[NSBundle mainBundle] appStoreReceiptURL]] encoding:NSUTF8StringEncoding];
                [self verifyPurchaseWithPaymentTrasaction:AppStore];
//                [self reportReceipt:receipt];
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed://交易失败
                    [self hideHud];
                [self failedTransaction:transaction];
//                [MBProgressHUD showInfo:@"支付失败" detail:nil image:nil inView:nil];
                break;
            case SKPaymentTransactionStateRestored://已经购买过该商品
                [self hideHud];
                [self verifyPurchaseWithPaymentTrasaction:AppStore];
//                [MBProgressHUD showInfo:@"恢复购买成功" detail:nil image:nil inView:nil];
                [self restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing://商品添加进列表
//                [MBProgressHUD showInfo:@"正在请求付费信息，请稍后" detail:nil image:nil inView:nil];
                break;
            default:
                break;
        }
    }
    
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void)reportReceipt:(NSString*)receipt{
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSInteger reward = [[_productId stringByReplacingOccurrencesOfString:@"reward_" withString:@""] integerValue];
    [params setObject:@(reward) forKey:@"amount"];
    [[HttpHelper new] submit:request_support_reward params:nil progress:^(NSProgress *progress) {

    } success:^(NSMutableDictionary *responseDic) {

    } failure:^(NSString *errorInfo) {
        
    }];
}

- (void)verifyPurchaseWithPaymentTrasaction:(NSString*) urlStr {
    // 验证凭据，获取到苹果返回的交易凭据
    // appStoreReceiptURL iOS7.0增加的，购买交易完成后，会将凭据存放在该地址
    NSURL *receiptURL = [[NSBundle mainBundle] appStoreReceiptURL];
    // 从沙盒中获取到购买凭据
    NSData *receiptData = [NSData dataWithContentsOfURL:receiptURL];
    // 发送网络POST请求，对购买凭据进行验证
    //测试验证地址:https://sandbox.itunes.apple.com/verifyReceipt
    //正式验证地址:https://buy.itunes.apple.com/verifyReceipt
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f];
    urlRequest.HTTPMethod = @"POST";
    NSString *encodeStr = [receiptData base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed];
    NSString *payload = [NSString stringWithFormat:@"{\"receipt-data\" : \"%@\"}", encodeStr];
    NSData *payloadData = [payload dataUsingEncoding:NSUTF8StringEncoding];
    urlRequest.HTTPBody = payloadData;
    // 提交验证请求，并获得官方的验证JSON结果 iOS9后更改了另外的一个方法
    NSData *result = [NSURLConnection sendSynchronousRequest:urlRequest returningResponse:nil error:nil];
    // 官方验证结果为空
    if (result == nil) {
        NSLog(@"验证失败");
        return;
    }
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:result options:NSJSONReadingAllowFragments error:nil];
    if (dict != nil) {
        if([dict[@"status"] integerValue]==21007 && ![urlStr isEqualToString:SANDBOX]) {
            [self verifyPurchaseWithPaymentTrasaction:SANDBOX];
        }else{
            [self reportReceipt:encodeStr];
        }
        // 比对字典中以下信息基本上可以保证数据安全
        // bundle_id , application_version , product_id , transaction_id
        [MBProgressHUD showInfo:nil detail:@"支付成功，感谢你的支持，么么哒" image:nil inView:nil];
        NSLog(@"验证成功！购买的商品是：%@", @"_productName");
    }

}


- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    __weak typeof(self) wkSelf = self;
    if(transaction.error.code != SKErrorPaymentCancelled) {
        [[AlertUtils new] alertWithConfirm:@"支付失败，是否重新" content:@"支付失败，是否重新支付" withBlock:^{
            [wkSelf buyProdution: wkSelf.productId];
        }];
    } else {
        [MBProgressHUD showInfo:@"用户取消交易" detail:nil image:nil inView:nil];
    }
    
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}


-(void)hideHud{
    if(_myHud){
        __weak typeof(self) wkSelf = self;
        if ([NSThread isMainThread]) {
            [wkSelf.myHud hideAnimated:YES];;
            wkSelf.myHud = nil;
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wkSelf.myHud hideAnimated:YES];
                wkSelf.myHud = nil;
            });
        }
    }
}



//- (void)viewWillAppear:(BOOL)animated{
//    self.tabBarController.tabBar.hidden = YES;
//}
//
//- (void)viewWillDisappear:(BOOL)animated{
//  self.tabBarController.tabBar.hidden = NO;
//}

@end
