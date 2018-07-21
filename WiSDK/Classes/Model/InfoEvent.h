//
//  InfoEvent.h
//  dealFlashTest
//
//  Created by Phillp Frantz on 23/02/13.
//  Copyright (c) 2013 Blackdog Software Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface InfoEvent : NSManagedObject

@property (nonatomic, retain) NSString * priority;
@property (nonatomic, retain) NSString * further_info;
@property (nonatomic, retain) Event *event;
@property (nonatomic, retain) NSString * rid;
@end
