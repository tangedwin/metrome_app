//
//  StationDetailModel.h
//  MetroMap
//
//  Created by edwin on 2019/10/23.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface StationDetailModel : NSObject

@property (nonatomic, copy) NSString *area;
@property (nonatomic, copy) NSString *area_en;

@property (nonatomic, retain) NSMutableArray *planMap_uri;
@property (nonatomic, retain) NSMutableArray *toilets;
@property (nonatomic, retain) NSMutableArray *toilets_en;
@property (nonatomic, retain) NSMutableArray *elevators;
@property (nonatomic, retain) NSMutableArray *elevators_en;
@property (nonatomic, retain) NSMutableArray *exits;
@property (nonatomic, retain) NSMutableArray *exits_en;

@property (nonatomic, retain) NSMutableDictionary *others;
@property (nonatomic, retain) NSMutableDictionary *others_en;
@end

