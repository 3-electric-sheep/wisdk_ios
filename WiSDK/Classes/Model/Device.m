//
//  Device.m
//  dealFlashTest
//
//  Created by Phillp Frantz on 15/02/13.
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

#import "Device.h"
#import "LocationInfo.h"
#import "PushInfo.h"

@implementation Device

- (nullable instancetype) initWithAttributes:(nonnull NSDictionary *)attributes
{
    self = [super init];
    if (self){

        _pushToken = [attributes valueForKey:@"push_info"] ;
        _pushType = [attributes valueForKey:@"push_type"] ;
        _pushProfile = [attributes valueForKey:@"push_profile"];
        _current = [attributes valueForKey:@"current"];
        
        _timezoneOffset = [attributes valueForKey:@"timezone_offset"];
        _locale = [attributes valueForKey:@"locale"];
        _version = [attributes valueForKey:@"version"];

        _pushTargets = [attributes valueForKey:@"push_targets"];
        return self;
    }
    return nil;
}

- (nonnull NSMutableDictionary *) toDictionary
{
    NSMutableDictionary * attributes = [[NSMutableDictionary alloc] initWithDictionary:@{
                                        @"current":  [_current toDictionary]
                                        }
                                        ];
    if ( _pushToken != nil)
        [attributes setValue:_pushToken forKey:@"push_info"];

    if (_pushType != nil)
        [attributes setValue: _pushType forKey: @"push_type"];
    
    if (_pushProfile != nil)
        [attributes setValue: _pushProfile forKey:@"push_profile"];
    
    if (_timezoneOffset != nil)
        [attributes setValue:_timezoneOffset forKey:@"timezone_offset"];
    if (_locale != nil)
        [attributes setValue:_locale forKey:@"locale"];
    if (_version != nil)
        [attributes setValue:_version forKey:@"version"];

    if (_pushTargets != nil){
        NSInteger resultCount = [_pushTargets count];
        NSMutableArray * results = [[NSMutableArray alloc] initWithCapacity:(resultCount==0)?1:resultCount];
        [_pushTargets enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            PushInfo * pushInfo = obj;
            [results addObject:[pushInfo toDictionary]];

        }];
        [attributes setValue:results forKey:@"push_targets"];
    }
    
    return attributes;
}

@end
