//
//  UserModel.h
//  MetroMap
//
//  Created by edwin on 2019/10/8.
//  Copyright © 2019 edwin. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UserModel : NSObject

@property(nonatomic, retain) NSString *identifyCode;
@property(nonatomic, retain) NSString *userName;
@property(nonatomic, retain) NSString *nickName;
@property(nonatomic, retain) NSString *phone;
@property(nonatomic, retain) NSString *portraitUrl;
@property(nonatomic, retain) NSString *homeAddressName;
@property(nonatomic, retain) NSString *homeAddress;
@property(nonatomic, retain) NSString *companyAddressName;
@property(nonatomic, retain) NSString *companyAddress;

@property (nonatomic, copy) NSString *weiboUid;
@property (nonatomic, copy) NSString *weixinUid;
@property (nonatomic, copy) NSString *qqUid;


+(UserModel*)createFakeModel;
@end
