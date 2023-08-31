//
//  MetroStationInfo.m
//  test-metro
//
//  Created by edwin on 2019/6/12.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MetroStationInfo.h"

@implementation MetroStationInfo

+(MetroStationInfo*)initWithNumber:(NSNumber*) identityNum stationName:(NSString*) stationName stationNameEn:(NSString*) stationNameEn stationNamePy:(NSString*) stationNamePy stationCode:(NSString*) stationCode stationLogoImage:(NSString*) stationLogoImage transferType:(NSString*) transferType locations:(NSMutableArray*)locations relationStations:(NSMutableArray*)relationStations{
    MetroStationInfo *msInfo = [MetroStationInfo new];
    msInfo.identityNum = identityNum;
    msInfo.stationName = stationName;
    msInfo.stationNameEn = stationNameEn;
    msInfo.stationNamePy = stationNamePy;
    msInfo.stationCode = stationCode;
    msInfo.stationLogoImage = stationLogoImage;
    msInfo.transferType = transferType;
    msInfo.locations = locations;
    msInfo.relationStations = relationStations;
    return msInfo;
    
}

+ (BOOL)supportsSecureCoding {
    return YES; //支持加密编码
}

//解码方法
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        if (aDecoder) {
            _identityNum = [aDecoder decodeObjectForKey:@"identityNum"];
            _status = [aDecoder decodeObjectForKey:@"status"];
            _baiduUids = [aDecoder decodeObjectOfClasses:[NSSet setWithObjects:[NSDictionary class],[NSMutableArray class],[NSNull class],nil] forKey:@"baiduUids"];
            _stationName = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"stationName"];
            _stationNameEn = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"stationNameEn"];
            _stationNamePy = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"stationNamePy"];
            _stationCode = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"stationCode"];
            _stationLogoImage = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"stationLogoImage"];
            _transferType = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"transferType"];
            _locations = [aDecoder decodeObjectOfClass:[NSArray class] forKey:@"locations"];
            _locationByLines = [aDecoder decodeObjectOfClass:[NSDictionary class] forKey:@"locationByLines"];
            _relationStations = [aDecoder decodeObjectOfClass:[NSArray class] forKey:@"relationStations"];
            
//            NSLog(@"%@ ---> %@",_identityNum,_stationName);
        }
    }
    return self;
}

//编码方法
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_identityNum forKey:@"identityNum"];
    [aCoder encodeObject:_status forKey:@"status"];
//    [aCoder encodeObject:_baiduUid forKey:@"baiduUid"];
    [aCoder encodeObject:_baiduUids forKey:@"baiduUids"];
    [aCoder encodeObject:_stationName forKey:@"stationName"];
    [aCoder encodeObject:_stationNameEn forKey:@"stationNameEn"];
    [aCoder encodeObject:_stationNamePy forKey:@"stationNamePy"];
    [aCoder encodeObject:_stationCode forKey:@"stationCode"];
    [aCoder encodeObject:_stationLogoImage forKey:@"stationLogoImage"];
    [aCoder encodeObject:_transferType forKey:@"transferType"];
    [aCoder encodeObject:_locations forKey:@"locations"];
    [aCoder encodeObject:_locationByLines forKey:@"locationByLines"];
    [aCoder encodeObject:_relationStations forKey:@"relationStations"];
}
@end
