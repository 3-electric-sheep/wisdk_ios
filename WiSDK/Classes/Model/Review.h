//
//  Review.h
//  dealFlashTest
//
//  Created by Phillp Frantz on 7/03/13.
//  Copyright © 2012-2018 3 Electric Sheep Pty Ltd. All rights reserved.
//
//  The Welcome Interruption Software Development Kit (SDK) is licensed to you subject to the terms
//  of the License Agreement. The License Agreement forms a legally binding contract between you and
//  3 Electric Sheep Pty Ltd in relation to your use of the Welcome Interruption SDK.
//  You may not use this file except in compliance with the License Agreement.
//
//  A copy of the License Agreement can be found in the LICENSE file in the root directory of this
//  source tree.
//
//  Unless required by applicable law or agreed to in writing, software distributed under the License
//  Agreement is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either
//  express or implied. See the License Agreement for the specific language governing permissions
//  and limitations under the License Agreement.
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
