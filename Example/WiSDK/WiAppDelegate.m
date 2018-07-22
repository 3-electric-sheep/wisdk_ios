//
//  WiAppDelegate.m
//  WiSDK
//
//  Created by pfrantz on 07/20/2018.
//  Copyright (c) 2018 pfrantz. All rights reserved.
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

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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
