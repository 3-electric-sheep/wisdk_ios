//
//  WiViewController.m
//  WiSDK
//
//  Created by pfrantz on 07/20/2018.
//  Copyright (c) 2012-2018 3 Electric Sheep Pty Ltd All rights reserved.
//

#import "WiViewController.h"
#import "WiSDK/TESWIApp.h"

@interface WiViewController ()

@end

@implementation WiViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

    TESWIApp * app = [TESWIApp manager];

    NSDictionary * params = @{
           /* @"email": @"demo@acme.com",
            @"first_name": @"Demo",
            @"last_name": @"User",
            @"external_id": @"666123666",
            @"program_attr": @{
                    @"name": @"3esCampaignDemo",
                    @"attributes":
                    @{
                         @"Gender": @{@"name": @"Gender", @"value":@"Female"},
                         @"DOB": @{@"name": @"DOB", @"value":@"1964-12-04"}
                    }
            } */


            @"email": @"demo-2@3es.com",
            @"first_name": @"Demo",
            @"last_name": @"User",
            @"external_id": @"666123666",
            @"attributes": @{
                    @"Gender":@"Male",
                    @"DOB": @"1939-12-04"
            }

    };
    [app updateAccountProfile:params onCompletion:^ void (TESCallStatus  status, NSDictionary * _Nullable result) {
        switch (status) {
            case TESCallSuccessOK: {
                NSString *data = [result valueForKey:@"data"];
                NSLog(@"updateAccountProfile Success %@", data);
                break;
            }
            case TESCallSuccessFAIL: {
                NSNumber *code = [result valueForKey:@"code"];
                NSString *msg = [result valueForKey:@"msg"];
                NSLog(@"updateAccountProfile Fail %d %@", code, msg);
                break;
            }
            case TESCallError: {
                NSString *msg = [result valueForKey:@"msg"];
                NSLog(@"updateAccountProfile Network %@", msg);
                break;
            }
        }
    }];

    params = @{

    };

    [app listAlertedEvents:params onCompletion:^ void (TESCallStatus  status, NSDictionary * _Nullable result) {
        switch (status) {
            case TESCallSuccessOK: {
                NSString *data = [result valueForKey:@"data"];
                NSLog(@"ListtAlerted Success %@", data);
                break;
            }
            case TESCallSuccessFAIL: {
                NSNumber *code = [result valueForKey:@"code"];
                NSString *msg = [result valueForKey:@"msg"];
                NSLog(@"ListtAlerted Fail %d %@", code, msg);
                break;
            }
            case TESCallError: {
                NSString *msg = [result valueForKey:@"msg"];
                NSLog(@"ListtAlerted Network %@", msg);
                break;
            }
        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
