//
//  StationInfo.m
//  MetroMap
//
//  Created by edwin on 2019/9/5.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "StationInfo.h"

@implementation StationInfo

-(BOOL) checkStationByName:(NSString*)nameCn{
    if(self.nameCnOnly && [self.nameCnOnly isEqualToString:nameCn]) return YES;
    else if(!self.nameCnOnly && [self.nameCn isEqualToString:nameCn]) return YES;
    else return NO;
}

@end
