//
//  DayOpenDetail.m
//  dealFlashSeller
//
//  Created by Phillp Frantz on 10/04/13.
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

#import "DayOpenDetail.h"

@implementation DayOpenDetail

/**
 returns formatted hrs for day of week.  0=sunday, 1=monday, .. 6=saturday
 **/

+(NSString *) formattedOpenHrsForDay: (NSInteger) dayOfWeek openDetails: (NSArray *) openDetails
{
    
    NSString * day = [DayOpenDetail dayFromNumber:dayOfWeek];
    
    __block NSMutableString *open_times =  [[NSMutableString alloc] initWithCapacity:80];
    
    [openDetails enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DayOpenDetail * t = (DayOpenDetail *)obj;
        if ([t.day isEqualToString:day]){
            if ([t.status isEqualToString:@"open"]){
                if ([open_times length]>0){
                    [open_times appendFormat:@", %@ - %@", t.open, t.close];
                }
                else {
                    [open_times appendFormat:@"%@ %@ - %@", NSLocalizedString(@"OPEN_STATUS", nil), t.open, t.close];
                }
            }
            else {
                [open_times appendString: NSLocalizedString(@"CLOSED_STATUS", nil)];
                *stop = YES;
            }
        }
    }];
    
    if ([open_times length]<1){
        [open_times appendString:NSLocalizedString(@"NO_OPENING_TIMES_PROVIDED", nil)];
    }
    
    return open_times;
}

+(NSDictionary *) toDictFromOpenHrs: (NSArray *) openDetails
{    
    // a dictionary with entries like: 'friday': {'status': 'open', 'times': [{'close': '21:00', 'open': '09:00'}]},
    
    __block NSMutableDictionary * info = [[NSMutableDictionary alloc]init];
    [openDetails enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DayOpenDetail * t = (DayOpenDetail *)obj;
        NSDictionary * infoDay = [info objectForKey:t.day];
        if (infoDay == nil){
            if ([t.status isEqualToString:@"open"]){
                infoDay = @{@"status":t.status, @"times":[[NSMutableArray alloc] initWithObjects:@{@"open":t.open, @"close":t.close}, nil]};
            }
            else {
                infoDay = @{@"status":t.status};
            }
            [info setObject:infoDay forKey:t.day];
        }
        else {
            // only amend if we are open. 
            if ([t.status isEqualToString:@"open"]){
                if ([t.status isEqualToString:[infoDay valueForKey:@"status"]]){
                    NSMutableArray * infoTimes = [infoDay valueForKey:@"times"];
                    [infoTimes addObject:@{@"open":t.open, @"close":t.close}];
                }
                
            }
        }

    }];
    return info;
}

+ (NSInteger) dayOfWeek
{
    // Sunday = 1, Saturday = 7
    NSCalendarUnit units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday;
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDate * today = [NSDate date];
    NSDateComponents *components = [gregorian components:units fromDate:today];
    return components.weekday;
}

// converts a day string to a number 0=sunday, sat=6 (note: this is the day used in the open times field and is not localized)
+ (NSInteger) dayToNumber: (NSString *) dayString
{
    NSArray * _dow = @[@"sunday",@"monday", @"tuesday", @"wednesday", @"thursday", @"friday", @"saturday"];
    return [_dow indexOfObject:[dayString lowercaseString]];
}

/// converts a number to a day string where 0=sunday, sat=6 (note: the day is the value used from the open times field and is not localized)
+ (NSString *) dayFromNumber: (NSInteger) dayOfWeek
{
    NSArray * _dow = @[@"sunday",@"monday", @"tuesday", @"wednesday", @"thursday", @"friday", @"saturday"];
    return _dow[dayOfWeek];
}
@end
