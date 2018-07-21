//
//  Device.h
//  dealFlashTest
//
//  Created by Phillp Frantz on 15/02/13.
//  Copyright (c) 2013 Blackdog Software Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PushInfo : NSObject

@property (nullable, nonatomic, strong) NSString * pushToken;
@property (nullable, nonatomic, strong) NSString * pushType;
@property (nullable, nonatomic, strong) NSString * pushProfile;

- (nullable instancetype) initWithAttributes:(nonnull NSDictionary *)attributes;
- (nonnull NSMutableDictionary *) toDictionary;
@end
