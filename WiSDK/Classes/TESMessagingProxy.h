//
// Created by Phillp Frantz on 8/08/2017.
// Copyright (c) 2017 3 Electric Sheep Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TESMessagingProxy: NSObject

// ----------------------------------------------
// private internal methods
// -----------------------------------------------
+ (instancetype)sharedProxy;

+ (void) swizzleMethods;

- (void)_wisdk_application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken;
- (void)_wisdk_application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error;
- (void)_wisdk_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo;

@end