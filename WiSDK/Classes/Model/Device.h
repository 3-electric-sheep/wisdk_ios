//
//  Device.h
//  dealFlashTest
//
//  Created by Phillp Frantz on 15/02/13.
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

#import <Foundation/Foundation.h>

@class LocationInfo;

@interface Device : NSObject

@property (nullable, nonatomic, strong) NSString * pushToken;
@property (nullable, nonatomic, strong) NSString * pushType;
@property (nullable, nonatomic, strong) NSString * pushProfile;
@property (nullable, nonatomic, strong) NSString * locale;
@property (nullable, nonatomic, strong) NSString * timezoneOffset;
@property (nullable, nonatomic, strong) NSString * version;

@property (nonnull, nonatomic, copy) LocationInfo * current;
@property (nullable, nonatomic, strong) NSArray * pushTargets;

- (nullable instancetype) initWithAttributes:(nonnull NSDictionary *)attributes;
- (nonnull NSMutableDictionary *) toDictionary;
@end
