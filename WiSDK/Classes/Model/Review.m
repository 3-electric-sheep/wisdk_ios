//
//  Review.m
//  dealFlashTest
//
//  Created by Phillp Frantz on 7/03/13.
//  Copyright (c) 2013 Blackdog Software Pty Ltd. All rights reserved.
//

#import "Review.h"
#import "Event.h"
#import "Poi.h"


@implementation Review

@dynamic comment;
@dynamic event_id;
@dynamic last_update;
@dynamic nickname;
@dynamic poi_id;
@dynamic rating;
@dynamic rid;
@dynamic editable;
@dynamic event;
@dynamic poi;

- (double) starRating;
{
    double rating = 5.0 * ([self.rating doubleValue]/100.0); // ratings are stored from 0 - 100
    return rating;
    
}

- (NSString * ) formatReviewer
{
    NSString * reviewer;
    if ([self.editable boolValue]){
        reviewer =  (self.nickname) ? self.nickname : NSLocalizedString(@"REVIEWER_MY_REVIEW", nil);
    }
    else {
        reviewer = (self.nickname) ? self.nickname : NSLocalizedString(@"REVIEWER_NAME_DEFAULT", nil);
    }
    
    return reviewer;
}

- (NSString *) formatLastUpdate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setTimeStyle:NSDateFormatterNoStyle];
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];
    return [dateFormatter stringFromDate: self.last_update];
}
@end
