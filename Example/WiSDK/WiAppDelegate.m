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
    NSString * PROVIDER_KEY = @"5b53e675ec8d831eb30242d3"; // the wisdk-example account (user is wisdk@3-electric-sheep.com)
    TESConfig * config = [[TESConfig alloc] initWithProviderKey:PROVIDER_KEY];
    config.authAutoAuthenticate = YES;
    config.authCredentials = @{
           @"anonymous_user": @YES,
    };
    config.deviceTypes = deviceTypeAPN | deviceTypeWallet;
    
#ifdef DEBUG
    config.testPushProfile = @"wisdk-example-aps-dev";  // test profile name (allocted by 3es)
    config.pushProfile = @"wisdk-example-aps-dev"; // prod profile name (allocated by 3es)
#endif
#ifndef DEBUG
    config.testPushProfile = @"wisdk-example-aps-prod";  // test profile name (allocted by 3es)
    config.pushProfile = @"wisdk-example-aps-prod"; // prod profile name (allocated by 3es)
#endif

    TESWIApp * app = [TESWIApp manager];
    app.delegate = self;

    [app start:config withLaunchOptions:launchOptions];

    return YES;
}

#pragma mark - TESWiAppDelegate

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
