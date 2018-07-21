//
//  TESWIApp.m
//  WISDKdemo
//
//  Created by Phillp Frantz on 22/07/2017.
//  Copyright © 2017 3 Electric Sheep Pty Ltd. All rights reserved.
//

#import "TESWIApp.h"
#import "NSData+HexString.h"
#import "TESMessagingProxy.h" //needed for swizzling

#define TES_PATH_REGISTER @"account"
#define TES_PATH_LOGIN @"auth/login"
#define TES_PATH_PROFILE @"account"

#define TES_PATH_GEODEVICE @"geodevice" // TODO: this should be plural

#define TES_PATH_LIVE_EVENTS @"geodevice/%@/live-events"
#define TES_PATH_LIVE_EVENTS_REVIEWS @"live-events/%@/reviews"
#define TES_PATH_LIVE_EVENTS_CREATE_REVIEW @"live-events/%@/reviews"
#define TES_PATH_EVENTS_REVIEWS @"events/%@/reviews"

#define TES_PATH_SEARCH_LIVE_EVENTS @"geopos/%f,%f/live-events"

#define TES_PATH_PROVIDERS @"providers"
#define TES_PATH_PROVIDER @"providers/%@"

#define TES_PATH_PROVIDER_CREATE_EVENT @"providers/%@/events"
#define TES_PATH_POI_CREATE_EVENT @"poi/%@/events"

#define TES_PATH_PROVIDER_LIVE_EVENTS @"providers/%@/live-events"
#define TES_PATH_PROVIDER_EVENTS @"providers/%@/events"

#define TES_PATH_LIVE_EVENTS_RUD @"live-events/%@"
#define TES_PATH_EVENTS_RUD @"events/%@"
#define TES_PATH_LIVE_EVENTS_ACK @"live-events/%@/ack"
#define TES_PATH_LIST_LIVE_EVENTS_ACK @"live-events/acknowledged"
#define TES_PATH_LIST_LIVE_EVENTS_FOLLOW @"live-events/following"

#define TES_PATH_LIVE_EVENTS_ENACTED  @"live-events/%@/enact"
#define TES_PATH_LIVE_EVENTS_SHARE @"live-events/%@/share"

#define TES_PATH_POI @"providers/%@/poi"
#define TES_PATH_PLACE_RUD @"poi/%@"

#define TES_PATH_PLACE_REVIEWS  @"poi/%@/reviews"
#define TES_PATH_PLACE_CREATE_REVIEW @"poi/%@/reviews"

#define TES_PATH_PROVIDER_RECEIPT @"providers/%@/receipts"

#define TES_PATH_REVIEW_RUD @"reviews/%@"

#define TES_PATH_PLACE_IMAGES @"poi/%@/images"
#define TES_PATH_ACCOUNT_PROFILE_IMAGES @"account/current/images"
#define TES_PATH_IMAGES_RUD @"/images/%@.%@"
#define TES_PATH_ANY_IMAGES_RUD @"/images/%@"

#define TES_PATH_GEOPOS_GEODEVICES  @"geopos/%f,%f/geodevices"

#define TES_PATH_PRODUCT_LIST @"products/itunes"

#define TES_PATH_ADDRESS_LOOKUP @"providers/address"

/**
 Error codes returned by the server
 **/
#define ERROR_NOT_FOUND  1
#define ERROR_ADD  2
#define ERROR_REMOVE  3
#define ERROR_UPDATE  4


@implementation TESWIApp {

@private
    BOOL newPushToken;
    BOOL newDeviceToken;
    BOOL newAccessToken;
    BOOL newAccessAuthType;
    BOOL newAccessUserName;
    BOOL newAccessSystemDefaults;
    BOOL newLocaleToken;
    BOOL newTimezoneToken;
    BOOL newVersionToken;

}

#pragma mark - wi application object

+ (nonnull TESWIApp *) manager
{
    static TESWIApp *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[TESWIApp alloc] init];
        
    });
    
    return _manager;
}

- (nullable instancetype) init
{
    self = [super init];
    if (self){
        [self setLocaleAndVersionInfo];
        [TESMessagingProxy swizzleMethods];
    }
    return self;
}

#pragma mark - visible routines

- (BOOL)start:(nonnull TESConfig *)config withLaunchOptions:(nullable NSDictionary *)launchOptions {
    self.config = config;
    
    // setup the managers
    self.locMgr = [[TESLocationMgr alloc] initWithConfig:self.config];
    if (self.locMgr == nil){
        NSLog(@"Failed to initialise Location manager");
        return NO;
    }
    self.locMgr.delegate = self;

    [self.locMgr startLocationManager:self.config.requireBackgroundLocation requestAuth:YES];

    self.pushMgr = [[TESPushMgr alloc] initWithProfile:self.config.envPushProfile];
    if (self.pushMgr == nil){
        NSLog(@"Failed to initialise push manager");
        return NO;
    }

    self.walletMgr = [[TESWalletMgr alloc] init];
    if (self.walletMgr == nil){
        NSLog(@"Failed to initialise wallet manager");
        return NO;
    }

    // setup our cache
    NSURLCache *URLCache = [[NSURLCache alloc] initWithMemoryCapacity:self.config.memCacheSize diskCapacity:self.config.diskCacheSize diskPath:nil];
    [NSURLCache setSharedURLCache:URLCache];

    // setup the API caller
    self.api = [[TESApi alloc] initWithUrl:self.config.envServer sessionConfiguration:self.config.sessionConfig];
    if (self.api == nil){
        NSLog(@"Failed to initialise API manager");
        return NO;
    }
    self.api.delegate = self;

    [self initTokens];
    [self setLocaleAndVersionInfo];
    NSLog(@"Environment: %@ Debug: %d Endpoint: %@", config.environment, config.debug, [self.api endpoint:@"/"]);

    // get our push token if we want to register APN devices
    [self reRegisterServices];

    // we self authenticate and pass on the result to any delgate implementing this routine.
    if (!self.isAuthorized && self.config.authAutoAuthenticate){
        [self authenticate:self.config.authCredentials completion:^(TESCallStatus status, NSDictionary * responseObject){
             if (self.delegate && [self.delegate respondsToSelector:@selector(onAutoAuthenticate:withResponse:)]){
                 [self.delegate onAutoAuthenticate:status withResponse:responseObject];
             }
        }];
    }

    // where we launched indirectly via a push notification or a location update
    if (launchOptions != nil){
        NSDictionary* dictionary = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
        if (dictionary != nil){
            NSLog(@"Launched from push notification: %@", dictionary);
            [self processRemoteNotification:dictionary];
        }

        if (launchOptions[UIApplicationLaunchOptionsLocationKey]){
            [self.locMgr writeDebugMsg:nil msg:@"App relaunched due ot location message"];
            if (self.isAuthorized)
                [self.locMgr ensureMonitoring];
        }
    }
    return YES;
}

- (void)reRegisterServices {
    if (self.config.deviceTypes & deviceTypeAPN)
        [self.pushMgr registerRemoteNotifications];
}


#pragma mark - Remote notifications

- (void)registerRemoteNotificationToken:(nonnull NSData *)deviceToken {

    NSString * hexDeviceToken = [deviceToken hexRepresentation];
    NSLog(@"Remote notification token: %@", hexDeviceToken);
    [self setToken:hexDeviceToken forKey:PUSH_TOKEN_KEY];

    // if we have a device token and we have a fix already, update the device with this push info
    if (self.deviceToken != nil && self.locMgr.lastLocation != nil){
        [self sendDeviceUpdate:@[self.locMgr.lastLocation] inBackground: NO];
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(onRemoteNoficiationRegister:withResponse:)]){
        [self.delegate onRemoteNoficiationRegister: TESCallSuccessOK withResponse:@{@"success":@YES, @"data":hexDeviceToken}];
    }
}

- (void)didFailToRegisterForRemoteNotificationsWithError:(nullable NSError *)error {
    NSLog(@"Failed to register remote notification: %@", error);
    if (self.delegate && [self.delegate respondsToSelector:@selector(onRemoteNoficiationRegister:withResponse:)]){
        [self.delegate onRemoteNoficiationRegister: TESCallError withResponse:@{@"success":@NO, @"msg":[error localizedDescription]}];
    }

}

- (void) processRemoteNotification: (nullable NSDictionary*) userInfo
{
    NSLog(@"Received notification: %@", userInfo);
    if (self.delegate && [self.delegate respondsToSelector:@selector(processRemoteNotification:)]){
        [self.delegate processRemoteNotification:userInfo];
    }

}

#pragma mark - API specific

- (BOOL) hasDeviceToken
{
    return self.deviceToken != nil;
}

- (BOOL) hasPushToken
{
    return self.pushToken != nil;
}

- (BOOL) isAuthorized
{
    return self.api.isAuthorized;
}

- (void) clearAuth
{
    [self clearToken:ACCESS_AUTH_TYPE];
    [self clearToken:ACCESS_USER_NAME];
    [self clearToken:ACCESS_TOKEN_KEY];
    [self clearToken:ACCESS_USER_SETTINGS];
}


- (NSString *)providerToken {
    return self.config.providerKey;
}

- (void)setProviderToken:(NSString *)providerToken {
    self.config.providerKey = providerToken;
}



#pragma mark - TESLocationMgrDelegate

- (void)sendDeviceUpdate: (nonnull NSArray *) locInfo inBackground:(BOOL)background {
    NSString * path = nil;

    LocationInfo * lastloc = nil;

    if (locInfo != nil && locInfo.count >0) {
        for (NSUInteger i=0; i<locInfo.count; i++) {
            lastloc = locInfo[i];

            Device *dev = [self _fillDeviceFromLocation:lastloc];
            NSDictionary *parameters = [dev toDictionary];

            TESApiCallback callback = ^void(TESCallStatus status, NSDictionary *_Nullable result) {
                switch (status) {
                    case TESCallSuccessOK: {
                        NSString *device_id = [result valueForKey:@"device_id"];
                        if (device_id != nil) {
                            [self setToken:device_id forKey:DEVICE_TOKEN_KEY];
                        }
                        break;
                    }
                    case TESCallSuccessFAIL: {
                        NSNumber *code = [result valueForKey:@"code"];
                        NSString *msg = [result valueForKey:@"msg"];
                        if (code != nil && [code intValue] == ERROR_NOT_FOUND) {
                            // looks like the device id has been nuked on the server. Just try again with a new device id
                            NSLog(@"Trying again with no device token");
                            [self clearToken:DEVICE_TOKEN_KEY];
                            [self sendDeviceUpdate:locInfo inBackground:background];

                        } else {
                            [self.locMgr writeDebugMsg:nil msg:[NSString stringWithFormat:@"Device token request failed with unknown code: %@", msg]];
                        }
                        break;
                    }
                    case TESCallError: {
                        NSString *msg = [result valueForKey:@"msg"];
                        [self.locMgr writeDebugMsg:nil msg:[NSString stringWithFormat:@"HTTP Request failed : %@", msg]];
                        break;
                    }
                    default:
                        [self.locMgr writeDebugMsg:nil msg:[NSString stringWithFormat:@"HTTP Request failed : unknown status %ld", (long) status]];
                }
            };

            NSURLSessionDataTask *task;
            if (self.deviceToken != nil) {
                path = [[NSString alloc] initWithFormat:@"%@/%@", TES_PATH_GEODEVICE, self.deviceToken];
                task = [self.api call:@"PUT" url:path parameters:parameters auth:YES completionHandler:callback];
            } else {
                path = TES_PATH_GEODEVICE;
                task = [self.api call:@"POST" url:path parameters:parameters auth:YES completionHandler:callback];
            }

            if (background) {
                __weak __typeof(&*self) weakSelf = self;
                [self.api setShouldExecuteAsBackgroundTask:task WithExpirationHandler:^{
                    __strong __typeof(&*weakSelf) strongSelf = weakSelf;
                    [strongSelf.locMgr writeDebugMsg:nil msg:[NSString stringWithFormat:@"HTTP Request background task terminated"]];
                }];
            }
        }
    }

    if (lastloc != nil) {
        [self clearGeofences];
        [self addGeofences: @[
           @{
                 @"latitude": lastloc.latitude,
                 @"longitude": lastloc.longitude,
                 @"radius": @(self.config.geoRadius),
                 @"identifier": [NSString stringWithFormat:@"gf_%@", [[NSUUID UUID] UUIDString]]
            }
        ]];
        self.lastLoc = lastloc;
    }
}

- (void)sendRegionUpdate:(nonnull CLRegion *)region withLocation:(nonnull LocationInfo *)locInfo inBackground:(BOOL)background {
    if (locInfo.didExit){
        locInfo.regionIdentifier = nil; // clear this so no geo region info is sent to the server
        [self sendDeviceUpdate:@[locInfo] inBackground:background];
    }
}

- (void)sendChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusAuthorizedAlways || status == kCLAuthorizationStatusAuthorizedWhenInUse){
        if (self.isAuthorized)
            [self.locMgr ensureMonitoring];
    }
    else {
        [self.locMgr ensureNotMonitoring];
    }
}

- (void) sendError:(nullable NSError *)error withMsg:(nullable NSString *)msg inGeo:(BOOL)geoError {
    NSInteger code = -1;
    NSString * errorMsg = @"";
    if (error != nil){
        code = [error code];
        errorMsg = [error localizedDescription];

    }
    NSString * debugMsg =  [NSString stringWithFormat:@"%@ %@ (Code=%ld)", msg, errorMsg, (long) code];
    [self.locMgr writeDebugMsg:nil msg:debugMsg];
}

#pragma mark - TESLocationMgrDelegate helpers
/**
 * Adds geofences. This method should be called after the user has granted the location
 * permission.
 */
- (BOOL) addGeofences: (NSArray *) geofencesToAdd
{
    for (NSDictionary * entry in geofencesToAdd) {
        double lat = [[entry valueForKey:@"latitude"] doubleValue];
        double lng = [[entry valueForKey:@"longitude"] doubleValue];
        NSNumber * radiusObj =  [entry valueForKey:@"radius"];
        double radius = (radiusObj != nil) ? [radiusObj doubleValue]: -1;
        NSString * ident =[entry valueForKey:@"identifier"];

        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lng);
        if (![self.locMgr addRegion:coord andRadius:radius andIdentifier:ident]) {
            NSString * msg = [self getError];
            [self.locMgr writeDebugMsg:nil msg:[NSString stringWithFormat:@"AddGeofenceFailed %@", msg]];
            return NO;
        }
    }
    return YES;
}

/**
 * Removes geofences by id. This method should be called after the user has granted the location
 * permission.
 */
- (BOOL) removeGeofences:(NSArray<NSString *> *) ids
{
    for(NSString * ident in ids) {
        if (![self.locMgr removeRegion:ident]) {
            NSString * msg = [self getError];
            [self.locMgr writeDebugMsg:nil msg:[NSString stringWithFormat:@"RemoveGeofenceFailed %@", msg]];
            return NO;
        }
    }
    return YES;
}

/**
 * Removes all geofences. This method should be called after the user has granted the location
 * permission.
 */
- (void)clearGeofences
{
    [self.locMgr clearRegions];
}

-(NSString *) getError {
    if (self.locMgr == nil)
        return @"Location manager has not been initialised";

    NSString *err = [self.locMgr getErrorMsg];
    [self.locMgr clearErrorMsg];
    return err;
}

#pragma mark - TESWIAppDelegate

- (void)httpAuthFailure: (nullable NSHTTPURLResponse *) response
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(authorizeFailure:)]){
        [self.delegate authorizeFailure:response.statusCode];
    }
}

#pragma mark - user and device calls

-(void) registerUser:(nullable NSDictionary *) params  completion:(TESApiCallback) completionBlock {

    if (self.isAuthenticating){
        if (completionBlock){
            completionBlock(TESCallError, @{@"success":@NO, @"msg":@"Already in authenticate call"});
        }
        return;
    }

    self.isAuthenticating = TRUE;
    [self.api call:@"POST" url:TES_PATH_REGISTER parameters:params auth:NO completionHandler:^(TESCallStatus status, NSDictionary *_Nullable result) {
        self.isAuthenticating = FALSE;
        if (status == TESCallSuccessOK) {
            NSDictionary *data = [result valueForKey:@"data"];

            NSString *token_id = [data valueForKey:@"token"];
            NSString *auth_type = [data valueForKey:@"auth_type"];
            NSString *user_name = [data valueForKey:@"user_name"];

            if (token_id != nil) {
                [self setToken:token_id forKey:ACCESS_TOKEN_KEY];
                [self setToken:auth_type forKey:ACCESS_AUTH_TYPE];
                [self setToken:user_name forKey:ACCESS_USER_NAME];
            }
        }
        if (completionBlock) {
            completionBlock(status, result);
        }
    }];
}

- (void)loginUser:(nullable NSDictionary *)params completion:(TESApiCallback)completionBlock {

    if (self.isAuthenticating){
        if (completionBlock){
            completionBlock(TESCallError, @{@"success":@NO, @"msg":@"Already in authenticate call"});
        }
        return;
    }

    self.isAuthenticating = TRUE;
    [self.api call:@"POST" url:TES_PATH_LOGIN parameters:params auth:NO completionHandler:^(TESCallStatus status, NSDictionary *_Nullable result) {
        self.isAuthenticating = FALSE;
        if (status == TESCallSuccessOK) {
            NSDictionary *data = [result valueForKey:@"data"];

            NSString *token_id = [data valueForKey:@"token"];
            NSString *auth_type = [data valueForKey:@"auth_type"];
            NSString *user_name = [data valueForKey:@"user_name"];

            if (token_id != nil) {
                if (self.api.accessToken )
                [self setToken:token_id forKey:ACCESS_TOKEN_KEY];
                [self setToken:auth_type forKey:ACCESS_AUTH_TYPE];
                [self setToken:user_name forKey:ACCESS_USER_NAME];
            }
        }
        if (completionBlock) {
            completionBlock(status, result);
        }
    }];
}

-(void) authenticate: (nullable NSDictionary *) inputParams completion:(TESApiCallback) completionBlock
{
    if (self.isAuthenticating)
        return; // already doing an authenticate
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithDictionary:inputParams];

    BOOL haveUser = FALSE;
    if (params == nil){
        if (self.authUserName != nil && [self.api.accessAuthType isEqualToString: TES_AUTH_TYPE_ANONYMOUS ] ){
            params = [NSMutableDictionary dictionaryWithDictionary: @{
                @"user_name": self.authUserName
            }];
        }
        else {
            params = [NSMutableDictionary dictionaryWithDictionary:  @{
               @"anonymous_user": @YES,
            }];
        }

    }

    if (params[@"user_name"] != nil){
        haveUser = TRUE;
    }
    
    if (params[@"provider_id"] == nil){
        params[@"provider_id"] = self.config.providerKey;
    }

     if (haveUser){
        [self loginUser:params completion:^(TESCallStatus status,  NSDictionary * _Nullable responseObject) {
            NSLog(@"login: %ld : %@", (long) status, responseObject);
            if (status == TESCallSuccessOK){
                [self _finishAuth:responseObject];
            }
            else {
                [self clearAuth];
            }
            if (completionBlock)
                completionBlock(status, responseObject);
        }];
    }
    else {
        [self registerUser:params completion:^(TESCallStatus status, NSDictionary * _Nullable responseObject){
            NSLog(@"Registered: %ld : %@", (long) status, responseObject);
            if (status == TESCallSuccessOK){
                [self _finishAuth:responseObject];
            }
            if (completionBlock)
                completionBlock(status, responseObject);
        }];
    }
}

- (void)_finishAuth: (nullable NSDictionary *) responseObject
{
    if (self.deviceToken == nil){
        Device * dev = [self _fillDeviceFromLocation:nil];
        NSDictionary * parameters = [dev toDictionary];

        [self.api call:@"POST" url:TES_PATH_GEODEVICE parameters:parameters auth:YES completionHandler: ^ void (TESCallStatus  status, NSDictionary * _Nullable result){
            switch (status) {
                case TESCallSuccessOK: {
                    NSString *device_id = [result valueForKey:@"device_id"];
                    if (device_id != nil) {
                        [self setToken:device_id forKey:DEVICE_TOKEN_KEY];
                    }
                    break;
                }
                case TESCallSuccessFAIL: {
                    NSNumber *code = [result valueForKey:@"code"];
                    NSString *msg = [result valueForKey:@"msg"];
                    [self.locMgr writeDebugMsg:nil msg:[NSString stringWithFormat:@"Device token request failed with unknown code: %@ %@", code, msg]];
                    break;
                }
                case TESCallError: {
                    NSString *msg = [result valueForKey:@"msg"];
                    [self.locMgr writeDebugMsg:nil msg:[NSString stringWithFormat:@"HTTP Request failed : %@", msg]];
                    break;
                }
                default:
                    [self.locMgr writeDebugMsg:nil msg:[NSString stringWithFormat:@"HTTP Request failed : unknown status %ld", (long)status]];
            }
            // Just start monitoring regardless as a the send device update will try and create a device token
            [self.locMgr ensureMonitoring];
        }];

    }
    else {
        [self.locMgr ensureMonitoring];
    }

}

- (nonnull  Device *) _fillDeviceFromLocation: (nullable LocationInfo *) loc
{
    if (loc == nil)
        loc = [LocationInfo CreateEmptyLocation];

    Device * dev = [[Device alloc] initWithAttributes: @{@"current":loc}];

    NSMutableArray * pushTargets = [[NSMutableArray alloc] initWithCapacity:5];
    PushInfo * pushInfo = nil;
    if (self.config.deviceTypes & deviceTypeAPN){
        // setup the push token if its new or we are a new device.
        if (self.pushToken != nil){
            pushInfo = [[PushInfo alloc] init];
            pushInfo.pushToken = self.pushToken;
            pushInfo.pushType = DEVICE_TYPE_APN;
            pushInfo.pushProfile = self.config.envPushProfile;
            [pushTargets addObject:pushInfo];
        }

    }

    if (self.config.deviceTypes & deviceTypeWallet){
        pushInfo = [[PushInfo alloc]init];
        pushInfo.pushToken = WALLET_PROFILE;
        pushInfo.pushType = DEVICE_TYPE_WALLET;
        pushInfo.pushProfile = self.config.walletOfferClass;
        [pushTargets addObject:pushInfo];

    }

    if (self.config.deviceTypes & deviceTypeMail){
        pushInfo = [[PushInfo alloc]init];
        pushInfo.pushToken = @"email";
        pushInfo.pushType = DEVICE_TYPE_MAIL;
        pushInfo.pushProfile = @"";
        [pushTargets addObject:pushInfo];
    }

    if (self.config.deviceTypes & deviceTypeSms){
        pushInfo.pushToken = @"phone";
        pushInfo.pushType = DEVICE_TYPE_SMS;
        pushInfo.pushProfile = @"";
        [pushTargets addObject:pushInfo];
    }

    NSInteger tgtCount = [pushTargets count];
    if (tgtCount == 1) {
        // setup the push token if its new or we are a new device.
        pushInfo = (PushInfo *) pushTargets[0];
        dev.pushToken = pushInfo.pushToken;
        dev.pushType = pushInfo.pushType;
        dev.pushProfile = pushInfo.pushProfile;
    }
    else if (tgtCount > 1){
        dev.pushType = DEVICE_TYPE_MULTIPLE;
        dev.pushToken = @"";
        dev.pushProfile = @"";
        dev.pushTargets = pushTargets;
    }

    if (self.localeToken != nil){
        dev.locale = self.localeToken;
    }
    if (self.timezoneToken != nil){
        dev.timezoneOffset = self.timezoneToken;
    }
    if (self.versionToken != nil ){
        dev.version = self.versionToken;
    }

    return dev;
}


- (void)getAccountProfile:(TESApiCallback)completionBlock {
    [self.api call:@"GET" url:TES_PATH_PROFILE parameters:nil auth:YES completionHandler:completionBlock];
}

- (void)updateAccountProfile:(nullable NSDictionary *)params onCompletion:(TESApiCallback)completionBlock {
    [self.api call:@"PUT" url:TES_PATH_PROFILE parameters:params auth:YES completionHandler:completionBlock];
}

- (void)updateAccountProfilePassword:(nonnull NSString *)password oldPassword:(nonnull NSString *)oldPassword onCompletion:(TESApiCallback)completionBlock {
     NSDictionary * params = @{@"password": password, @"old_password": oldPassword};
    [self.api call:@"PUT" url:TES_PATH_PROFILE parameters:params auth:YES completionHandler:completionBlock];
}

- (void)updateAccountSettings:(nullable NSDictionary *)params onCompletion:(TESApiCallback)completionBlock {
    NSMutableDictionary * new_settings = [TESWIApp recursiveToMutable:[self getToken:ACCESS_USER_SETTINGS]];
    if (new_settings == nil){
        new_settings = [[NSMutableDictionary alloc] initWithDictionary:@{@"exclusions":@{}, @"following":@[], @"watch_zones":@[], @"notifications":@{}}];
    }
    [new_settings addEntriesFromDictionary:params];

    NSDictionary * settings = @{@"settings":new_settings};
    [self.api call:@"PUT" url:TES_PATH_PROFILE parameters:settings auth:YES completionHandler:completionBlock];
}

- (void)uploadImageForProfile:(nonnull UIImage *)image completion:(TESApiCallback)completionBlock {
    [self.api uploadImage:@"GET" path:TES_PATH_ACCOUNT_PROFILE_IMAGES withImage:image withName:@"profile" auth:YES completionHandler:completionBlock];
}

- (void)readProfileImage:(TESApiCallback)completionBlock {
    [self.api downloadImage:@"GET" url:TES_PATH_IMAGES_RUD parameters:nil auth:YES completionHandler:completionBlock];
}

#pragma mark - events

- (void)listLiveEvents:(nullable NSDictionary *)params onCompletion:(TESApiCallback)completionBlock {
    NSString * path = [[NSString alloc] initWithFormat:TES_PATH_LIVE_EVENTS, self.deviceToken];
    [self.api call:@"GET" url:path parameters:params auth:YES completionHandler:completionBlock];
}

- (void)listSearchEvents:(nullable NSDictionary *)params withlocation:(CLLocationCoordinate2D)location onCompletion:(TESApiCallback)completionBlock {
    NSString * path = [[NSString alloc] initWithFormat:TES_PATH_SEARCH_LIVE_EVENTS, location.longitude, location.latitude];
    [self.api call:@"GET" url:path parameters:params auth:YES completionHandler:completionBlock];
}

- (void)listAcknowledgedLiveEvents:(nullable NSDictionary *)params onCompletion:(TESApiCallback)completionBlock {
    [self.api call:@"GET" url:TES_PATH_LIST_LIVE_EVENTS_ACK parameters:params auth:YES completionHandler:completionBlock];
}

- (void)listFollowedLiveEvents:(nullable NSDictionary *)params onCompletion:(TESApiCallback)completionBlock {
    [self.api call:@"GET" url:TES_PATH_LIST_LIVE_EVENTS_FOLLOW parameters:params auth:YES completionHandler:completionBlock];
}

- (void)updateEventAck:(nonnull NSString *)eventId isAck:(BOOL)ack onCompletion:(TESApiCallback)completionBlock {
    NSDictionary * params = @{@"ack": @(ack)};
    NSString * path = [[NSString alloc] initWithFormat:TES_PATH_LIVE_EVENTS_ACK, eventId];
    [self.api call:@"PUT" url:path parameters:params auth:YES completionHandler:completionBlock];
}

- (void)updateEventEnacted:(nonnull NSString *)eventId isEnacted:(BOOL)enacted onCompletion:(TESApiCallback)completionBlock {
    NSDictionary * params = @{@"enact": @(enacted)};
    NSString * path = [[NSString alloc] initWithFormat:TES_PATH_LIVE_EVENTS_ENACTED, eventId];
    [self.api call:@"PUT" url:path parameters:params auth:YES completionHandler:completionBlock];
}

- (void)readEventImage:(nonnull NSString *)imageId completion:(TESApiCallback)completionBlock {
    NSString * path = [[NSString alloc] initWithFormat:TES_PATH_ANY_IMAGES_RUD, imageId];
    [self.api downloadImage:@"GET" url:path parameters:nil auth:YES completionHandler:completionBlock];
}

#pragma - provider and places of interest

- (void)getProvider:(TESApiCallback)completionBlock {

    NSString * path = [[NSString alloc] initWithFormat:TES_PATH_PROVIDER, self.providerToken];
    NSDictionary * params = @{@"timezone":self.timezoneToken, @"locale":self.localeToken};
    [self.api call:@"GET" url:path parameters:params auth:YES completionHandler:completionBlock];
}

- (void)listPlacesOfInterestForProvider:(nullable NSDictionary *)params onCompletion:(TESApiCallback)completionBlock {
    NSString * path = [[NSString alloc] initWithFormat:TES_PATH_POI, self.providerToken];
    [self.api call:@"GET" url:path parameters:params auth:YES completionHandler:completionBlock];
}

-(void) listLiveEventsForProvider: (nullable NSDictionary *)params onCompletion: (TESApiCallback) completionBlock
{
    NSString * path = [[NSString alloc] initWithFormat:TES_PATH_PROVIDER_LIVE_EVENTS, self.providerToken];
    [self.api call:@"GET" url:path parameters:params auth:YES completionHandler:completionBlock];
}

-(void) listEventsForProvider: (nullable NSDictionary *)params onCompletion: (TESApiCallback) completionBlock
{
    NSString * path = [[NSString alloc] initWithFormat:TES_PATH_PROVIDER_EVENTS, self.providerToken];
    [self.api call:@"GET" url:path parameters:params auth:YES completionHandler:completionBlock];
}

-(void) listReviewsForPlace:(nonnull NSString *) poiId withParams: (nullable NSDictionary *)params onCompletion: (TESApiCallback) completionBlock {
    NSString * path = [[NSString alloc] initWithFormat:TES_PATH_PLACE_REVIEWS, poiId];
    [self.api call:@"GET" url:path parameters:params auth:YES completionHandler:completionBlock];
}

- (void)createReviewForPlace:(nonnull NSString *)poiId withParams:(nullable NSDictionary *)params onCompletion:(TESApiCallback)completionBlock {
    NSString * path = [[NSString alloc] initWithFormat:TES_PATH_PLACE_CREATE_REVIEW, poiId];
    [self.api call:@"POST" url:path parameters:params auth:YES completionHandler:completionBlock];
}

- (void)updateReview:(nonnull NSString *)reviewId withParams:(nullable NSDictionary *)params onCompletion:(TESApiCallback)completionBlock {
    NSString * path = [[NSString alloc] initWithFormat:TES_PATH_REVIEW_RUD, reviewId];
    [self.api call:@"PUT" url:path parameters:params auth:YES completionHandler:completionBlock];
}

- (void)deleteReview:(nonnull NSString *)reviewId onCompletion:(TESApiCallback)completionBlock {
    NSString * path = [[NSString alloc] initWithFormat:TES_PATH_REVIEW_RUD, reviewId];
    [self.api call:@"DELETE" url:path parameters:nil auth:YES completionHandler:completionBlock];
}

- (void)readPoiImage:(nonnull NSString *)imageId completion:(TESApiCallback)completionBlock {
    NSString * path = [[NSString alloc] initWithFormat:TES_PATH_ANY_IMAGES_RUD, imageId];
    [self.api downloadImage:@"GET" url:path parameters:nil auth:YES completionHandler:completionBlock];
}

#pragma mark - user settings

- (id) getUserSetting: (NSString *) key mutable:(BOOL) make_mutable;
{
    NSDictionary * user_settings = [self getToken:ACCESS_USER_SETTINGS];
    if (user_settings == nil)
        return nil;

    id val = [user_settings valueForKey:key];
    if (val == nil)
        return nil;

    if (make_mutable)
        return [TESWIApp recursiveToMutable:val];

    return val;
}

- (void) setUserSetting: (id) object withKey: (NSString *) key
{
    NSDictionary * user_settings = [self getToken:ACCESS_USER_SETTINGS];
    if (user_settings == nil)
        user_settings = [[NSMutableDictionary alloc] init];
    else
        user_settings = [TESWIApp recursiveToMutable:user_settings];
    [user_settings setValue:object forKey:key];
    [self setToken:user_settings forKey:ACCESS_USER_SETTINGS];

}

# pragma  mark - user setting high level functions

- (NSDictionary *) getExclusions
{
    return [self getUserSetting:@"exclusions" mutable:NO];
}

// exclude event (ie. add to the exclusion list)
- (void) excludeEventType: (NSString *) exc_type andCategory: (NSString *) exc_cat withCompletion:(TESApiCallback) completionBlock
{
    // update the exclusion dictionary
    NSMutableDictionary * exclusions = [self getUserSetting:@"exclusions" mutable:YES];
    if (exclusions == nil)
        exclusions = [[NSMutableDictionary alloc]init];

    NSMutableArray * exclusion_list = [exclusions valueForKey:exc_type];
    if (exclusion_list == nil)
        exclusion_list = [[NSMutableArray alloc]init];

    if ([exclusion_list indexOfObject:exc_cat] == NSNotFound)
        [exclusion_list addObject:exc_cat];

    [exclusions setValue:exclusion_list forKey:exc_type];

    // write the exclusion list to the server
    NSDictionary * params = @{@"exclusions":exclusions};
    [self updateAccountSettings:params onCompletion:^(TESCallStatus status, NSDictionary *_Nullable result){
        [self setUserSetting:exclusions withKey:@"exclusions"];
        if (completionBlock)
            completionBlock(status, result);
    }];
}

// include event (ie. remove from the inclusion list)
- (void) includeEventType: (NSString *) evt_type andCategory: (NSString *) evt_cat withCompletion:(TESApiCallback) completionBlock
{
    TESCallStatus errStatus = TESCallSuccessFAIL;

    // update the exclusion dictionary
    NSMutableDictionary * exclusions = [self getUserSetting:@"exclusions" mutable:YES];
    if (exclusions == nil){
        if (completionBlock)
            completionBlock(errStatus, @{@"success":@NO, @"msg":@"No exclusions found"});
        return ;
    }

    NSMutableArray * exclusion_list = [exclusions valueForKey:evt_type];
    if (exclusion_list == nil){
        if (completionBlock)
            completionBlock(errStatus, @{@"success":@NO, @"msg":@"No exclusions for event type found"});
        return;
    }

    BOOL changed = NO;
    NSInteger idx = [exclusion_list indexOfObject:evt_cat];
    if (idx != NSNotFound){
        [exclusion_list removeObjectAtIndex:idx];
        changed = YES;
    }

    if (changed){
        if ([exclusion_list count]<1){
            [exclusions removeObjectForKey:evt_type];
        }
        else {
            [exclusions setValue:exclusion_list forKey:evt_type];
        }

        // write the notification list to the server
        NSDictionary * params = @{@"exclusions":exclusions};
        [self updateAccountSettings:params onCompletion:^(TESCallStatus status, NSDictionary *_Nullable result){
            [self setUserSetting:exclusions withKey:@"exclusions"];
            if (completionBlock)
                completionBlock(status,result);
        }];
    }
    else {
        if (completionBlock)
            completionBlock(errStatus, @{@"success":@NO, @"msg":@"No changes to exclusion list found"});
    }
}

// notify events

- (void) allowNotifyEventType: (NSString *) evt_type andCategory: (NSString *) evt_cat withCompletion:(TESApiCallback) completionBlock
{
    // update the exclusion dictionary
    NSMutableDictionary * allow_notifications = [self getUserSetting:@"notifications" mutable:YES];
    if (allow_notifications == nil)
        allow_notifications = [[NSMutableDictionary alloc]init];

    NSMutableArray * notify_list = [allow_notifications valueForKey:evt_type];
    if (notify_list == nil)
        notify_list = [[NSMutableArray alloc]init];

    if ([notify_list indexOfObject:evt_cat] == NSNotFound)
        [notify_list addObject:evt_cat];

    [allow_notifications setValue:notify_list forKey:evt_type];

    // write the notification list to the server
    NSDictionary * params = @{@"notifications":allow_notifications};
    [self updateAccountSettings:params onCompletion:^(TESCallStatus status, NSDictionary *_Nullable result){
        [self setUserSetting:allow_notifications withKey:@"notifications"];
        if (completionBlock)
            completionBlock(status,result);
    }];
}

- (void) disallowNotifyEventType: (NSString *) evt_type andCategory: (NSString *) evt_cat withCompletion:(TESApiCallback) completionBlock
{
    TESCallStatus errStatus = TESCallSuccessFAIL;

    // update the exclusion dictionary
    NSMutableDictionary * allow_notifications = [self getUserSetting:@"notifications" mutable:YES];
    if (allow_notifications == nil){
        if (completionBlock)
            completionBlock(errStatus, @{@"success":@NO, @"msg":@"No notifications found"});
        return;
    }

    NSMutableArray * notify_list = [allow_notifications valueForKey:evt_type];
    if (notify_list == nil){
        if (completionBlock)
            completionBlock(errStatus, @{@"success":@NO, @"msg":@"No notifications for event type found"});
        return;
    }


    BOOL changed = NO;
    NSUInteger  idx = [notify_list indexOfObject:evt_cat];
    if (idx != NSNotFound){
        [notify_list removeObjectAtIndex:idx];
        changed = YES;
    }
    else {
        idx = [notify_list indexOfObject:@"*"];
        if (idx != NSNotFound){
            [notify_list removeObjectAtIndex:idx];
            changed = YES;
        }
    }

    if (changed){
        if ([notify_list count]<1){
            [allow_notifications removeObjectForKey:evt_type];
        }
        else {
            [allow_notifications setValue:notify_list forKey:evt_type];
        }

        // write the notification list to the server
        NSDictionary * params = @{@"notifications":allow_notifications};
        [self updateAccountSettings:params onCompletion:^(TESCallStatus status, NSDictionary *_Nullable result){
            [self setUserSetting:allow_notifications withKey:@"notifications"];
            if (completionBlock)
                completionBlock(status,result);
        }];
    }
    else {
        if (completionBlock)
            completionBlock(errStatus, @{@"success":@NO, @"msg":@"No changes to exclusion list found"});
    }
}

- (BOOL) isAllowNotify: (NSString *) evt_type andCategory: (NSString *) evt_cat
{
    BOOL allow = NO;
    NSMutableDictionary * allow_notifications = [self getUserSetting:@"notifications" mutable:NO];
    if (allow_notifications == nil)
        return allow;

    NSArray * notify_list = [allow_notifications valueForKey:evt_type];
    if (notify_list == nil)
        return allow;

    for (NSString * cat in notify_list){
        if ([cat isEqualToString:@"*"] || [cat isEqualToString:evt_cat]){
            allow = YES;
            break;
        }
    }
    return allow;
}

// following routines

- (BOOL) isFollowingPoi: (NSString *) rid
{
    BOOL fnd = NO;
    NSArray * following = [self getUserSetting:@"following" mutable:NO];
    for (NSDictionary * obj in following){
        NSString * typ = [obj valueForKey:@"object_type"];
        NSString * oid = [obj valueForKey:@"object_id"];
        if ([typ isEqualToString:@"poi"] && [oid isEqualToString:rid]){
            fnd = YES;
            break;
        }
    }
    return fnd;
}

- (void) addFollowPoi: (NSString *) rid  withCompletion:(TESApiCallback) completionBlock

{
    if ([self isFollowingPoi:rid])
        return; // nothing to do.

    NSMutableArray * following = [self getUserSetting:@"following" mutable:YES];
    if (following == nil){
        following = [[NSMutableArray alloc] init];
    }
    [following addObject:@{@"object_type":@"poi", @"object_id":rid}];

    NSDictionary * params = @{@"following":following};
    [self updateSettings:params withCompletion:^(TESCallStatus status, NSDictionary *_Nullable result){
        [self setUserSetting:following withKey:@"following"];

        if (completionBlock)
            completionBlock(status,result);
    }];

}

- (void) removeFollowPoi: (NSString *) rid  withCompletion:(TESApiCallback) completionBlock

{
    if (![self isFollowingPoi:rid])
        return; // nothing to do.

    NSMutableArray * following = [self getUserSetting:@"following" mutable:YES];
    if (following == nil)
        return; // nothing to do

    for (NSDictionary * obj in following){
        NSString * typ = [obj valueForKey:@"object_type"];
        NSString * oid = [obj valueForKey:@"object_id"];
        if ([typ isEqualToString:@"poi"] && [oid isEqualToString:rid]){
            [following removeObject:obj];
            break;
        }
    }

    NSDictionary * params = @{@"following":following};
    [self updateSettings:params withCompletion:^(TESCallStatus status, NSDictionary *_Nullable result){
        [self setUserSetting:following withKey:@"following"];
        if (completionBlock){
            completionBlock(status,result);
        }
    }];
}

// watchzone routines

- (NSArray *) getWatchZones
{
    return [self getUserSetting:@"watch_zones" mutable:NO];


}

- (NSDictionary *) findZone: (NSString *) name fromZones: (NSArray *) watchZones
{
    NSDictionary *zone = nil;
    for (NSDictionary * obj in watchZones){
        NSString * oid = [obj valueForKey:@"name"];
        if ([oid isEqualToString:name]){
            zone = obj;
            break;
        }
    }
    return zone;
}

- (NSDictionary *) getWatchZoneNamed: (NSString *) name
{
    NSArray * watchZones = [self getUserSetting:@"watch_zones" mutable:NO];
    NSDictionary *zone = [self findZone:name fromZones:watchZones];
    return zone;
}

- (BOOL) addWatchZoneNamed: (NSString *) name
              withDistance: (NSNumber *) distance
              fromLocation: (NSString *) location
               atLongitude: (CLLocationDegrees) longitude
               andLatitude: (CLLocationDegrees) latitude
               oldZoneInfo: (NSDictionary *) oldZoneInfo
            withCompletion:(TESApiCallback) completionBlock

{
    NSMutableArray * watchZones = [self getUserSetting:@"watch_zones" mutable:YES];
    if (watchZones == nil){
        watchZones = [[NSMutableArray alloc] init];
    }

    // remove the old version of the zone
    if (oldZoneInfo != nil){
        NSString * oldName = [oldZoneInfo valueForKey:@"name"];
        NSDictionary * zone = [self findZone:oldName fromZones:watchZones];
        if (zone != nil)
            [watchZones removeObject:zone];
    }

    // see if we have a duplicate name
    NSDictionary * zone = [self findZone:name fromZones:watchZones];
    if (zone != nil){
        return NO;
    }



    if (location == nil || [location length]<1){
        [watchZones addObject:@{@"name":name, @"distance":distance, @"current_location": @YES}];
    }
    else
    {
        [watchZones addObject:@{@"name":name, @"distance":distance, @"current_location": @NO, @"location":location, @"location_coord":@[[NSNumber numberWithDouble:longitude], [NSNumber numberWithDouble:latitude]]}];

    }

    NSDictionary * params = @{@"watch_zones":watchZones};
    [self updateSettings:params withCompletion:^(TESCallStatus status, NSDictionary *_Nullable result){
        [self setUserSetting:watchZones withKey:@"watch_zones"];

        if (completionBlock)
            completionBlock(status,result);
    }];

    return YES;

}

- (void) removeWatchZonenamed: (NSString *) name  withCompletion:(TESApiCallback) completionBlock {
    NSDictionary *zone = [self getWatchZoneNamed:name];
    if (zone == nil)
        return; // nothing to do

    NSMutableArray *watchZones = [self getUserSetting:@"watch_zones" mutable:YES];
    if (watchZones == nil)
        return; // nothing to do

    [watchZones removeObject:zone];

    NSDictionary *params = @{@"watch_zones": watchZones};
    [self updateSettings:params withCompletion:^(TESCallStatus status, NSDictionary *_Nullable result){
        [self setUserSetting:watchZones withKey:@"watch_zones"];
        if (completionBlock) {
            completionBlock(status,result);
        }
    }];

}

- (void) updateSettings: (NSDictionary * ) params withCompletion:(TESApiCallback) completionBlock
{
    [self updateAccountSettings:params onCompletion:completionBlock];
}

#pragma mark - misc

+ (nonnull id)recursiveToMutable:(nonnull id)object {
    if([object isKindOfClass:[NSDictionary class]])
    {
        NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithDictionary:object];
        for(NSString* key in [dict allKeys])
        {
            dict[key] = [TESWIApp recursiveToMutable:dict[key]];
        }
        return dict;
    }
    else if([object isKindOfClass:[NSArray class]])
    {
        NSMutableArray* array = [NSMutableArray arrayWithArray:object];
        for(int i=0;i<[array count];i++)
        {
            array[i] = [TESWIApp recursiveToMutable:array[i]];
        }
        return array;
    }

    return object;
}

#pragma mark - Token management

/**
 Persistance layer for various tokens
 */

- (void) initTokens
{
    //setup the special tokens we keep track of

    self.api.accessToken = [self getToken:ACCESS_TOKEN_KEY];
    self.api.accessAuthType = [self getToken:ACCESS_AUTH_TYPE];
    self.api.accessSystemDefaults = [self getToken:ACCESS_SYSTEM_DEFAULTS];

    self.deviceToken = [self getToken:DEVICE_TOKEN_KEY];
    self.pushToken = [self getToken:PUSH_TOKEN_KEY];
    self.localeToken = [self getToken:LOCALE_TOKEN_KEY];
    self.timezoneToken = [self getToken:TIMEZONE_TOKEN_KEY];

    self.versionToken = [self getToken:LAST_LAUNCHED_VERSION_TOKEN_KEY];

    // clear out the new flags
    newPushToken = NO;
    newDeviceToken = NO;
    newAccessToken = NO;
    newAccessAuthType = NO;

    newLocaleToken = NO;
    newTimezoneToken = NO;
    newVersionToken = NO;

}

- (id) getToken: (NSString *)token
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults objectForKey:token];
}


- (NSString *) getToken: (NSString *)token withDefault: (NSString *) defaultValue
{
    NSString *tok = [self getToken:token];
    if (tok == nil)
        tok = defaultValue;
    return tok;
}

- (void) setToken: (id) value forKey: (NSString *)token
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:value forKey:token];
    [defaults synchronize];
    [self _syncInternalTokens: value forKey:token];
}

- (void) clearToken: (NSString *) token
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:token];
    [defaults synchronize];
    [self _syncInternalTokens: nil forKey:token];
}

- (void) _syncInternalTokens: (id) value forKey: (NSString *) token
{
    if([token isEqual: ACCESS_TOKEN_KEY]){
        newAccessToken =  (self.api.accessToken == nil && value != nil) || ![self.api.accessToken isEqualToString:value];
        self.api.accessToken = value;
    }
    else if ([token isEqual: ACCESS_AUTH_TYPE]){
        newAccessAuthType =  (self.api.accessAuthType == nil && value != nil) || ![self.api.accessAuthType isEqualToString:value];
        self.api.accessAuthType = value;
    }
    else if ([token isEqual:ACCESS_SYSTEM_DEFAULTS]){
        newAccessSystemDefaults = YES;
        self.api.accessSystemDefaults = value;
    }
    else if ([token isEqual: DEVICE_TOKEN_KEY]){
        newDeviceToken =  (self.deviceToken == nil && value != nil) || ![self.deviceToken isEqualToString:value];
        self.deviceToken = value;
    }
    else if ([token isEqual: PUSH_TOKEN_KEY]){
        newPushToken =  (self.pushToken == nil && value != nil) || ![self.pushToken isEqualToString:value];
        self.pushToken = value;
    }
    else if ([token isEqual: LOCALE_TOKEN_KEY]){
        newLocaleToken =  (self.localeToken == nil && value != nil) || ![self.localeToken isEqualToString:value];
        self.localeToken = value;
    }
    else if ([token isEqualToString: TIMEZONE_TOKEN_KEY]){
        newTimezoneToken =  (self.timezoneToken == nil && value != nil) || ![self.timezoneToken isEqualToString:value];
        self.timezoneToken = value;
    }
    else if ([token isEqualToString: LAST_LAUNCHED_VERSION_TOKEN_KEY]){
        newVersionToken = (self.versionToken == nil && value !=nil) || ![self.versionToken isEqualToString:value];
        self.versionToken = value;
    }
    else if ([token isEqualToString: ACCESS_USER_NAME]){
        newAccessUserName = (self.authUserName == nil && value != nil) || ![self.authUserName isEqualToString:value];
        self.authUserName = value;
    }

    if (newAccessToken && self.delegate && [self.delegate respondsToSelector:@selector(newAccessToken:)]){
        [self.delegate newAccessToken:self.api.accessToken];
        newAccessToken = NO;
    }

    if (newDeviceToken && self.delegate && [self.delegate respondsToSelector:@selector(newDeviceToken:)]){
        [self.delegate newDeviceToken:self.deviceToken];
        newDeviceToken = NO;
    }

    if (newPushToken && self.delegate && [self.delegate respondsToSelector:@selector(newPushToken:)]){
        [self.delegate newPushToken:self.pushToken];
        newPushToken = NO;
    }
}


-(void) setLocaleAndVersionInfo
{
    NSLocale *locale = [NSLocale currentLocale];
    NSString *currentLocaleID = [locale localeIdentifier];

    NSString *preferredLang = [[NSLocale preferredLanguages] objectAtIndex:0];
    NSLog(@"Locale: %@ Current Language: %@" , currentLocaleID, preferredLang);

    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSLog(@"Timezone: %@ , seconds from GMT: %ld", tz.name, (long)tz.secondsFromGMT);

    NSString * version = [[NSBundle mainBundle] objectForInfoDictionaryKey: @"CFBundleShortVersionString"];
    NSString * build = [[NSBundle mainBundle] objectForInfoDictionaryKey: (NSString *)kCFBundleVersionKey];
    NSString * prodIdentifier = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleIdentifier"];
    NSLog(@"Version: %@ build: %@  Identifier: %@", version, build, prodIdentifier);

    [self setToken:currentLocaleID forKey:LOCALE_TOKEN_KEY];
    [self setToken:[NSString stringWithFormat:@"%ld", (long)tz.secondsFromGMT]  forKey:TIMEZONE_TOKEN_KEY];
    [self setToken:[NSString stringWithFormat:@"%@.%@ %@", version, build, prodIdentifier] forKey:LAST_LAUNCHED_VERSION_TOKEN_KEY];
}

@end
