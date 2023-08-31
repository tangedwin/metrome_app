//
//  StationTimetable.m
//  MetroMap
//
//  Created by edwin on 2019/10/23.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "StationTimetableModel.h"
#import "BaseUtils.h"

@implementation StationTimetableModel


-(NSString*) findFirstTime{
    if(self.special){
        NSMutableDictionary *date = [BaseUtils dateByDict];
        NSInteger weekday = date[@"weekday"]?([date[@"weekday"] integerValue]-1):1;
        weekday = weekday<=0 ? 7 : weekday;
        NSString *dateStr = [NSString stringWithFormat:@"%4ld%2ld%2ld",(long)[date[@"year"] integerValue],(long)[date[@"month"] integerValue],(long)[date[@"day"] integerValue]];
        
        for(StationTimetableModel *stt in self.special){
            if(stt.inweek && [stt.inweek containsObject:@(weekday)]){
                return [self parseTime:stt.first];
            }else if(stt.bydate && [stt.bydate containsObject:@([dateStr integerValue])]){
                return [self parseTime:stt.first];
            }
        }
    }
    return [self parseTime:self.first];
}
-(NSString*) findLastTime{
    if(self.special){
        NSMutableDictionary *date = [BaseUtils dateByDict];
        NSInteger weekday = date[@"weekday"]?([date[@"weekday"] integerValue]-1):1;
        weekday = weekday<=0 ? 7 : weekday;
        NSString *dateStr = [NSString stringWithFormat:@"%4ld%2ld%2ld",(long)[date[@"year"] integerValue],(long)[date[@"month"] integerValue],(long)[date[@"day"] integerValue]];
        
        for(StationTimetableModel *stt in self.special){
            if(stt.inweek && [stt.inweek containsObject:@(weekday)]){
                return [self parseTime:stt.last];
            }else if(stt.bydate && [stt.bydate containsObject:@([dateStr integerValue])]){
                return [self parseTime:stt.last];
            }
        }
    }
    return [self parseTime:self.last];
}


-(NSString*) parseTime:(NSInteger)time{
    if(time<0) return @"-";
    NSString *hour = [NSString stringWithFormat:@"%02d", time/60];
    if(time/60>=24) hour = [NSString stringWithFormat:@"次日 %02d", (time/60-24)];
    NSString *minute = [NSString stringWithFormat:@"%02d",time % 60];
    return [NSString stringWithFormat:@"%@:%@",hour,minute];
}


+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"identifyCode":@"id"};
}

+(NSDictionary *)modelContainerPropertyGenericClass{
    return @{@"special" : [StationTimetableModel class]};
}

@end
