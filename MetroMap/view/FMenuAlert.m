//
//  FMenuAlert.m
//  test-metro
//
//  Created by edwin on 2019/6/14.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "FMenuAlert.h"
#import "MetroStationInfo.h"
#import "RouteInfo.h"
#import "ColorUtils.h"

#define TINY_ROW_HIGHT (CGFloat)(40);
#define STATION_ROW_HIGHT (CGFloat)(100);
#define ROUTE_ROW_HIGHT (CGFloat)(160);
@interface FMenuAlert ()<UITableViewDataSource, UITableViewDelegate>
@property(nonatomic, strong) UITableView * tableView;
@property (nonatomic) CGFloat estimatedRowHeight NS_AVAILABLE_IOS(7_0); // default is UITableViewAutomaticDimension, set to 0 to disable


@property(nonatomic, assign) CGSize textSize;
@end

@implementation FMenuAlert

-(instancetype)initWithFrame:(CGRect)frame withType:(int)type withMaxHeight:(float)maxHeight{
    if (self = [super initWithFrame:frame]) {
        _type = type;
        _maxHeight = maxHeight;
        [self initUI];
        if(type==0){
            _tableView.backgroundColor = [UIColor grayColor];
        }
    }
    return self;
}


-(void)initUI{
//    UIImage *pulldown = [UIImage imageNamed:@"pulldown"];
//    CGSize pulldownSize = pulldown.size;
//    self.textSize = pulldownSize;
//    UITableView * tableView = nil;
    UITableView *tableView= [UITableView new];
    
//    if(_type==2){
//        tableView  = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStyleGrouped];
//    }else{
////        tableView= [UITableView new];
//        tableView  = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
//    }
    
    tableView.showsVerticalScrollIndicator = NO;
    tableView.frame = self.bounds;
//    tableView.frame = CGRectMake(0, pulldownSize.height, self.bounds.size.width, self.bounds.size.height-pulldownSize.height);
    [self addSubview:tableView];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.userInteractionEnabled = YES;
    self.tableView = tableView;
    tableView.rowHeight = TINY_ROW_HIGHT;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"fmenualert"];
//    self.tabColor = [UIColor whiteColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
    
    
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    [self.tableView addObserver:self forKeyPath:@"contentSize" options:0 context:NULL];
    self.tableView.contentSize = CGSizeMake(self.tableView.contentSize.width,0);
    
    if(_type==11 || _type==4){
        self.tableView.separatorStyle = UITableViewCellEditingStyleNone;     //让tableview不显示分割线
    }
    
    if(_type!=4) {
        if(_type!=3 && _type!=11) self.tableView.layer.cornerRadius = 8;
    }else{
        self.tableView.showsVerticalScrollIndicator = YES;
        self.tableView.backgroundColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
    }
//    self.tableView.layer.masksToBounds = YES;
//    self.tableView.layer.borderWidth = 8;
//    [self addSubview:tableView];
    
//    UIImageView *iview = [[UIImageView alloc] initWithImage:pulldown];
//    iview.frame = CGRectMake(0, 0, pulldownSize.width, pulldownSize.height);
//    [self addSubview:iview];
    
}

-(void)setArrMDataSource:(NSMutableArray *)arrMDataSource{
    _arrMDataSource = arrMDataSource;
    [_tableView reloadData];
}

-(void)setDefaultSelect:(NSInteger) row section:(NSInteger) section{
    NSIndexPath *firstPath = [NSIndexPath indexPathForRow:row inSection:section];
    [self.tableView selectRowAtIndexPath:firstPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    if ([self.tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:firstPath];
    }
}

#pragma mark --observe content size
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    //type==0为定高
    if([keyPath isEqualToString: @"contentSize"] && _type>0 && _type!=3 && _type!=11){
        CGRect frame = self.tableView.frame;
        CGFloat height = self.tableView.contentSize.height+10;
        height = (_maxHeight>0&&_maxHeight<height)?_maxHeight:height;
        self.tableView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, height);
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, frame.size.width, height);
    }
}

#pragma mark --callback
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.didSelectedCallback) {
        if(_type==2){
            MetroLineInfo *minfo = _arrMDataSource[indexPath.section];
            MetroStationInfo *sinfo = minfo.stations[indexPath.row];
            NSArray *lineNames = [sinfo.locationByLines allKeys];
            if([@(0) compare: sinfo.status]!=NSOrderedSame && [lineNames containsObject:minfo.lineName]){
                self.didSelectedCallback(indexPath.row, sinfo);
            }
        }else{
            self.didSelectedCallback(indexPath.row, _arrMDataSource[indexPath.row]);
        }
    }
    if(_type==4){
        UITableViewCell *celled = [_tableView cellForRowAtIndexPath:_selIndex];
//        celled.contentView.backgroundColor = [UIColor whiteColor];
        celled.contentView.backgroundColor = [UIColor clearColor];
        
        _selIndex = indexPath;
        UITableViewCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
        cell.contentView.backgroundColor = [ColorUtils colorWithHexString:@"#BDBDBD"];
        [tableView reloadData];
    }
}

-(void) previewMetroMap:(UIButton *)btn{
    CityInfo *cinfo = self.arrMDataSource[btn.tag];
    if (self.previewMap) {
        self.previewMap(btn.tag, cinfo.namePdf);
    }
}

#pragma mark --tableView
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"fmenualert" forIndexPath:indexPath];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tableView.frame.size.width, cell.frame.size.height);
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.backgroundColor = [UIColor clearColor];
    if(_type==3){
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 5, 0, 5)];
        //站点
//        MetroBetweenInfo *binfo = (MetroBetweenInfo*)_arrMDataSource[indexPath.row];
        NSMutableDictionary *binfo = _arrMDataSource[indexPath.row];
        UILabel *label0 = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width/4, 0, cell.frame.size.width/2, 30)];
//        label0.text = binfo.line.lineName;
        MetroLineInfo * line = [binfo objectForKey:@"line"];
        label0.text = [NSString stringWithFormat:@"  %@",line.lineName];
        label0.textColor = [UIColor blackColor];
        label0.textAlignment = NSTextAlignmentCenter;
//        label0.backgroundColor = [UIColor clearColor];
        label0.backgroundColor = [ColorUtils colorWithHexString:line.lineColor];
        label0.font = [UIFont fontWithName:@"KFONT" size:15];
        [cell.contentView addSubview:label0];
        
        NSMutableArray *times = [binfo mutableArrayValueForKey:@"times"];
        CGFloat height=30;
        for(NSDictionary *time in times){
            UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(5, height, cell.frame.size.width-5, 20)];
            label1.text = [NSString stringWithFormat:@"%@方向  %@-%@",[time objectForKey:@"directionName"],[time objectForKey:@"firstTime"],[time objectForKey:@"lastTime"]];
            label1.textColor = [UIColor blackColor];
            label1.textAlignment = NSTextAlignmentLeft;
            label1.backgroundColor = [UIColor clearColor];
            label1.font = [UIFont systemFontOfSize:12];
            [cell.contentView addSubview:label1];
            height += 30;
        }
    }else if(_type==4){
        //线路
        RouteInfo* routeInfo = _arrMDataSource[indexPath.row];
//        NSLog(@"indexPath -> %ld", indexPath.row);
        CGFloat height = 20;
        CGFloat indent = 40;
        int stationNums = 0;
        NSString *preEndStation = @"";
        for(int i=0; i<routeInfo.routeFrags.count; i++){
            RouteFrag *frag = routeInfo.routeFrags[i];
            float distance = [[[NSDecimalNumber decimalNumberWithDecimal:[frag.distance decimalValue]] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"1000"]] floatValue];
            float minutes = [[[NSDecimalNumber decimalNumberWithDecimal:[frag.time decimalValue]] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"60"]] floatValue];
            
            //起点站
            UILabel *labelStartName = [[UILabel alloc] initWithFrame:CGRectMake(indent, height, cell.frame.size.width-5, 30)];
            NSString *time = [NSString stringWithFormat: @" (%@-%@)", frag.startTime,frag.endTime];
            if(frag.startTime==nil || frag.endTime==nil) time = @"";
            labelStartName.text = [NSString stringWithFormat: @"%@%@%@",preEndStation, frag.startStationName,time];
            labelStartName.textColor = [UIColor blackColor];
            labelStartName.textAlignment = NSTextAlignmentLeft;
            labelStartName.backgroundColor = [UIColor clearColor];
            //    label1.font = [UIFont fontWithName:@"KFONT" size:8];
            labelStartName.font = [UIFont systemFontOfSize:15];
            [cell.contentView addSubview:labelStartName];
            height += 30;
            
            //方向+时间+距离
            UILabel *labelDetail = [[UILabel alloc] initWithFrame:CGRectMake(indent+5, height, cell.frame.size.width-5, 20)];
            stationNums += [frag.stationNum intValue];
            labelDetail.text = [NSString stringWithFormat: @"%@方向 %@站 %.2f分钟 %.fkm", frag.lineDirection, frag.stationNum, minutes, distance];
            labelDetail.textColor = [UIColor blackColor];
            labelDetail.textAlignment = NSTextAlignmentLeft;
            labelDetail.backgroundColor = [UIColor clearColor];
            //    label1.font = [UIFont fontWithName:@"KFONT" size:8];
            labelDetail.font = [UIFont systemFontOfSize:12];
            [cell.contentView addSubview:labelDetail];
            height += 20;
            
            CGFloat endTextHeight = 0;
            if(i<routeInfo.routeFrags.count-1 && [((RouteFrag*)routeInfo.routeFrags[i+1]).startStationName compare:frag.endStationName]!=NSOrderedSame){
                //本段路线终点站与下一段线路起点站不同，则显示该终点站
                preEndStation = [NSString stringWithFormat: @"%@ 换乘 ",frag.endStationName];
            }else if(i>=routeInfo.routeFrags.count-1){
                //终点站
                UILabel *labeleEndName = [[UILabel alloc] initWithFrame:CGRectMake(indent, height, cell.frame.size.width-5, 30)];
                labeleEndName.text = [NSString stringWithFormat: @"%@", frag.endStationName];
                labeleEndName.textColor = [UIColor blackColor];
                labeleEndName.textAlignment = NSTextAlignmentLeft;
                labeleEndName.backgroundColor = [UIColor clearColor];
                //    label1.font = [UIFont fontWithName:@"KFONT" size:8];
                labeleEndName.font = [UIFont systemFontOfSize:15];
                [cell.contentView addSubview:labeleEndName];
                height += 30;
                endTextHeight = 30;
            }else{
                preEndStation = @"";
            }
            
            
            //线路名
            UILabel *labelLine = [[UILabel alloc] initWithFrame:CGRectMake(5, height-35-endTextHeight, 30, 50)];
//            if([BaseUtils isNum:frag.line.lineCode] && [frag.line.lineCode integerValue]>900){
//                labelLine.text = [NSString stringWithFormat:@"  %@", [frag.line.lineName substringToIndex:1]];
//            }else if([BaseUtils isNum:frag.line.lineCode] && [frag.line.lineCode integerValue]>10){
//                labelLine.text = [NSString stringWithFormat:@"  %@", frag.line.lineCode];
//            }else{
//                labelLine.text = [NSString stringWithFormat:@"   %@", frag.line.lineCode];
//            }
//            NSString *lineName = [frag.line.lineName stringByReplacingOccurrencesOfString:@"号线" withString:@""];
//            lineName = [lineName stringByReplacingOccurrencesOfString:@"线" withString:@""];
            labelLine.text = [NSString stringWithFormat:@"%@", frag.line.lineCode];
            labelLine.textColor = [UIColor whiteColor];
            labelLine.textAlignment = NSTextAlignmentCenter;
            if(frag.line.lineColor!=nil){
                labelLine.backgroundColor = [ColorUtils colorWithHexString:frag.line.lineColor];
                if(![BaseUtils isLighterColor:labelLine.backgroundColor]) {
                    labelLine.textColor = [UIColor blackColor];
                }
            }else{
                labelLine.backgroundColor = [UIColor darkGrayColor];
            }
            labelLine.font = [UIFont systemFontOfSize:15];
            [cell.contentView addSubview:labelLine];
            
            if([indexPath compare:_selIndex]==NSOrderedSame){
                cell.contentView.backgroundColor = [ColorUtils colorWithHexString:@"#BDBDBD"];
            }
        }
        
        
        float distance = [[[NSDecimalNumber decimalNumberWithDecimal:[routeInfo.distance decimalValue]] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"1000"]] floatValue];
        float price = [[[NSDecimalNumber decimalNumberWithDecimal:[routeInfo.price decimalValue]] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"100"]] floatValue];
        float minutes = [[[NSDecimalNumber decimalNumberWithDecimal:[routeInfo.time decimalValue]] decimalNumberByDividingBy:[NSDecimalNumber decimalNumberWithString:@"60"]] floatValue];
        
        UILabel *label0 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, 20)];
        long count = routeInfo.routeFrags.count-1;
        NSString *countStr = [NSString stringWithFormat:@"换乘%ld次",count];
        if(count==0) countStr = @"无需换乘";
        
        label0.text = [NSString stringWithFormat: @"   %@ 共%d站 %.2f元 %.f分钟 %.2fkm",countStr,stationNums, price,minutes,distance];
        label0.textColor = [UIColor blackColor];
        label0.textAlignment = NSTextAlignmentLeft;
        label0.backgroundColor = [UIColor lightGrayColor];
        label0.font = [UIFont systemFontOfSize:15];
        [cell.contentView addSubview:label0];
        
        cell.backgroundColor = [UIColor clearColor];
//        cell.contentView.backgroundColor = [UIColor blueColor];
    }else if(_type==1){
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 5, 0, 5)];
        //城市
        UILabel *label0 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width/2, 30)];
        CityInfo *cinfo = _arrMDataSource[indexPath.row];
        label0.text = cinfo.name;
        label0.textColor = [UIColor blackColor];
        label0.textAlignment = NSTextAlignmentCenter;
        label0.backgroundColor = [UIColor clearColor];
        label0.font = [UIFont systemFontOfSize:15];
        [cell.contentView addSubview:label0];
        
        UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button1 setFrame:CGRectMake(cell.frame.size.width/4*3, 0, cell.frame.size.width/4, 30)];
        [button1 setTitle:@"预览" forState:UIControlStateNormal];
        button1.backgroundColor = [UIColor clearColor];
        button1.tag = indexPath.row;
        [button1 addTarget:self action:@selector(previewMetroMap:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:button1];
    }else if(_type==11){
        //城市
        CityInfo *cinfo = _arrMDataSource[indexPath.row];
        NSString *name = [NSString stringWithFormat:@"%@CityPDF",cinfo.nameCode];
//        NSURL *pdfUrl = [DataUtils getfilePathFromBundle:name withType:@"pdf"];
//        if(pdfUrl == nil){
//            UILabel *label0 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width/2, 30)];
//            label0.text = cinfo.name;
//            label0.textColor = [UIColor blackColor];
//            label0.textAlignment = NSTextAlignmentCenter;
//            label0.backgroundColor = [UIColor clearColor];
//            label0.font = [UIFont systemFontOfSize:15];
//            [cell.contentView addSubview:label0];
//
//            UIButton *button1 = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//            [button1 setFrame:CGRectMake(cell.frame.size.width/4*3, 0, cell.frame.size.width/4, 30)];
//            [button1 setTitle:@"预览" forState:UIControlStateNormal];
//            button1.backgroundColor = [UIColor clearColor];
//            button1.tag = indexPath.row;
//            [button1 addTarget:self action:@selector(previewMetroMap:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.contentView addSubview:button1];
//        }else{
//            SVGKImage *svgImage = [SVGKImage imageNamed:@"shenzhenSVG"];
//            SVGKLayeredImageView *imageView = [[SVGKLayeredImageView alloc] initWithSVGKImage:svgImage];
            
//            UIImage *image = [UIImage yh_imageWithPDFFileURL:pdfUrl expectSize:CGSizeZero];
//            float width = self.tableView.frame.size.width;
//            float height = image.size.height * self.tableView.frame.size.width / image.size.width;
//            UIImage *imagePro = [UIImage yh_imageWithPDFFileURL:pdfUrl expectSize:CGSizeMake(width, height)];
//            UIImageView *imageView = [[UIImageView alloc] initWithImage:imagePro];
            
            UIImage *image = [UIImage imageNamed:cinfo.nameCode];
            float width = self.tableView.frame.size.width - 40;
            float height = image.size.height * width / image.size.width;
            UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
            [imageView setFrame:CGRectMake(20, 10, width, height)];
        
            //超过子图层的部分裁减掉,所以给圆角的图片设置阴影会被裁掉
//            imageView.layer.masksToBounds=YES;
        
            UIView *uview = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, height+30)];
            uview.layer.shadowColor = [UIColor lightGrayColor].CGColor;//阴影颜色
            uview.layer.shadowOffset = CGSizeMake(0, 8);//偏移距离
            uview.layer.shadowOpacity = 0.4;//不透明度
            uview.layer.shadowRadius = 10.0;//半径
            [uview addSubview:imageView];
        
            [cell.contentView addSubview:uview];
//        }
    }else if(_type==2){
        //站点列表
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 5, 0, 5)];
        MetroLineInfo *minfo = _arrMDataSource[indexPath.section];
        MetroStationInfo *sinfo = minfo.stations[indexPath.row];
        [sinfo setLine:minfo];
        UILabel *label0 = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, cell.frame.size.width-5, 30)];
        label0.text = sinfo.stationName;
        label0.textAlignment = NSTextAlignmentLeft;
        label0.backgroundColor = [UIColor whiteColor];
        label0.font = [UIFont systemFontOfSize:15];
        [cell.contentView addSubview:label0];
        
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(5, 30, cell.frame.size.width-5, 20)];
        label1.text = sinfo.stationNameEn;
        label1.textAlignment = NSTextAlignmentLeft;
        label1.backgroundColor = [UIColor whiteColor];
        label1.font = [UIFont systemFontOfSize:10];
        [cell.contentView addSubview:label1];
        
        NSArray *lineNames = [sinfo.locationByLines allKeys];
        if([@(0) compare: sinfo.status]==NSOrderedSame || ![lineNames containsObject:minfo.lineName]){
            label0.textColor = [UIColor lightGrayColor];
            label1.textColor = [UIColor lightGrayColor];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }else{
            label0.textColor = [UIColor blackColor];
            label1.textColor = [UIColor blackColor];
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
        }
    }else{
        //普通列表
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 5, 0, 5)];
        cell.textLabel.text = _arrMDataSource[indexPath.row];
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.font = _cusFont ? _cusFont : [UIFont fontWithName:@"KFONT" size:15];
    }
    return cell;
}

//设置cell的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat height = 0;
    if(_type==3){
        NSMutableDictionary *binfo = _arrMDataSource[indexPath.row];
        NSMutableArray *times = [binfo mutableArrayValueForKey:@"times"];
        height = 30 + times.count*30;
    }else if(_type==11){
        CityInfo *cinfo = _arrMDataSource[indexPath.row];
//        NSString *name = [NSString stringWithFormat:@"%@CityPDF",cinfo.nameCode];
//        NSURL *pdfUrl = [DataUtils getfilePathFromBundle:name withType:@"pdf"];
//        if(pdfUrl!=nil){
//            UIImage *image = [UIImage yh_imageWithPDFFileURL:pdfUrl expectSize:CGSizeZero];
//            height = image.size.height * self.tableView.frame.size.width / image.size.width;
//        }else{
//            height = 30;
//        }
        UIImage *image = [UIImage imageNamed:cinfo.nameCode];
        height = image.size.height * (self.tableView.frame.size.width-40) / image.size.width + 30;
        
    }else if(_type==4){
        RouteInfo* routeInfo = _arrMDataSource[indexPath.row];
        height += 50*routeInfo.routeFrags.count;
        height += 60;
    }else if(_type==2){
        height = 50;
    }else{
        height = 30;
    }
    return height;
}


//设置sectionheader的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(_type==2){
        return 20;
    }if(_type==4 || _type==11){
        return 0;
    }else{
        return 1;
    }
}

//设置sectionfooter的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}

//返回列表每个分组头部说明
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if(_type==2){
        return [[NSString alloc]initWithFormat:@"%@", [_arrMDataSource[section] lineName]];
    }else{
        return nil;
    }
}

- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    if(_type==2){
        NSMutableArray *array = [NSMutableArray new];
        for(int i=0; i<_arrMDataSource.count; i++){
            MetroLineInfo *minfo = _arrMDataSource[i];
            [array addObject:minfo.lineCode];
        }
        return array;
    }
    return nil;
}

//返回列表每个分组尾部说明
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return nil;
}

//返回列表分组数，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(_type==2){
        return [_arrMDataSource count];
    }else{
        return 1;
    }
}


//返回列表每个分组section拥有cell行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if(_type==2){
        return [((MetroLineInfo *)_arrMDataSource[section]).stations count];
    }else{
        return _arrMDataSource.count;
    }
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

@end
