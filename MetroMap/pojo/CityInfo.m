//
//  CityInfo.m
//  test-metro
//
//  Created by edwin on 2019/6/19.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "CityInfo.h"

@implementation CityInfo

+(CityInfo*)initWithNumber:(NSNumber*)identityNum withName:(NSString*) name withNameEn:(NSString*)nameEn withNameCode:(NSString*)nameCode withNamePdf:(NSString*)namePdf{
    CityInfo *cInfo = [CityInfo new];
    cInfo.identityNum = identityNum;
    cInfo.name = name;
    cInfo.nameEn = nameEn;
    cInfo.nameCode = nameCode;
    cInfo.namePdf = namePdf;
    return cInfo;
}

+ (BOOL)supportsSecureCoding {
    return YES; //支持加密编码
}

//解码方法
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        if (aDecoder) {
            _identityNum = [aDecoder decodeObjectForKey:@"identityNum"];
            _name = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"name"];
            _nameEn = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"nameEn"];
            _nameCode = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"nameCode"];
            _namePdf = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"namePdf"];
        }
    }
    return self;
}

//编码方法
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_identityNum forKey:@"identityNum"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_nameEn forKey:@"nameEn"];
    [aCoder encodeObject:_nameCode forKey:@"nameCode"];
    [aCoder encodeObject:_namePdf forKey:@"namePdf"];
}

@end
