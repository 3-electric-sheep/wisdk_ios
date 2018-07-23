//
//  LocationInfo.h
//  Location
//
//  Created by Phillp Frantz on 8/11/12.
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
#import <CoreLocation/CoreLocation.h>


@interface LocationInfo : NSObject

@property (nonnull, nonatomic, strong) NSNumber * longitude;
@property (nonnull,nonatomic, strong) NSNumber * latitude;
@property (nullable, nonatomic, strong) NSNumber * accuracy;
@property (nullable, nonatomic, strong) NSNumber * speed;
@property (nullable, nonatomic, strong) NSNumber * course;
@property (nonnull,nonatomic, strong) NSDate * fix_timestamp;
@property (nonnull,nonatomic, strong) NSNumber * inBackground;
@property (nullable, nonatomic, strong) NSDate * arrival;
@property (nullable, nonatomic, strong) NSDate * departure;
@property (nullable, nonatomic, strong) NSNumber * didEnter;
@property (nullable, nonatomic, strong) NSNumber * didExit;
@property (nullable, nonatomic, strong) NSString * regionIdentifier;
@property (nullable, nonatomic, strong) NSNumber * altitude;


- (nullable instancetype) initWithLocation: (nonnull CLLocation *) loc andBackgroundMode: (BOOL) inBackground;
- (nullable instancetype) initWithVisit: (nonnull CLVisit *) visit andBackgroundMode: (BOOL) inBackground;
- (nullable instancetype) initWithAttributes:(nonnull NSDictionary *)attributes;

+ (nonnull LocationInfo *) CreateEmptyLocation;

- (nullable instancetype)initWithRegion:(nonnull CLRegion *)region andLocation:(nullable CLLocation *)location andState:(CLRegionState)state andBackgroundMode:(BOOL)mode;

- (nonnull NSMutableDictionary *) toDictionary;

@end
