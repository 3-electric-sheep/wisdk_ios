//
//  DayOpenDetail.h
//  dealFlashSeller
//
//  Created by Phillp Frantz on 10/04/13.
//  Copyright (c) 2013 Blackdog Software Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DayOpenDetail : NSObject

@property (nonatomic, retain) NSString * day;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * open;
@property (nonatomic, retain) NSString * close;

/**
 returns formatted hrs for day of week.  0=sunday, 1=monday, .. 6=saturday
 **/

+(NSString *) formattedOpenHrsForDay: (NSInteger) dayOfWeek openDetails: (NSArray *) openDetails;

/**
 returns opening times as a dictionary compatible with the server api
**/

+(NSDictionary *) toDictFromOpenHrs: (NSArray *) openDetails;
@end
