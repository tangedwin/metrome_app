//
//  CityInfo.h
//  test-metro
//
//  Created by edwin on 2019/6/19.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityInfo : NSObject<NSSecureCoding>

@property (nonatomic, retain) NSNumber *identityNum;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *nameEn;
@property (nonatomic, retain) NSString *nameCode;
@property (nonatomic, retain) NSString *namePdf;

+(CityInfo*)initWithNumber:(NSNumber*)identityNum withName:(NSString*) name withNameEn:(NSString*)nameEn withNameCode:(NSString*)nameCode withNamePdf:(NSString*)namePdf;

@end
