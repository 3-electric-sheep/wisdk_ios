//
//  OpenTimes.h
//  dealFlashTest
//
//  Created by Phillp Frantz on 23/02/13.
//  Copyright (c) 2013 Blackdog Software Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OpenHours;

@interface OpenTimes : NSManagedObject

@property (nonatomic, retain) NSString * open;
@property (nonatomic, retain) NSString * close;
@property (nonatomic, retain) OpenHours *open_hours;
@property (nonatomic, retain) NSString * rid;
@end
