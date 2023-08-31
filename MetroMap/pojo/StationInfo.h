//
//  StationInfo.h
//  MetroMap
//
//  Created by edwin on 2019/9/5.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface StationInfo : UIView
    
    @property (nonatomic, retain) NSNumber *identityNum;
    
    @property (nonatomic, copy) NSString *nameCn;
    
    @property (nonatomic, copy) NSString *nameCnOnly;
    
    @property (nonatomic, copy) NSString *nameEn;
    
    @property (nonatomic, copy) NSString *namePy;
    
    @property (nonatomic, assign) CGPoint location;
    
    @property (nonatomic, copy) NSString *iconUrl;
    
    @property (nonatomic, retain) NSMutableArray *lineIds;
    
    @property (nonatomic, assign) NSNumber *status;

    -(BOOL) checkStationByName:(NSString*)nameCn;
@end

