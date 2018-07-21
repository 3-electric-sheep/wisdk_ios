//
//  OpenHours.m
//  dealFlashTest
//
//  Created by Phillp Frantz on 23/02/13.
//  Copyright (c) 2013 Blackdog Software Pty Ltd. All rights reserved.
//

#import "OpenHours.h"
#import "OpenTimes.h"
#import "Poi.h"

@implementation OpenHours

@dynamic day;
@dynamic status;
@dynamic times;
@dynamic poi;
@dynamic rid;

-(NSString *) formattedOpenHrs
{
    NSString * hrs;
    __block NSMutableString *open_times;
    NSString * status = ([self.status isEqualToString:@"open"]) ? NSLocalizedString(@"OPEN_STATUS", nil) :  NSLocalizedString(@"CLOSED_STATUS", nil);
    
    [self.times enumerateObjectsUsingBlock: ^(id obj, BOOL *stop) {
        OpenTimes * t = (OpenTimes *)obj;
        if (open_times == nil){
            open_times = [[NSMutableString alloc] initWithFormat:@"%@ - %@", t.open, t.close];
        }
        else {
            [open_times appendFormat:@", %@ - %@", t.open, t.close];
        }
    }];
    
    if (open_times != nil){
        hrs = [[NSString alloc] initWithFormat:@"%@ %@", status, open_times ];
    }
    else {
        hrs = [status copy];
    }
    return hrs;
}


@end
