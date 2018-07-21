//
//  Provider.m
//  SnapItUpSeller
//
//  Created by Phillp Frantz on 18/07/13.
//  Copyright (c) 2013 Blackdog Software Pty Ltd. All rights reserved.
//

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
