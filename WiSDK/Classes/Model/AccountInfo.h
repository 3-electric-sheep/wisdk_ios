//
//  AccountInfo.h
//  SnapItUpSeller
//
//  Created by Phillp Frantz on 18/07/13.
//  Copyright (c) 2013 Blackdog Software Pty Ltd. All rights reserved.
//

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
