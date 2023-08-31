//
//  FMenuAlert.h
//  test-metro
//
//  Created by edwin on 2019/6/14.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MetroStationInfo.h"
#import "CityInfo.h"

#import "UIImage+YHPDFIcon.h"
#import "DataUtils.h"
#import "BaseUtils.h"

#import "UIImage+SVGManager.h"
#import "SVGKImage.h"

@class FMenuAlert;

@protocol  TableViewLayoutDeleaget<NSObject>

@required
//每个item的高度
- (CGFloat)menuAlertLayout:(FMenuAlert *)menuAlertLayout heightForItemAtIndexPath:(NSUInteger)indexPath itemWidth:(CGFloat)itemWidth;

@end

@interface FMenuAlert : UIView
// 显示字体设置
@property(nonatomic,assign)UIFont * cusFont;

/**
 点击回调,返回所点的角标以及点击的内容
 */
@property(nonatomic, copy) void(^didSelectedCallback)(NSInteger index, NSObject * content);

@property(nonatomic, copy) void(^previewMap)(NSInteger index, NSString *pdfName);
/// 数据源 数据, 下拉列表的内容数组.
@property(nonatomic, strong) NSMutableArray * arrMDataSource;

//@property(nonatomic, retain) MetroStationInfo *station;
//@property(nonatomic, retain) NSMutableArray *routeList;
// tableview以及cell的背景色, 如果不设置默认白色
//@property(nonatomic, strong) UIColor * tabColor;
// 文字的颜色, 默认黑色
//@property(nonatomic, strong) UIColor * txtColor;

//0显示菜单（定高）1显示下拉菜单（不定高）2显示站点信息 3显示路线信息
@property(nonatomic,assign)int type;
@property(nonatomic,assign)float maxHeight;

@property(nonatomic,assign)NSIndexPath *selIndex;

-(instancetype)initWithFrame:(CGRect)frame withType:(int)type withMaxHeight:(float)maxHeight;
-(void)setDefaultSelect:(NSInteger) row section:(NSInteger) section;
    
@end
