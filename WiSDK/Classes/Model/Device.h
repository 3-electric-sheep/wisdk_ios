//
//  Device.h
//  dealFlashTest
//
//  Created by Phillp Frantz on 15/02/13.
//  Copyright (c) 2013 Blackdog Software Pty Ltd. All rights reserved.
//

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
