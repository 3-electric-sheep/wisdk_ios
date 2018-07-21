//
//  Review.h
//  dealFlashTest
//
//  Created by Phillp Frantz on 7/03/13.
//  Copyright (c) 2013 Blackdog Software Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, Poi;

@interface Review : NSManagedObject

@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSString * event_id;
@property (nonatomic, retain) NSDate * last_update;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * poi_id;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * rid;
@property (nonatomic, retain) NSNumber * editable;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) Poi *poi;

- (double) starRating;
- (NSString * ) formatReviewer;
- (NSString *) formatLastUpdate;
@end
