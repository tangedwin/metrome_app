//
//  RouteUtils.m
//  test-metro
//
//  Created by edwin on 2019/6/17.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "RouteUtils.h"
#import "RouteInfo.h"

@implementation RouteUtils

-(void)queryCityCode{
    NSString *str = @"https://map.baidu.com/?qt=subwayscity&t=1567932399124";
    NSURL *url = [NSURL URLWithString:str];
    
    NSMutableDictionary *result = [NSMutableDictionary new];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"网络响应：response：%@",response);
        if(!response) {
            dispatch_group_leave(group);
            return;
        }
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSDictionary *subwaysCities = [jsonDict objectForKey:@"subways_city"];
        NSMutableArray<NSDictionary*> *cities = [subwaysCities mutableArrayValueForKey:@"cities"];
        for(NSDictionary *city in cities){
            NSString *cename = [city objectForKey:@"cename"];
            NSString *code = [city objectForKey:@"code"];
            if(cename && code) [result setObject:code forKey:cename];
        }
        
        dispatch_group_leave(group);
    }];
    [task resume];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^(){
        NSLog(@"%@",result);
        if(self.queryCallback) self.queryCallback(result);
    });
}
    
    
-(void)queryForRouteWithCityCode:(NSString*)cityCode{
    NSString *str = [NSString stringWithFormat:  @"https://map.baidu.com/?qt=subways&c=%@&format=json&t=1567926804864&callback=jsonp30409673",cityCode];
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSMutableDictionary *result = [NSMutableDictionary new];
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"网络响应：response：%@",response);
        if(!response) {
            dispatch_group_leave(group);
            return;
        }
        if(!response) return;
        NSString * str  =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray *array = [str componentsSeparatedByString:@"30409673("];
        if(array!=nil && array.count>1){
            NSString *contentStr =[array[1] stringByReplacingOccurrencesOfString:@"})" withString:@"}"];
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[contentStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            NSDictionary *subways = [jsonDict objectForKey:@"subways"];
            NSMutableArray *lines = [subways mutableArrayValueForKey:@"l"];
            for(NSDictionary *line in lines){
                NSMutableArray *stations = [line mutableArrayValueForKey:@"p"];
                for(NSDictionary *s in stations){
                    NSDictionary *station = [s objectForKey:@"p_xmlattr"];
                    if(!station) continue;
                    NSString *sid = [station objectForKey:@"sid"];
                    NSString *uid = [station objectForKey:@"uid"];
                    if(!uid || [@"" isEqualToString:uid]) continue;
                    
                    if(sid && ![@"" isEqualToString:sid]){
                        sid = [sid stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                        if(![result objectForKey:sid]) [result setObject:uid forKey:sid];
                    }
                }
            }
        }
        
        dispatch_group_leave(group);
    }];
    [task resume];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^(){
        if(self.queryCallback) self.queryCallback(result);
    });
}
    
    
-(void)queryForRouteWithCityCode:(NSString*)cityCode withStartUid:(NSString*)startUid withEndUid:(NSString*)endUid{
    if(cityCode==nil || startUid==nil || endUid==nil) {
        if (self.queryRouteCallback) {
            self.queryRouteCallback(nil);
        }
//        return;
    }
    NSString *str = [NSString stringWithFormat: @"https://map.baidu.com/?qt=bt&newmap=1&f=[1,12,13,14]&ie=utf-8&c=%@&sn=0$$%@$$null,null$$null$$&en=0$$%@$$null,null$$null$$&m=sbw&ccode=%@&from=dtzt&sy=0&t=1560764242542",cityCode,startUid,endUid,cityCode];
//    NSLog(@"url is %@", str);
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    
    
    //规划路线
    NSMutableArray *routesAll = [[NSMutableArray alloc]init];
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"网络响应：response：%@",response);
        if(!response) {
            dispatch_group_leave(group);
            return;
        }
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        NSMutableArray<NSDictionary*> *content = [jsonDict mutableArrayValueForKey:@"content"];
        
        for(NSDictionary *route in content){
            //每条路线的分段区间
            NSMutableArray *routeFrags = [[NSMutableArray alloc]init];
            NSMutableArray<NSMutableArray*> *lineContent = [route mutableArrayValueForKey:@"lines"];
            NSMutableArray<NSMutableArray*> *stopContent = [route mutableArrayValueForKey:@"stops"];
            NSMutableArray<NSDictionary*> *exts = [route objectForKey:@"exts"];
            
            //每个route中可能含有多条路线，因此建立集合
            NSMutableArray *routes = [[NSMutableArray alloc]init];
            [routes addObject:[[RouteInfo alloc] init]];
            for(int i=0; i<exts.count; i++){
                //如果exts大于1，则表示有多条线路
                if(i>0){
                    [routes addObject:[[RouteInfo alloc] init]];
                }
                NSDictionary *ext = exts[i];
                [routes.lastObject setDistance:[ext valueForKey:@"distance"]];
                [routes.lastObject setPrice:[ext valueForKey:@"price"]];
                [routes.lastObject setTime:[ext valueForKey:@"time"]];
            }
            
            for(int k=0; k<stopContent.count; k++){
                //每条线路有一个stopArray，表示起点终点和换乘站
                NSMutableArray *stopArray = stopContent[k];
                if(k>0){
                    routeFrags = [[NSMutableArray alloc]init];
                }
                [routeFrags addObject:[[RouteFrag alloc] init]];
                for(int i=0; i<stopArray.count; i++){
                    NSDictionary *stop = stopArray[i];
                    NSDictionary *start = [stop objectForKey:@"getOff"];
                    NSDictionary *end = [stop objectForKey:@"getOn"];
                    
                    if(i==0){
                        [routeFrags.lastObject setStartStationName:[end objectForKey:@"name"]];
                        [routeFrags.lastObject setStartStationUid:[end objectForKey:@"uid"]];
                    }else if(i<stopArray.count-1){
                        [routeFrags.lastObject setEndStationName:[start objectForKey:@"name"]];
                        [routeFrags.lastObject setEndStationUid:[start objectForKey:@"uid"]];
                        [routeFrags addObject:[[RouteFrag alloc] init]];
                        [routeFrags.lastObject setStartStationName:[end objectForKey:@"name"]];
                        [routeFrags.lastObject setStartStationUid:[end objectForKey:@"uid"]];
                    }else{
                        [routeFrags.lastObject setEndStationName:[start objectForKey:@"name"]];
                        [routeFrags.lastObject setEndStationUid:[start objectForKey:@"uid"]];
                    }
                }
                [routes[k] setRouteFrags:routeFrags];
            }
            
            for(int k=0; k<lineContent.count; k++){
                NSMutableArray *lineArray = lineContent[k];
                RouteInfo *rInfo =routes[k];
                NSMutableArray *frags = rInfo.routeFrags;
                [rInfo setLineUids:[[NSMutableArray alloc]init]];
                for(int i=0; i<lineArray.count; i++){
                    if(![lineArray[i] isKindOfClass:[NSDictionary class]]){
                        continue;
                    }
                    if(routeFrags.count<=i){
                        NSLog(@"数据错误！");
                        break;
                    }
                    NSDictionary *line = lineArray[i];
                    RouteFrag *frag = frags[i];
                    [frag setLineName:[line objectForKey:@"name"]];
                    [frag setLineUid:[line objectForKey:@"uid"]];
                    [frag setDistance:[line valueForKey:@"distance"]];
                    [frag setTime:[line valueForKey:@"time"]];
                    [frag setStationNum:[line valueForKey:@"station_num"]];
                    
                    [rInfo.lineUids addObject:[line objectForKey:@"uid"]];
                }
            }
            
            
            [routesAll addObjectsFromArray:routes];
        }
        NSLog(@"request success");
        dispatch_group_leave(group);
    }];
    [task resume];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^(){
        if (self.queryRouteCallback) {
            self.queryRouteCallback(routesAll);
        }
    });
    NSLog(@"end");
}



-(NSMutableDictionary *)queryStationTime:(NSString*)cityCode withStationUid:(NSString*)stationUid{
    NSString *str = [NSString stringWithFormat: @"https://map.baidu.com/?qt=inf&newmap=1&it=3&ie=utf-8&f=[1,12,13]&c=%@&m=sbw&ccode=%@&uid=%@&callback=jsonp99981348",cityCode,cityCode,stationUid];
    //    NSLog(@"url is %@", str);
    NSURL *url = [NSURL URLWithString:str];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    NSURLSession *session = [NSURLSession sharedSession];
    
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0); //创建信号量
    //    dispatch_group_t group = dispatch_group_create();
    //    dispatch_group_enter(group);
    NSMutableDictionary *trainTimes = [NSMutableDictionary new];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"网络响应：response：%@",response);
        if(!response) return;
        NSString * str  =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSArray *array = [str componentsSeparatedByString:@"99981348("];
        if(array!=nil && array.count>1){
            NSString *contentStr =[array[1] stringByReplacingOccurrencesOfString:@"})" withString:@"}"];
            NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:[contentStr dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            NSDictionary *content = [jsonDict objectForKey:@"content"];
            NSDictionary *ext = [content objectForKey:@"ext"];
            NSMutableArray *array = [ext mutableArrayValueForKey:@"line_info"];
            for(int i=0; i<array.count; i++){
                NSDictionary *dic = array[i];
                NSMutableDictionary *trainTime = [NSMutableDictionary new];
                if([[dic objectForKey:@"first_time"] compare:@""]!=NSOrderedSame) [trainTime setObject:[dic objectForKey:@"first_time"] forKey:@"firstTime"];
                if([[dic objectForKey:@"last_time"] compare:@""]!=NSOrderedSame) [trainTime setObject:[dic objectForKey:@"last_time"] forKey:@"lastTime"];
                
                [trainTime setObject:[dic objectForKey:@"terminals"] forKey:@"direction"];
                NSString *lineName = [dic objectForKey:@"abb"];
                lineName = [lineName stringByReplacingOccurrencesOfString:@"地铁" withString:@""];
                lineName = [NSString stringWithFormat:@"%@号线",[lineName componentsSeparatedByString:@"号线"][0]];
                [trainTime setObject:lineName forKey:@"lineName"];
                [trainTimes setObject:trainTime forKey:[dic objectForKey:@"uid"]];
            }
        }
        
        NSLog(@"request success");
        //        dispatch_group_leave(group);
//        dispatch_semaphore_signal(semaphore);   //发送信号
    }];
    [task resume];
    //    dispatch_group_notify(group, dispatch_get_main_queue(), ^(){
    //
    //    });
//    dispatch_semaphore_wait(semaphore,DISPATCH_TIME_FOREVER);
    NSLog(@"end");
    return trainTimes;
}




@end
