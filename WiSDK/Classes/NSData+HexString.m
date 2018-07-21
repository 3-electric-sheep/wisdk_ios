//
//  NSData+HexString.m
//  dealFlashTest
//
//  Created by Phillp Frantz on 26/02/13.
//  Copyright © 2013-2017 3 Electric Sheep Pty Ltd. All rights reserved.
//

#import "NSData+HexString.h"

@implementation NSData (HexString)
-(NSString*)hexRepresentation
{
    const unsigned char* bytes = (const unsigned char*)[self bytes];
    NSUInteger nbBytes = [self length];


    NSUInteger strLen = 2*nbBytes;
    
    NSMutableString* hex = [[NSMutableString alloc] initWithCapacity:strLen];
    for(NSUInteger i=0; i<nbBytes; i++) {
        [hex appendFormat:@"%02x", bytes[i]];
    }
    return hex;
}
@end
