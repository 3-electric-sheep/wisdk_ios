//
//  LocationInfo.h
//  Location
//
//  Created by Phillp Frantz on 8/11/12.
//  Copyright (c) 2012-2017 3 Electric Sheep Pty Ltd. All rights reserved.
//

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
