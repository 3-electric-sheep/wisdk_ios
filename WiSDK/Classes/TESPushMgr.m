//
//  TESPushMgr.m
//  WISDKdemo
//
//  Created by Phillp Frantz on 22/07/2017.
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
    if (@available(iOS 10, *)){
        UNUserNotificationCenter* center = [UNUserNotificationCenter currentNotificationCenter];
        [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert + UNAuthorizationOptionSound + UNAuthorizationOptionBadge)
                              completionHandler:^(BOOL granted, NSError * _Nullable error) {
                                  // TODO : allow callback here
                              }];
        [app registerForRemoteNotifications];
    }
    else if (@available(iOS 9, *)) {
        // Let the device know we want to receive push notifications
        [app registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [app registerForRemoteNotifications];
    }
    else if (@available(iOS 8, *)){
        [app registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories: nil]];
        [app registerForRemoteNotifications];
    }
    else {
        [app registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
    }
}
@end
