//
//  UserModel.m
//  MetroMap
//
//  Created by edwin on 2019/10/8.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "UserModel.h"

@implementation UserModel

+(UserModel*)createFakeModel{
    UserModel *userInfo = [UserModel new];
    userInfo.identifyCode = @"aaaa";
    userInfo.nickName = @"赵天志";
    userInfo.homeAddressName = @"芳园里社区";
    userInfo.homeAddress = @"北京市朝阳区将台路";
    userInfo.companyAddressName = @"启发大厦";
    userInfo.companyAddress = @"北京市朝阳区胜古中路234弄81号";
    return userInfo;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"identifyCode":@"id"};
}

@end
