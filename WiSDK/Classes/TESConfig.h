//
//  TESConfig.h
//  WISDKdemo
//
//  Created by Phillp Frantz on 21/07/2017.
//  Copyright © 2017 3 Electric Sheep Pty Ltd. All rights reserved.
//

#ifndef TESConfig_h
#define TESConfig_h

#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocation.h>
#import <CoreLocation/CLAvailability.h>

@interface TESConfig : NSObject

#define ENV_PROD @"prod"
#define ENV_TEST @"test"

#define PROD_SERVER @"https://api.3-electric-sheep.com"
#define PROD_PUSH_PROFILE @"snapitup_prod"

#define TEST_SERVER @"http://test.3-electric-sheep.com"
#define TEST_PUSH_PROFILE @"snapitup_dev"

#define WALLET_OFFER_CLASS @"wi_offer_pass"
#define WALLET_PROFILE @"email"

#define MEM_CACHE_SIZE 8388608  //8 * 1024 * 1024;
#define DISK_CACHE_SIZE 20971520 // 20 * 1024 * 1024;

#define GEOFENCE_RADIUS  50; //50 mtrs

#define DEVICE_TYPE_APN  @"apn"
#define DEVICE_TYPE_MAIL  @"mail"
#define DEVICE_TYPE_SMS  @"sms"
#define DEVICE_TYPE_WALLET  @"pkpass"
#define DEVICE_TYPE_MULTIPLE @"multiple"


typedef NS_OPTIONS(NSUInteger, DevicePushTargets
){
    deviceTypeNone = 0,
    deviceTypeAPN = 1 << 0,
    deviceTypeWallet = 1 << 1,
    deviceTypeMail = 1 << 2,
    deviceTypeSms = 1 << 3
};

/**
 Configuration options for the WiApp object
 */

@property (strong, nonatomic, nullable) NSString * environment;
@property (strong, nonatomic, nullable) NSString * providerKey;

@property (nonatomic) NSUInteger memCacheSize;
@property (nonatomic) NSUInteger diskCacheSize;

@property (nonatomic, strong, nullable) NSString * server;
@property (nonatomic, strong, nullable) NSString * pushProfile;

@property (nonatomic, strong, nullable) NSString * testServer;
@property (nonatomic, strong, nullable) NSString * testPushProfile;

@property (nonatomic, strong, nullable) NSString * walletOfferClass;

@property (nonatomic) BOOL requireBackgroundLocation;

@property (nonatomic) BOOL useSignficantLocation;
@property (nonatomic) BOOL useVisitMonitoring;
@property (nonatomic) BOOL useForegroundMonitoring;

@property (nonatomic) CLLocationDistance distacneFilter; // in meters
@property (nonatomic) CLLocationAccuracy accuracy;
@property (nonatomic) CLActivityType activityType;

@property (nonatomic) NSInteger staleLocationThreshold; // in seconds

@property (nonatomic) BOOL logLocInfo; // whether to log debugging info
@property (nonatomic) BOOL nativeRequestAuth;

/**
 * do automatic authentication if set. uses auth credentials to fill the register/login call
 * if credentials has the field  anonymous_user set ot YES  or
 * left as null, then an anonymous register/login is made
 */
@property (nonatomic) BOOL authAutoAuthenticate;
@property (nonatomic, strong, nullable) NSDictionary * authCredentials;

/**
 * list of device types wanted by a user apn, pkpass, mail, sms,
 */
@property (nonatomic) DevicePushTargets deviceTypes;


@property (nonatomic) BOOL debug;

@property (nonatomic, strong, nullable) NSURLSessionConfiguration * sessionConfig;

@property (nonatomic, strong, readonly, nonnull) NSString * envServer;
@property (nonatomic, strong, readonly, nullable) NSString * envPushProfile;

@property (nonatomic) BOOL useGeoFences;
@property (nonatomic) double geoRadius;

- (nullable instancetype) initWithProviderKey: (nullable NSString *) providerKey NS_DESIGNATED_INITIALIZER;
- (void) fromDictionary: (nonnull NSDictionary *) dict;
@end
#endif /* TESConfig_h */
