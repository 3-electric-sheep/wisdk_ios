//
//  AccountInfo.h
//  SnapItUpSeller
//
//  Created by Phillp Frantz on 18/07/13.
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
#import <CoreData/CoreData.h>

@class Provider;

@interface AccountInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * alerts_sent;
@property (nonatomic, retain) NSString * current_plan;
@property (nonatomic, retain) NSDate * current_plan_expiry_date;
@property (nonatomic, retain) NSString * current_plan_product_id;
@property (nonatomic, retain) NSNumber * event_ack;
@property (nonatomic, retain) NSDate * event_credit_expiry_date;
@property (nonatomic, retain) NSNumber * event_credits;
@property (nonatomic, retain) NSNumber * event_credits_noexp;
@property (nonatomic, retain) NSNumber * event_enacted;
@property (nonatomic, retain) NSNumber * events_sent;
@property (nonatomic, retain) NSDate * last_credit_date;
@property (nonatomic, retain) NSString * last_credit_receipt;
@property (nonatomic, retain) NSString * rid;
@property (nonatomic, retain) NSNumber * events_shared;
@property (nonatomic, retain) Provider *provider;

- (NSNumber *) totalCredits;

@end
