//
//  MetroInfo.m
//  test-metro
//
//  Created by edwin on 2019/6/12.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "MetroInfo.h"

@implementation MetroInfo

+(MetroInfo*)initWithNumber:(NSNumber*)identityNum lines:(NSMutableArray*) lines stations:(NSMutableArray*)stations buttonSize:(float)buttonSize{
    MetroInfo *mInfo = [MetroInfo new];
    mInfo.identityNum = identityNum;
    mInfo.stations = stations;
    mInfo.lines = lines;
    mInfo.buttonSize = buttonSize;
    return mInfo;
}

+ (BOOL)supportsSecureCoding {
    return YES; //支持加密编码
}

//解码方法
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        if (aDecoder) {
            _identityNum = [aDecoder decodeObjectForKey:@"identityNum"];
            _baiduUid = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"baiduUid"];
            _stations = [aDecoder decodeObjectOfClasses:[NSSet setWithObjects:[NSMutableArray class],[MetroStationInfo class], nil] forKey:@"stations"];
            _lines = [aDecoder decodeObjectOfClasses:[NSSet setWithObjects:[NSMutableArray class],[MetroLineInfo class], nil] forKey:@"lines"];
            _buttonSize = [aDecoder decodeFloatForKey:@"buttonSize"];
        }
    }
    return self;
}

//编码方法
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_identityNum forKey:@"identityNum"];
    [aCoder encodeObject:_baiduUid forKey:@"baiduUid"];
    [aCoder encodeObject:_stations forKey:@"stations"];
    [aCoder encodeObject:_lines forKey:@"lines"];
    [aCoder encodeFloat:_buttonSize forKey:@"buttonSize"];
}

@end
