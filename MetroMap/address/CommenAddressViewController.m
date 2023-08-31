//
//  CommenAddressViewController.m
//  MetroMap
//
//  Created by edwin on 2019/10/30.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "CommenAddressViewController.h"

@interface CommenAddressViewController ()
@property(nonatomic, retain)CommenAddressCollectionView *commenAddressView;
@property (nonatomic, retain) NSMutableArray *addressArray;
@property (nonatomic, retain) UILabel *submitButton;

@property (nonatomic, retain) NSMutableArray *changeArray;
@property (nonatomic, retain) CityModel *city;
@end

@implementation CommenAddressViewController

-(instancetype)initWithAddressArray:(NSMutableArray*)addressArray{
    self = [super init];
    _addressArray = addressArray;
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view setBackgroundColor:dynamic_color_white];
    [self.view addSubview:self.naviMask];
    [self.naviMask addSubview:self.backButton];
    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-200)/2, STATUS_BAR_HEIGHT+10, 200, 25)];
    title.font = main_font_big;
    title.textColor = dynamic_color_black;
    title.text = @"常用地址";
    title.textAlignment = NSTextAlignmentCenter;
    [self.naviMask addSubview:title];
    
    _changeArray = [NSMutableArray new];
    NSString *submitName = @"保存";
    CGSize submitButtonSize = [submitName sizeWithAttributes:@{NSFontAttributeName:main_font_small}];
    _submitButton = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-view_margin-ceil(submitButtonSize.width), (self.searchBar.height-ceil(submitButtonSize.height))/2+STATUS_BAR_HEIGHT+2, ceil(submitButtonSize.width), ceil(submitButtonSize.height))];
    _submitButton.font = main_font_small;
    _submitButton.textColor = main_color_blue;
    _submitButton.text = submitName;
    _submitButton.alpha = 0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(submitAddressCollect:)];
    _submitButton.userInteractionEnabled = YES;
    [_submitButton addGestureRecognizer:tap];
    [self.naviMask addSubview:_submitButton];
    
    _commenAddressView = [[CommenAddressCollectionView alloc] initWithFrame:CGRectMake(0, NAVIGATION_BAR_HEIGHT+STATUS_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT)];
    [self.view addSubview:_commenAddressView];
    [_commenAddressView loadAddressArray:_addressArray];
    
    __weak typeof(self) wkSelf = self;
    [_commenAddressView setSearchAddress:^(NSInteger index, AddressModel *address) {
        AddressSearchViewController *asVC = [[AddressSearchViewController alloc] initWithIndex:index];
        asVC.hidesBottomBarWhenPushed = YES;
        [wkSelf.navigationController pushViewController:asVC animated:YES];
    }];
}

-(void) setAddress:(AddressModel*)address city:(CityModel*)city forIndex:(NSInteger)index{
    _city = city;
    if(index==0) address.type = home_type;
    else if(index==1) address.type = company_type;
    BOOL containAddress = NO;
    if(_addressArray) for(int i=0; i<_addressArray.count; i++){
        AddressModel *addressModel = _addressArray[i];
        if([home_type isEqualToString: addressModel.type] && index==0){
            address.identifyCode = addressModel.identifyCode;
            _addressArray[i] = address;
            containAddress = YES;
            break;
        }
        if([company_type isEqualToString: addressModel.type] && index==1){
            address.identifyCode = addressModel.identifyCode;
            _addressArray[i] = address;
            containAddress = YES;
            break;
        }
    }
    if(!containAddress) [_addressArray addObject:address];
    [_changeArray addObject:address];
    if(_commenAddressView) [_commenAddressView loadAddressArray:_addressArray];
    _submitButton.alpha = 1;
}


//- (void)viewWillAppear:(BOOL)animated{
//    self.tabBarController.tabBar.hidden = YES;
//}
//
//- (void)viewWillDisappear:(BOOL)animated{
//  self.tabBarController.tabBar.hidden = NO;
//}

-(void)submitAddressCollect:(UITapGestureRecognizer*)tap{
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("concurrent.commenAddress.queue", DISPATCH_QUEUE_CONCURRENT);
    __weak typeof(self) wkSelf = self;
    for(AddressModel *address in _changeArray){
        dispatch_group_async(group, queue, ^{
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            [self saveAddressCollects:address city:wkSelf.city success:^{
                //发送信号量
                dispatch_semaphore_signal(semaphore);
            }];
            // 在网络请求任务成功之前，信号量等待中
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        });
    }
    dispatch_group_notify(group, queue, ^{
        if ([NSThread isMainThread]) {
            [wkSelf.navigationController popViewControllerAnimated:YES];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [wkSelf.navigationController popViewControllerAnimated:YES];
            });
        }
    });
}

-(void)saveAddressCollects:(AddressModel*)address city:(CityModel*)city success:(void(^)(void))success{
    NSMutableDictionary *params = [NSMutableDictionary new];
    NSString *uri = request_address_collect_update;
    if(address.identifyCode) [params setObject:@(address.identifyCode) forKey:@"id"];
    else uri = request_address_collect;
    [params setObject:address.addressName forKey:@"addressName"];
    [params setObject:address.address forKey:@"address"];
    if(address.type) [params setObject:address.type forKey:@"type"];
    if(address.latitude) [params setObject:@(address.latitude) forKey:@"latitude"];
    if(address.longitude) [params setObject:@(address.longitude) forKey:@"longitude"];
    
    if(address.cityId) [params setObject:@(address.cityId) forKey:@"cityId"];
    else if(city && city.identifyCode) [params setObject:@(city.identifyCode) forKey:@"cityId"];
    if(address.cityName) [params setObject:address.cityName forKey:@"cityName"];
    else if(city && city.nameCn) [params setObject:city.nameCn forKey:@"cityName"];
    
    [[HttpHelper new] submit:uri params:params progress:^(NSProgress *progress) {
    } success:^(NSMutableDictionary *responseDic) {
        if(success) success();
    } failure:^(NSString *errorInfo) {
        if(success) success();
    }];
}
@end
