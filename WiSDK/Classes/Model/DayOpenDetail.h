//
//  DayOpenDetail.h
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
