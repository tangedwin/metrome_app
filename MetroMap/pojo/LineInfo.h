//
//  LineInfo.h
//  MetroMap
//
//  Created by edwin on 2019/9/5.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LineInfo : UIView
    
    @property (nonatomic, retain) NSNumber *identityNum;
    
    @property (nonatomic, copy) NSString *code;
    
    @property (nonatomic, copy) NSString *scode;
    
    @property (nonatomic, copy) NSString *nameCn;
    
    @property (nonatomic, copy) NSString *nameEn;
    
    @property (nonatomic, copy) NSString *iconUrl;
    
    @property (nonatomic, retain) NSMutableArray *stationIds;
    
    @property (nonatomic, copy) NSString *bgcolor;
@end
