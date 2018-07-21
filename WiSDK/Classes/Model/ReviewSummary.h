//
//  ReviewSummary.h
//  dealFlashTest
//
//  Created by Phillp Frantz on 25/02/13.
//  Copyright (c) 2013 Blackdog Software Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event, Poi;

@interface ReviewSummary : NSManagedObject

@property (nonatomic, retain) NSNumber * review_count;
@property (nonatomic, retain) NSNumber * review_points;
@property (nonatomic, retain) NSNumber * average_rating;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) Poi *poi;
@property (nonatomic, retain) NSString * rid;
@end
