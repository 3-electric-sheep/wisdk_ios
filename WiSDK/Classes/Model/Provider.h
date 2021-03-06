//
//  Provider.h
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class AccountInfo, Poi, ReviewSummary, SystemConfig;

@interface Provider : NSManagedObject

@property (nonatomic, retain) NSNumber * live_events;
@property (nonatomic, retain) NSNumber * live_events_ack;
@property (nonatomic, retain) NSNumber * live_events_alerted;
@property (nonatomic, retain) NSNumber * live_events_enacted;
@property (nonatomic, retain) NSNumber * live_events_shared;
@property (nonatomic, retain) NSString * logo;
@property (nonatomic, retain) NSDate * logo_last_modified;
@property (nonatomic, retain) NSData * logo_media;
@property (nonatomic, retain) NSString * loyalty_card_id;
@property (nonatomic, retain) NSString * loyalty_card_name;
@property (nonatomic, retain) NSNumber * monthly_events;
@property (nonatomic, retain) NSNumber * monthly_events_ack;
@property (nonatomic, retain) NSNumber * monthly_events_alerted;
@property (nonatomic, retain) NSNumber * monthly_events_enacted;
@property (nonatomic, retain) NSNumber * monthly_events_shared;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * rid;
@property (nonatomic, retain) AccountInfo *account_info;
@property (nonatomic, retain) NSSet *poi;
@property (nonatomic, retain) ReviewSummary *review_summaries;
@property (nonatomic, retain) NSSet *system_config;

- (NSArray *) placeListBy: (NSString *) field ascending: (BOOL) ascending;
- (NSSet *) purchasedProducts;

- (id) getConfigValue: (NSString *) key defaultVal: (id) defaultVal;

@end

@interface Provider (CoreDataGeneratedAccessors)

- (void)addPoiObject:(Poi *)value;
- (void)removePoiObject:(Poi *)value;
- (void)addPoi:(NSSet *)values;
- (void)removePoi:(NSSet *)values;

- (void)addSystem_configObject:(SystemConfig *)value;
- (void)removeSystem_configObject:(SystemConfig *)value;
- (void)addSystem_config:(NSSet *)values;
- (void)removeSystem_config:(NSSet *)values;

@end
