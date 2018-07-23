//
//  Review.h
//  dealFlashTest
//
//  Created by Phillp Frantz on 7/03/13.
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
#import <CoreData/CoreData.h>

@class Event, Poi;

@interface Review : NSManagedObject

@property (nonatomic, retain) NSString * comment;
@property (nonatomic, retain) NSString * event_id;
@property (nonatomic, retain) NSDate * last_update;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * poi_id;
@property (nonatomic, retain) NSNumber * rating;
@property (nonatomic, retain) NSString * rid;
@property (nonatomic, retain) NSNumber * editable;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) Poi *poi;

- (double) starRating;
- (NSString * ) formatReviewer;
- (NSString *) formatLastUpdate;
@end
