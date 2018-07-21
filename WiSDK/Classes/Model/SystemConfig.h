//
//  SystemConfig.h
//  SnapItUpSeller
//
//  Created by Phillp Frantz on 19/07/13.
//  Copyright (c) 2013 Blackdog Software Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Provider;

@interface SystemConfig : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSString * rid;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) Provider *provider;

@end
