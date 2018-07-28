//
//  Review.m
//  dealFlashTest
//
//  Created by Phillp Frantz on 7/03/13.
//  Copyright © 2012-2018 3 Electric Sheep Pty Ltd. All rights reserved.
//
//  The Welcome Interruption Software Development Kit (SDK) is licensed to you subject to the terms
//  of the License Agreement. The License Agreement forms a legally binding contract between you and
//  3 Electric Sheep Pty Ltd in relation to your use of the Welcome Interruption SDK.
//  You may not use this file except in compliance with the License Agreement.
//
//  A copy of the License Agreement can be found in the LICENSE file in the root directory of this
//  source tree.
//
//  Unless required by applicable law or agreed to in writing, software distributed under the License
//  Agreement is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
//  express or implied. See the License Agreement for the specific language governing permissions
//  and limitations under the License Agreement.

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
