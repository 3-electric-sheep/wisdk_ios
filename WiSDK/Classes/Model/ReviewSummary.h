//
//  ReviewSummary.h
//  dealFlashTest
//
//  Created by Phillp Frantz on 25/02/13.
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

@interface ReviewSummary : NSManagedObject

@property (nonatomic, retain) NSNumber * review_count;
@property (nonatomic, retain) NSNumber * review_points;
@property (nonatomic, retain) NSNumber * average_rating;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) Poi *poi;
@property (nonatomic, retain) NSString * rid;
@end
