//
//  FeedbackView.m
//  MetroMap
//
//  Created by edwin on 2019/11/25.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "FeedbackView.h"
#import "FeedbackTitleView.h"
#import "SZAddImage.h"

#define contentMaxNum 200
#define contentMaxLine 5
#define contactMaxNum 50
#define placeHolderText @"请填写详细问题描述"
@interface FeedbackView ()<UICollectionViewDelegate, UICollectionViewDataSource, UITextViewDelegate, UIScrollViewDelegate>

@property (nonatomic, retain) UICollectionViewFlowLayout *fallLayout;
@property(nonatomic, assign) NSInteger type;

@property(nonatomic, retain) UITextView *textView;
@property(nonatomic, retain) UILabel *textLabel;
@property(nonatomic, retain) FeedbackTitleView *feedbackTitleView;
@property(nonatomic, retain) SZAddImage *szAddImage;

@property(nonatomic, retain) NSMutableArray *phoneTypes;
@property(nonatomic, retain) NSMutableArray *systemTypes;
@property(nonatomic, retain) NSMutableArray *feedbackTitle;
@property(nonatomic, retain) NSString *phoneType;
@property(nonatomic, retain) NSString *systemType;
@property(nonatomic, assign) BOOL phoneTypeSelecting;
@property(nonatomic, assign) BOOL systemTypeSelecting;
@property(nonatomic, copy) NSString *textViewContent;
@property(nonatomic, retain) UITextField *contactType;

@property(nonatomic, retain) NSMutableArray *layers;
@property(nonatomic, retain) FeedbackModel *feedback;
@property(nonatomic, retain) NSString *contactTypeStr;

@property(nonatomic, retain) MBProgressHUD *hud;

//提醒机型填写（仅提醒一次）
@property(nonatomic, assign) BOOL alertPhoneType;
@property(nonatomic, assign) BOOL submitting;

@end

@implementation FeedbackView
static NSString * const feedback_collection_id = @"feedback_collection";
static NSString * const feedback_collection_header_id = @"feedback_collection_header";

-(instancetype)initWithFrame:(CGRect)frame type:(NSInteger)type feedback:(FeedbackModel*)feedback{
//    self = [super initWithFrame:frame];
    // 创建布局
    _fallLayout = [[UICollectionViewFlowLayout alloc]init];
    _fallLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    _fallLayout.sectionHeadersPinToVisibleBounds = YES;
    self = [super initWithFrame:frame collectionViewLayout:_fallLayout];
    [self registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:feedback_collection_id];
    [self registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:feedback_collection_header_id];
    self.dataSource = self;
    self.delegate = self;
    self.allowsSelection = NO;
    self.alwaysBounceHorizontal = YES;
    self.directionalLockEnabled = YES;
    if (@available(iOS 11.0, *)) {
        self.contentInsetAdjustmentBehavior=UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    self.backgroundColor = dynamic_color_white;
    self.showsVerticalScrollIndicator = YES;
    
    _phoneTypes = [[NSMutableArray alloc] initWithObjects:@"iPhone 4s 及更早机型",@"iPhone 5 / 5s",
                   @"iPhone 6 / 6s / 7 / 8",@"iPhone 6 Plus / 6s Plus / 7 Plus / 8 Plus",@"iPhone X / Xs / 11 Pro",
                   @"iPhone Xr / 11 / Xs Max / 11 Pro Max", nil];
    _systemTypes = [[NSMutableArray alloc] initWithObjects:@"iOS 10",@"iOS 11",@"iOS 12",@"iOS 13", nil];
    _type = type;
    _phoneTypeSelecting = YES;
    _feedback = feedback;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped)];
    tap1.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tap1];
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}


#pragma mark - UICollectionViewDataSource
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionReusableView *reusableView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:feedback_collection_header_id forIndexPath:indexPath];
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        if(reusableView.subviews) for(UIView *sview in reusableView.subviews) [sview removeFromSuperview];
        
        if(indexPath.section>0){
            NSInteger section = indexPath.section;
            if(_type==2) section = indexPath.section+2;
            if(section==1) [self createHeaderLabel:@"* 您使用的机型" reusableView:reusableView indexPath:indexPath];
            else if(section==2) [self createHeaderLabel:@"* 您使用的系统版本" reusableView:reusableView indexPath:indexPath];
            else if(section==6){
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, SCREEN_WIDTH, fitFloat(14))];
                label.font = sub_font_small;
                label.textColor = dynamic_color_gray;
                label.text = @"感谢您的反馈，请留下您的联系方式，方便我们及时将处理结果回复给您";
                label.textAlignment = NSTextAlignmentCenter;
                [reusableView addSubview:label];
            }
        }
        reusableView.backgroundColor = dynamic_color_white;
    }
    //如果是头视图
    return reusableView;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    //根据注册标记查找cell
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:feedback_collection_id forIndexPath:indexPath];
    if(cell.contentView.subviews) for(UIView *view in cell.contentView.subviews) [view removeFromSuperview];
    if(indexPath.section==0){
        NSMutableArray *titles = nil;
        if(_feedbackTitleView) {
            titles = _feedbackTitleView.selectedTitles;
            _feedbackTitleView=nil;
        }
        //title滑动条
        if(_type==1) _feedbackTitleView = [[FeedbackTitleView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, fitFloat(44)) titles:[[NSMutableArray alloc] initWithObjects:@"闪退",@"卡顿",@"优化建议",@"其它问题", nil] selected:titles];
        else if(_type==2) _feedbackTitleView = [[FeedbackTitleView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, fitFloat(44)) titles:[[NSMutableArray alloc] initWithObjects:@"方案规划异常",@"方案数据错误",@"时刻表错误",@"站点信息错误",@"其它问题", nil] selected:titles];
        if(_feedbackTitleView) [cell.contentView addSubview:_feedbackTitleView];
    }else{
        //手机及系统型号
        NSInteger section = indexPath.section;
        if(_type==2) section = indexPath.section+2;
        if(section==1) {
            if(indexPath.item==0) {
                if(_phoneType && !_phoneTypeSelecting) [self createTableLabel:_phoneType cell:cell indexPath:indexPath];
                else [self createTableLabel:_phoneTypes[0] cell:cell indexPath:indexPath];
            }else if(indexPath.item<_phoneTypes.count) [self createTableLabel:_phoneTypes[indexPath.item] cell:cell indexPath:indexPath];
        }else if(section==2){
            if(indexPath.item==0 && !_systemTypeSelecting) {
                if(_systemType) [self createTableLabel:_systemType cell:cell indexPath:indexPath];
                else [self createTableLabel:_systemTypes[0] cell:cell indexPath:indexPath];
            }else if(indexPath.item<_systemTypes.count) [self createTableLabel:_systemTypes[indexPath.item] cell:cell indexPath:indexPath];
        }else if(section==3){
            [self createTextViewInCell:cell indexPath:indexPath];
        }else if(section==4){
            [self createImageUploadViewInCell:cell indexPath:indexPath];
        }else if(section==5){
            [self createTextFieldInCell:cell indexPath:indexPath];
        }else if(section==6){
            UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake((SCREEN_WIDTH-fitFloat(240))/2, fitFloat(12), fitFloat(240), fitFloat(44))];
            CAGradientLayer *gl1 = [CAGradientLayer layer];
            gl1.frame = CGRectMake(0,0,fitFloat(240),fitFloat(44));
            gl1.startPoint = CGPointMake(0, 0.5);
            gl1.endPoint = CGPointMake(1, 0.5);
            gl1.colors = gradual_color_blue;
            gl1.locations = @[@(0), @(1.0f)];
            [titleView.layer insertSublayer:gl1 atIndex:0];
            titleView.layer.cornerRadius = 6;
            titleView.layer.masksToBounds = YES;
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (titleView.height-fitFloat(23))/2, titleView.width, fitFloat(23))];
            titleLabel.font = main_font_middle;
            titleLabel.textColor = main_color_white;
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.text = @"提交";
            [titleView addSubview:titleLabel];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(submit:)];
            titleView.userInteractionEnabled = YES;
            [titleView addGestureRecognizer:tap];
            [cell.contentView addSubview:titleView];
        }
    }
    return cell;
}
-(void)initSelectedData{
    if(_feedback && _feedback.titles){
        _feedbackTitleView.selectedTitles = _feedback.titles;
        [_feedbackTitleView reloadData];
    }
}

-(void)submit:(UITapGestureRecognizer*)tap{
    if(_submitting) {
        [MBProgressHUD showInfo:nil detail:@"操作太快了，正在处理中" image:nil inView:nil];
        return;
    }
    _submitting = YES;
    [self performSelector:@selector(updateSubmittingStatus) withObject:self afterDelay:3.0f];
    _hud = [MBProgressHUD showWaitingWithText:@"正在提交" image:nil inView:nil];
    if(!_feedback) _feedback = [FeedbackModel new];
    _feedback.type = _type;
    _feedback.titles = _feedbackTitleView.selectedTitles;
    if(_type==1){
        if((!_phoneType || !_systemType) && !_alertPhoneType){
            [_hud showCustomView:nil detail:@"请留下您的机型和系统版本，以便我们重现问题哦" image:nil];
            _alertPhoneType = YES;
            return;
        }else if((!_textView || _textView.text.length<=0 || [_textView.text isEqualToString: placeHolderText]) && (!_feedback.titles || _feedback.titles.count<=0)){
            [_hud showCustomView:nil detail:@"请描述一下问题吧" image:nil];
            return;
        }
        _feedback.phoneType = _phoneType;
        _feedback.systemType = _systemType;
    }else if(_type==2){
        if((!_textView || _textView.text.length<=0) && (!_feedback.dataDetailStr || _feedback.dataDetailStr.length<=0)){
            [_hud showCustomView:nil detail:@"请描述一下问题吧" image:nil];
            return;
        }
    }
    if(_textView && _textView.text.length>0 && ![_textView.text isEqualToString: placeHolderText]) _feedback.content = _textView.text;
    _feedback.contactType = _contactType.text;
    [self submitFeedback:_feedback];
}

-(void)updateSubmittingStatus{
    _submitting = NO;
}

-(void)submitFeedback:(FeedbackModel*)feedback{
    if(_szAddImage && _szAddImage.imageInfos){
        NSMutableArray *imageUris = [NSMutableArray new];
        for(NSMutableDictionary *imageInfo in _szAddImage.imageInfos){
            if(imageInfo[@"uri"]) [imageUris addObject:imageInfo[@"uri"]];
            else if(imageInfo[@"uploading"]){
                //正在上传，1秒后再次检查
                [self performSelector:@selector(updateSubmittingStatus) withObject:self afterDelay:1.0f];
            }
        }
        feedback.imageUrls = imageUris;
    }
    NSMutableDictionary *params = [NSMutableDictionary new];
    if(feedback.contactType) [params setObject:feedback.contactType forKey:@"contactType"];
    if(feedback.content) [params setObject:feedback.content forKey:@"content"];
    if(feedback.imageUrls) [params setObject:feedback.imageUrls forKey:@"imageUrls"];
    if(feedback.phoneType) [params setObject:feedback.phoneType forKey:@"phoneType"];
    if(feedback.systemType) [params setObject:feedback.systemType forKey:@"systemType"];
    if(feedback.type==1) [params setObject:@"APP问题" forKey:@"type"];
    else if(feedback.type==2) [params setObject:@"出行问题" forKey:@"type"];
    if(feedback.titles) [params setObject:feedback.titles forKey:@"titles"];
    if(feedback.objectType) [params setObject:@(feedback.objectType) forKey:@"objectType"];
    if(feedback.dataDetailStr) [params setObject:feedback.dataDetailStr forKey:@"dataDetailStr"];
    __weak typeof(self) wkSelf = self;
    [[HttpHelper new] submit:request_feedback_submit params:params progress:^(NSProgress *progress) {
    } success:^(NSMutableDictionary *responseDic) {
        if(wkSelf.hud){
            [wkSelf.hud hideAnimated:YES];
            wkSelf.hud = nil;
        }
        [MBProgressHUD showInfo:@"提交成功，感谢您的反馈" detail:nil image:nil inView:nil];
        if(self.popView) self.popView();
    } failure:^(NSString *errorInfo) {
        if(wkSelf.hud){
            [wkSelf.hud hideAnimated:YES];
            wkSelf.hud = nil;
        }
        [MBProgressHUD showInfo:@"提交失败" detail:errorInfo image:nil inView:nil];
    }];
}

-(void)createTableLabel:(NSString*)title cell:(UICollectionViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    CGFloat width = SCREEN_WIDTH-view_margin;
    CGFloat labelX = 0;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(view_margin, 0, width, fitFloat(44))];
    
    UIView *selectIcon = [[UIView alloc] initWithFrame:CGRectMake(0, fitFloat(44-10)/2, fitFloat(10), fitFloat(10))];;
    
    if((_phoneType && [title isEqualToString:_phoneType]) || (_systemType && [title isEqualToString:_systemType])){
        CAGradientLayer *gl1 = [CAGradientLayer layer];
        gl1.frame = CGRectMake(0,0,fitFloat(10),fitFloat(10));
        gl1.startPoint = CGPointMake(0, 0);
        gl1.endPoint = CGPointMake(1, 1);
        gl1.colors = gradual_color_blue;
        gl1.locations = @[@(0), @(1.0f)];
        [selectIcon.layer addSublayer:gl1];
        selectIcon.layer.cornerRadius = fitFloat(10)/2;
        selectIcon.layer.masksToBounds = YES;
    }else {
        CAShapeLayer *gl1 = [CAShapeLayer layer];
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(fitFloat(10/2), fitFloat(10/2)) radius:fitFloat(10/2) startAngle:0 endAngle:M_PI * 2 clockwise:YES];
        gl1.frame = selectIcon.bounds;
        gl1.strokeColor = main_color_lightgray.CGColor;
        gl1.fillColor = [UIColor clearColor].CGColor;
        gl1.lineCap = kCALineCapSquare;
        gl1.path = path.CGPath;
        gl1.lineWidth = 1.0f;
        gl1.strokeStart = 0.0f;
        gl1.strokeEnd = 1.0f;
        [selectIcon.layer addSublayer:gl1];
//        if(!_layers) _layers = [NSMutableArray new];
//        [_layers addObject:gl1];
    }
    
    [view addSubview:selectIcon];
    
    labelX = labelX+fitFloat(10)+view_margin;
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, (fitFloat(44)-20)/2, view.width-labelX, 20)];
    titleLabel.font = main_font_small;
    titleLabel.textColor = dynamic_color_black;
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [view addSubview:titleLabel];
    
    CALayer *viewBorder = [CALayer layer];
    viewBorder.frame = CGRectMake(0, view.height-1, view.width, 1);
    viewBorder.backgroundColor = dynamic_color_lightgray.CGColor;
    viewBorder.opacity = 0.5;
    [view.layer addSublayer:viewBorder];
    [cell.contentView addSubview:view];
    if(!_layers) _layers = [NSMutableArray new];
    [_layers addObject:viewBorder];

    
    if((_phoneTypeSelecting && indexPath.section==1) || (_systemTypeSelecting && indexPath.section==2)){
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(selectedType:)];
        view.userInteractionEnabled = YES;
        view.tag = indexPath.item+indexPath.section*100;
        [view addGestureRecognizer:tap];
    }else{
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchTypeShow:)];
        view.userInteractionEnabled = YES;
        view.tag = indexPath.section;
        [view addGestureRecognizer:tap];
    }
}

-(void)createTextViewInCell:(UICollectionViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    _textView = [[UITextView alloc] initWithFrame:CGRectMake(view_margin, view_margin, SCREEN_WIDTH-view_margin*2, fitFloat(132))];
    [_textView setFont:[UIFont fontWithName:@"Arial" size:14]];
    _textView.returnKeyType = UIReturnKeyDefault;//return键的类型
    _textView.keyboardType = UIKeyboardTypeDefault;//键盘类型
    _textView.textAlignment = NSTextAlignmentLeft; //文本显示的位置默认为居左
    _textView.textColor= [UIColor darkGrayColor];
    _textView.text = placeHolderText;
    _textView.layer.cornerRadius = 6;
    _textView.layer.masksToBounds = YES;
    _textView.backgroundColor = dynamic_color_lightGrayWhite;
    _textView.textColor = dynamic_color_gray;
    
    _textView.delegate = self;
    _textLabel = [[UILabel alloc]initWithFrame:CGRectMake(SCREEN_WIDTH-fitFloat(100), _textView.height-10, 80, 20)];
    _textLabel.text = [NSString stringWithFormat: @"%d/%ld", 0, (long)contentMaxNum];
    _textLabel.font = [UIFont systemFontOfSize:12];
    _textLabel.textAlignment = NSTextAlignmentRight;
    _textLabel.tag=1;
    _textLabel.textColor = dynamic_color_gray;
    [cell.contentView addSubview:_textView];
    [cell.contentView addSubview:_textLabel];
}

-(void)createImageUploadViewInCell:(UICollectionViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    if(!_szAddImage) {
        _szAddImage = [[SZAddImage alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, fitFloat(72))];
        _szAddImage.uploadUrl = request_feedback_image_upload;
    }
    [cell.contentView addSubview:_szAddImage];
}
-(void)createTextFieldInCell:(UICollectionViewCell*)cell indexPath:(NSIndexPath*)indexPath{
    CGFloat width = SCREEN_WIDTH-view_margin;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(view_margin, 0, width, fitFloat(44))];
    
    CALayer *viewBorder = [CALayer layer];
    viewBorder.frame = CGRectMake(0, view.height-1, view.width, 1);
    viewBorder.backgroundColor = dynamic_color_lightgray.CGColor;
    viewBorder.opacity = 0.5;
    [view.layer addSublayer:viewBorder];
    [cell.contentView addSubview:view];
    if(!_layers) _layers = [NSMutableArray new];
    [_layers addObject:viewBorder];

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, (fitFloat(44-20))/2, fitFloat(56), fitFloat(20))];
    titleLabel.font = main_font_small;
    titleLabel.textColor = dynamic_color_black;
    titleLabel.text = @"联系方式";
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [view addSubview:titleLabel];
    
    _contactType = [[UITextField alloc] initWithFrame:CGRectMake(titleLabel.width, 0, view.width-titleLabel.width-view_margin, view.height)];
    _contactType.textAlignment = NSTextAlignmentRight;
    _contactType.textColor = dynamic_color_black;
    _contactType.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入微信/手机号/邮箱/QQ 等联系方式" attributes:@{NSFontAttributeName:sub_font_middle}];
    [view addSubview:_contactType];
}

-(void)selectedType:(UITapGestureRecognizer*)tap{
    if(tap.view.tag/100 == 1 && tap.view.tag%100<_phoneTypes.count){
        _phoneType = _phoneTypes[tap.view.tag%100];
        _phoneTypeSelecting = NO;
        [self reloadSections:[NSIndexSet indexSetWithIndex:1]];
        if(!_systemTypeSelecting && !_systemType){
            _systemTypeSelecting = YES;
            [self reloadSections:[NSIndexSet indexSetWithIndex:2]];
        }
    }else if(tap.view.tag/100 == 2 && tap.view.tag%100<_systemTypes.count){
        _systemType = _systemTypes[tap.view.tag%100];
        _systemTypeSelecting = NO;
        [self reloadSections:[NSIndexSet indexSetWithIndex:2]];
    }
    [self viewTapped];
}

-(void)createHeaderLabel:(NSString*)title reusableView:(UICollectionReusableView*)reusableView indexPath:(NSIndexPath*)indexPath{
    CGFloat width = SCREEN_WIDTH-view_margin;
    CGFloat labelX = 0;
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(view_margin, 0, width, fitFloat(44))];
    
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, (fitFloat(44)-20)/2, SCREEN_WIDTH-view_margin*2, 20)];
    titleLabel.font = main_font_small;
    titleLabel.textColor = dynamic_color_gray;
    titleLabel.text = title;
    titleLabel.textAlignment = NSTextAlignmentLeft;
    [view addSubview:titleLabel];
    
    CALayer *viewBorder = [CALayer layer];
    viewBorder.frame = CGRectMake(0, view.height, view.width, 1);
    viewBorder.backgroundColor = dynamic_color_lightgray.CGColor;
    viewBorder.opacity = 0.5;
    [view.layer addSublayer:viewBorder];
    [reusableView addSubview:view];
    if(!_layers) _layers = [NSMutableArray new];
    [_layers addObject:viewBorder];
    
    BOOL selecting = ((indexPath.section==1 && _phoneTypeSelecting) || (indexPath.section==2 && _systemTypeSelecting));
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:selecting?@"pull_up_big":@"pull_down_big"]];
    icon.frame = CGRectMake(view.width-view_margin-fitFloat(15), (view.height-fitFloat(15))/2, fitFloat(15), fitFloat(15));
    [view addSubview:icon];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchTypeShow:)];
    view.userInteractionEnabled = YES;
    view.tag = indexPath.section;
    [view addGestureRecognizer:tap];
}

-(void)switchTypeShow:(UITapGestureRecognizer*)tap{
    if(_type==1 && tap.view.tag==1){
        if(_phoneTypeSelecting) _phoneTypeSelecting = NO;
        else _phoneTypeSelecting = YES;
    }else if(_type==1 && tap.view.tag==2){
        if(_systemTypeSelecting) _systemTypeSelecting = NO;
        else _systemTypeSelecting = YES;
    }
    [self reloadSections:[NSIndexSet indexSetWithIndex:tap.view.tag]];
    [self viewTapped];
}





//返回collection的section数量
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    if(_type==1) return 7;
    else if(_type==2) return 5;
    else return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(section==0) return 1;
    
    if(_type==2) section = section+2;
    
    if(section==1){
        if(_phoneTypeSelecting) return 6;
        else if(_phoneType) return 1;
        else return 0;
    }else if(section==2){
        if(_systemTypeSelecting) return 4;
        else if(_systemType) return 1;
        else return 0;
    }else return 1;
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section==0) return CGSizeMake(SCREEN_WIDTH, fitFloat(44));
    
    NSInteger section = indexPath.section;
    if(_type==2) section = indexPath.section+2;
    
    if(section==1) return CGSizeMake(SCREEN_WIDTH, fitFloat(44));
    if(section==2) return CGSizeMake(SCREEN_WIDTH, fitFloat(44));
    if(section==3) return CGSizeMake(SCREEN_WIDTH, fitFloat(150));
    if(section==4) return CGSizeMake(SCREEN_WIDTH, fitFloat(78));
    if(section==6) return CGSizeMake(SCREEN_WIDTH, fitFloat(68)+SAFE_AREA_INSERTS_BOTTOM);
    return CGSizeMake(SCREEN_WIDTH, fitFloat(44));
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    if(section==0) return CGSizeZero;
    if(_type==2) section = section+2;
    if(section==1 || section==2) return CGSizeMake(SCREEN_WIDTH, fitFloat(44));
    if(section==6) return CGSizeMake(SCREEN_WIDTH, fitFloat(32));
    return CGSizeZero;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    if(_type==2) section = section+2;
    if(section==6) return CGSizeMake(SCREEN_WIDTH, SAFE_AREA_INSERTS_BOTTOM);
    return CGSizeZero;
}

//section盖住滚动条解决
- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath {
    view.layer.zPosition = 0.0;
}



-(void)viewTapped{
    if(_textView && _textView.editable) [_textView endEditing:YES];
    if(_contactType && _contactType.editing) [_contactType endEditing:YES];
}

-(void)textFieldTextDidChange{
    if(_contactType && _contactType.text.length>contactMaxNum){
        [MBProgressHUD showInfo:nil detail:@"超出限定字数" image:nil inView:nil];
        _contactType.text = _contactTypeStr?_contactTypeStr:@"";
        [_contactType endEditing:YES];
    }else{
        _contactTypeStr = _contactType.text;
    }
}

- (void)textViewDidChange:(UITextView *)textView{
    NSString *content = textView.text;
    NSInteger lines = [[content componentsSeparatedByString:@"\n"] count]-1;
    if(content.length>contentMaxNum || lines>contentMaxLine){
        textView.text = _textViewContent;
        return;
    }else{
        _textViewContent = textView.text;
    }
    
    if(textView.subviews && textView.subviews.count>0){
        if(_textLabel){
            _textLabel.text = [NSString stringWithFormat: @"%lu/%d", (unsigned long)content.length, contentMaxNum];
        }
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if(textView.text.length < 1){
        textView.text = placeHolderText;
        textView.textColor = [UIColor darkGrayColor];
    }
}
- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if([textView.text isEqualToString:placeHolderText]){
        textView.text=@"";
        textView.textColor=dynamic_color_black;
    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [self viewTapped];
}
#pragma mark -keyboard
-(void)keyboardWillChange:(NSNotification *)aNotification{
    NSDictionary *userInfo = aNotification.userInfo;
    CGFloat duration = [userInfo[@"UIKeyboardAnimationDurationUserInfoKey"] doubleValue];
    CGRect keyFrame = [userInfo[@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
    int height = keyFrame.size.height - SAFE_AREA_INSERTS_BOTTOM;
    CGRect rect = [_textView.superview convertRect:_textView.frame toView:self];
    if(_contactType.isEditing) rect = [_contactType.superview convertRect:_contactType.frame toView:self];

    __weak typeof(self) wkSelf = self;
    [UIView animateWithDuration:duration animations:^{
        if(keyFrame.origin.y<SCREEN_HEIGHT){
            int textViewMaxY = rect.origin.y + rect.size.height;
            int offset = height-(self.height-(textViewMaxY-self.contentOffset.y)) + self.contentOffset.y;
            offset = offset<0?0:offset;
            self.contentOffset = CGPointMake(0, offset);
        }else if(wkSelf.contentSize.height-wkSelf.contentOffset.y < wkSelf.height){
            CGFloat offset = wkSelf.contentSize.height-wkSelf.height;
            self.contentOffset = CGPointMake(0, offset<0?0:offset);
        }
    } completion:^(BOOL finished) {
    }];
}


- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    // trait发生了改变
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            if(self.layers) for(CALayer *layer in self.layers){
                if([layer isKindOfClass:CAShapeLayer.class]){
                    CAShapeLayer *slayer = (CAShapeLayer*)layer;
                    slayer.strokeColor = main_color_lightgray.CGColor;
                } else{
                    layer.backgroundColor = dynamic_color_lightgray.CGColor;
                }
            }
        }
    } else {
    }
}
@end
