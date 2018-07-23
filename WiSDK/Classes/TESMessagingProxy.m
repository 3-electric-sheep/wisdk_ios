//
// Created by Phillp Frantz on 8/08/2017.
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

#import "TESMessagingProxy.h"
#import <objc/runtime.h>
#import "WiSDK/TESWIApp.h"

@interface  TESMessagingProxy ()

@property(nonatomic) BOOL didSwizzleMethods;

@property(strong, nonatomic) NSMutableDictionary<NSString *, NSValue *> *originalAppDelegateImps;
@property(strong, nonatomic) NSMutableDictionary<NSString *, NSArray *> *swizzledSelectorsByClass;

@end


@implementation TESMessagingProxy

+ (instancetype) sharedProxy {
    static TESMessagingProxy *proxy;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        proxy = [[TESMessagingProxy alloc] init];
    });
    return proxy;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _originalAppDelegateImps = [[NSMutableDictionary alloc] init];
    }
    return self;
}


+ (void)swizzleMethods {
    [[TESMessagingProxy sharedProxy] swizzleMethodsIfPossible];
}

- (void)swizzleMethodsIfPossible {
    if (self.didSwizzleMethods) {
        return;
    }

    NSObject<UIApplicationDelegate> *appDelegate = [[UIApplication sharedApplication] delegate];
    Class appDelegateClass = [appDelegate class];

    [self _swizzle:appDelegateClass method:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:) with: @selector(_wisdk_application:didRegisterForRemoteNotificationsWithDeviceToken:)];
    [self _swizzle:appDelegateClass method:@selector(application:didFailToRegisterForRemoteNotificationsWithError:) with: @selector(_wisdk_application:didFailToRegisterForRemoteNotificationsWithError:)];
    [self _swizzle:appDelegateClass method:@selector(application:didReceiveRemoteNotification:) with: @selector(_wisdk_application:didReceiveRemoteNotification:)];

    self.didSwizzleMethods = YES;
}

- (void)saveOriginalImplementation:(IMP)imp forSelector:(SEL)selector {
    if (imp && selector) {
        NSValue *IMPValue = [NSValue valueWithPointer:imp];
        NSString *selectorString = NSStringFromSelector(selector);
        self.originalAppDelegateImps[selectorString] = IMPValue;
    }
}

- (IMP)originalImplementationForSelector:(SEL)selector {
    NSString *selectorString = NSStringFromSelector(selector);
    NSValue *implementation_value = self.originalAppDelegateImps[selectorString];
    if (!implementation_value) {
        return nil;
    }

    IMP imp;
    [implementation_value getValue:&imp];
    return imp;
}

- (void)_swizzle: (Class) kls method: (SEL) originalSelector with: (SEL) swizzledSelector
{
    Method originalMethod = class_getInstanceMethod(kls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod([self class], swizzledSelector);


    if (originalMethod && originalMethod != swizzledMethod) {
        IMP __swizzle_method_implementation = method_getImplementation(swizzledMethod);
        IMP __original_method_implementation = method_setImplementation(originalMethod, __swizzle_method_implementation);
        [self saveOriginalImplementation:__original_method_implementation forSelector:originalSelector];
    }
    else {

        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        // ...
        // Method originalMethod = class_getClassMethod(class, originalSelector);
        // Method swizzledMethod = class_getClassMethod(class, swizzledSelector);

        BOOL didAddMethod =
                class_addMethod(kls,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));

        if (didAddMethod) {
            class_replaceMethod(kls,
                    swizzledSelector,
                    method_getImplementation(originalMethod),
                    method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    }
}

#pragma mark - Method Swizzling


- (void)_wisdk_application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {;
    TESWIApp * app = [TESWIApp manager];
    [app registerRemoteNotificationToken:deviceToken];

    SEL _sel = @selector(application:didRegisterForRemoteNotificationsWithDeviceToken:);
    IMP original_imp = [[TESMessagingProxy sharedProxy] originalImplementationForSelector:_sel];
    if (original_imp) {
        NSObject<UIApplicationDelegate> *appDelegate = [[UIApplication sharedApplication] delegate];
        ((void (*)(id, SEL, UIApplication *, NSData *))original_imp)(appDelegate, _sel, application, deviceToken);
    }
}

- (void)_wisdk_application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    TESWIApp * app = [TESWIApp manager];
    [app didFailToRegisterForRemoteNotificationsWithError:error];

    SEL _sel = @selector(application:didFailToRegisterForRemoteNotificationsWithError:);
    IMP original_imp = [[TESMessagingProxy sharedProxy] originalImplementationForSelector:_sel];
    if (original_imp) {
        NSObject<UIApplicationDelegate> *appDelegate = [[UIApplication sharedApplication] delegate];
        ((void (*)(id, SEL, UIApplication *, NSError *))original_imp)(appDelegate, _sel, application, error);
    }

}

- (void)_wisdk_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    TESWIApp * app = [TESWIApp manager];
    [app processRemoteNotification:userInfo];


    SEL _sel = @selector(application:didReceiveRemoteNotification:);
    IMP original_imp = [[TESMessagingProxy sharedProxy] originalImplementationForSelector:_sel];
    if (original_imp) {
        NSObject<UIApplicationDelegate> *appDelegate = [[UIApplication sharedApplication] delegate];
        ((void (*)(id, SEL, UIApplication *, NSDictionary *))original_imp)(appDelegate, _sel, application, userInfo);
    }
}

@end