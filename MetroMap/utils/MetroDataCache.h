//
//  MetroDataUtils.h
//  MetroMap
//
//  Created by edwin on 2019/9/5.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "LineInfo.h"
#import "StationInfo.h"

@interface MetroDataCache : UIView

//@property(nonatomic, retain) NSMutableArray *stations;
@property(nonatomic, retain) NSMutableArray *lines;
@property(nonatomic, retain) NSMutableDictionary *stations;
//@property(nonatomic, retain) NSMutableDictionary *lines;
    
+ (instancetype)shareInstanceWithCityCode:(NSString*)cityCode;
@end
