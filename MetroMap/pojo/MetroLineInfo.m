//
//  MetroLineInfo.m
//  test-metro
//
//  Created by edwin on 2019/6/12.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "MetroLineInfo.h"

@implementation MetroLineInfo

+(MetroLineInfo*)initWithNumber:(NSNumber*) identityNum lineName:(NSString*) lineName lineNameEn:(NSString*) lineNameEn lineCode:(NSString*) lineCode lineColor:(NSString*) lineColor lineBorderColor:(NSString*) lineBorderColor lineTextColor:(NSString*) lineTextColor forwardName:(NSString*) forwardName reverseName:(NSString*) reverseName stationNumbers:(NSMutableArray*)stationNumbers relationLineNumbers:(NSMutableArray*)relationLineNumbers{
    MetroLineInfo *mlInfo = [MetroLineInfo new];
    mlInfo.identityNum = identityNum;
    mlInfo.lineName = lineName;
    mlInfo.lineNameEn = lineNameEn;
    mlInfo.lineCode = lineCode;
    mlInfo.lineColor = lineColor;
    mlInfo.lineBorderColor = lineBorderColor;
    mlInfo.lineTextColor = lineTextColor;
    mlInfo.forwardName = forwardName;
    mlInfo.reverseName = reverseName;
    mlInfo.stationNumbers = stationNumbers;
    mlInfo.relationLineNumbers = relationLineNumbers;
    return mlInfo;
}

+ (BOOL)supportsSecureCoding {
    return YES; //支持加密编码
}

//解码方法
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        if (aDecoder) {
            _identityNum = [aDecoder decodeObjectForKey:@"identityNum"];
//            _baiduUid = [aDecoder decodeObjectOfClass:[NSMutableArray class] forKey:@"baiduUid"];
            _baiduUids = [aDecoder decodeObjectOfClass:[NSDictionary class] forKey:@"baiduUids"];
            _lineName = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"lineName"];
            _lineNameEn = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"lineNameEn"];
            _lineCode = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"lineCode"];
            _lineColor = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"lineColor"];
            _lineBorderColor = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"lineBorderColor"];
            _lineTextColor = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"lineTextColor"];
            _forwardName = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"forwardName"];
            _reverseName = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"reverseName"];
            _stationNumbers = [aDecoder decodeObjectOfClass:[NSArray class] forKey:@"stationNumbers"];
            _relationLineNumbers = [aDecoder decodeObjectOfClass:[NSArray class] forKey:@"relationLineNumbers"];
        }
    }
    return self;
}

//编码方法
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_identityNum forKey:@"identityNum"];
//    [aCoder encodeObject:_baiduUid forKey:@"baiduUid"];
    [aCoder encodeObject:_baiduUids forKey:@"baiduUids"];
    [aCoder encodeObject:_lineName forKey:@"lineName"];
    [aCoder encodeObject:_lineNameEn forKey:@"lineNameEn"];
    [aCoder encodeObject:_lineCode forKey:@"lineCode"];
    [aCoder encodeObject:_lineColor forKey:@"lineColor"];
    [aCoder encodeObject:_lineBorderColor forKey:@"lineBorderColor"];
    [aCoder encodeObject:_lineTextColor forKey:@"lineTextColor"];
    [aCoder encodeObject:_forwardName forKey:@"forwardName"];
    [aCoder encodeObject:_reverseName forKey:@"reverseName"];
    [aCoder encodeObject :_stationNumbers forKey:@"stationNumbers"];
    [aCoder encodeObject :_relationLineNumbers forKey:@"relationLineNumbers"];
}
@end
