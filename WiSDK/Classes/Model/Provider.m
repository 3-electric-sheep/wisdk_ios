//
//  Provider.m
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
#import "Provider.h"
#import "AccountInfo.h"
#import "Poi.h"
#import "ReviewSummary.h"
#import "SystemConfig.h"


@implementation Provider

@dynamic live_events;
@dynamic live_events_ack;
@dynamic live_events_alerted;
@dynamic live_events_enacted;
@dynamic live_events_shared;
@dynamic logo;
@dynamic logo_last_modified;
@dynamic logo_media;
@dynamic loyalty_card_id;
@dynamic loyalty_card_name;
@dynamic monthly_events;
@dynamic monthly_events_ack;
@dynamic monthly_events_alerted;
@dynamic monthly_events_enacted;
@dynamic monthly_events_shared;
@dynamic name;
@dynamic rid;
@dynamic account_info;
@dynamic poi;
@dynamic review_summaries;
@dynamic system_config;

- (NSArray *) placeListBy: (NSString *) field ascending: (BOOL) ascending
{
    NSArray * sortOrder = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:field ascending:ascending]];
    NSArray * orderedPlaces = [self.poi sortedArrayUsingDescriptors:sortOrder];
    return orderedPlaces;
}

- (NSSet *) purchasedProducts
{
    NSSet * purchased;
    if (self.account_info.current_plan_product_id != nil && [self.account_info.current_plan_product_id length]>0){
        purchased = [[NSSet alloc] initWithArray:@[self.account_info.current_plan_product_id]];
    }
    else {
        purchased = [[NSSet alloc] init];
    }
    return purchased;
}

- (id) getConfigValue: (NSString *) key defaultVal: (id) defaultVal
{
    __block id retVal = defaultVal;
    [self.system_config enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        SystemConfig * cfg = obj;
        if ([cfg.name isEqualToString:key]){
            if ([cfg.type isEqualToString:@"number"]){
                NSNumberFormatter * nf = [[NSNumberFormatter alloc] init];
                retVal = [nf numberFromString:cfg.value];
            }
            else {
                retVal = cfg.value;            
            }
            *stop = YES;
        }
    }];
    return retVal;
}
@end
