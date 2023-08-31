//
//  StationList.m
//  MetroMap
//
//  Created by edwin on 2019/9/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "StationListView.h"

@interface StationListView ()<UITableViewDataSource, UITableViewDelegate>
    
@property(nonatomic, retain) UITableView * tableView;
@property(nonatomic, retain) MetroDataCache * dataCache;
    
@end

@implementation StationListView

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}
    
    
-(void)initUI{
    UITableView *tableView= [UITableView new];
    tableView.showsVerticalScrollIndicator = NO;
    tableView.showsVerticalScrollIndicator = YES;
    tableView.frame = self.bounds;
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.userInteractionEnabled = YES;
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"stationListView"];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.estimatedSectionHeaderHeight = 0;
    tableView.estimatedSectionFooterHeight = 0;
    
    self.backgroundColor = [UIColor whiteColor];
    self.tableView = tableView;
    [self addSubview:tableView];
    _dataCache = [MetroDataCache shareInstanceWithCityCode:@"shanghai"];
}
    
-(void)setDefaultSelect:(NSString*)lineCode stationName:(NSString*) stationName{
    if(self.tableView.indexPathForSelectedRow) [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:NO];
    if(lineCode && stationName) for(int i=0; i<_dataCache.lines.count; i++){
        LineInfo *l = _dataCache.lines[i];
        if([l.code isEqualToString:lineCode]){
            for(int j=0; j<l.stationIds.count; j++){
                StationInfo *s = [_dataCache.stations objectForKey:[NSString stringWithFormat:@"%@",l.stationIds[j]]];
                if([s.nameCn isEqualToString:stationName]){
                    NSIndexPath *selectedIndex = [NSIndexPath indexPathForRow:j inSection:i];
                    [self.tableView selectRowAtIndexPath:selectedIndex animated:YES scrollPosition:UITableViewScrollPositionTop];
                }
            }
        }
    }else{
        NSIndexPath *selectedIndex = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView scrollToRowAtIndexPath:selectedIndex atScrollPosition:UITableViewScrollPositionNone animated:NO];
        [self.tableView deselectRowAtIndexPath:selectedIndex animated:NO];
    }
}

#pragma mark --tableView
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"stationListView" forIndexPath:indexPath];
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, _tableView.frame.size.width, cell.frame.size.height);
//    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.contentView.backgroundColor = [UIColor clearColor];
    //站点列表
    [cell setSeparatorInset:UIEdgeInsetsMake(0, 10, 0, 5)];
    LineInfo *minfo = _dataCache.lines[indexPath.section];
    StationInfo *sinfo = [_dataCache.stations objectForKey:[NSString stringWithFormat:@"%@", minfo.stationIds[indexPath.row]]];
    UILabel *label0 = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, cell.frame.size.width-10, 25)];
    label0.text = sinfo.nameCn;
    label0.textAlignment = NSTextAlignmentLeft;
    label0.backgroundColor = [UIColor whiteColor];
    label0.font = [UIFont systemFontOfSize:15];
    [cell.contentView addSubview:label0];
    
    UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, cell.frame.size.width-15, 20)];
    label1.text = sinfo.nameEn;
    label1.textAlignment = NSTextAlignmentLeft;
    label1.backgroundColor = [UIColor whiteColor];
    label1.font = [UIFont systemFontOfSize:10];
    [cell.contentView addSubview:label1];
    
    if([@(1) compare: sinfo.status]!=NSOrderedSame){
        label0.textColor = [UIColor lightGrayColor];
        label1.textColor = [UIColor lightGrayColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }else{
        label0.textColor = [UIColor blackColor];
        label1.textColor = [UIColor blackColor];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
    }
    return cell;
}
    
    
    

    
#pragma mark --callback
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.didSelectedCallback) {
        LineInfo *l = _dataCache.lines[indexPath.section];
        StationInfo *s = [_dataCache.stations objectForKey:[NSString stringWithFormat:@"%@",l.stationIds[indexPath.row]]];
        self.didSelectedCallback(s, l);
    }
}
    


//设置cell的高度
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
    
    
//设置sectionheader的高度
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 20;
}
    
//设置sectionfooter的高度
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0;
}
    
    //返回列表每个分组头部说明
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    LineInfo *line = _dataCache.lines[section];
    return [[NSString alloc]initWithFormat:@"%@", line.nameCn];
}
    
- (NSArray<NSString *> *)sectionIndexTitlesForTableView:(UITableView *)tableView{
    NSMutableArray *array = [NSMutableArray new];
    for(int i=0; i<_dataCache.lines.count; i++){
        LineInfo *line = _dataCache.lines[i];
        [array addObject:line.code];
    }
    return array;
}
    
//返回列表每个分组尾部说明
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    return nil;
}
    
//返回列表分组数，默认为1
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return _dataCache.lines.count;
}
    
    
//返回列表每个分组section拥有cell行数
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    LineInfo *line = _dataCache.lines[section];
    return line.stationIds.count;
}
    
    
-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    return nil;
}
    
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    return nil;
}

@end
