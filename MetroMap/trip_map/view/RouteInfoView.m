//
//  RouteInfoView.m
//  MetroMap
//
//  Created by edwin on 2019/10/11.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "RouteInfoView.h"

@interface RouteInfoView()
@property(nonatomic, retain) UIImageView *pullButton;
@property(nonatomic, retain) UIView *pullButtonView;
@property(nonatomic, retain) ScrollSignView *scrollSignView;
@property(nonatomic, retain) RouteCollectionView *routeCollectionView;

@property (nonatomic, retain) NSMutableArray<RouteModel*> *routesList;
@property(nonatomic, retain) NSString *startName;
@property(nonatomic, retain) NSString *endName;
@property(nonatomic, retain) UIView *shareButton;
@property(nonatomic, retain) UIView *tripButton;
@property(nonatomic, retain) UIView *feedbackButton;
@property(nonatomic, retain) UIView *titleView;

@property(nonatomic, retain) NSMutableArray *layers;

@end

@implementation RouteInfoView

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    self.backgroundColor = dynamic_color_white;
    self.layer.cornerRadius = 12;
    self.layer.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.1].CGColor;
    self.layer.shadowOffset = CGSizeMake(0,-3);
    self.layer.shadowOpacity = 1;
    self.layer.shadowRadius = 12;
    return self;
}

-(void)setRouteHelper:(RouteHelpManager *)routeHelper{
    _routeHelper = routeHelper;
    if(routeHelper){
        _routesList = _routeHelper.routeList;
        _startName = _routeHelper.startStation.nameCn;
        _endName = _routeHelper.endStation.nameCn;
    }
}

-(void)loadData{
    [self initTitileBar];
    [self initMainView];
    [self createRouteCollectionView];
    
//    _scrollSignView = [[ScrollSignView alloc] initWithFrame:CGRectMake(view_margin*2, SAFE_AREA_INSERTS_BOTTOM>0?fitFloat(36+52*2+20+40+12):fitFloat(36+52*2+20+40+24), self.width-view_margin*4, 6) sum:_routesList.count selected:0 align:SignAlignCenter];
    _scrollSignView = [[ScrollSignView alloc] initWithFrame:CGRectMake(view_margin*2, fitFloat(36+52*2+72), self.width-view_margin*4, 6) sum:_routesList.count selected:0 align:SignAlignCenter];
    [self addSubview:_scrollSignView];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerAction:)];
    [pan setMaximumNumberOfTouches:1];
    [pan setMinimumNumberOfTouches:1];
    [self addGestureRecognizer:pan];
}



//-(void)pullButtonView:(UIView*)view scale:(CGFloat)scale{
//    scale = scale>1?1:scale;
//    scale = scale<-1?-1:scale;
//    CGFloat offset = scale*6;
//
//    UIBezierPath *maskPath = [UIBezierPath bezierPath];
//    [maskPath moveToPoint:CGPointMake(2+view.x, 3+view.y)];
//    [maskPath addQuadCurveToPoint:CGPointMake(2+view.x, 6+view.y) controlPoint:CGPointMake(0+view.x, 4.5+view.y)];
//    [maskPath addLineToPoint:CGPointMake(17+view.x, 6+offset+view.y)];
//    [maskPath addLineToPoint:CGPointMake(32+view.x, 6+view.y)];
//    [maskPath addQuadCurveToPoint:CGPointMake(32+view.x, 3+view.y) controlPoint:CGPointMake(34+view.x, 4.5+view.y)];
//    [maskPath addLineToPoint:CGPointMake(17+view.x, 3+offset+view.y)];
//    [maskPath closePath];
//    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
//    maskLayer.frame = view.frame;
//    maskLayer.path = maskPath.CGPath;
//    view.layer.mask = maskLayer;
//}

-(void)initTitileBar{
    _pullButton = [[UIImageView alloc] initWithFrame:CGRectMake((self.width-fitFloat(36))/2, 0, fitFloat(36), fitFloat(36))];
    _pullButton.image = [UIImage imageNamed:@"message_pull_up"];
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchWindow)];
    [_pullButton addGestureRecognizer:tap1];
    _pullButton.userInteractionEnabled = YES;
    [self addSubview:_pullButton];
    
//    _pullButtonView = [[UIView alloc] initWithFrame:CGRectMake((self.width-34)/2, 13, 34, 20)];
//    CAGradientLayer *gl1 = [CAGradientLayer layer];
//    gl1.frame = CGRectMake(0,0,34,20);
//    gl1.startPoint = CGPointMake(0.5, 0);
//    gl1.endPoint = CGPointMake(0.5, 1);
//    gl1.colors = gradual_color_blue;
//    gl1.locations = @[@(0), @(1.0f)];
//    [_pullButtonView.layer addSublayer:gl1];
//    [self pullButtonView:_pullButtonView scale:-1];
////    _pullButtonView.transform = CGAffineTransformMakeTranslation((self.width-36)/2, 13);
//    [self addSubview:_pullButtonView];
    
//    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(switchWindow:)];
//    [_pullButton addGestureRecognizer:tap1];
//    _pullButton.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeWindow:)];
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeWindow:)];
    UILabel *closeLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.width-view_margin-fitFloat(28), 6, fitFloat(28), 20)];
    closeLabel.font = main_font_small;
    closeLabel.textColor = main_color_pink;
    closeLabel.text = @"取消";
    [self addSubview:closeLabel];
    [closeLabel addGestureRecognizer:tap2];
    closeLabel.userInteractionEnabled = YES;
    
    UIImageView *closeButton = [[UIImageView alloc] initWithFrame:CGRectMake(self.width-view_margin-fitFloat(28)-3-fitFloat(15), 9, fitFloat(15), fitFloat(15))];
    closeButton.image = [UIImage imageNamed:@"cancel_icon"];
    [closeButton addGestureRecognizer:tap3];
    closeButton.userInteractionEnabled = YES;
    [self addSubview:closeButton];
}

-(void)initMainView{
    _titleView = [[UIView alloc] initWithFrame:CGRectMake(view_margin*2, fitFloat(36), self.width-view_margin*4, fitFloat(52))];
    CALayer *viewBorder = [CALayer layer];
    viewBorder.frame = CGRectMake(0, _titleView.height-1, _titleView.width, 1);
    viewBorder.backgroundColor = dynamic_color_lightgray.CGColor;
    viewBorder.opacity = 0.5;
    [_titleView.layer addSublayer:viewBorder];
    _titleView.backgroundColor = dynamic_color_white;
    [self addSubview:_titleView];
    if(!_layers) _layers = [NSMutableArray new];
    [_layers addObject:viewBorder];
    
    
    UIImageView *movingIcon = [[UIImageView alloc] initWithFrame:CGRectMake((_titleView.width-42)/2, fitFloat(52-14)/2, 42, fitFloat(14))];
    [movingIcon setImage:[UIImage imageNamed:@"moving_icon"]];
    [_titleView addSubview:movingIcon];
    
    CGSize startSize = [_startName sizeWithAttributes:@{NSFontAttributeName:main_font_small}];
    CGSize endSize = [_endName sizeWithAttributes:@{NSFontAttributeName:main_font_small}];
    CGFloat startWidth = startSize.width>((_titleView.width-42)/2-24-6)?((_titleView.width-42)/2-24-6):startSize.width;
    CGFloat endWidth = endSize.width>((_titleView.width-42)/2-24-6)?((_titleView.width-42)/2-24-6):endSize.width;
    UILabel *startStationName = [[UILabel alloc] initWithFrame:CGRectMake(18, (52-startSize.height)/2, startWidth, startSize.height)];
    startStationName.font = main_font_small;
    startStationName.textColor = dynamic_color_black;
    startStationName.textAlignment = NSTextAlignmentLeft;
    startStationName.text = _startName;
    [_titleView addSubview:startStationName];
    UILabel *endStationName = [[UILabel alloc] initWithFrame:CGRectMake(_titleView.width-endWidth, (52-endSize.height)/2, endWidth, endSize.height)];
    endStationName.font = main_font_small;
    endStationName.textColor = dynamic_color_black;
    endStationName.textAlignment = NSTextAlignmentRight;
    endStationName.text = _endName;
    [_titleView addSubview:endStationName];
    
    UIView *subStartIcon = [[UIView alloc] initWithFrame:CGRectMake(0, 23, 6, 6)];
    CAGradientLayer *gl = [CAGradientLayer layer];
    gl.frame = CGRectMake(0,0,6,6);
    gl.startPoint = CGPointMake(0, 0);
    gl.endPoint = CGPointMake(1, 1);
    gl.colors = gradual_color_blue;
    gl.locations = @[@(0), @(1.0f)];
    [subStartIcon.layer addSublayer:gl];
    subStartIcon.layer.cornerRadius = 3;
    subStartIcon.layer.masksToBounds = YES;
    [_titleView addSubview:subStartIcon];
    
    UIView *subEndIcon = [[UIView alloc] initWithFrame:CGRectMake(_titleView.width-endWidth-12-6, 23, 6, 6)];
    CAGradientLayer *gl1 = [CAGradientLayer layer];
    gl1.frame = CGRectMake(0,0,6,6);
    gl1.startPoint = CGPointMake(0, 0);
    gl1.endPoint = CGPointMake(1, 1);
    gl1.colors = gradual_color_pink;
    gl1.locations = @[@(0), @(1.0f)];
    [subEndIcon.layer addSublayer:gl1];
    subEndIcon.layer.cornerRadius = 3;
    subEndIcon.layer.masksToBounds = YES;
    [_titleView addSubview:subEndIcon];
    
    UIView *guideView = [[UIView alloc] initWithFrame:CGRectMake(view_margin*2, fitFloat(36+52)+1, self.width-view_margin*4, fitFloat(52))];
    CALayer *guideViewBorder = [CALayer layer];
    guideViewBorder.frame = CGRectMake(0, guideView.height, guideView.width, 1);
    guideViewBorder.backgroundColor = dynamic_color_lightgray.CGColor;
    guideViewBorder.opacity = 0.5;
    [guideView.layer addSublayer:guideViewBorder];
    [self addSubview:guideView];
    if(!_layers) _layers = [NSMutableArray new];
    [_layers addObject:guideViewBorder];

    CGFloat margin = (self.width-66-66-102-24-24)/2;
    CGFloat middleHeight = fitFloat(36+52*2+72+6+12+(SAFE_AREA_INSERTS_BOTTOM>0?52:40)) + ceil(SCREEN_HEIGHT/3)+ fitFloat(12);
//    _shareButton = [[UIView alloc] initWithFrame:CGRectMake(self.width-66-66-24-margin, SAFE_AREA_INSERTS_BOTTOM>0?fitFloat(473+26):(fitFloat(473+26)+14), 66, 22)];
    _shareButton = [[UIView alloc] initWithFrame:CGRectMake(self.width-66-66-24-margin, middleHeight-(SAFE_AREA_INSERTS_BOTTOM>0?52:40), 66, 22)];
    _shareButton.layer.cornerRadius = 6;
    _shareButton.layer.borderColor = dynamic_color_gray.CGColor;
    _shareButton.layer.borderWidth = 0.5;
    UIImageView *shareIcon = [[UIImageView alloc] initWithFrame:CGRectMake(26-fitFloat(15), (22-fitFloat(15))/2, fitFloat(15), fitFloat(15))];
    [shareIcon setImage:[UIImage imageNamed:@"share_icon"]];
    [_shareButton addSubview:shareIcon];
    UILabel *shareLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, (22-fitFloat(17))/2, fitFloat(24), fitFloat(17))];
    shareLabel.font = sub_font_middle;
    shareLabel.textColor = dynamic_color_gray;
    shareLabel.textAlignment = NSTextAlignmentLeft;
    shareLabel.text = @"分享";
    [_shareButton addSubview:shareLabel];
    UITapGestureRecognizer *shareTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(shareRoute:)];
    _shareButton.userInteractionEnabled = YES;
    [_shareButton addGestureRecognizer:shareTap];
    [self addSubview:_shareButton];
    
    _tripButton = [[UIView alloc] initWithFrame:CGRectMake(self.width-66-66-102-24-24-margin, middleHeight-(SAFE_AREA_INSERTS_BOTTOM>0?52:40), 102, 22)];
    _tripButton.layer.cornerRadius = 6;
    _tripButton.layer.borderColor = dynamic_color_gray.CGColor;
    _tripButton.layer.borderWidth = 0.5;
    UIImageView *tripCollectIcon = [[UIImageView alloc] initWithFrame:CGRectMake(26-fitFloat(15), (22-fitFloat(15))/2, fitFloat(15), fitFloat(15))];
    [tripCollectIcon setImage:[UIImage imageNamed:@"add_trip"]];
    [_tripButton addSubview:tripCollectIcon];
    UILabel *tripLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, (22-fitFloat(17))/2, fitFloat(60), fitFloat(17))];
    tripLabel.font = sub_font_middle;
    tripLabel.textColor = dynamic_color_gray;
    tripLabel.textAlignment = NSTextAlignmentLeft;
    tripLabel.text = @"添加行程";
    [_tripButton addSubview:tripLabel];
    UITapGestureRecognizer *tripTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addTrip:)];
    _tripButton.userInteractionEnabled = YES;
    [_tripButton addGestureRecognizer:tripTap];
    [self addSubview:_tripButton];
    
    _feedbackButton = [[UIView alloc] initWithFrame:CGRectMake(self.width-66-margin, middleHeight-(SAFE_AREA_INSERTS_BOTTOM>0?52:40), 66, 22)];
    _feedbackButton.layer.cornerRadius = 6;
    _feedbackButton.layer.borderColor = dynamic_color_gray.CGColor;
    _feedbackButton.layer.borderWidth = 0.5;
    UIImageView *feedbackIcon = [[UIImageView alloc] initWithFrame:CGRectMake(26-fitFloat(15), (22-fitFloat(15))/2, fitFloat(15), fitFloat(15))];
    [feedbackIcon setImage:[UIImage imageNamed:@"feedback_icon"]];
    [_feedbackButton addSubview:feedbackIcon];
    UILabel *feedbackLabel = [[UILabel alloc] initWithFrame:CGRectMake(30, (22-fitFloat(17))/2, fitFloat(60), fitFloat(17))];
    feedbackLabel.font = sub_font_middle;
    feedbackLabel.textColor = dynamic_color_gray;
    feedbackLabel.textAlignment = NSTextAlignmentLeft;
    feedbackLabel.text = @"报错";
    [_feedbackButton addSubview:feedbackLabel];
    UITapGestureRecognizer *feedbackTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(feedbackTap:)];
    _feedbackButton.userInteractionEnabled = YES;
    [_feedbackButton addGestureRecognizer:feedbackTap];
    [self addSubview:_feedbackButton];
}

-(void)createRouteCollectionView{
    __weak typeof(self) wkSelf = self;
//    _routeCollectionView = [[RouteCollectionView alloc] initWithFrame:CGRectMake(0, fitFloat(88), self.width, SAFE_AREA_INSERTS_BOTTOM>0?fitFloat(373+26):(fitFloat(373+26)-20)) routes:_routesList];
    _routeCollectionView = [[RouteCollectionView alloc] initWithFrame:CGRectMake(0, fitFloat(88), self.width, ceil(SCREEN_HEIGHT/3)+fitFloat(52+72+6+12)) routes:_routesList];
    [_routeCollectionView hideDetailView:YES];
    [_routeCollectionView setSwitchSelected:^(NSInteger selectedIndex) {
        [wkSelf.scrollSignView switchSelected:selectedIndex];
        [wkSelf switchSelected:selectedIndex];
    }];
    [_routeCollectionView setShowRouteDetail:^(NSInteger selectedIndex) {
        if(wkSelf.transform.ty==0) [wkSelf switchWindow];
    }];
    [self addSubview:_routeCollectionView];
}

-(void)switchSelected:(NSInteger)index{
    __weak typeof(self) wkSelf = self;
    RouteModel *route = _routeHelper.routeList[index];
    BOOL detailQueried = route.detailQueried;
//    [_routeHelper querySegmentPassBy:index success:^(NSMutableArray *segments) {
//        if ([NSThread isMainThread]) {
//            if(!detailQueried) [wkSelf.routeCollectionView reloadData];
//            if(wkSelf.switchSelected) wkSelf.switchSelected(index);
//        } else {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                if(!detailQueried) [wkSelf.routeCollectionView reloadData];
//                if(wkSelf.switchSelected) wkSelf.switchSelected(index);
//            });
//        }
//    }];
    [_routeHelper getRouteAtIndex:index success:^(RouteModel *routeInfo) {
        if ([NSThread isMainThread]) {
            if(!detailQueried) [wkSelf.routeCollectionView reloadData];
            if(wkSelf.switchSelected) wkSelf.switchSelected(index);
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                if(!detailQueried) [wkSelf.routeCollectionView reloadData];
                if(wkSelf.switchSelected) wkSelf.switchSelected(index);
            });
        }
    }];
}
-(void)switchWindow{
    __weak typeof(self) wkSelf = self;
    if(self.transform.ty<0){
        [UIView animateWithDuration:.5f animations:^{
            wkSelf.transform = CGAffineTransformIdentity;
            [wkSelf.routeCollectionView hideDetailView:YES];
        } completion:^(BOOL finished) {
            wkSelf.pullButton.image = [UIImage imageNamed:@"message_pull_up"];
        }];
    }else{
//        CGFloat minHeight = SAFE_AREA_INSERTS_BOTTOM>0?(fitFloat(226+26)):(fitFloat(226+26)+14);
//        CGFloat middleHeight = SAFE_AREA_INSERTS_BOTTOM>0?(fitFloat(519+26)):(fitFloat(519+26)+14);
        CGFloat middleDetailHeight = ceil(SCREEN_HEIGHT/3);
        CGFloat minHeight = fitFloat(36+52*2+72+6+12) + SAFE_AREA_INSERTS_BOTTOM;
        CGFloat middleHeight = fitFloat(36+52*2+72+6+12+(SAFE_AREA_INSERTS_BOTTOM>0?52:40)) + middleDetailHeight + fitFloat(12);
        CGFloat dist = middleHeight-minHeight;
        [UIView animateWithDuration:.5f animations:^{
            wkSelf.transform = CGAffineTransformMakeTranslation(0, -dist);
            [wkSelf.routeCollectionView hideDetailView:NO];
        } completion:^(BOOL finished) {
            self.pullButton.image = [UIImage imageNamed:@"message_pull_down"];
        }];
    }
}
-(void)closeWindow:(UITapGestureRecognizer*)tap{
    if(self.closeRouteSearch) self.closeRouteSearch();
    [self removeFromSuperview];
}
-(void)shareRoute:(UITapGestureRecognizer*)tap{
    UIImage *image = [_routeCollectionView getImageWithCustomRect];
    RouteModel *routeInfo = [_routeCollectionView getCurentRouteInfo];
    
    UIImage *logoTitle = [UIImage imageNamed:@"share_title"];
    UIImageView *logoView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, ceil(logoTitle.size.height/logoTitle.size.width*SCREEN_WIDTH)+1)];
    [logoView setImage:logoTitle];
    logoView.contentMode = UIViewContentModeScaleAspectFit;
    logoView.backgroundColor = dynamic_color_white;
    UIImage *logoImage = [logoView viewCutter];
    
    if(_titleView){
//        UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, _titleView.height+view_margin)];
//        if(!_titleView.backgroundColor || [_titleView.backgroundColor isEqual:[UIColor clearColor]])
//            titleView.backgroundColor = dynamic_color_white;
//        else titleView.backgroundColor = _titleView.backgroundColor;
//        NSData *tempArchive = [NSKeyedArchiver archivedDataWithRootObject:_titleView];
//        UIView *tempView = [NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
//        tempView.backgroundColor = dynamic_color_white;
//        tempView.frame = CGRectMake((SCREEN_WIDTH-_titleView.width)/2, view_margin, _titleView.width, _titleView.height);
//        [titleView addSubview:tempView];
//        UIImage *title = [titleView viewCutter];
        
        UIImage *title = [_titleView viewCutter];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:title];
        imageView.frame = CGRectMake(0, 0, SCREEN_WIDTH, _titleView.height);
        imageView.backgroundColor = dynamic_color_white;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        title = [imageView viewCutter];
        image = [BaseUtils combineImageUpImage:title DownImage:image];
    }
    
    image = [BaseUtils combineImageUpImage:logoImage DownImage:image];
    if(image && self.shareRouteImage) self.shareRouteImage(image, routeInfo);
}
-(void)addTrip:(UITapGestureRecognizer*)tap{
    [_routeCollectionView collectRouteInfo];
}
-(void)feedbackTap:(UITapGestureRecognizer*)tap{
    RouteModel *routeInfo = [_routeCollectionView getCurentRouteInfo];
    if(self.feedbackRouteInfo) self.feedbackRouteInfo(routeInfo);
}

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)pan {
    if (pan.state == UIGestureRecognizerStateChanged || pan.state == UIGestureRecognizerStateEnded) {
        UIView *view = pan.view;
        CGPoint offset = [pan translationInView:view];
        CGFloat transY = view.transform.ty + offset.y;
        
        __weak typeof(self) wkSelf = self;
//        CGFloat minHeight = SAFE_AREA_INSERTS_BOTTOM>0?(fitFloat(226+26)):(fitFloat(226+26)+14);
//        CGFloat middleHeight = SAFE_AREA_INSERTS_BOTTOM>0?(fitFloat(519+26)):(fitFloat(519+26)+14);
        CGFloat middleDetailHeight = ceil(SCREEN_HEIGHT/3);
        CGFloat minHeight = fitFloat(36+52*2+72+6+12) + SAFE_AREA_INSERTS_BOTTOM;
        CGFloat middleHeight = fitFloat(36+52*2+72+6+12+(SAFE_AREA_INSERTS_BOTTOM>0?52:40)) + middleDetailHeight + fitFloat(12);
        CGFloat dist = middleHeight-minHeight;
        CGFloat maxTy = -(SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT-minHeight);
                if (pan.state == UIGestureRecognizerStateEnded) {
                    [UIView animateWithDuration:0.25 animations:^{
                        if(view.transform.ty<-350){
                            view.transform = CGAffineTransformMakeTranslation(0, -(SCREEN_HEIGHT-NAVIGATION_BAR_HEIGHT-STATUS_BAR_HEIGHT-minHeight));
                            if(wkSelf.shareButton) wkSelf.shareButton.transform = CGAffineTransformMakeTranslation(0, -(maxTy+dist));
                            if(wkSelf.tripButton) wkSelf.tripButton.transform = CGAffineTransformMakeTranslation(0, -(maxTy+dist));
                            if(wkSelf.feedbackButton) wkSelf.feedbackButton.transform = CGAffineTransformMakeTranslation(0, -(maxTy+dist));
                            [wkSelf.routeCollectionView hideDetailView:NO];
                            [wkSelf.routeCollectionView resetViewHeight:-maxTy-dist+middleDetailHeight];
        //                    [wkSelf pullButtonView:wkSelf.pullButtonView scale:1];
                            wkSelf.pullButton.image = [UIImage imageNamed:@"message_pull_down"];
                        }else if(view.transform.ty<-100){
                            view.transform = CGAffineTransformMakeTranslation(0, -dist);
                            if(wkSelf.shareButton) wkSelf.shareButton.transform = CGAffineTransformIdentity;
                            if(wkSelf.tripButton) wkSelf.tripButton.transform = CGAffineTransformIdentity;
                            if(wkSelf.feedbackButton) wkSelf.feedbackButton.transform = CGAffineTransformIdentity;
                            [wkSelf.routeCollectionView hideDetailView:NO];
                            [wkSelf.routeCollectionView resetViewHeight:middleDetailHeight];
        //                    [wkSelf pullButtonView:wkSelf.pullButtonView scale:1];
                            wkSelf.pullButton.image = [UIImage imageNamed:@"message_pull_down"];
                        }else {
                            view.transform = CGAffineTransformIdentity;
                            if(wkSelf.shareButton) wkSelf.shareButton.transform = CGAffineTransformIdentity;
                            if(wkSelf.tripButton) wkSelf.tripButton.transform = CGAffineTransformIdentity;
                            if(wkSelf.feedbackButton) wkSelf.feedbackButton.transform = CGAffineTransformIdentity;
                            [wkSelf.routeCollectionView hideDetailView:YES];
        //                    [wkSelf pullButtonView:wkSelf.pullButtonView scale:-1];
                            wkSelf.pullButton.image = [UIImage imageNamed:@"message_pull_up"];
                        }
                    } completion:^(BOOL finished) {
                    }];
                } else {
                    view.transform = CGAffineTransformMakeTranslation(0, transY>maxTy?transY:maxTy);
        //            if(view.transform.ty>=-293){
        //                CGFloat percent = 1/293*2 * ((view.transform.ty>293/2)?-1:1);
        //                [wkSelf pullButtonView:wkSelf.pullButtonView scale:percent];
        //            }
                    if(view.transform.ty<-dist){
                        if(_shareButton) _shareButton.transform = CGAffineTransformMakeTranslation(0, -(view.transform.ty+dist));
                        if(_tripButton) _tripButton.transform = CGAffineTransformMakeTranslation(0, -(view.transform.ty+dist));
                        if(_feedbackButton) _feedbackButton.transform = CGAffineTransformMakeTranslation(0, -(view.transform.ty+dist));
                    }
                    if(view.transform.ty<0){
                        [self.routeCollectionView hideDetailView:NO];
                    }
                }
                [pan setTranslation:CGPointMake(0, 0) inView:view];
            }
        }


        -(void)updateCGColors{
            if(self.layers) for(CALayer *layer in self.layers){
                layer.backgroundColor = dynamic_color_lightgray.CGColor;
            }
            if(_tripButton) _tripButton.layer.borderColor = dynamic_color_gray.CGColor;
            if(_shareButton) _shareButton.layer.borderColor = dynamic_color_gray.CGColor;
            if(_feedbackButton) _feedbackButton.layer.borderColor = dynamic_color_gray.CGColor;
        }
        @end
