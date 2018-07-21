//
//  TESUtil.h
//  WISDKdemo
//
//  Created by Phillp Frantz on 12/07/2017.
//  Copyright © 2017 3 Electric Sheep Pty Ltd. All rights reserved.
//

#ifndef TESUtil_h
#define TESUtil_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

static BOOL atLeastIOS(NSString * _Nonnull ver) {
    return SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(ver);
}

@interface TESUtil : NSObject
///-----------------------
/// @name utility methods
///----------------------

/**
 converts date to string using ISO date format
 **/
+ (nullable NSDate *) dateFromString: (nullable NSString *) dateString;

/**
 converts string to date using ISO date format
 **/

+ (nullable NSString *) stringFromDate: (nullable NSDate *) date;

/**
 creates a date from components - use -1 for nil in NSInteger fields
 **/
+ (nullable NSDate *) dateFromComponents: (NSInteger) year
                                   month: (NSInteger) month
                                     day: (NSInteger) day
                                    hour: (NSInteger) hour
                                  minute: (NSInteger) minute
                                  second: (NSInteger) second
                                timezone: (nullable NSTimeZone *) timezone;

///----------------
/// @name Functions
///----------------

/**
 convert a ISO8601 formatted string to a date
 */
extern NSDate * _Nullable TESDateFromISO8601String(NSString  * _Nullable   ISO8601String);

@end;

#endif /* TESUtil_h */
