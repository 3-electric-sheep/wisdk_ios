//
//  TESPushMgr.h
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

#ifndef TESPushMgr_h
#define TESPushMgr_h

@interface TESPushMgr : NSObject

@property (strong, nonatomic, nullable) NSString * apnProfile;

- (nullable instancetype)initWithProfile: (nullable NSString *) pushProfile NS_DESIGNATED_INITIALIZER;

- (void) registerRemoteNotifications;

@end

#endif /* TESPushMgr_h */
