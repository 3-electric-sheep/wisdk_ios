//
//  Event.m
//  SnapItUpSeller
//
//  Created by Phillp Frantz on 18/07/13.
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


#import "Event.h"
#import "InfoEvent.h"
#import "Poi.h"
#import "Review.h"
#import "ReviewSummary.h"

#define TYPE_INFO       @"info"

@implementation Event

@dynamic detail;
@dynamic distance;
@dynamic enactable;
@dynamic event_ack;
@dynamic event_enacted;
@dynamic event_enacted_time;
@dynamic event_id;
@dynamic expires;
@dynamic image;
@dynamic image_last_modified;
@dynamic image_media;
@dynamic rid;
@dynamic starts;
@dynamic time_remaining;
@dynamic title;
@dynamic total_ack;
@dynamic total_enacted;
@dynamic total_shares;
@dynamic type;
@dynamic gallery;
@dynamic info_detail;
@dynamic poi;
@dynamic review_summaries;
@dynamic reviews;

- (NSString *) formattedTypeInfo
{
    
    NSString *dealType = self.type;
    NSString *info;

    if ([dealType isEqualToString:TYPE_INFO]){
        if (self.info_detail != nil){
            info = (self.info_detail.further_info && [self.info_detail.further_info length]>0) ? self.info_detail.further_info : NSLocalizedString(@"EVENT_INFORMATION", nil);
        }
    }
    else {
        info = @"";
    }
    
    return info;
    
}


- (NSString *) formattedDistance
{
    NSLocale * locale = [NSLocale currentLocale];
    BOOL  metric = [[locale objectForKey:NSLocaleUsesMetricSystem] boolValue];
    NSString * dist_fmt = NSLocalizedString((metric) ? @"DISTANCE_METRIC":@"DISTANCE_IMPERIAL", nil);
    
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [numberFormatter setMaximumFractionDigits:2];
    
    // TODO:PJF - the assumption is to assume distance is already in the correct units.  Make sure this is TRUE
    NSString * dist = [[NSString alloc] initWithFormat:dist_fmt, [numberFormatter stringFromNumber:self.distance]];
    return dist;
}

- (NSString *) formattedTimeRemaining
{
    int hr = [self.time_remaining intValue] / 3600;
    int min = ([self.time_remaining intValue] - (hr*3600))/60 ;
    int sec = [self.time_remaining intValue] - (hr*3600)-(min*60);
    return [[NSString alloc] initWithFormat:NSLocalizedString(@"EVENT_TIME_REMAINING_FORMAT",nil), hr, min, sec];
}

- (NSString *) formattedTimeToStart
{
    NSTimeInterval timeToStart = [self.starts timeIntervalSinceNow];
    int hr = timeToStart / 3600;
    int min = (timeToStart - (hr*3600))/60 ;
    int sec = timeToStart - (hr*3600)-(min*60);
    return [[NSString alloc] initWithFormat:NSLocalizedString(@"EVENT_TIME_REMAINING_FORMAT",nil), hr, min, sec];
}

- (NSString *) formattedStatus
{
    // check for future start
    NSTimeInterval timeToStart = [self.starts timeIntervalSinceNow];
    if (timeToStart > 0){
        return [NSString stringWithFormat:NSLocalizedString(@"EVENT_TIME_TO_START",nil), [self formattedTimeToStart]];
    }

    if ([self.time_remaining integerValue] <= 0){
        NSDateFormatter * df = [[NSDateFormatter alloc] init];
        [df setDateStyle: NSDateFormatterLongStyle];
        [df setTimeStyle: NSDateFormatterShortStyle];
        return [NSString stringWithFormat:NSLocalizedString(@"EVENT_TIME_FINISED",nil), [df stringFromDate:self.expires]];
    }
    
    return [NSString stringWithFormat:NSLocalizedString(@"EVENT_EXPIRES_IN", nil),  [self formattedTimeRemaining]];
    
}

- (NSString *) formattedReviewCount
{
    long review_count = 0;
    if (self.review_summaries){
        review_count = [self.review_summaries.review_count integerValue];
    }
    
    NSString * lbl;
    if (review_count == 0){
        lbl = NSLocalizedString(@"NO_REVIEW_SUMMARY", nil);
    }
    else{
        if (review_count == 1)
            lbl = NSLocalizedString(@"ONE_REVIEW_SUMMARY", nil);
        else
            lbl = [[NSString alloc] initWithFormat:NSLocalizedString(@"REVIEW_SUMMARY", nil), review_count];
    }
    return lbl;
}


- (double) starRating;
{
    double rating = 0.0;
    if (self.review_summaries){
        rating = 5.0 * ([self.review_summaries.average_rating doubleValue]/100.0); // ratings are stored from 0 - 100
    }
    
    return rating;
    
}

- (NSInteger) dayOfWeek
{
    // TODO : pjf - fix return [TESApi dayOfWeek];
    return 0;
}

-(void) fixDistancesFormLocation: (CLLocation *) locsrc asMetric:(BOOL) metric
{
    CLLocation *loctgt = [[CLLocation alloc] initWithLatitude:[self.poi.latitude doubleValue] longitude:[self.poi.longitude doubleValue]];
    CLLocationDistance dist = [locsrc distanceFromLocation:loctgt];
    if (metric){
        dist = dist / 1000.0; // convert mtrs to km
    }
    else {
        dist = dist / 1609.34; // convert mtrs to miles
    }
    NSLog(@"src %f,%f  tgt %f,%f dist:%f", locsrc.coordinate.longitude, locsrc.coordinate.latitude, loctgt.coordinate.longitude, loctgt.coordinate.latitude, dist);
    self.distance = [NSNumber numberWithDouble:dist];
}

-(BOOL) isExpiredOrInvalid
{
    return (self.managedObjectContext == nil || self.isDeleted || [self.time_remaining integerValue]<1);
}
@end
