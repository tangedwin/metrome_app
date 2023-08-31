//
//  CityModel.m
//  MetroMap
//
//  Created by edwin on 2019/10/7.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "CityModel.h"

@implementation CityModel

+(CityModel*)parseCity:(NSDictionary *)dict{
    NSMutableDictionary *cityDict = [[NSMutableDictionary alloc] initWithDictionary:dict];
    CityModel *city = [CityModel new];
    if([cityDict objectForKey:@"id"]) [city setIdentifyCode:[[cityDict objectForKey:@"id"] integerValue]];
    if([cityDict objectForKey:@"nameCn"]) [city setNameCn:[cityDict objectForKey:@"nameCn"]];
    if([cityDict objectForKey:@"nameEn"]) [city setNameEn:[cityDict objectForKey:@"nameEn"]];
    if([cityDict objectForKey:@"namePy"]){
        [city setNamePy:[cityDict objectForKey:@"namePy"]];
        [city setNameFirstLetter:[[[cityDict objectForKey:@"namePy"] substringToIndex:1] uppercaseString]];
    }
    if([cityDict objectForKey:@"fileSize"]) [city setContentSize: [[cityDict objectForKey:@"fileSize"] floatValue]];
    if([cityDict objectForKey:@"updateDate"]) [city setUpdateTime:[cityDict objectForKey:@"updateDate"]];
    if([cityDict objectForKey:@"hotCityImage"]) [city setHotCityImage:[cityDict objectForKey:@"hotCityImage"]];
    if([cityDict objectForKey:@"hotCityImageDark"]) [city setHotCityImageDark:[cityDict objectForKey:@"hotCityImageDark"]];
    if([cityDict objectForKey:@"iconUri"]) [city setIconUri:[cityDict objectForKey:@"iconUri"]];
    if([cityDict objectForKey:@"baiduUid"]) [city setBaiduUid:[cityDict objectForKey:@"baiduUid"]];
    if([cityDict objectForKey:@"recommendPriority"]) [city setPriority:[[cityDict objectForKey:@"recommendPriority"] integerValue]];
    if([cityDict objectForKey:@"latestVersion"]) [city setVersion:[[cityDict objectForKey:@"latestVersion"] integerValue]];
    return city;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"identifyCode":@"id",
             @"contentSize":@"fileSize"
    };
}

+(CityModel*)createFakeModel{
    int i = arc4random() % 5 ;
    
    CityModel *city = [CityModel new];
    city.identifyCode = 111;
    city.nameCn = @"上海";
    city.nameEn = @"Shanghai";
    city.namePy = @"shang hai";
    if(i==0){
        city.nameCn = @"上海";
        city.nameEn = @"Shanghai";
        city.namePy = @"shang hai";
    }else if(i==1){
        city.nameCn = @"北京";
        city.nameEn = @"Beijing";
        city.namePy = @"bei jing";
    }else if(i==2){
        city.nameCn = @"南京";
        city.nameEn = @"Nanjing";
        city.namePy = @"nan jing";
    }else if(i==3){
        city.nameCn = @"青岛";
        city.nameEn = @"Qingdao";
        city.namePy = @"qing dao";
    }else if(i==4){
        city.nameCn = @"苏州";
        city.nameEn = @"Suzhou";
        city.namePy = @"su zhou";
    }
    
    city.nameFirstLetter = [[city.namePy substringToIndex:1] uppercaseString];
    city.contentSize = 123321;
    city.updateTime = @"2019-08-18";
    city.hotCityImage = @"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1570440022396&di=ecc51d8b8950d5638885d549551018cb&imgtype=0&src=http%3A%2F%2Fimg.mp.itc.cn%2Fupload%2F20170605%2Fced5f249cbd94e119659a1bd8b83fca0_th.jpg";
    return city;
}

@end
