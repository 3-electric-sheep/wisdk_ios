//
//  AccountInfo.m
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
