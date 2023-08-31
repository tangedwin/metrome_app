//
//  DateUtils.m
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "DateUtils.h"

@implementation DateUtils

//将时间转换为（32 分钟前，1 小时前，1 天前， 7-25）
+ (NSString *)parseTime:(NSString*)dateTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [formatter dateFromString:dateTime];
    NSDate* curDate = [NSDate date];
    NSTimeInterval time = [curDate timeIntervalSinceDate:date];
    if(time<60) return [NSString stringWithFormat:@"%.f 秒前",time];
    else if(time < 60*60) return [NSString stringWithFormat:@"%.f 分钟前",time/60];
    else if(time < 60*60*24) return [NSString stringWithFormat:@"%.f 小时前",time/60/60];
    else if(time < 60*60*24*4) return [NSString stringWithFormat:@"%.f 天前",time/60/60/24];
    [formatter setDateFormat:@"MM-dd HH:mm"];
    return [formatter stringFromDate:date];
}

//多少秒以前
+ (NSString *)time:(NSString*)time beforeSeconds:(NSInteger)seconds{
    BOOL nextDay = NO;
    if([time hasPrefix:@"次日"]) {
        time = [time stringByReplacingOccurrencesOfString:@"次日 " withString:@""];
        nextDay = YES;
    }
    NSArray *times = [time componentsSeparatedByString:@":"];
    if(times.count!=2) return time;
    NSInteger t = ([times[0] integerValue] *60*60 + [times[1] integerValue]*60-seconds)/60;
    NSString *hour = [NSString stringWithFormat:@"%02ld", t/60];
    NSString *minutes = [NSString stringWithFormat:@"%02ld", t%60];
    if(t<0 && nextDay) {
        hour = [NSString stringWithFormat:@"%02ld", (t+24*60*60)/60];
        minutes = [NSString stringWithFormat:@"%02ld", (t+24*60*60)%60];
        return [NSString stringWithFormat:@"次日 %@:%@",hour,minutes];
    }else if(t>0 && nextDay) return [NSString stringWithFormat:@"次日 %@:%@",hour,minutes];
    else if(t>0 && !nextDay) return [NSString stringWithFormat:@"%@:%@",hour,minutes];
    return time;
}


+(BOOL) checkTime:(NSString*)time1 beforeTime:(NSString*)time2{
    BOOL nextDay1 = NO;
    BOOL nextDay2 = NO;
    if([time1 hasPrefix:@"次日"]) {
        time1 = [time1 stringByReplacingOccurrencesOfString:@"次日 " withString:@""];
        nextDay1 = YES;
    }
    if([time2 hasPrefix:@"次日"]) {
        time2 = [time2 stringByReplacingOccurrencesOfString:@"次日 " withString:@""];
        nextDay2 = YES;
    }
    
    NSArray *times1 = [time1 componentsSeparatedByString:@":"];
    NSArray *times2 = [time2 componentsSeparatedByString:@":"];
    if(times1.count!=2 || times2.count!=2) return true;
    NSInteger t1 = [times1[0] integerValue] *60 + [times1[1] integerValue] + (nextDay1?24*60*60:0);
    NSInteger t2 = [times2[0] integerValue]*60 + [times2[1] integerValue] + (nextDay2?24*60*60:0);
    if(t1>t2) return false;
    return true;
}
@end
