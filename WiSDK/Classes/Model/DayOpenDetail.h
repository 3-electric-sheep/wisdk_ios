//
//  DayOpenDetail.h
//  dealFlashSeller
//
//  Created by Phillp Frantz on 10/04/13.
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
