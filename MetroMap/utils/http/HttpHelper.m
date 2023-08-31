//
//  HttpHelper.m
//  ipet-photo
//
//  Created by edwin on 2019/8/1.
//  Copyright © 2019 edwin. All rights reserved.
//

#import "HttpHelper.h"

#import "MBProgressHUD+Customer.h"

@interface HttpHelper()

@property(nonatomic, retain) HttpHelper *httpHelper;

@property(nonatomic, assign) NSInteger timeStamp;
@property(nonatomic, retain) NSString *version;
@property(nonatomic, retain) NSString *deviceUuid;
@property(nonatomic, retain) NSString *userAgent;
@property(nonatomic, retain) NSString *authorization;


@property(nonatomic, copy) NSString *reqUri;
@property(nonatomic, copy) NSString *token;
@property(nonatomic, copy) NSString *userId;
@property(nonatomic, copy) NSMutableDictionary *parameters;
@property(nonatomic, copy) NSString *requesteType;

@property(nonatomic, retain) AFHTTPSessionManager *tokenHTTPRequestManager;
@property(nonatomic, retain) AFHTTPSessionManager *tokenJSONRequestManager;
@property(nonatomic, retain) AFHTTPSessionManager *normalJSONRequestManager;

@end

@implementation HttpHelper

//查询详情
-(void)requestDetail:(NSString*)url params:(NSMutableDictionary*)parameters progress:(void(^)(NSProgress *progress))progress success:(void(^)(NSMutableDictionary *responseDic))success failure:(void(^)(NSString *errorInfo))failure{

    url = [url stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
    [self.normalJSONRequestManager GET:url parameters:parameters progress:^(NSProgress * _Nonnull queryProgress) {
        if(progress){
            progress(queryProgress);
        }else{
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        success(responseObject);
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        if(failure) failure([error description]);
    }];
}

//提交
- (void)submit:(NSString*)uri params:(NSMutableDictionary*)parameters progress:(void(^)(NSProgress *progress))progress success:(void(^)(NSMutableDictionary *responseDic))success failure:(void(^)(NSString *errorInfo))failure{
    _reqUri = uri;
    _requesteType = @"POST";
    _parameters = parameters;
    
    if(!parameters || parameters.count<=0){
        failure(@"参数错误");
        return;
    }
    [self.tokenJSONRequestManager POST:[self url:uri] parameters:_parameters progress:^(NSProgress * _Nonnull uploadProgress) {
        if(progress){
            progress(uploadProgress);
        }else{
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableDictionary *dic = (NSMutableDictionary*)responseObject;
        if([@"0000" isEqualToString:[dic objectForKey:@"respCode"]]){
            success((NSMutableDictionary*)[dic objectForKey:@"result"]);
        }else if([@"1100" isEqualToString:[dic objectForKey:@"respCode"]]){
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_USER_ID_KEY];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_USER_TOKEN_KEY];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_USER_KEY];
            [[NSUserDefaults standardUserDefaults] setObject:LOGIN_USER_TYPE_TOURIST forKey:LOGIN_USER_TYPE_KEY];
            if(failure) failure((NSString*)[dic objectForKey:@"respDesc"]);
        }else{
            if(failure) failure((NSString*)[dic objectForKey:@"respDesc"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",[error description]);
        if(failure) failure([error description]);
        else [MBProgressHUD showInfo:@"网络异常" detail:nil image:nil inView:nil];
    }];
    
}


//查询详情
-(void)findRoute:(NSString*)uri params:(NSMutableDictionary*)parameters progress:(void(^)(NSProgress *progress))progress success:(void(^)(NSMutableDictionary *responseDic))success failure:(void(^)(NSString *errorInfo))failure{
    _reqUri = uri;
    _requesteType = @"GET";
    _parameters = parameters;
    
    self.tokenJSONRequestManager.requestSerializer.timeoutInterval = 5.f;
//    AlertUtils *alert = [AlertUtils new];
    [self.tokenJSONRequestManager GET:[self url:uri] parameters:_parameters progress:^(NSProgress * _Nonnull queryProgress) {
        if(progress){
            progress(queryProgress);
        }else{
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableDictionary *dic = (NSMutableDictionary*)responseObject;
        if([@"0000" isEqualToString:[dic objectForKey:@"respCode"]]){
            success((NSMutableDictionary*)[dic objectForKey:@"result"]);
        }else if([@"1100" isEqualToString:[dic objectForKey:@"respCode"]]){
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_USER_ID_KEY];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_USER_TOKEN_KEY];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_USER_KEY];
            [[NSUserDefaults standardUserDefaults] setObject:LOGIN_USER_TYPE_TOURIST forKey:LOGIN_USER_TYPE_KEY];
            if(failure) failure((NSString*)[dic objectForKey:@"respDesc"]);
        }else{
            if(failure) failure((NSString*)[dic objectForKey:@"respDesc"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",[error description]);
        if(failure) failure([error description]);
        else [MBProgressHUD showInfo:@"网络异常" detail:nil image:nil inView:nil];
    }];
}


//查询详情
-(void)findDetail:(NSString*)uri params:(NSMutableDictionary*)parameters progress:(void(^)(NSProgress *progress))progress success:(void(^)(NSMutableDictionary *responseDic))success failure:(void(^)(NSString *errorInfo))failure{
    _reqUri = uri;
    _requesteType = @"GET";
    _parameters = parameters;
    
//    AlertUtils *alert = [AlertUtils new];
    [self.tokenJSONRequestManager GET:[self url:uri] parameters:_parameters progress:^(NSProgress * _Nonnull queryProgress) {
        if(progress){
            progress(queryProgress);
        }else{
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableDictionary *dic = (NSMutableDictionary*)responseObject;
        if([@"0000" isEqualToString:[dic objectForKey:@"respCode"]]){
            success((NSMutableDictionary*)[dic objectForKey:@"result"]);
        }else if([@"1100" isEqualToString:[dic objectForKey:@"respCode"]]){
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_USER_ID_KEY];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_USER_TOKEN_KEY];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_USER_KEY];
            [[NSUserDefaults standardUserDefaults] setObject:LOGIN_USER_TYPE_TOURIST forKey:LOGIN_USER_TYPE_KEY];
            if(failure) failure((NSString*)[dic objectForKey:@"respDesc"]);
        }else{
            if(failure) failure((NSString*)[dic objectForKey:@"respDesc"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",[error description]);
        if(failure) failure([error description]);
        else [MBProgressHUD showInfo:@"网络异常" detail:nil image:nil inView:nil];
    }];
}

//查询列表
-(void)findList:(NSString*)uri params:(NSMutableDictionary*)parameters page:(NSInteger)page progress:(void(^)(NSProgress *progress))progress success:(void(^)(NSMutableDictionary *responseDic))success failure:(void(^)(NSString *errorInfo))failure{
    _reqUri = uri;
    _requesteType = @"GET";
    
    if(!parameters){
        parameters = [NSMutableDictionary new];
    }
    [parameters setObject:@(page) forKey:@"pageNum"];
    _parameters = parameters;
    
    [self.tokenJSONRequestManager GET:[self url:uri] parameters:_parameters progress:^(NSProgress * _Nonnull queryProgress) {
        if(progress){
            progress(queryProgress);
        }else{
        }
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        NSMutableDictionary *dic = (NSMutableDictionary*)responseObject;
        if([@"0000" isEqualToString:[dic objectForKey:@"respCode"]]){
            success((NSMutableDictionary*)[dic objectForKey:@"result"]);
        }else if([@"1100" isEqualToString:[dic objectForKey:@"respCode"]]){
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_USER_ID_KEY];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_USER_TOKEN_KEY];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_USER_KEY];
            [[NSUserDefaults standardUserDefaults] setObject:LOGIN_USER_TYPE_TOURIST forKey:LOGIN_USER_TYPE_KEY];
            if(failure) failure((NSString*)[dic objectForKey:@"respDesc"]);
        }else{
            if(failure) failure((NSString*)[dic objectForKey:@"respDesc"]);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@",[error description]);
        if(failure) failure([error description]);
        else [MBProgressHUD showInfo:@"网络异常" detail:nil image:nil inView:nil];
    }];
}

//上传图片
- (void)uploadImage:(UIImage*)image uri:(NSString*)uri progress:(void(^)(NSProgress *progress))progress success:(void(^)(NSMutableDictionary *responseDic))success failure:(void(^)(NSString *errorInfo))failure{
    _reqUri = uri;
    
    NSMutableURLRequest *request = [self.tokenHTTPRequestManager.requestSerializer  multipartFormRequestWithMethod:@"POST" URLString:[self url:uri]  parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:UIImageJPEGRepresentation(image, 1.0) name:@"file" fileName:@"test.jpg" mimeType:@"image/jpg"];
    } error:nil];
    
    [self.tokenHTTPRequestManager.requestSerializer willChangeValueForKey:@"timeoutInterval"];
    self.tokenHTTPRequestManager.requestSerializer.timeoutInterval = 30.f;
    [self.tokenHTTPRequestManager.requestSerializer didChangeValueForKey:@"timeoutInterval"];
    
//    AlertUtils *alert = [AlertUtils new];
    NSURLSessionUploadTask *uploadTask = [self.tokenHTTPRequestManager uploadTaskWithStreamedRequest:request progress:^(NSProgress *taskProgress){
        if(progress){
            progress(taskProgress);
        }else{
//            dispatch_sync(dispatch_get_main_queue(), ^{
//                [alert showProgressView:taskProgress];
//            });
        }
    } completionHandler:^(NSURLResponse *response, id responseObject, NSError *error) {
        if (error) {
            if(failure) failure([error description]);
        } else {
            NSMutableDictionary *dic = (NSMutableDictionary*)responseObject;
            if([@"0000" isEqualToString:[dic objectForKey:@"respCode"]]){
                success((NSMutableDictionary*)[dic objectForKey:@"result"]);
            }else if([@"1100" isEqualToString:[dic objectForKey:@"respCode"]]){
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_USER_ID_KEY];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_USER_TOKEN_KEY];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:LOGIN_USER_KEY];
                [[NSUserDefaults standardUserDefaults] setObject:LOGIN_USER_TYPE_TOURIST forKey:LOGIN_USER_TYPE_KEY];
                if(failure) failure((NSString*)[dic objectForKey:@"respDesc"]);
            }else{
                if(failure) failure((NSString*)[dic objectForKey:@"respDesc"]);
            }
        }
    }];
    [uploadTask resume];
}


-(NSString*)url:(NSString*)uri{
//    if([uri hasPrefix:@"user"] || [uri hasPrefix:@"/user"]){
//        return [Base_URL_USER stringByAppendingString:uri];
//    }else if([uri hasPrefix:@"pet"] || [uri hasPrefix:@"/pet"]){
//        return [Base_URL_PET stringByAppendingString:uri];
//    }else if([uri hasPrefix:@"photo"] || [uri hasPrefix:@"/photo"] || [uri hasPrefix:@"file"] || [uri hasPrefix:@"/file"]){
//        return [Base_URL_PHOTO stringByAppendingString:uri];
//    }else{
//        return [Base_URL stringByAppendingString:uri];
//    }
    return [Base_URL stringByAppendingString:uri];
}

-(AFHTTPSessionManager*)tokenHTTPRequestManager{
    //如果token变化则重新获取manager
    [self checkToken];
//    if(!_tokenJSONRequestManager || !sameToken){
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = 10;
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration: configuration];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        
        if(_token && ![_token isEqualToString:@""]){
            [manager.requestSerializer setValue:_token forHTTPHeaderField:@"session"];
            [manager.requestSerializer setValue:_userId forHTTPHeaderField:@"userId"];
        }
        [manager.requestSerializer setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
        [manager.requestSerializer setValue:@"APP" forHTTPHeaderField:@"request-source"];
        if(_authorization) [manager.requestSerializer setValue:_authorization forHTTPHeaderField:@"authorization"];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/javascript",@"application/json",@"text/json",@"text/plain",nil];
        _tokenJSONRequestManager = manager;
//    }
    [self decryptParameters];
    return _tokenJSONRequestManager;
}


-(AFHTTPSessionManager*)normalJSONRequestManager{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    configuration.timeoutIntervalForRequest = 10;
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration: configuration];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    _normalJSONRequestManager = manager;
    return _normalJSONRequestManager;
}

-(AFHTTPSessionManager*)tokenJSONRequestManager{
    //如果token变化则重新获取manager
    [self checkToken];
    if(!_tokenJSONRequestManager){
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.timeoutIntervalForRequest = 10;
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration: configuration];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
    
        if(_token && ![_token isEqualToString:@""]){
            [manager.requestSerializer setValue:_token forHTTPHeaderField:@"session"];
            [manager.requestSerializer setValue:_userId forHTTPHeaderField:@"userId"];
        }
        
        [manager.requestSerializer setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
        [manager.requestSerializer setValue:@"APP" forHTTPHeaderField:@"request-source"];
        [manager.requestSerializer setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        if(_authorization) [manager.requestSerializer setValue:_authorization forHTTPHeaderField:@"authorization"];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"text/html",@"text/javascript",@"application/json",@"text/json",@"text/plain",nil];
        _tokenJSONRequestManager = manager;
        [self decryptParameters];
    }
    return _tokenJSONRequestManager;
}

-(void)decryptParameters{
    if(!_parameters || !_requesteType) return;
    
    if([@"POST" isEqualToString:_requesteType]){
        int offset = [[_userAgent substringFromIndex:_userAgent.length-1] intValue];
        int beginIdx = 0 + offset;
        NSString *key = [_authorization substringWithRange:NSMakeRange(beginIdx, 16)];
        NSString *encryptString = [BaseUtils encryptStringWithString:[_parameters yy_modelToJSONString] andKey:key];
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setValue:encryptString forKey:@"params"];
        _parameters = params;
    }else if([@"GET" isEqualToString:_requesteType] && _userAgent){
        NSString *paramsStr = @"";
        NSArray *pnames = _parameters.allKeys;
        for(NSString *name in pnames){
            if([_parameters[name] isKindOfClass:[NSString class]])
                paramsStr = [NSString stringWithFormat:@"%@&%@=%@",paramsStr,name,_parameters[name]];
            else paramsStr = [NSString stringWithFormat:@"%@&%@=%@",paramsStr,name,[_parameters[name] stringValue]];
        }
        
        int offset = [[_userAgent substringFromIndex:_userAgent.length-1] intValue];
        int beginIdx = 0 + offset;
        NSString *key = [_authorization substringWithRange:NSMakeRange(beginIdx, 16)];
        NSString *encryptString = [BaseUtils encryptStringWithString:paramsStr andKey:key];

        encryptString = [encryptString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
        NSMutableDictionary *params = [NSMutableDictionary new];
        [params setValue:encryptString forKey:@"params"];
        _parameters = params;
    }
}


-(NSString *)userAgent{
    _timeStamp = [BaseUtils getNowTimeTimestamp];
    //TODO: 获取后台版本号
    _version = MY_VERSION;
    _deviceUuid = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    
    NSString *userAgent = [NSString stringWithFormat: @"MetroMe/%@", _version];
    //手机系统
    userAgent = [userAgent stringByAppendingString:[NSString stringWithFormat:@"/%@",[[UIDevice currentDevice] systemName]]];
    //系统版本
    userAgent = [userAgent stringByAppendingString:[NSString stringWithFormat:@"/%@",[[UIDevice currentDevice] systemVersion]]];
    //手机型号
    userAgent = [userAgent stringByAppendingString:[NSString stringWithFormat:@"/%@",[BaseUtils iphoneType]]];
    //UUID
    userAgent = [userAgent stringByAppendingString:[NSString stringWithFormat:@"/%@",_deviceUuid]];
    //时间戳
    userAgent = [userAgent stringByAppendingString:[NSString stringWithFormat:@"/%@",[NSString stringWithFormat:@"%ld", (long)_timeStamp]]];
    _userAgent =  userAgent;
    
    if(_reqUri){
        NSString *signature = [NSString stringWithFormat:@"%@%ld%@%@",_version,(long)_timeStamp,_reqUri,_deviceUuid];
        _authorization = [NSString stringWithFormat:@"%@%@",[BaseUtils stringToMD5:signature],[BaseUtils hexStringFromString:[NSDecimalNumber decimalNumberWithString:[NSString stringWithFormat:@"%ld",(long)_timeStamp]]]];
    }
    
    return _userAgent;
}

-(BOOL)checkToken{
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_USER_TOKEN_KEY];
    NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:LOGIN_USER_ID_KEY];
    if(!_token || !_userId){
        _token = token;
        _userId = userId;
        return NO;
    }else if(![_token isEqualToString:token] || ![_userId isEqualToString:userId]){
        _token = token;
        _userId = userId;
        return NO;
    }
    return YES;
}

+(instancetype)http{
//    static HttpHelper *_httpHelper = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        //不能再使用alloc方法
//        //因为已经重写了allocWithZone方法，所以这里要调用父类的分配空间的方法
//        _httpHelper = [[super allocWithZone:NULL] init];
//    });
//    return _httpHelper;
    return [HttpHelper new];
}
@end
