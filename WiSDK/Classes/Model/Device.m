//
//  Device.m
//  dealFlashTest
//
//  Created by Phillp Frantz on 15/02/13.
//  Copyright (c) 2013 Blackdog Software Pty Ltd. All rights reserved.
//

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
