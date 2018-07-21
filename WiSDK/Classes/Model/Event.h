//
//  Event.h
//  SnapItUpSeller
//
//  Created by Phillp Frantz on 18/07/13.
//  Copyright (c) 2013 Blackdog Software Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import <CoreLocation/CLLocation.h>

@class GalleryImage, InfoEvent, Poi, Review, ReviewSummary;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * detail;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSNumber * enactable;
@property (nonatomic, retain) NSNumber * event_ack;
@property (nonatomic, retain) NSNumber * event_enacted;
@property (nonatomic, retain) NSDate * event_enacted_time;
@property (nonatomic, retain) NSString * event_id;
@property (nonatomic, retain) NSDate * expires;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSDate * image_last_modified;
@property (nonatomic, retain) NSData * image_media;
@property (nonatomic, retain) NSString * rid;
@property (nonatomic, retain) NSDate * starts;
@property (nonatomic, retain) NSNumber * time_remaining;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSNumber * total_ack;
@property (nonatomic, retain) NSNumber * total_enacted;
@property (nonatomic, retain) NSNumber * total_shares;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSSet *gallery;
@property (nonatomic, retain) InfoEvent *info_detail;
@property (nonatomic, retain) Poi *poi;
@property (nonatomic, retain) ReviewSummary *review_summaries;
@property (nonatomic, retain) NSSet *reviews;

// formatted fields
- (NSString *) formattedTypeInfo;
- (NSString *) formattedDistance;
- (NSString *) formattedTimeRemaining;
- (NSString *) formattedTimeToStart;
- (NSString *) formattedStatus;

- (NSString *) formattedReviewCount;
- (double) starRating;

// returns day of week as an int 1=sunday, 7=saturday
- (NSInteger) dayOfWeek;

// calculates distance from given point to event poi
-(void) fixDistancesFormLocation: (CLLocation *) locsrc asMetric:(BOOL) metric;

// check to see if we have been expired or deleted
-(BOOL) isExpiredOrInvalid;

@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addGalleryObject:(GalleryImage *)value;
- (void)removeGalleryObject:(GalleryImage *)value;
- (void)addGallery:(NSSet *)values;
- (void)removeGallery:(NSSet *)values;

- (void)addReviewsObject:(Review *)value;
- (void)removeReviewsObject:(Review *)value;
- (void)addReviews:(NSSet *)values;
- (void)removeReviews:(NSSet *)values;

@end
