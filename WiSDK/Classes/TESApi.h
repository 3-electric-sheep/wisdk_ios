//
//  TESApi.h
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

#ifndef TESApi_h
#define TESApi_h

#import "LocationInfo.h"
#import "Device.h"

#import "AFNetworking/AFNetworking.h"
#import "AFNetworking/AFNetworkReachabilityManager.h"

#define TES_AUTH_TYPE_NATIVE  @"native"
#define TES_AUTH_TYPE_FACEBOOK  @"facebook"
#define TES_AUTH_TYPE_GOOGLE  @"google"
#define TES_AUTH_TYPE_ANONYMOUS @"anonymous"

/**
 response status
 */
typedef NS_ENUM(NSInteger, TESCallStatus) {
    TESCallSuccessOK,     // call succeeded with an OK status
    TESCallSuccessFAIL,   // call succeeded but the json packet returned failure
    TESCallError
};

/**
 * status of call if in error
 */

typedef NS_ENUM(NSInteger, TESResultType){
    TESResultGood,          // no error in the result.  All good
    TESResultErrorNetwork,  // general nework error
    TESResultErrorHttp,     // http server returned a bad status
    TESResultErrorAuth      // either a 401 or 403 was returned
};

/** 
 progress callback signaure
 */

typedef  void(^ProgressCallback)(NSProgress * _Nullable);

/**
 callback type for all App API calls
 */
typedef void  (^ _Nullable TESApiCallback)(TESCallStatus status,  NSDictionary * _Nullable responseObject);

//----------------------------------------------
// TESWIAppDelegate protocol
//----------------------------------------------
@protocol TESApiDelegate <NSObject>
@optional

/**
 sent what an authorization has failed
 */
- (void) httpAuthFailure: (nullable NSHTTPURLResponse *) response;

@end

/**
 The API class used to make http calls
 **/

@interface TESApi : AFHTTPSessionManager

@property (nullable) id <TESApiDelegate> delegate;

/**
 Authentication token to be passed to all endpoints that require an authenticated user.
 this token is returned from a login call
 */

@property (strong, nonatomic, nullable) NSString * accessToken;
@property (nonatomic, strong, nullable) NSString *accessAuthType;
@property (nonatomic, strong, nullable) NSDictionary * accessAuthInfo;
@property (nonatomic, strong, nullable) NSDictionary * accessSystemDefaults;

/**
 * background expiration handler
 */

@property (readwrite, nonatomic, assign) UIBackgroundTaskIdentifier backgroundTaskIdentifier;


/**
 Status of network 
 */

@property (nonatomic) AFNetworkReachabilityStatus networkStatus;

/**
 upload / download process hooks
 **/

@property (nonatomic, copy, nullable) ProgressCallback uploadProgress;
@property (nonatomic, copy, nullable) ProgressCallback downloadProgress;

/**
 checks to see if a web reguest is successful. The default implementation  checks the response dictionary for a boolean field called success
 
 @param result The dictionary returned from the request
 **/
- (BOOL) isSuccessful: (nonnull NSDictionary *) result;

/**
 returns whether the user has an authorziation token or not
 */
- (BOOL) isAuthorized;



/**
 Set of headers to pass to each request
*/

@property (strong, nonatomic, nullable) NSDictionary * headers;

/**
 A representionation of the an api endpoint as a NSURL object.
 
 @param path the path to add to the endpoint.
 */

- (nullable NSURL *) endpoint: (nullable NSString *) path
;

///-----------------------
/// @ class functions
///-----------------------

/**
 *  Initializes an instance of the API manager *
 
    @param url : which endpoint to connect to
    @param configuration : session config or null*/
- (nonnull instancetype)initWithBaseURL:(nullable NSURL *)url sessionConfiguration:(nullable NSURLSessionConfiguration *)configuration NS_DESIGNATED_INITIALIZER;


/**
 *  Conenience Initializes an instance of the API manager * with just takes a string rather than a NSUrl for the endpoint

    @param urlString : which endpoint to connect to
    @param configuration : session config or null*/

- (nonnull instancetype)initWithUrl:(nullable NSString *)urlString sessionConfiguration:(nullable NSURLSessionConfiguration *)configuration;


/**
 Creates and runs an `NSURLSessionDataTask` with a request.
 
 @param method the HTTP method
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param needToken needs authentication
 @param callback A block object to be executed when the task finishes . This block has no return value and takes 4 arguments:

         status of task : SUCCESS_OK , SUCCESS_FAIL, ERROR
         response object created by the client response serializer.
 */

- (nullable NSURLSessionDataTask *)call:(nonnull NSString *)method
                                    url:(nonnull NSString *)URLString
                            parameters:(nullable id)parameters
                                   auth:(BOOL) needToken
                      completionHandler:(TESApiCallback)callback;

/**
 Creates and runs an `NSURLSessionDataTask` with a request to return a file.

 @param method the HTTP method
 @param urlString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param needToken needs authentication
 @param callback A block object to be executed when the task finishes . This block has no return value and takes 4 arguments:

         status of task : SUCCESS_OK , SUCCESS_FAIL, ERROR
         response object created by the client image serializer. Yhe image is in the response object under the key image.
 */

- (nullable NSURLSessionDataTask *) downloadImage:(nonnull NSString *)method
                                              url:(nonnull NSString *)urlString
                                       parameters:(nullable id)parameters
                                             auth:(BOOL) needToken
                                completionHandler:(TESApiCallback)callback;

/**
 Uploads the image as defined by the image parameter

 @param method the HTTP method
 @param urlString The URL string used to create the request URL.
 @param image the image to upload
 @param name the name of the image
 @param needToken needs authentication
 @param callback A block object to be executed when the task finishes . This block has no return value and takes 4 arguments:

         status of task : SUCCESS_OK , SUCCESS_FAIL, ERROR
         response object created by the client image serializer. Yhe image is in the response object under the key image.
 */

- (void)uploadImage:(nonnull NSString *)method
               path:(nonnull NSString *)urlString
          withImage:(nonnull UIImage *)image
           withName:(nonnull NSString *)name
               auth:(BOOL)needToken
  completionHandler: (TESApiCallback) callback;

/**
 Creates and runs an `NSURLSessionDownloadTask` with a request.
 
 @param method the HTTP method
 @param URLString The URL string used to create the request URL.
 @param parameters The parameters to be encoded according to the client request serializer.
 @param needToken needs authentication
 @param callback A block object to be executed when the task finishes . This block has no return value and takes 4 arguments:

     status of task : SUCCESS_OK , SUCCESS_FAIL, ERROR
     response object created by the client response serializer.

 NOTE: the result is a dictionary with a the following structure :

 {
    success:  true/false
    msg:      error message if success is false
    data:     result for the call
    code:     [optional] the error code if success is false.
 }

 there may be other properties reuturned depending on the call
 */

- (nullable NSURLSessionDownloadTask *)downloadFile:(nonnull NSString *)method
                                    url:(nonnull NSString *)URLString
                             parameters:(nullable id)parameters
                                   auth:(BOOL) needToken
                      completionHandler:(TESApiCallback) callback;


/**
 * Decode api call result
 *
 * figures out what the response is and fills the result and status accordingly.
 * also returns a more fine grained result type.
 *
 * this call will also call the authorizeFail delete if the reponse is 401 or 403
 * @param response the reponse object returned from the call
 * @param responseObject the response obhect from the call
 * @param error any error
 * @param result reference
 * @param status reference
 *
 */
- (TESResultType) decodeResult: (nonnull NSHTTPURLResponse *) response
            withResponseObject: (nonnull id) responseObject
                      andError: (nullable NSError *) error
                  outputResult: (NSDictionary * _Nonnull * _Nonnull) result
                  outputStatus: (nonnull TESCallStatus *) status;

/**
 * Expiration handler for call when made in background
 *
 * @param handler expiration handler
 *
 * Port from AFNetworking 2.0
 */
- (void)setShouldExecuteAsBackgroundTask: (nullable NSURLSessionDataTask *) downloadTask
                   WithExpirationHandler:(nullable void (^)(void)) handler;

/**
 Check for authorization failure by interpreting the NSError returned
 
 @param error - the error object retunred
 **/

- (BOOL) isAuthFailure: (NSError * _Nonnull) error;

/**
 Check for general server errors - 400+
 **/

-(BOOL) isServerError: (NSError * _Nonnull) error;

/**
 check for connectivity errors
 **/
-(BOOL) isNetworkError: (NSError * _Nonnull) error;

///-----------------------
/// @name utility methods
///----------------------

@end


#endif /* TESApi_h */
