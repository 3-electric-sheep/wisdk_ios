//
//  Poi.h
//  dealFlashTest
//
//  Created by Phillp Frantz on 23/02/13.
//  Copyright © 2012-2018 3 Electric Sheep Pty Ltd. All rights reserved.
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define TYPE_URL     @"url"    //   Website address
#define TYPE_MOBILE  @"mobile" //   Mobile phone number
#define TYPE_PHONE   @"phone"  //   Phone number
#define TYPE_FAX     @"fax"    //  FAX number
#define TYPE_EMAIL   @"email"  //  Email address

@class Contact, Event, OpenHours, ReviewSummary;

@interface Poi : NSManagedObject
{
    UIImage * _defaultImage;
}

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * logo;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * postal_code;
@property (nonatomic, retain) NSString * rid;
@property (nonatomic, retain) NSString * state;
@property (nonatomic, retain) NSString * suburb;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * provider_id;
@property (nonatomic, retain) NSSet *event;
@property (nonatomic, retain) NSSet *contacts;
@property (nonatomic, retain) NSSet *opening_hours;
@property (nonatomic, retain) ReviewSummary *review_summaries;
@property (nonatomic, retain) NSSet *reviews;
@property (nonatomic, retain) NSData * logo_media;
@property (nonatomic, retain) NSDate * logo_last_modified;
@end

@interface Poi (CoreDataGeneratedAccessors)

- (void)addEventObject:(Event *)value;
- (void)removeEventObject:(Event *)value;
- (void)addEvent:(NSSet *)values;
- (void)removeEvent:(NSSet *)values;

- (void)addContactsObject:(Contact *)value;
- (void)removeContactsObject:(Contact *)value;
- (void)addContacts:(NSSet *)values;
- (void)removeContacts:(NSSet *)values;

- (void)addOpening_hoursObject:(OpenHours *)value;
- (void)removeOpening_hoursObject:(OpenHours *)value;
- (void)addOpening_hours:(NSSet *)values;
- (void)removeOpening_hours:(NSSet *)values;

- (void)addReviewsObject:(NSManagedObject *)value;
- (void)removeReviewsObject:(NSManagedObject *)value;
- (void)addReviews:(NSSet *)values;
- (void)removeReviews:(NSSet *)values;

// find functions
- (NSString *) findContactForType: (NSString *) type;

// formatter functions
- (NSString *) formattedAddress;
- (NSString *) formattedContacts;
- (NSString *) formattedOpeningHrs: (NSInteger) dayOfWeek;

- (NSString *) formattedReviewCount;
- (double) starRating;

// conversion functions
-(NSArray *) toDayOpenDetail;
-(void) fromDayOpenDetail: (NSArray *) dayDetails;

// image retrieval from server but use the given image name if not found
- (void) setLogoForImageView: (UIImageView *) imageView placeholder: (NSString *) placeholder onceOnly: (BOOL) onceOnly completion:(void (^)(UIImage * image)) completionBlock;

// image retrieval but use the default image if not found
- (void) setLogoForImageView: (UIImageView *) imageView onceOnly: (BOOL) onceOnly completion:(void (^)(UIImage * image)) completionBlock;

- (UIImage *) defaultImage: (CGSize) size usingColor: (UIColor *) usingColor;

@end
