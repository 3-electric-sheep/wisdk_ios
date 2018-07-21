//
//  Contact.h
//  dealFlashTest
//
//  Created by Phillp Frantz on 23/02/13.
//  Copyright (c) 2013 Blackdog Software Pty Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Poi;

@interface Contact : NSManagedObject

@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) Poi *poi;
@property (nonatomic, retain) NSString * rid;
@end
