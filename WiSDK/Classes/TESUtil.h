//
//  TESUtil.h
//  WISDKdemo
//
//  Created by Phillp Frantz on 12/07/2017.
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

#ifndef TESUtil_h
#define TESUtil_h

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

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

+ (BOOL) atLeastIOS: (NSString *) ver;

///----------------
/// @name Functions
///----------------

/**
 convert a ISO8601 formatted string to a date
 */
extern NSDate * _Nullable TESDateFromISO8601String(NSString  * _Nullable   ISO8601String);

@end;

#endif /* TESUtil_h */
