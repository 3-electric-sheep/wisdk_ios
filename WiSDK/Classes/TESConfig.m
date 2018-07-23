//
//  TESConfig.m
//  WISDKdemo
//
//  Created by Phillp Frantz on 21/07/2017.
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

#import "TESConfig.h"


#define LOC_DISTANCE_FILTER  500  // 0.5km between update
#define LOC_DESIRED_ACCURACY kCLLocationAccuracyHundredMeters // 100m good enough
#define LOC_STALE_LOCATION_THRESHOLD 300 // 5*60 - 300 seconds

@implementation TESConfig

#pragma mark - Init

- (nullable instancetype) init
{
    return [self initWithProviderKey:nil];
    
}

- (nullable instancetype) initWithProviderKey: (nullable NSString *) providerKey
{
    self = [super init];
    if (self){
        // system config
        self.providerKey = providerKey;
        self.environment = ENV_PROD;
        self.server = PROD_SERVER;
        self.pushProfile = PROD_PUSH_PROFILE;
        self.testServer = TEST_SERVER;
        self.testPushProfile = TEST_PUSH_PROFILE;
        self.walletOfferClass = WALLET_OFFER_CLASS;
        self.memCacheSize = MEM_CACHE_SIZE;
        self.diskCacheSize = DISK_CACHE_SIZE;
        self.sessionConfig = nil;
        self.debug = NO;

        // location config
        self.requireBackgroundLocation = YES;

        self.useSignficantLocation = YES;
        self.useForegroundMonitoring = YES;
        self.useGeoFences = YES;
        self.useVisitMonitoring = NO;

        self.distacneFilter = LOC_DISTANCE_FILTER;
        self.accuracy = LOC_DESIRED_ACCURACY;
        self.activityType = CLActivityTypeOther;
        self.staleLocationThreshold = LOC_STALE_LOCATION_THRESHOLD;
        self.logLocInfo = NO;

        // auth config
        self.authAutoAuthenticate = NO;
        self.authCredentials = nil;

        //device config
        self.deviceTypes = deviceTypeAPN;

        // geo fence details
        self.geoRadius = GEOFENCE_RADIUS;

        // use system native auth
        self.nativeRequestAuth = NO;

    }
    return self;
}
- (nonnull NSString *) envServer
{
    return ([self.environment isEqualToString:ENV_PROD]) ? self.server : self.testServer;
}

- (nullable NSString *) envPushProfile
{
    return ([self.environment isEqualToString:ENV_PROD]) ? self.pushProfile : self.testPushProfile;
}

-(void) fromDictionary: (NSDictionary *) dict
{
    if (dict[@"providerKey"]) self.providerKey = dict[@"providerKey"];
    if (dict[@"environment"])self.environment = dict[@"environment"];
    if (dict[@"server"])self.server = dict[@"server"];
    if (dict[@"pushProfile"])self.pushProfile = dict[@"pushProfile"];
    if (dict[@"testServer"])self.testServer = dict[@"testServer"];
    if (dict[@"testPushProfile"])self.testPushProfile = dict[@"testPushProfile"];
    if (dict[@"walletOfferClass"])self.walletOfferClass =dict[@"walletOfferClass"];
    if (dict[@"memCacheSize"])self.memCacheSize = (NSUInteger) dict[@"memCacheSize"];
    if (dict[@"diskCacheSize"])self.diskCacheSize = (NSUInteger) dict[@"diskCacheSize"];
    if (dict[@"sessionConfig"])self.sessionConfig = dict[@"sessionConfig"];
    if (dict[@"debug"])self.debug = [dict[@"debug"] boolValue];

    // location config
    if (dict[@"requireBackgroundLocation"])self.requireBackgroundLocation = [dict[@"requireBackgroundLocation"] boolValue];

    if (dict[@"useSignficantLocation"])self.useSignficantLocation = [dict[@"useSignficantLocation"] boolValue];
    if (dict[@"useForegroundMonitoring"])self.useForegroundMonitoring = [dict[@"useForegroundMonitoring"] boolValue];
    if (dict[@"useVisitMonitoring"])self.useVisitMonitoring = [dict[@"useVisitMonitoring"] boolValue];

    if (dict[@"distacneFilter"])self.distacneFilter = [dict[@"distacneFilter"] doubleValue];
    if (dict[@"accuracy"])self.accuracy = [dict[@"accuracy"] intValue];
    if (dict[@"activityType"])self.activityType = (CLActivityType)[dict[@"activityType"] intValue];
    if (dict[@"staleLocationThreshold"])self.staleLocationThreshold = [dict[@"staleLocationThreshold"]intValue];
    if (dict[@"logLocInfo"])self.logLocInfo = [dict[@"logLocInfo"] boolValue];

    // auth config
    if (dict[@"authAutoAuthenticate"])self.authAutoAuthenticate = [dict[@"authAutoAuthenticate"] boolValue];
    if (dict[@"authCredentials"])self.authCredentials = dict[@"authCredentials"];

    //device config
    if (dict[@"deviceTypes"])self.deviceTypes = (DevicePushTargets) [dict[@"deviceTypes"] intValue];

    if (dict[@"useGeoFences"])self.useGeoFences = [dict[@"useGeoFences"] boolValue];
    if (dict[@"geoRadius"])self.geoRadius = [dict[@"geoRadius"] floatValue];

    if (dict[@"nativeRequestAuth"])self.nativeRequestAuth = [dict[@"nativeRequestAuth"] boolValue];
}

@end
