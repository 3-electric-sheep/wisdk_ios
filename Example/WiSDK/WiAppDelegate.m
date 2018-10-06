//
//  WiAppDelegate.m
//  WiSDK
//
//  Created by pfrantz on 07/20/2018.
//  Copyright (c) 2012-2018 3 Electric Sheep Pty Ltd All rights reserved.
//

#import "WiAppDelegate.h"
#import "WiSDK/TESWIApp.h"

@implementation WiAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
#ifdef DEBUG
    NSString * PROVIDER_KEY = @"5bb54bd58f3f541552dd0097"; // wi_test wisdk demo provider
#endif
#ifndef DEBUG
    NSString * PROVIDER_KEY = @"5b53e675ec8d831eb30242d3"; // the wisdk-example account (user is wisdk@3-electric-sheep.com)
#endif

    TESConfig * config = [[TESConfig alloc] initWithProviderKey:PROVIDER_KEY];
    config.authAutoAuthenticate = YES;
    config.authCredentials = @{
           @"anonymous_user": @YES,
           @"external_id": @"123456"
    };

    config.deviceTypes = deviceTypeAPN | deviceTypePassive;
    
#ifdef DEBUG
    config.environment = TES_ENV_TEST;
    config.testPushProfile = @"wisdk-example-aps-dev";  // test profile name (allocted by 3es)
    config.pushProfile = @"wisdk-example-aps-dev"; // prod profile name (allocated by 3es)
#endif
#ifndef DEBUG
    config.environment = TES_ENV_PROD;
    config.testPushProfile = @"wisdk-example-aps-prod";  // test profile name (allocted by 3es)
    config.pushProfile = @"wisdk-example-aps-prod"; // prod profile name (allocated by 3es)
#endif

    config.singleLocationFix = YES;

    TESWIApp * app = [TESWIApp manager];
    app.delegate = self;

    [app start:config withLaunchOptions:launchOptions];

    return YES;
}

#pragma mark - TESWiAppDelegate

-(void)onStartupComplete:(BOOL)authorized{
    NSLog(@"--> Startup complete: %ld", (long) authorized);
    if (authorized){
        TESWIApp * app = [TESWIApp manager];

        NSDictionary * params = @{
                @"email": @"demo-2@3es.com",
                @"first_name": @"Demo",
                @"last_name": @"User",
                @"external_id": @"666123666",
                @"attributes": @{
                        @"Gender":@"Male",
                        @"DOB": @"1939-12-04"
                }

        };
        [app updateAccountProfile:params onCompletion:^ void (TESCallStatus  status, NSDictionary * _Nullable result) {
            switch (status) {
                case TESCallSuccessOK: {
                    NSString *data = [result valueForKey:@"data"];
                    NSLog(@"updateAccountProfile Success %@", data);
                    break;
                }
                case TESCallSuccessFAIL: {
                    NSNumber *code = [result valueForKey:@"code"];
                    NSString *msg = [result valueForKey:@"msg"];
                    NSLog(@"updateAccountProfile Fail %d %@", code, msg);
                    break;
                }
                case TESCallError: {
                    NSString *msg = [result valueForKey:@"msg"];
                    NSLog(@"updateAccountProfile Network %@", msg);
                    break;
                }
            }
        }];

        params = @{
            @"relative_start":@"20d"
        };

        [app listAlertedEvents:params onCompletion:^ void (TESCallStatus  status, NSDictionary * _Nullable result) {
            switch (status) {
                case TESCallSuccessOK: {
                    NSString *data = [result valueForKey:@"data"];
                    NSLog(@"ListtAlerted Success %@", data);
                    break;
                }
                case TESCallSuccessFAIL: {
                    NSNumber *code = [result valueForKey:@"code"];
                    NSString *msg = [result valueForKey:@"msg"];
                    NSLog(@"ListtAlerted Fail %d %@", code, msg);
                    break;
                }
                case TESCallError: {
                    NSString *msg = [result valueForKey:@"msg"];
                    NSLog(@"ListtAlerted Network %@", msg);
                    break;
                }
            }
        }];

    }
}


- (void)authorizeFailure:(NSInteger)httpStatus {
    NSLog(@"--> Authorize failure: %ld", (long) httpStatus);
}

- (void)onAutoAuthenticate:(TESCallStatus)status withResponse:(nonnull NSDictionary *)responseObeject {
    NSLog(@"--> onAutoAuthenticate %@", responseObeject);
}

- (void)newAccessToken:(nullable NSString *)token {
    NSLog(@"--> newAccessToken %@", token);
}

- (void)newDeviceToken:(nullable NSString *)token {
    NSLog(@"--> newDeviceToken %@", token);
}

- (void)newPushToken:(nullable NSString *)token {
    NSLog(@"--> newPushToken %@", token);
}

- (void)processRemoteNotification:(nullable NSDictionary *)userDictionary {
    NSLog(@"--> processRemoteNotification %@", userDictionary);
}

- (void)onRemoteNoficiationRegister:(TESCallStatus)status withResponse:(nonnull NSDictionary *)responseObeject {
    NSLog(@"--> onRemoteNoficiationRegister %@", responseObeject);
}

#pragma mart - notification delegates

- (void) application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {;
    NSLog(@"Original didRegisterForRemoteNotificationsWithDeviceToken");
}

- (void) application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    NSLog(@"Original didFailToRegisterForRemoteNotificationsWithError");
}

- (void) application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Original didReceiveRemoteNotification");
}


@end
