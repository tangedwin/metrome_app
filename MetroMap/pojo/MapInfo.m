//
//  mapInfo.m
//  test-metro
//
//  Created by edwin on 2019/6/21.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "MapInfo.h"

@implementation MapInfo


+ (BOOL)supportsSecureCoding {
    return YES; //支持加密编码
}

//解码方法
- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        if (aDecoder) {
            _scale = [aDecoder decodeObjectOfClass:[NSNumber class] forKey:@"scale"];
            _rate = [aDecoder decodeObjectOfClass:[NSNumber class] forKey:@"rate"];
        }
    }
    return self;
}

//编码方法
- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:_scale forKey:@"scale"];
    [aCoder encodeObject:_rate forKey:@"rate"];
}


@end
