//
//  TESWIApp.h
//  WISDKdemo
//
//  Created by Phillp Frantz on 18/07/2017.
//  Copyright © 2012-2017 3 Electric Sheep Pty Ltd. All rights reserved.
//

#ifndef TESWIApp_h
#define TESWIApp_h

/**
 
 TESWIApp
     |
     +----  LocationMgr
     |
     +----  PushMgr
     |
     +----  Api
     |
     +----  WalletMgr
 
 Flow 
 1.  login / register (anonymous or full)
 2.  get location fix
 3.  create/update device (multi device - wallet, push, other ?)
 4.  as location changes update device
 5. register and listen for push (optional)
 6. register and listen for wallet updates
 
 SUpport :-
 1. updating profile
 2. list live events at location
 3. all live events for provider/location
 4. update events to ack / enacted
 5. broad search for events
 
 */

#import <Foundation/Foundation.h>

#import "TESConfig.h"
#import "TESApi.h"
#import "TESLocationMgr.h"
#import "TESPushMgr.h"
#import "TESWalletMgr.h"

#import "LocationInfo.h"
#import "PushInfo.h"
#import "Device.h"
#import "LiveEvent.h"
#import "SearchEvent.h"
#import "Provider.h"
#import "Poi.h"
#import "Review.h"
#import "User.h"

#define ACCESS_TOKEN_KEY @"accessToken"
#define ACCESS_AUTH_TYPE @"accessAuthType"
#define ACCESS_USER_NAME @"accessUserName"

#define ACCESS_SYSTEM_DEFAULTS @"accessSystemDefaults"
#define ACCESS_USER_SETTINGS @"accessUserSettings"

#define DEVICE_TOKEN_KEY @"deviceToken"
#define PUSH_TOKEN_KEY @"pushToken"

#define LOCALE_TOKEN_KEY @"localeToken"
#define TIMEZONE_TOKEN_KEY @"localeTimezoneToken"

#define LAST_LAUNCHED_VERSION_TOKEN_KEY @"lastLaunchedVersion" // version | devel/staging/prod

#define SEARCH_DISTANCE_KEY @"searchDistance" // numeric
#define SEARCH_CURRENT_LOC_KEY @"searchCurrentLocation"  // YES:NO
#define SEARCH_LOCATION_LAT_KEY @"searchLocationLat" // latitude
#define SEARCH_LOCATION_LONG_KEY @"searchLocationLng" // longitude
#define SEARCH_LOCATION_TEXT_KEY @"searchLocationText" // location description


#define ALL_SELLER_PLACES @"ALL"

#define EXCLUDE_ALL_CATEGORIES @"*"


typedef void (^errorBlockType)();

//----------------------------------------------
// TESWIAppDelegate protocol
//----------------------------------------------
@protocol TESWIAppDelegate <NSObject>

/**
 sent when authorization has failed (401)
 */
- (void) authorizeFailure: (NSInteger) httpStatus;

@optional

/**
 * sent when authorization is complete
*/
- (void) onAutoAuthenticate:(TESCallStatus)status withResponse: (nonnull NSDictionary *) responseObeject;

/**
 * sent when a new access token is returned
 */
- (void) newAccessToken: (nullable NSString *) token;

/**
 sent when a new device token has been created
 */
- (void) newDeviceToken: (nullable NSString *) token;

/**
 * sent when a new push token is returned
 */
- (void) newPushToken: (nullable NSString *) token;

/**
 * Called when a remmote notification needs to be processed
 */
- (void) processRemoteNotification: (nullable NSDictionary *) userDictionary;

/**
 * Called when remote notifications is registered or fails to register
 *
 */
-(void) onRemoteNoficiationRegister:(TESCallStatus)status withResponse: (nonnull NSDictionary *) responseObeject;

@end

//----------------------------------------------
// TESWIApp interface
//----------------------------------------------

/***
 * TESWiApp main interface
 */
@interface TESWIApp : NSObject <TESLocationMgrDelegate, TESApiDelegate>

/***
 *
 */
@property (nullable) id <TESWIAppDelegate> delegate;


/**
 environment details

 used to specify:-
 
 server
 testserver
 push profile
 test push profile
 cache size
 */
@property (nonatomic, strong, nullable) TESConfig * config;

/**
 API manager for dealing with all REST based api calls
 **/
@property (nonatomic, strong, nullable) TESApi * api;

/**
 Location manager for dealing with location monitoring
 **/
@property (nonatomic, strong, nullable) TESLocationMgr * locMgr;

/**
 Push manager for dealing with push notification
 **/

@property (nonatomic, strong, nullable) TESPushMgr * pushMgr;

/**
 Wallet mamager for dealing with wallet based events
 **/
@property (nonatomic, strong, nullable) TESWalletMgr * walletMgr;

/**
 * username associated with current api access token
 */

@property (nonatomic, strong, nullable) NSString * authUserName;

/**
 device Token associated with this device
 **/
@property (nonatomic, strong, nullable) NSString *deviceToken;

/**
 APN push token associated with this device
 **/
@property (nonatomic, strong, nullable) NSString *pushToken;

/**
 provider token - all users and secure items will be tied to this provider
 */

@property (nonatomic, strong, nullable) NSString * providerToken;


/**
 currently saved locale info
 */

@property (nonatomic, strong, nullable) NSString *localeToken;

/**
 currently saved token info
 */

@property (nonatomic, strong, nullable) NSString * timezoneToken;

/**
 currently saved last run version info
 **/
@property (nonatomic, strong, nullable) NSString * versionToken;

/**
 * Last registered location
 *
 */
 @property (nonatomic, strong, nullable) LocationInfo * lastLoc;

/**
 One off error handler.
 
 IMPORTANT: if set this will be automatically reset in a notify error block but it is your responsibility
 to reset it in the completion block.  (ie. do the following:-
 
 store.errorBlock = ^{blah blah};
 store.do_func: ^ {
 completion code
 store.errorBlock = nil;
 }
 
 not doing this could lead to wierd errors
 */
@property (strong, nonatomic, nullable) errorBlockType errorBlock;

/**
 * set while registering or login
 */
@property(nonatomic) BOOL isAuthenticating;

/**
 Creates and returns an `TESWIApp` object.
 */

- (nullable instancetype) init NS_DESIGNATED_INITIALIZER;


//----------------------------------------------
// Core methods
//--------------------------------------------
/**
 shared client is a singleton used to make all store related callses
 */


+ (nonnull TESWIApp *)manager;

/**
 Start the framework. This initialises location services, boots up the push manager and authenticates with the wi server
 
 
 **/

- (BOOL)start:(nonnull TESConfig *)config withLaunchOptions:(nullable NSDictionary *)launchOptions;


/**
 returns whether the user has a valid device token
 */

- (BOOL) hasDeviceToken;

/**
 returns whether the user has a valid push token
 */
- (BOOL) hasPushToken;


/**
 * are we authorized
 */
- (BOOL) isAuthorized;

/**
 * Clears the set of auth tokens
 */
- (void) clearAuth;

/**
 * register services
 *  NOTE: only needed if you turn on apn or wallet or other device type after calling start
 */

- (void)reRegisterServices;


// --------------------------
// remote push nothification
//----------------------------

- (void) registerRemoteNotificationToken: (nonnull NSData * )deviceToken;
- (void) didFailToRegisterForRemoteNotificationsWithError: (nullable NSError *) error;

- (void) processRemoteNotification: (nullable NSDictionary*)userInfo;

//-----------------------
// WIApp API calls
//-----------------------

/**
 * Authenticate a session
 * @param inputParams params to pass to register/login
 * @param completionBlock call on function result
 */
-(void) authenticate: (nullable NSDictionary *) inputParams completion:(TESApiCallback) completionBlock;

/**
 * register a user

 To create an anonymous user pass in anonymous_user=true

 @param params Parameters to the list live events call
 @param completionBlock the code block to call on successful completion
 */

-(void) registerUser:(nullable NSDictionary *) params  completion:(TESApiCallback) completionBlock;


/**
 login a user
 
 @param params Parameters to the list live events call
 @param completionBlock the code block to call on successful completion
 **/

-(void) loginUser:(nullable NSDictionary *) params  completion:(TESApiCallback) completionBlock;


/**
 account profile for user
 
 must be registered or logged in
 
 **/

-(void) getAccountProfile: (TESApiCallback) completionBlock;

/**
 update account profile for user
 
 must be registered or logged in
 
 @param completionBlock the code block to call on successful completion
 **/

-(void) updateAccountProfile: (nullable NSDictionary *)params onCompletion:(TESApiCallback) completionBlock;


/**
 update account profile password for user
 
 only if user is not anonymous
 
 @param password - the new password
 @param oldPassword - the old password
 @param completionBlock the code block to call on successful completion
 **/

-(void) updateAccountProfilePassword: (nonnull NSString *) password oldPassword: (nonnull NSString *) oldPassword onCompletion:(TESApiCallback) completionBlock;

/**
 update account profile setting for user
 
 @param params - settings to change can be  exclusions, following, watch_zones, notifications, allow_notifications
 @param completionBlock the code block to call on successful completion
 **/;
-(void) updateAccountSettings:(nullable NSDictionary *)params onCompletion:(TESApiCallback) completionBlock;

/**
 upload an image for a user profile
 
 @param image the image to upload
 @param completionBlock the completion block to execute on completion, returns the new image id from the server
 **/

-(void)uploadImageForProfile: (nonnull UIImage *) image
                  completion:(TESApiCallback) completionBlock;

/**
 reads an image into a user object
 
 @param completionBlock the completion block to execute on completion, returns the new image id from the server
 **/

-(void) readProfileImage: (TESApiCallback) completionBlock;

/**
 Sends a point to the server. Automatically deals with new or existing devices
 
 @param locInfo the location info to update
 @param background are we running in background atm.
 
 */

- (void) sendDeviceUpdate:(nonnull NSArray *)locInfo inBackground: (BOOL) background;
- (void) sendRegionUpdate: (nonnull CLRegion *) region withLocation:(nonnull LocationInfo *) locInfo inBackground: (BOOL) background;
- (void) sendChangeAuthorizationStatus:(CLAuthorizationStatus)status;

- (void) sendError:(nullable NSError *)error withMsg:(nullable NSString *)msg inGeo:(BOOL)geoError;

/**
 List all live events for a device token
 
 @param params Parameters to the list live events call
 @param completionBlock the code block to call on successful completion
 **/

-(void) listLiveEvents: (nullable NSDictionary *)params
          onCompletion:(TESApiCallback) completionBlock;

/**
 List all search events for a location and distance
 
 @param params Parameters to the list search events call -
 distance = distance to search
 units = metric/imperial
 num = number of results to return , 0 for all
 @param completionBlock the code block to call on successful completion
 **/

-(void) listSearchEvents: (nullable NSDictionary *)params
            withlocation: (CLLocationCoordinate2D) location
            onCompletion:(TESApiCallback) completionBlock;


/**
 List all acknowledged live events
 
 @param params Parameters to the list live events call
 @param completionBlock the code block to call on successful completion
 **/

-(void) listAcknowledgedLiveEvents: (nullable NSDictionary *)params
                      onCompletion:(TESApiCallback) completionBlock;

/**
 List all followed live events
 
 @param params Parameters to the list live events call
 @param completionBlock the code block to call on successful completion
 **/
-(void) listFollowedLiveEvents: (nullable NSDictionary *)params
                  onCompletion:(TESApiCallback) completionBlock;

/**
 
 update the event acknoledge flag for an event
 
 @param eventId Event to ack/non-ack
 @param ack either YES or NO to ack or not ack
 @param completionBlock the code block to call on successful completion.
 
 **/

-(void) updateEventAck: (nonnull NSString *) eventId isAck: (BOOL) ack onCompletion:(TESApiCallback) completionBlock;


/**
 
 update the event enacted flag for an event
 
 @param eventId Event to enact=
 @param enacted YES or NO to enact or not
 @param completionBlock the code block to call on successful completion.
 
 **/

-(void) updateEventEnacted: (nonnull NSString *) eventId isEnacted: (BOOL) enacted onCompletion:(TESApiCallback) completionBlock;



/**
 
 Get current provider linked to this app

 @param completionBlock the code block to call on successful completion.

 */

-(void) getProvider:(TESApiCallback) completionBlock;

/**
 List all pois for a provider
 
 @param params Extra params to send to the call
 @param completionBlock the code block to call on successful completion.
 
 **/
-(void) listPlacesOfInterestForProvider: (nullable NSDictionary *)params onCompletion:(TESApiCallback) completionBlock;

/**
 List all live events created by a provider

 @param params Extra params to send to the call
 @param completionBlock the code block to call on successful completion.

 **/
-(void) listLiveEventsForProvider: (nullable NSDictionary *)params onCompletion: (TESApiCallback) completionBlock;

/**
 List all historic events for a rrovider

 @param params Extra params to send to the call
 @param completionBlock the code block to call on successful completion.

 **/
-(void) listEventsForProvider: (nullable NSDictionary *)params onCompletion: (TESApiCallback) completionBlock;

/**
 List all reviews for a place

 @param params Extra params to send to the call
 @param completionBlock the code block to call on successful completion.

 **/
-(void) listReviewsForPlace:(nonnull NSString *) poiId withParams: (nullable NSDictionary *)params onCompletion: (TESApiCallback) completionBlock;


/**
 
 create a review for a place
 @param poiId Place to list reviews for
 @param params Extra params to send to the call
 @param completionBlock the code block to call on successful completion.
 
 **/

-(void) createReviewForPlace:(nonnull NSString *) poiId withParams: (nullable NSDictionary *)params onCompletion:(TESApiCallback) completionBlock;

/**
 update an existing review
 
 @param reviewId to update
 @param params all the poi parameters
 @param completionBlock the completion block to execute on completion, returns and updated poi dictionary from the server
 **/
-(void) updateReview: (nonnull NSString *) reviewId withParams:(nullable NSDictionary *)params onCompletion:(TESApiCallback) completionBlock;

/**
 delete an existing review
 
 @param reviewId to delete
 @param completionBlock the completion block to execute on completion, returns and updated poi dictionary from the server
 **/
-(void) deleteReview: (nonnull NSString *) reviewId onCompletion:(TESApiCallback) completionBlock;


/**
 reads an image into a poi object
 
 @param imageId - the poi object to read to
 @param completionBlock - completion block to call on success
 **/
-(void)readPoiImage: (nonnull NSString *)imageId completion:(TESApiCallback) completionBlock;

/**
 reads an image into an event object
 
 @param imageId - the poi object to read to
 @param completionBlock - completion block to call on success
 **/
-(void)readEventImage: (nonnull NSString *)imageId completion:(TESApiCallback) completionBlock;


//------------------------------------------------------
// reads/updates/clears token to the user defaults store
//------------------------------------------------------

- (void) initTokens;
- (void) setLocaleAndVersionInfo;

- (nullable id) getToken: (nonnull NSString *)token;
- (nullable NSString *) getToken: (nonnull NSString *)token withDefault: (nullable NSString *) defaultValue;

- (void) setToken: (nonnull id) value forKey: (nonnull NSString *)token;
- (void) clearToken: (nonnull NSString *) token;

//--------------------------------------------------------------
// helpers to make it easier to get/set a particular user setting
//---------------------------------------------------------------

- (nullable id) getUserSetting: (nonnull NSString *) key mutable:(BOOL) make_mutable;
- (void) setUserSetting: (nonnull id) object withKey: (nonnull NSString *) key;

// excludes support

- (nullable NSDictionary *) getExclusions;

- (void) excludeEventType: (nonnull NSString *) exc_type andCategory: (nullable NSString *) exc_cat withCompletion:(TESApiCallback) completionBlock;
- (void) includeEventType: (nonnull NSString *) evt_type andCategory: (nullable NSString *) evt_cat withCompletion:(TESApiCallback) completionBlock;

// notify support
- (void) allowNotifyEventType: (nonnull NSString *) evt_type andCategory: (nullable NSString *) evt_cat withCompletion:(TESApiCallback) completionBlock;
- (void) disallowNotifyEventType: (nonnull NSString *) evt_type andCategory: (nullable NSString *) evt_cat withCompletion:(TESApiCallback) completionBlock;

- (BOOL) isAllowNotify: (nonnull NSString *) evt_type andCategory: (nullable NSString *) evt_cat;

// poi following support

- (BOOL) isFollowingPoi: (nonnull NSString *) rid;

- (void) addFollowPoi: (nonnull NSString *) rid  withCompletion:(TESApiCallback) completionBlock;
- (void) removeFollowPoi: (nonnull NSString *) rid withCompletion:(TESApiCallback) completionBlock;

- (void) updateSettings: (nonnull NSDictionary * ) params withCompletion:(TESApiCallback) completionBlock;

// watch zones
- (nullable NSArray *) getWatchZones;
- (nullable NSDictionary *) getWatchZoneNamed: (nonnull NSString *) name;

- (nullable NSDictionary *) findZone: (nonnull NSString *) name fromZones: (nullable NSArray *) watchZones;

// adds a watch zone. If the there is a watchzone with the same name NO is returned otherwise yes is returned.

- (BOOL) addWatchZoneNamed: (nonnull NSString *) name
              withDistance: (nonnull NSNumber *) distance
              fromLocation: (nonnull NSString *) location
               atLongitude: (CLLocationDegrees) longitude
               andLatitude: (CLLocationDegrees) latitude
               oldZoneInfo: (nullable NSDictionary *) oldZoneInfo
            withCompletion:(TESApiCallback) completionBlock;

- (void) removeWatchZonenamed: (nonnull NSString *) name  withCompletion:(TESApiCallback) completionBlock;


//-----------------------------------------------------
// converts a dictionary or array into an mutable object of
// the same type. Does a deep copy
// --------------------------------------------------------

+(nonnull id) recursiveToMutable:(nonnull id)object;

@end

#endif /* TESWIApp_h */
