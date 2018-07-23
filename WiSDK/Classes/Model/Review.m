//
//  Review.m
//  dealFlashTest
//
//  Created by Phillp Frantz on 7/03/13.
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
