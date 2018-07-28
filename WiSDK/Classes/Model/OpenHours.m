//
//  OpenHours.m
//  dealFlashTest
//
//  Created by Phillp Frantz on 23/02/13.
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
#import "OpenHours.h"
#import "OpenTimes.h"
#import "Poi.h"

@implementation OpenHours

@dynamic day;
@dynamic status;
@dynamic times;
@dynamic poi;
@dynamic rid;

-(NSString *) formattedOpenHrs
{
    NSString * hrs;
    __block NSMutableString *open_times;
    NSString * status = ([self.status isEqualToString:@"open"]) ? NSLocalizedString(@"OPEN_STATUS", nil) :  NSLocalizedString(@"CLOSED_STATUS", nil);
    
    [self.times enumerateObjectsUsingBlock: ^(id obj, BOOL *stop) {
        OpenTimes * t = (OpenTimes *)obj;
        if (open_times == nil){
            open_times = [[NSMutableString alloc] initWithFormat:@"%@ - %@", t.open, t.close];
        }
        else {
            [open_times appendFormat:@", %@ - %@", t.open, t.close];
        }
    }];
    
    if (open_times != nil){
        hrs = [[NSString alloc] initWithFormat:@"%@ %@", status, open_times ];
    }
    else {
        hrs = [status copy];
    }
    return hrs;
}


@end
