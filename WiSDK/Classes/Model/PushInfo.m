//
//  Device.m
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

#import "PushInfo.h"

@implementation PushInfo

-(nullable instancetype) initWithAttributes:(nonnull NSDictionary *)attributes
{
    self = [super init];
    if (self){

        _pushToken = [attributes valueForKey:@"push_info"] ;
        _pushType = [attributes valueForKey:@"push_type"] ;
        _pushProfile = [attributes valueForKey:@"push_profile"];
        return self;
    }
    return nil;
}

- (nonnull NSMutableDictionary *) toDictionary
{
    NSMutableDictionary * attributes = [[NSMutableDictionary alloc] initWithDictionary:@{
    }];

    if ( _pushToken != nil)
        [attributes setValue:_pushToken forKey:@"push_info"];

    if (_pushType != nil)
        [attributes setValue: _pushType forKey: @"push_type"];
    
    if (_pushProfile != nil)
        [attributes setValue: _pushProfile forKey:@"push_profile"];
    
    return attributes;
}

@end
