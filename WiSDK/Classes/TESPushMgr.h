//
//  TESPushMgr.h
//  WISDKdemo
//
//  Created by Phillp Frantz on 22/07/2017.
//  Copyright © 2017 3 Electric Sheep Pty Ltd. All rights reserved.
//

#ifndef TESPushMgr_h
#define TESPushMgr_h

@interface TESPushMgr : NSObject

@property (strong, nonatomic, nullable) NSString * apnProfile;

- (nullable instancetype)initWithProfile: (nullable NSString *) pushProfile NS_DESIGNATED_INITIALIZER;

- (void) registerRemoteNotifications;

@end

#endif /* TESPushMgr_h */
