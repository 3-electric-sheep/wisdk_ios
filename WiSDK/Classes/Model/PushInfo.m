//
//  Device.m
//  dealFlashTest
//
//  Created by Phillp Frantz on 15/02/13.
//  Copyright (c) 2013 Blackdog Software Pty Ltd. All rights reserved.
//

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
