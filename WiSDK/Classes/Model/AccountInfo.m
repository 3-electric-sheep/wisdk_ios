//
//  AccountInfo.m
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

#import "AccountInfo.h"


@implementation AccountInfo

@dynamic alerts_sent;
@dynamic current_plan;
@dynamic current_plan_expiry_date;
@dynamic current_plan_product_id;
@dynamic event_ack;
@dynamic event_credit_expiry_date;
@dynamic event_credits;
@dynamic event_credits_noexp;
@dynamic event_enacted;
@dynamic events_sent;
@dynamic last_credit_date;
@dynamic last_credit_receipt;
@dynamic rid;
@dynamic events_shared;
@dynamic provider;

- (NSNumber *) totalCredits;
{
    return [NSNumber numberWithInteger:[self.event_credits integerValue]+[self.event_credits_noexp integerValue]];
}
@end
