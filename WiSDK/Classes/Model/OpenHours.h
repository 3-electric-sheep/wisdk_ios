//
//  OpenHours.h
//  dealFlashTest
//
//  Created by Phillp Frantz on 23/02/13.
//  Copyright (c) 2013 Blackdog Software Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Poi;

@interface OpenHours : NSManagedObject

@property (nonatomic, retain) NSString * day;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSSet *times;
@property (nonatomic, retain) Poi *poi;
@property (nonatomic, retain) NSString * rid;
@end

@interface OpenHours (CoreDataGeneratedAccessors)

- (void)addTimesObject:(NSManagedObject *)value;
- (void)removeTimesObject:(NSManagedObject *)value;
- (void)addTimes:(NSSet *)values;
- (void)removeTimes:(NSSet *)values;

-(NSString *) formattedOpenHrs;

@end
