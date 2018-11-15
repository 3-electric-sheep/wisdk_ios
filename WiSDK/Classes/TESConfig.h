//
//  TESConfig.h
//  WISDKdemo
//
//  Created by Phillp Frantz on 21/07/2017.
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

#ifndef TESConfig_h
#define TESConfig_h

#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocation.h>
#import <CoreLocation/CLAvailability.h>


#define ENV_PROD @"prod"
#define ENV_TEST @"test"

#define PROD_SERVER @"https://api.3-electric-sheep.com"
#define TEST_SERVER @"https://testapi.3-electric-sheep.com"

#define PROD_PUSH_PROFILE @"<PROD_PROFILE>"
#define TEST_PUSH_PROFILE @"<TEST_PROFILE>"

#define WALLET_OFFER_CLASS @"wioffers_pass"
#define WALLET_PROFILE @"email"

#define MEM_CACHE_SIZE 8388608  //8 * 1024 * 1024;
#define DISK_CACHE_SIZE 20971520 // 20 * 1024 * 1024;

#define GEOFENCE_RADIUS  50; //50 mtrs

#define DEVICE_TYPE_APN  @"apn"
#define DEVICE_TYPE_MAIL  @"mail"
#define DEVICE_TYPE_SMS  @"sms"
#define DEVICE_TYPE_WALLET  @"pkpass"
#define DEVICE_TYPE_MULTIPLE @"multiple"
#define DEVICE_TYPE_PASSIVE @"passive"


extern NSString * const TES_ENV_TEST;
extern NSString * const TES_ENV_PROD;
/**
 * @class TESConfig TESConfig.h "WiSDK/TESonfig.h"
 Configuration options for the WiApp object
 */
@interface TESConfig : NSObject

/**
 @typedef
 supported push mechanisms. Not SMS requires the purchase of an SMS gateway with additional charges
 */
typedef NS_OPTIONS(NSUInteger, DevicePushTargets
){
    deviceTypeNone = 0,
    deviceTypeAPN = 1 << 0,
    deviceTypeWallet = 1 << 1,
    deviceTypeMail = 1 << 2,
    deviceTypeSms = 1 << 3,
    deviceTypePassive = 1 << 4
};

/**
 * @property environment
 * environment test or prod  default is prod
 */
@property (strong, nonatomic, nullable) NSString * environment;

/**
 * @property providerKey
 * provider key as supplied by 3es
 */
@property (strong, nonatomic, nullable) NSString * providerKey;
@property (strong, nonatomic, nullable) NSString * testProviderKey;

/**
 * @property memCacheSize
 * size of mem cache
 */
@property (nonatomic) NSUInteger memCacheSize;

/**
 * @property diskCacheSize
 * size fo disk cache
 */
@property (nonatomic) NSUInteger diskCacheSize;

/**
 * @property server
 * production server endpoint
 */
@property (nonatomic, strong, nullable) NSString * server;

/**
 * @property pushProfile
 * production push profile
 */
@property (nonatomic, strong, nullable) NSString * pushProfile;

/**
 * @property testServer
 * terst server endpoint
 */

@property (nonatomic, strong, nullable) NSString * testServer;

/**
 * @property testPushProfile
 * test push profile
 */
@property (nonatomic, strong, nullable) NSString * testPushProfile;

/**
 * @property walletOfferClass
 * wallet offer class
 */

@property (nonatomic, strong, nullable) NSString * walletOfferClass;

/**
 * @property requireBackgroundLocation
 * require background location (default=true)
 */
@property (nonatomic) BOOL requireBackgroundLocation;
/**
 * @property useSignficantLocation
 * use significant location monitoring in background (default=true)
 */
@property (nonatomic) BOOL useSignficantLocation;

/**
 * @property useVisitMonitoring
 * use visit monitoring (default=false) **experimental**
 */
@property (nonatomic) BOOL useVisitMonitoring;

/**
 * @property useForegroundMonitoring
 * use  location monitoring in foreground (default=true)
 */
@property (nonatomic) BOOL useForegroundMonitoring;

/**
 * @property distacneFilter
 * distance to invoke a location update (default 500m)
 */
@property (nonatomic) CLLocationDistance distacneFilter; // in meters

/**
 * @property accuracy
 * accuracy of location fixes (default - kCLLocationAccuracyHundredMeters 100 m)
 */
@property (nonatomic) CLLocationAccuracy accuracy;

/**
 * @property activityType
 * activity type to log with location manager (default CLActivityTypeOther)
 */
@property (nonatomic) CLActivityType activityType;

/**
 * @property staleLocationThreshold
 * deterines when a location is stale  (default 300 sec)
 */
@property (nonatomic) NSInteger staleLocationThreshold; // in seconds

/**
 * @property logLocInfo
 * debug loc info - writes logs in local storage (default false)
 */
@property (nonatomic) BOOL logLocInfo; // whether to log debugging info

/**
 * @property nativeRequestAuth
 * not used.
 */
@property (nonatomic) BOOL nativeRequestAuth;

/**
 * @property authAutoAuthenticate
 * do automatic authentication if set. uses auth credentials to fill the register/login call
 * if credentials has the field  anonymous_user set ot YES  or
 * left as null, then an anonymous register/login is made
 */
@property (nonatomic) BOOL authAutoAuthenticate;

/**
 * @property authCredentials
 * Credentials dictionary supports:-
 *
 * either:-
 *
 * 'anonymous_user' : true/false
 *
 * or:-
 *
 *  'user_name': string,
 *  'password': string,
 *  'auth_type': 'native'
 *  'email': string
 *  'first_name': string
 *  'last_name':string
 *
 * You can also specify
 *
 * 'external_id': string
 * 'attributes': { key: value..}
 *
 */
@property (nonatomic, strong, nullable) NSDictionary * authCredentials;

/**
 * @property deviceTypes
 * list of device types wanted by a user apn, pkpass, mail, sms,
 */
@property (nonatomic) DevicePushTargets deviceTypes;

/**
 * @property debug
 * debug mode
 */
@property (nonatomic) BOOL debug;

/*
 * internal usage
 */

@property (nonatomic, strong, nullable) NSURLSessionConfiguration * sessionConfig;

@property (nonatomic, strong, readonly, nonnull) NSString * envServer;
@property (nonatomic, strong, readonly, nullable) NSString * envPushProfile;
@property (nonatomic, strong, readonly, nullable) NSString * getEnvProvider;

/**
 * @property useGeoFences
 * uses dynamic geofences for higher accuracy
 */
@property (nonatomic) BOOL useGeoFences;

/**
 * @property geoRadius
 * Geofence radius in meters
 */
@property (nonatomic) double geoRadius;

/**
 * @ singleLocationFix
 * Only get a single location fix in foreground then stop foreground location monitoring (default NO)
 */

@property (nonatomic) BOOL singleLocationFix;

/**
 * Initialises a config object with defaults
 * @param providerKey the provider api key
 * @param testProviderKey the test api key
 * @returns  a config object
 */
- (nullable instancetype) initWithProviderKey: (nullable NSString *) providerKey andTestProvider: (nullable NSString *) testProviderKey NS_DESIGNATED_INITIALIZER;

/**
 * creates a config object from a dictionay
 * @param dict key value pairs that correspond to the properties
 */
- (void) fromDictionary: (nonnull NSDictionary *) dict;
@end
#endif /* TESConfig_h */
