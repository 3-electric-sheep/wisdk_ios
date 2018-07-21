//
//  AccountInfo.m
//  SnapItUpSeller
//
//  Created by Phillp Frantz on 18/07/13.
//  Copyright (c) 2013 Blackdog Software Pty Ltd. All rights reserved.
//

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
