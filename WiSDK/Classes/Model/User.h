//
//  User.h
//  SnapItUp
//
//  Created by Phillp Frantz on 22/05/13.
//  Copyright (c) 2013 Blackdog Software Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * first_name;
@property (nonatomic, retain) NSString * full_name;
@property (nonatomic, retain) NSString * last_name;
@property (nonatomic, retain) NSString * profile_image;
@property (nonatomic, retain) NSDate * profile_image_last_modified;
@property (nonatomic, retain) NSData * profile_image_media;
@property (nonatomic, retain) NSString * rid;
@property (nonatomic, retain) NSString * user_name;
@property (nonatomic, retain) NSString * locale;
@property (nonatomic, retain) NSString * timezone_offset;
@property (nonatomic, retain) NSString * email;

@end
