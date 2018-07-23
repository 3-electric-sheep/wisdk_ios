//
//  Poi.m
//  dealFlashTest
//
//  Created by Phillp Frantz on 23/02/13.
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

#import "Poi.h"
#import "Contact.h"
#import "Event.h"
#import "OpenHours.h"
#import "OpenTimes.h"
#import "ReviewSummary.h"

#import "DayOpenDetail.h"


@implementation Poi

@dynamic address;
@dynamic latitude;
@dynamic logo;
@dynamic longitude;
@dynamic name;
@dynamic postal_code;
@dynamic rid;
@dynamic state;
@dynamic suburb;
@dynamic type;
@dynamic provider_id;
@dynamic event;
@dynamic contacts;
@dynamic opening_hours;
@dynamic review_summaries;
@dynamic reviews;
@dynamic logo_media;
@dynamic logo_last_modified;



- (NSString *) findContactForType: (NSString *) type
{
    if (!self.contacts || [self.contacts count]< 1){
        return nil;
    }
    
    __block NSString * value = nil;
    [self.contacts enumerateObjectsUsingBlock: ^(id obj, BOOL *stop) {
        Contact * contact = (Contact *)obj;
        if ([contact.type isEqualToString:type]){
            value = contact.value;
            *stop = YES;
        }
    }];
    return value;
}

- (NSString *) formattedContacts
{
    if (!self.contacts || [self.contacts count]< 1){
        return NSLocalizedString(@"NO_CONTACTS_AVAILABLE", nil);
    }
    
    NSMutableArray *contacts = [[NSMutableArray alloc] initWithCapacity:[self.contacts count]];
    
    __block NSMutableString *phone;
    __block NSMutableString *fax;
    __block NSMutableString *mobile;
    __block NSMutableString *email;
    __block NSMutableString *web;
    __block NSMutableString *other;
    
    [self.contacts enumerateObjectsUsingBlock: ^(id obj, BOOL *stop) {
        Contact * contact = (Contact *)obj;
        if ([contact.type isEqualToString:TYPE_PHONE]){
            if (phone == nil){
                phone = [[NSMutableString alloc] initWithFormat:NSLocalizedString(@"CONTACT_PHONE", nil), contact.value];
            }
            else {
                [phone appendFormat:@", %@", contact.value];
            }
            
        }      
        else if ([contact.type isEqualToString:TYPE_MOBILE]){
            if (mobile == nil){
                mobile = [[NSMutableString alloc] initWithFormat:NSLocalizedString(@"CONTACT_MOBILE", nil),contact.value];
            }
            else {
                [mobile appendFormat:@", %@", contact.value];
            }
        }
        else if ([contact.type isEqualToString:TYPE_FAX]){
            if (fax == nil){
                fax = [[NSMutableString alloc] initWithFormat:NSLocalizedString(@"CONTACT_FAX", nil),contact.value];
            }
            else {
                [fax appendFormat:@", %@", contact.value];
            }
        }
        else if ([contact.type isEqualToString:TYPE_EMAIL]){
            if (email == nil){
                email = [[NSMutableString alloc] initWithFormat:NSLocalizedString(@"CONTACT_EMAIL", nil),contact.value];
            }
            else {
                [email appendFormat:@", %@", contact.value];
            }
        }
        else if ([contact.type isEqualToString:TYPE_URL]){
            if (web == nil){
                web = [[NSMutableString alloc] initWithFormat:NSLocalizedString(@"CONTACT_WEB", nil), contact.value];
            }
            else {
                [web appendFormat:@", %@", contact.value];
            }
        }
        else {
            if (other == nil){
                other = [[NSMutableString alloc] initWithFormat:NSLocalizedString(@"CONTACT_OTHER", nil), contact.value];
            }
            else {
                [other appendFormat:@", %@", contact.value];
            }
        }
        
    }];
    
    if (phone != nil)
        [contacts addObject:phone];
    if (mobile != nil)
        [contacts addObject:mobile];
    if (fax != nil)
        [contacts addObject:fax];
    if (email != nil)
        [contacts addObject:email];
    if (web != nil)
        [contacts addObject:web];
    if (other != nil)
        [contacts addObject:other];
    
    if ([contacts count]<1)
        return @"";
    
    return [contacts componentsJoinedByString:@"\n"];
}

- (NSString *) formattedOpeningHrs: (NSInteger) dayOfWeek
{
    NSArray * dow = @[@"sunday", @"monday", @"tuesday", @"wednesday", @"thursday", @"friday", @"saturday"];
    __block NSString * dayKey = dow[dayOfWeek-1];
    __block NSString * info = NSLocalizedString(@"NO_OPENING_TIMES_PROVIDED", nil);
    [self.opening_hours enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        OpenHours * openHrs = (OpenHours *)obj;
        if ([openHrs.day isEqualToString:dayKey]){
            info =[openHrs formattedOpenHrs];
            *stop=YES;
        }
    }];
    
   return info;
}

- (NSString *) formattedReviewCount
{
    long review_count = 0;
    if (self.review_summaries){
        review_count = [self.review_summaries.review_count integerValue];
    }
    
    NSString * lbl;
    if (review_count == 0){
        lbl = NSLocalizedString(@"NO_REVIEW_SUMMARY", nil);
    }
    else{
        if (review_count == 1)
            lbl = NSLocalizedString(@"ONE_REVIEW_SUMMARY", nil);
        else
            lbl = [[NSString alloc] initWithFormat:NSLocalizedString(@"REVIEW_SUMMARY", nil), review_count];
    }
    return lbl;
}


- (double) starRating;
{
    double rating = 0.0;
    if (self.review_summaries){
        rating = 5.0 * ([self.review_summaries.average_rating doubleValue]/100.0); // ratings are stored from 0 - 100
    }
    
    return rating;
    
}


-(NSArray *) toDayOpenDetail
{
    NSMutableArray * days = [[NSMutableArray alloc]initWithCapacity:[self.opening_hours count]];
    [self.opening_hours enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        OpenHours * oh = obj;

        if ([oh.status isEqualToString:@"closed"]){
           DayOpenDetail * newDay = [[DayOpenDetail alloc] init];
            newDay.day = oh.day;
            newDay.status = oh.status;
            newDay.open = nil;
            newDay.close = nil;
            [days addObject:newDay];
        }
        else if (oh.times != nil && [oh.times count]>0){
            [oh.times enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
                OpenTimes * tm = obj;
                DayOpenDetail * newDay = [[DayOpenDetail alloc] init];
                newDay.day = oh.day;
                newDay.status = oh.status;
                newDay.open = tm.open;
                newDay.close = tm.close;
                [days addObject:newDay];
            }];
        }
        
    }];
    return days;
}

-(void) fromDayOpenDetail: (NSArray *) dayDetails
{
    
    NSMutableSet * openHrs = [[NSMutableSet alloc] init];
    [dayDetails enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        DayOpenDetail * day = obj;

        OpenHours * hrs = [self findDay:day.day inSet:openHrs];
        if (hrs == nil){
            hrs = [NSEntityDescription insertNewObjectForEntityForName:@"OpenHours" inManagedObjectContext:self.managedObjectContext];
            hrs.day = day.day;
            hrs.status = day.status;
            [openHrs addObject:hrs];
        }
        if (day.open != nil && day.close != nil ){
            if (![hrs.status isEqualToString:@"open"])
                hrs.status = @"open";
            
            OpenTimes * tm =[NSEntityDescription insertNewObjectForEntityForName:@"OpenTimes" inManagedObjectContext:self.managedObjectContext];
            tm.open = day.open;
            tm.close = day.close;
            [hrs addTimesObject:tm];
        }  
    }];
    [self addOpening_hours:openHrs];
}

- (OpenHours *) findDay: (NSString*)  dow  inSet:(NSSet *) openHrs
{
    __block OpenHours * fndHrs = nil;
    [openHrs enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        OpenHours * curr = obj;
        if ([dow isEqualToString:curr.day]){
            fndHrs = curr;
            *stop = YES;
        }
    }];
    return fndHrs;
}


@end
