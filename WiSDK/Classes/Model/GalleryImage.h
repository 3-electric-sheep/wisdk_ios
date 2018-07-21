//
//  GalleryImage.h
//  dealFlashSeller
//
//  Created by Phillp Frantz on 22/04/13.
//  Copyright (c) 2013 Blackdog Software Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface GalleryImage : NSManagedObject

@property (nonatomic, retain) NSString * rid;
@property (nonatomic, retain) NSString * image;
@property (nonatomic, retain) NSData * image_media;
@property (nonatomic, retain) NSDate * image_last_modified;
@property (nonatomic, retain) Event *event;

@end
