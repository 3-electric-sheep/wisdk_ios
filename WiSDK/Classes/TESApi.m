//
//  TESApi.m
//  WISDKdemo
//
//  Created by Phillp Frantz on 13/07/2017.
//  Copyright © 2012-2018 3 Electric Sheep Pty Ltd. All rights reserved.
//
//  The Welcome Interruption Software Development Kit (SDK) is licensed to you subject to the terms
//  of the License Agreement. The License Agreement forms a legally binding contract between you and
//  3 Electric Sheep Pty Ltd in relation to your use of the Welcome Interruption SDK.
//  You may not use this file except in compliance with the License Agreement.
//
//  A copy of the License Agreement can be found in the LICENSE file in the root directory of this
//  source tree.
//
//  Unless required by applicable law or agreed to in writing, software distributed under the License
//  Agreement is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
//  express or implied. See the License Agreement for the specific language governing permissions
//  and limitations under the License Agreement.

#import "TESApi.h"
#import "TESUtil.h"
#include <xlocale.h>

@implementation TESApi{

}


#pragma mark - Init

- (nonnull instancetype)initWithUrl:(nullable NSString *)urlString sessionConfiguration:(nullable NSURLSessionConfiguration *)configuration
{
    NSURL * url = [NSURL URLWithString:urlString];
    self = [self initWithBaseURL:url sessionConfiguration:configuration];
    if (!self)
        return nil;

    return self;
}

- (instancetype)initWithBaseURL:(nullable NSURL *)url sessionConfiguration:(nullable NSURLSessionConfiguration *)configuration {

    self = [super initWithBaseURL:url sessionConfiguration:configuration];
    if (!self)
        return nil;

    self.requestSerializer = [AFJSONRequestSerializer serializer];


    self.uploadProgress = nil;
    self.downloadProgress = nil;

    // seutp network reachability code

    [self.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        NSLog(@"Reachability Change: %@", AFStringFromNetworkReachabilityStatus(status));
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWWAN:
            case AFNetworkReachabilityStatusReachableViaWiFi:
                NSLog(@"WIFI");
                break;
            case AFNetworkReachabilityStatusNotReachable:
            default:
                NSLog(@"oflline");
                break;
        }
    }];
    [self.reachabilityManager startMonitoring];


    return self;
}

#pragma mark - API specific

- (NSURL *) endpoint : (NSString *) path
{
    return [NSURL URLWithString:path relativeToURL:self.baseURL];
    
}

- (BOOL) isAuthorized
{
    return self.accessToken != nil;
}

- (BOOL) isSuccessful: (NSDictionary *) result
{
    return [[result valueForKey:@"success"] boolValue];
}

- (BOOL) isAuthFailure: (NSError *) error
{
    if (!error)
        return NO;

    BOOL authFailure = NO;
    if (error.domain == AFURLResponseSerializationErrorDomain && error.userInfo != nil){
        NSHTTPURLResponse * resp = [error.userInfo valueForKey:AFNetworkingOperationFailingURLResponseErrorKey];
        if (resp != nil && (resp.statusCode == 403 || resp.statusCode == 401)){
            authFailure = YES;
        }
    }
    return authFailure;
}
            
-(BOOL) isServerError: (NSError *) error
{
    return (error.domain == AFURLResponseSerializationErrorDomain && (error.code == NSURLErrorBadServerResponse || error.code == NSURLErrorCannotDecodeContentData || error.code == NSURLErrorBadURL));
}
            
            
-(BOOL) isNetworkError: (NSError *) error
{
    return (error.domain == NSURLErrorDomain);
}
            
- (nullable NSURLSessionDataTask *)call:(nonnull NSString *)method
                                    url:(nonnull NSString *)urlString
                             parameters:(nullable id)parameters
                                   auth:(BOOL) needToken
                      completionHandler:(TESApiCallback)callback
{
    if (needToken)
        urlString = [self addAccessToken:urlString];
    
    NSDictionary * jsonParams = TEStoJSON(parameters);
    [self.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"]; // Accept HTTP Header
    self.responseSerializer = [AFJSONResponseSerializer serializer];
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:urlString relativeToURL:self.baseURL] absoluteString] parameters:jsonParams error:&serializationError];
    
    if (serializationError) {
        dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
            NSLog(@"SerializationError: %@", serializationError);
        });
        
        return nil;
    }
    
    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:request
                          uploadProgress:self.uploadProgress
                        downloadProgress:self.downloadProgress
                       completionHandler:(void (^)(NSURLResponse *, id, NSError *)) ^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
                           NSDictionary *result;
                           TESCallStatus status;
                           TESResultType resultType = [self decodeResult:response
                                                      withResponseObject:responseObject
                                                                andError:error
                                                            outputResult:&result
                                                            outputStatus:&status];

                           // callback is not called if we get an auth error and it was handled in the delegate. If there
                           // is no delegate the result type will never be set and the callback will be called as usual with a
                           // status of TESApiError
                           if (callback && resultType != TESResultErrorAuth) {
                               callback(status, result);
                           }


                       }];
    [dataTask resume];
    
    return dataTask;
}


- (nullable NSURLSessionDataTask *) downloadImage:(nonnull NSString *)method
                                    url:(nonnull NSString *)urlString
                             parameters:(nullable id)parameters
                                   auth:(BOOL) needToken
                      completionHandler:(TESApiCallback)callback
{
    if (needToken)
        urlString = [self addAccessToken:urlString];

    NSDictionary * jsonParams = TEStoJSON(parameters);
    self.responseSerializer = [AFImageResponseSerializer serializer];

    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:urlString relativeToURL:self.baseURL] absoluteString] parameters:jsonParams error:&serializationError];

    if (serializationError) {
        dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
            NSLog(@"SerializationError: %@", serializationError);
        });

        return nil;
    }

    __block NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:request
                          uploadProgress:self.uploadProgress
                        downloadProgress:self.downloadProgress
                       completionHandler:(void (^)(NSURLResponse *, id, NSError *)) ^(NSHTTPURLResponse *response, id responseObject, NSError *error) {
                           NSDictionary *result;
                           TESCallStatus status;
                           TESResultType resultType = [self decodeResult:response
                                                      withResponseObject:responseObject
                                                                andError:error
                                                            outputResult:&result
                                                            outputStatus:&status];

                           // callback is not called if we get an auth error and it was handled in the delegate. If there
                           // is no delegate the result type will never be set and the callback will be called as usual with a
                           // status of TESApiError
                           if (callback && resultType != TESResultErrorAuth) {
                              callback(status, result);
                          }

                      }];
    [dataTask resume];

    return dataTask;
}

- (nullable NSURLSessionDownloadTask *)downloadFile:(nonnull NSString *)method
                                                url:(nonnull NSString *)urlString
                                     parameters:(nullable id)parameters
                                           auth:(BOOL) needToken
                              completionHandler:(TESApiCallback)callback
{
    if (needToken)
        urlString = [self addAccessToken:urlString];
    
    NSDictionary * jsonParams = TEStoJSON(parameters);
    
    NSError *serializationError = nil;
    NSMutableURLRequest *request = [self.requestSerializer requestWithMethod:method URLString:[[NSURL URLWithString:urlString relativeToURL:self.baseURL] absoluteString] parameters:jsonParams error:&serializationError];
    
    if (serializationError) {
        dispatch_async(self.completionQueue ?: dispatch_get_main_queue(), ^{
            NSLog(@"SerializationError: %@", serializationError);
        });
        
        return nil;
    }

    NSURLSessionDownloadTask *downloadTask = [self downloadTaskWithRequest:request progress:self.downloadProgress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
    }                                                   completionHandler:(void (^)(NSURLResponse *, NSURL *, NSError *)) ^(NSHTTPURLResponse *response, NSURL *filePath, NSError *error) {
        NSDictionary *result;
        TESCallStatus status;
        TESResultType resultType = [self decodeResult:response
                                   withResponseObject:filePath
                                             andError:error
                                         outputResult:&result
                                         outputStatus:&status];

        // callback is not called if we get an auth error and it was handled in the delegate. If there
        // is no delegate the result type will never be set and the callback will be called as usual with a
        // status of TESApiError
        if (callback && resultType != TESResultErrorAuth) {
            callback(status, result);
        }
    }];
    [downloadTask resume];
    return downloadTask;
}


#pragma mark - image upload
-(void)uploadImage:(nonnull NSString *)method
              path:(nonnull NSString *)urlString
         withImage:(nonnull UIImage *)image
          withName:(nonnull NSString *)name
              auth:(BOOL)needToken
 completionHandler: (TESApiCallback) callback
{
    if (needToken)
        urlString = [self addAccessToken:urlString];

    // for now hard wired to png
    NSData * data = UIImagePNGRepresentation(image);
    NSString * imageType = @"png";
    NSString * filename = [[NSString alloc] initWithFormat:@"%@.%@", name, imageType];

    NSMutableURLRequest *request = [[AFHTTPRequestSerializer serializer] multipartFormRequestWithMethod:method URLString:[[NSURL URLWithString:urlString relativeToURL:self.baseURL] absoluteString]   parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
        [formData appendPartWithFileData:data name:name fileName:filename mimeType:[[NSString alloc] initWithFormat:@"image/%@", imageType]];
    } error:nil];


    NSURLSessionUploadTask *uploadTask;
    uploadTask = [self uploadTaskWithStreamedRequest:request
                                            progress:self.uploadProgress
                                   completionHandler:(void (^)(NSURLResponse *, id, NSError *)) ^(NSHTTPURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                       NSDictionary *result;
                                       TESCallStatus status;
                                       TESResultType resultType = [self decodeResult:response
                                                                  withResponseObject:responseObject
                                                                            andError:error
                                                                        outputResult:&result
                                                                        outputStatus:&status];

                                       // callback is not called if we get an auth error and it was handled in the delegate. If there
                                       // is no delegate the result type will never be set and the callback will be called as usual with a
                                       // status of TESApiError
                                       if (callback && resultType != TESResultErrorAuth) {
                                           callback(status, result);
                                       }
                                    }];

    [uploadTask resume];
}

#pragma mark - background support

- (void)setShouldExecuteAsBackgroundTask: (nullable NSURLSessionDataTask *)downloadTask WithExpirationHandler:(nullable void (^)())handler {
    if (!self.backgroundTaskIdentifier) {
        UIApplication *application = [UIApplication sharedApplication];
        __weak __typeof(&*self)weakSelf = self;
        __weak  NSURLSessionDataTask * weakTask = downloadTask;
        self.backgroundTaskIdentifier = [application beginBackgroundTaskWithExpirationHandler:^{
            __strong __typeof(&*weakSelf)strongSelf = weakSelf;
            __strong  NSURLSessionDataTask * strongTask = weakTask;

            if (handler) {
                handler();
            }

            if (strongTask) {
                [strongTask cancel];

                [application endBackgroundTask:strongSelf.backgroundTaskIdentifier];
                strongSelf.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
            }
        }];
    }
}

#pragma mark - Utility functions

- (TESResultType) decodeResult: (nonnull NSHTTPURLResponse *) response
            withResponseObject: (nonnull id) responseObject
                      andError: (nullable NSError *) error
                  outputResult: (NSDictionary **) result
                  outputStatus: (TESCallStatus *) status

{
    TESResultType resultType;
    NSNumber * httpStatus = @(response.statusCode);

    if (error) {
        *status = TESCallError;
        *result = @{
                @"success": @NO,
                @"msg": [error description],
                @"HttpStatus": httpStatus
        };
        resultType = TESResultErrorNetwork;
    } else {
        if (response.statusCode >= 100 || response.statusCode < 300) {
            if ([responseObject isKindOfClass:[NSDictionary class]]){
                *result = (NSDictionary *) responseObject;
                BOOL success = [[*result valueForKey:@"success"] boolValue];
                *status = (success) ? TESCallSuccessOK : TESCallSuccessFAIL;
            }
            else {
                *result = @{
                        @"success": @YES,
                        @"data": responseObject
                };
                *status = TESCallSuccessOK;
            };
            resultType = TESResultGood;
        } else {
            *status = TESCallError;
            *result = @{
                    @"success": @NO,
                    @"msg": response.description,
                    @"HttpStatus": httpStatus
            };
            resultType = TESResultErrorHttp;
        }
    }

    if (([self isAuthFailure:error] || response.statusCode == 401 || response.statusCode == 403) && self.delegate != nil) {
        resultType = TESResultErrorAuth;
        [self.delegate httpAuthFailure:response];
    }

    return resultType;

}

- (NSString *) addAccessToken: (NSString *) url
{
  if (self.accessToken) {
        NSString * delim = ([url rangeOfString:@"?"].location == NSNotFound) ? @"?" : @"&";
        NSString * auth =  AFPercentEscapedStringFromString(self.accessToken);
        url =[url stringByAppendingFormat:@"%@token=%@", delim, auth];
    }
        
    return url;

}

NSDictionary * TEStoJSON(NSDictionary * params)
{
    if (params == nil)
        return params;
    
    NSMutableDictionary * json_params = [params mutableCopy];
    [params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([obj isKindOfClass:[NSDate class]]) {
            // note: this is on purpose since we can't enumerate json_params directly
            // due to enumeration not allowing the change of items we are enumerating.
            [json_params setValue:[TESUtil stringFromDate:obj] forKey:key];
        }
    }];
    return json_params;
}

@end
