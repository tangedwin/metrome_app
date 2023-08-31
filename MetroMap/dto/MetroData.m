//
//  MetroData.m
//  MetroMap
//
//  Created by edwin on 2019/6/22.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "MetroData.h"

@implementation MetroData

//TODO 查询数据
+(MetroData*)initDataWithCityCode:(NSString *)cityCode{
    MetroData *mdata = [[MetroData alloc] init];
    [mdata setCities:[mdata findCitiesFromPlist]];
    if(cityCode==nil){
        [mdata setCityInfo:mdata.cities.firstObject];
    }else{
        if([mdata checkCities]){
            for(CityInfo *cinfo in mdata.cities){
                if([cinfo.nameCode compare:cityCode]==NSOrderedSame){
                    [mdata setCityInfo:cinfo];
                    break;
                }
            }
        }
    }
    [mdata setMetroInfo:[mdata findMetroInfoFromPlist:mdata.cityInfo.nameCode]];
    for(MetroLineInfo *line in mdata.metroInfo.lines){
        if(line.stations==nil) [line setStations:[[NSMutableArray alloc] init]];
        else continue;
        for(NSNumber *stationId in line.stationNumbers){
            for(MetroStationInfo *station in mdata.metroInfo.stations){
                if([station.identityNum compare:stationId]==NSOrderedSame && ![line.stations containsObject:station]){
                    [line.stations addObject:station];
                }
            }
        }
    }
    return mdata;
}


-(UIImage*)getMetroImage1{
    _mapInfo = (MapInfo*)[DataUtils unArchiveData:[DataUtils getDataFromPlist:USER_PLIST withKey:self.cityInfo.namePdf] withClasses:[NSSet setWithObjects:[MapInfo class], nil]];
    UIImage *imagePro = [DataUtils findImageWithName:self.cityInfo.namePdf withFilePath:@"metroMaps" withScale:_mapInfo==nil?1:_mapInfo.scale.floatValue];
    
    if(imagePro==nil){
        NSURL *pdfUrl = [DataUtils getfilePathFromBundle:self.cityInfo.namePdf withType:@"pdf"];
        //        NSURL *pdfUrl = [DataUtils getfilePathFromBundle:[NSString stringWithFormat:@"%@CityPDF",self.cityInfo.nameCode] withType:@"pdf"];
        UIImage *image = [UIImage yh_imageWithPDFFileURL:pdfUrl expectSize:CGSizeZero];
    
        float rateW = 5000/image.size.width;
        float rateH = 4000/image.size.height;
        float rate = rateW<rateH?rateW:rateH;
        if([self.cityInfo.namePdf compare:@"chengduPDF"]==NSOrderedSame) rate = 5;
        CGSize imageSize = CGSizeMake(image.size.width*rate, image.size.height*rate);
        imagePro = [UIImage yh_imageWithPDFFileURL:pdfUrl expectSize:imageSize];
        [DataUtils saveImage:imagePro withName:self.cityInfo.namePdf withFilePath:@"metroMaps"];
    
        _mapInfo = [MapInfo new];
        [_mapInfo setRate: [NSNumber numberWithFloat: rate]];
        [_mapInfo setScale: [NSNumber numberWithFloat: imagePro.scale]];
        [DataUtils writeDataToPlist:USER_PLIST withKey:self.cityInfo.namePdf withData:[DataUtils archiveData:_mapInfo]];
    }
    if(imagePro.size.height<=0 || imagePro.size.width<=0){
        if(_alertSomething) self.alertSomething(0, @"图片数据异常");
        return nil;
    }
    return imagePro;
}

-(UIImage*)getMetroImage{
    _mapInfo = (MapInfo*)[DataUtils unArchiveData:[DataUtils getDataFromPlist:USER_PLIST withKey:self.cityInfo.namePdf] withClasses:[NSSet setWithObjects:[MapInfo class], nil]];
    UIImage *imagePro = [UIImage imageNamed:[NSString stringWithFormat: @"myMapBundle.bundle/%@PNG",self.cityInfo.nameCode]];
    if(imagePro == nil){
        if(_alertSomething) self.alertSomething(0, [NSString stringWithFormat: @"%@图片数据异常", self.cityInfo.name]);
        return nil;
    }
    float rateH = imagePro.size.height/SCREEN_HEIGHT;
    float rateW = imagePro.size.width/SCREEN_WIDTH;
    float rate = rateW<rateH?rateW:rateH;
    [DataUtils saveImage:imagePro withName:self.cityInfo.namePdf withFilePath:@"metroMaps"];
    
    _mapInfo = [MapInfo new];
    [_mapInfo setRate: [NSNumber numberWithFloat: rate]];
    [_mapInfo setScale: [NSNumber numberWithFloat: imagePro.scale]];
    [DataUtils writeDataToPlist:USER_PLIST withKey:self.cityInfo.namePdf withData:[DataUtils archiveData:_mapInfo]];
    
    if(imagePro.size.height<=0 || imagePro.size.width<=0){
        if(_alertSomething) self.alertSomething(0, [NSString stringWithFormat: @"%@图片数据异常", self.cityInfo.name]);
        return nil;
    }
    return imagePro;
}


-(SVGKLayeredImageView*)getMetroSVGImage{
    _mapInfo = (MapInfo*)[DataUtils unArchiveData:[DataUtils getDataFromPlist:USER_PLIST withKey:self.cityInfo.namePdf] withClasses:[NSSet setWithObjects:[MapInfo class], nil]];
    
    SVGKImage *imagePro = [SVGKImage imageNamed:@"shanghaiMap"];
    if(imagePro == nil){
        if(_alertSomething) self.alertSomething(0, [NSString stringWithFormat: @"%@图片数据异常", self.cityInfo.name]);
        return nil;
    }
    float rateH = imagePro.size.height/SCREEN_HEIGHT;
    float rateW = imagePro.size.width/SCREEN_WIDTH;
    float rate = rateW<rateH?rateW:rateH;
    
    SVGKLayeredImageView *svgImageView = [[SVGKLayeredImageView alloc] initWithSVGKImage:imagePro];
    
    _mapInfo = [MapInfo new];
    [_mapInfo setRate: [NSNumber numberWithFloat: rate]];
    [_mapInfo setScale: [NSNumber numberWithFloat: imagePro.scale]];
    [DataUtils writeDataToPlist:USER_PLIST withKey:self.cityInfo.namePdf withData:[DataUtils archiveData:_mapInfo]];
    
    if(imagePro.size.height<=0 || imagePro.size.width<=0){
        if(_alertSomething) self.alertSomething(0, [NSString stringWithFormat: @"%@图片数据异常", self.cityInfo.name]);
        return nil;
    }
    return svgImageView;
}

-(CGPoint)getStationLocationWithIndex:(NSInteger)index orStation:(NSObject*)station{
    if(station!=nil){
        MetroStationInfo *stationInfo = (MetroStationInfo*)station;
        NSArray *array = [stationInfo.locationByLines allValues];
        if(array!=nil && array.count>0){
            CGPoint stationLocation = CGPointFromString(array.firstObject);
//            return CGPointMake(stationLocation.x*_mapInfo.rate.floatValue, stationLocation.y*_mapInfo.rate.floatValue);
            return stationLocation;
        }
        return CGPointZero;
//        return CGPointFromString(stationInfo.locations.firstObject);
    }else{
        MetroStationInfo *stationInfo = _metroInfo.stations[index];
        return CGPointFromString(stationInfo.locations.firstObject);
    }
}

-(void)queryRouteData{
    RouteUtils *routeUtils = [[RouteUtils alloc]init];
    __weak typeof(self) wkSelf = self;
    [routeUtils setQueryRouteCallback:^(NSMutableArray *data) {
        if(data==nil){
            if(wkSelf.alertSomething){
                wkSelf.alertSomething(0, @"异常查询");
                wkSelf.showRouteDetail(-1);
            }
        }
        wkSelf.routeList = [[NSMutableArray alloc]init];
        RouteUtils *rutils = [[RouteUtils alloc]init];
        for(RouteInfo *rinfo in data){
            if(rinfo.routeFrags==nil) continue;
            BOOL allMetro = YES;
            for(int i=0; i<rinfo.routeFrags.count; i++){
                RouteFrag *frag = rinfo.routeFrags[i];
                for(MetroLineInfo *lineInfo in wkSelf.metroInfo.lines){
                    NSString *lineDirection = [lineInfo.baiduUids valueForKey:frag.lineUid];
                    if(lineDirection!=nil){
                        [frag setLine:lineInfo];
                        [frag setLineDirection:lineDirection];
                        break;
                    }
                }
                if(frag.line == nil){
                    allMetro = NO;
                    break;
                }
                
                if(frag.startStationUid!=nil){
                    NSDictionary *stationTimes = [rutils queryStationTime:wkSelf.metroInfo.baiduUid withStationUid:frag.startStationUid];
                    NSDictionary *stationTime = [stationTimes objectForKey:frag.lineUid];
                    [frag setStartTime:[stationTime objectForKey:@"firstTime"]];
                    [frag setEndTime:[stationTime objectForKey:@"lastTime"]];
                }
                if(rinfo.routeStationLocations == nil) [rinfo setRouteStationLocations:[NSMutableArray new]];
                if([frag.line.stationNumbers.firstObject compare:frag.line.stationNumbers.lastObject]==NSOrderedSame){
                    BOOL reverseCircle = [frag.lineDirection hasPrefix:@"内"];
                    [rinfo.routeStationLocations addObjectsFromArray:[self findFragStationLocations2:frag.line startName:frag.startStationName endName:frag.endStationName first:i==0 last:i==rinfo.routeFrags.count-1 reverseCircle:reverseCircle]];
                }else{
                    [rinfo.routeStationLocations addObjectsFromArray:[self findFragStationLocations1:frag.line sNumbers:nil startName:frag.startStationName endName:frag.endStationName first:i==0 last:i==rinfo.routeFrags.count-1]];
                }
                
            }
            if(allMetro) [wkSelf.routeList addObject:rinfo];
        }
        if(wkSelf.routeList==nil || wkSelf.routeList.count<=0){
            if(wkSelf.alertSomething){
                wkSelf.alertSomething(0, @"异常查询");
                wkSelf.showRouteDetail(-1);
            }
        }else if(wkSelf.showRouteDetail){
            wkSelf.showRouteDetail(0);
        }
    }];
    
    NSString *startStationUid = [_startStationInfo.baiduUids allKeys].firstObject;
    NSString *endStationUid = [_endStationInfo.baiduUids allKeys].firstObject;
    [routeUtils queryForRouteWithCityCode:_metroInfo.baiduUid withStartUid:startStationUid withEndUid:endStationUid];
}


-(void)tapStation:(CGPoint)point scrollOffset:(CGPoint)scrollOffset scale:(float)scale barHeight:(CGFloat)barHeight{
    NSLog(@"you tap the point is %f,%f", point.x,point.y);
    if(_metroInfo==nil || _metroInfo.stations==nil) return;
    float buttonSize = _metroInfo.buttonSize<=0 ? 0 : _metroInfo.buttonSize;
    buttonSize = buttonSize/(scale*3>1?1:scale*3);
    BOOL showSign = NO;
    for(MetroStationInfo *station in _metroInfo.stations){
        NSArray *lineLocations = [station.locationByLines allValues];
        for(int i = 0; i<lineLocations.count; i++){
            CGPoint stationPoint = CGPointFromString(lineLocations[i]);
//            stationPoint = CGPointMake(stationPoint.x*_mapInfo.rate.floatValue, stationPoint.y*_mapInfo.rate.floatValue);
            if(point.x > (stationPoint.x-buttonSize) && point.x < (stationPoint.x+buttonSize) && point.y > (stationPoint.y-buttonSize) && point.y < (stationPoint.y+buttonSize)){
//                NSLog(@"you tap the station %@", station.stationName);
                _stationInfo = station;
                _stationLocation = stationPoint;
                
                //设置站点线路
                NSMutableArray *lineNames = [NSMutableArray new];
                NSMutableArray *lineColors = [NSMutableArray new];
                NSArray *keysArray = [station.locationByLines allKeys];
                for(MetroLineInfo *line in _metroInfo.lines){
                    for(NSString *lineId in keysArray){
                        if([lineId compare: line.lineName]==NSOrderedSame){
                            [lineNames addObject: line.lineName];
                            if(line.lineColor!=nil) [lineColors addObject: line.lineColor];
                        }
                    }
                }
                if(self.showStationInfo){
                    self.showStationInfo(station.stationName, station.stationLogoImage, lineNames, lineColors);
                }
                showSign = YES;
                break;
            }
        }
    }
    if(!showSign && self.hideStationSign){
        self.hideStationSign(nil);
    }
}

-(void)clearStationSign{
    _stationInfo = nil;
    _startStationInfo = nil;
    _endStationInfo = nil;
    _routeList = nil;
}

-(NSMutableArray*)getRouteStationLocations:(NSInteger) index{
    if(index<0 || index>=_routeList.count) return nil;
    RouteInfo *route = _routeList[index];
    
    NSMutableArray *array = [NSMutableArray new];
    for(NSString *str in route.routeStationLocations){
        CGPoint point = CGPointFromString(str);
//        CGPoint pointResult = CGPointMake(point.x*_mapInfo.rate.floatValue, point.y*_mapInfo.rate.floatValue);
//        [array addObject:NSStringFromCGPoint(pointResult)];
        [array addObject:NSStringFromCGPoint(point)];
    }
    
    _curRouteIndex = index;
    return array;
}

//正常线路获取线路片段
-(NSMutableArray*)findFragStationLocations1:(MetroLineInfo*)line sNumbers:(NSMutableArray*)sNumbers startName:(NSString*)startName endName:(NSString*)endName first:(BOOL)first last:(BOOL)last{
    NSMutableArray *array = [NSMutableArray new];
    BOOL reverse = NO;
    BOOL isRouteStation = NO;
    //如果存在sNumbers，强制优先起点
    BOOL forceFirst = sNumbers!=nil;
    sNumbers = sNumbers==nil?line.stationNumbers:sNumbers;
    for(NSNumber *snum in sNumbers){
        //匹配站点
        MetroStationInfo *station = nil;
        for(MetroStationInfo *sinfo in line.stations){
            if([sinfo.identityNum compare:snum]==NSOrderedSame){
                station = sinfo;
                break;
            }
        }
        if(!isRouteStation && array.count>0){
            //已经结束而且查询到结果则结束
            break;
        }
        if(station==nil){
            //遇到间隔
            if(isRouteStation){
                //如果没有结束，则重置
                array = [NSMutableArray new];
                reverse = NO;
                isRouteStation = NO;
                continue;
            }else if(array.count<=0){
                continue;
            }else{
                break;
            }
        }
        if(!isRouteStation){
            //还没有开始不添加，除非匹配到终点站或起点站
            if([station.stationName compare:startName]==NSOrderedSame){
                //匹配到起点站,第一个线路片段不添加起点站
                isRouteStation = YES;
                if(!first && [station.locationByLines objectForKey:line.lineName]!=nil) [array addObject:[station.locationByLines objectForKey:line.lineName]];
            }else if(!forceFirst && [station.stationName compare:endName]==NSOrderedSame){
                //匹配到终点站,终点站无需添加
                isRouteStation = YES;
                reverse = YES;
            }
        }else{
            //已经开始添加站点
            if(reverse && [station.stationName compare:startName]==NSOrderedSame){
                //如果先匹配到终点站，再匹配到起点站
                isRouteStation = NO;
                if(!first && [station.locationByLines objectForKey:line.lineName]!=nil) [array addObject:[station.locationByLines objectForKey:line.lineName]];
            }else if([station.stationName compare:endName]==NSOrderedSame){
                //如果先匹配到起点站，终点站无需展示
                isRouteStation = NO;
            }else{
                if([station.locationByLines objectForKey:line.lineName]!=nil){
                    [array addObject:[station.locationByLines objectForKey:line.lineName]];
                }
            }
        }
    }
    
    if(reverse){
        NSArray *array1 = [[array reverseObjectEnumerator] allObjects];
        return [[NSMutableArray alloc] initWithArray:array1];
    }else{
        return array;
    }
    
}

//换线查询
-(NSMutableArray*)findFragStationLocations2:(MetroLineInfo*)line startName:(NSString*)startName endName:(NSString*)endName first:(BOOL)first last:(BOOL)last reverseCircle:(BOOL)isReverse{
    
    NSMutableArray *sNumbers = [[NSMutableArray alloc] initWithArray: [line.stationNumbers copy]];
    [sNumbers addObjectsFromArray:line.stationNumbers];
    if(isReverse){
        NSArray *array1 = [[sNumbers reverseObjectEnumerator] allObjects];
        sNumbers = [[NSMutableArray alloc] initWithArray:array1];
    }
    
    return [self findFragStationLocations1:line sNumbers:sNumbers startName:startName endName:endName first:first last:last];
}


#pragma mark --check data
-(BOOL)checkData{
    return ([self checkCities] && [self checkMetro]);
}
-(BOOL)checkCities{
    if(self.cities == nil || self.cities.count<=0){
        if(_alertSomething) self.alertSomething(0, @"数据异常，未加载到数据");
        return NO;
    }else{
        return YES;
    }
}
-(BOOL)checkMetro{
    if(self.cityInfo == nil || self.cityInfo.name == nil || self.metroInfo == nil){
        if(_alertSomething) self.alertSomething(0, @"数据异常，未加载到数据");
        return NO;
    }else if(self.cityInfo.namePdf == nil){
        if(_alertSomething) self.alertSomething(0, [NSString stringWithFormat:@"%@数据异常，未加载到数据",self.cityInfo.name]);
        return NO;
    }else{
        return YES;
    }
}

#pragma mark --read data
-(NSMutableArray*)findCitiesFromPlist{
    NSMutableArray *cities = (NSMutableArray *)[DataUtils unArchiveData:[DataUtils getDataFromBundlePlist:DATA_PLIST withKey:@"cities_info"] withClasses:[NSSet setWithObjects:[NSMutableArray class],[CityInfo class],nil]];
    return cities;
}
-(MetroInfo*)findMetroInfoFromPlist:(NSString*) key{
    MetroInfo *info = (MetroInfo *)[DataUtils unArchiveData:[DataUtils getDataFromBundlePlist:DATA_PLIST withKey:key] withClasses:[NSSet setWithObjects:[MetroInfo class],[NSMutableArray class],[NSDictionary class],[MetroLineInfo class],[MetroStationInfo class],nil]];
    return info;
}
@end
