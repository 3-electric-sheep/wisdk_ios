//
//  TESPushMgr.m
//  WISDKdemo
//
//  Created by Phillp Frantz on 22/07/2017.
//  Copyright © 2012-2018 3 Electric Sheep Pty Ltd. All rights reserved.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import <UserNotifications/UserNotifications.h>
#import "TESPushMgr.h"
#import "TESUtil.h"

@implementation TESPushMgr{
    BOOL sentAlert;
}


- (nullable instancetype)initWithProfile: (nullable NSString *) pushProfile
{
    self = [super init];
    if (self){
        self.apnProfile = pushProfile;

    }
    return self;
}

- (nullable instancetype) init
{
    self = [self initWithProfile:nil];
    if (!self)
        return nil;

    return self;
}

- (void) registerRemoteNotifications
{
    UIApplication * app =  [UIApplication sharedApplication];
    if ([TESUtil atLeastIOS:@"10.0"]){
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge)
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  UIApplication * app = [UIApplication sharedApplication];
                                  BOOL isInBackground = (app.applicationState == UIApplicationStateBackground);

                                  // Enable or disable features based on authorization.
                                  if (!granted) {
                                      if (!sentAlert && !isInBackground) {
                                          NSString *title =  NSLocalizedString(@"Remote notifications disabled", nil);
                                          NSString *msg = NSLocalizedString(@"In order to be notified about special offers near you, please open this app's settings and enable notifications", nil);

                                          UIAlertController *alert = [UIAlertController
                                                  alertControllerWithTitle:title
                                                                   message:msg
                                                            preferredStyle:UIAlertControllerStyleAlert];

                                          UIAlertAction *ok = [UIAlertAction
                                                  actionWithTitle:NSLocalizedString(@"Open Settings", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [alert dismissViewControllerAnimated:YES completion:nil];
                                                              NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                                                              [app openURL:settingsURL options:@{} completionHandler:^(BOOL ok) {
                                                              }];

                                                          }];
                                          UIAlertAction *cancel = [UIAlertAction
                                                  actionWithTitle:NSLocalizedString(@"Cancel", nil)
                                                            style:UIAlertActionStyleDefault
                                                          handler:^(UIAlertAction *action) {
                                                              [alert dismissViewControllerAnimated:YES completion:nil];

                                                          }];

                                          [alert addAction:ok];
                                          [alert addAction:cancel];

                                          [app.delegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
                                          sentAlert = TRUE;
                                      }
                                  }
                              }];
        [app registerForRemoteNotifications];
    }
    else if ([TESUtil atLeastIOS:@"9.0"]) {
        // Let the device know we want to receive push notifications
        [app registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [app registerForRemoteNotifications];
    }
    else if ([TESUtil atLeastIOS:@"8.0"]){
        [app registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories: nil]];
        [app registerForRemoteNotifications];
    }
    else {
        [app registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    }
}
@end