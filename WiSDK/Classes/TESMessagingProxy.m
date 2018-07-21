//
// Created by Phillp Frantz on 8/08/2017.
// Copyright (c) 2017 3 Electric Sheep Pty Ltd. All rights reserved.
//

#import "TESMessagingProxy.h"
#import <objc/runtime.h>
#import "WiSDK/TESWIApp.h"

@interface  TESMessagingProxy ()

@property(nonatomic) BOOL didSwizzleMethods;

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

+ (void)swizzleMethods {
    [[TESMessagingProxy sharedProxy] swizzleMethodsIfPossible];
}

- (void)swizzleMethodsIfPossible {
    if (self.didSwizzleMethods) {
        return;
    }

    NSObject<UIApplicationDelegate> *appDelegate = [[UIApplication sharedApplication] delegate];
    Class appDelegateClass = [appDelegate class];

    [TESMessagingProxy _swizzle:appDelegateClass method:@selector(application:didRegisterForRemoteNotificationsWithDeviceToken:) with: @selector(_wisdk_application:didRegisterForRemoteNotificationsWithDeviceToken:)];
    [TESMessagingProxy _swizzle:appDelegateClass method:@selector(application:didFailToRegisterForRemoteNotificationsWithError:) with: @selector(_wisdk_application:didFailToRegisterForRemoteNotificationsWithError:)];
    [TESMessagingProxy _swizzle:appDelegateClass method:@selector(application:didReceiveRemoteNotification:) with: @selector(_wisdk_application:didReceiveRemoteNotification:)];

    self.didSwizzleMethods = YES;
}

+ (void)_swizzle: (Class) kls method: (SEL) originalSelector with: (SEL) swizzledSelector
{
    Method originalMethod = class_getInstanceMethod(kls, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(kls, swizzledSelector);

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

#pragma mark - Method Swizzling


- (void)_wisdk_application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {;
    TESWIApp * app = [TESWIApp manager];
    [app registerRemoteNotificationToken:deviceToken];
    [self _wisdk_application:application didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}

- (void)_wisdk_application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    TESWIApp * app = [TESWIApp manager];
    [app didFailToRegisterForRemoteNotificationsWithError:error];
    [self _wisdk_application:application didFailToRegisterForRemoteNotificationsWithError:error];

}

- (void)_wisdk_application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    TESWIApp * app = [TESWIApp manager];
    [app processRemoteNotification:userInfo];
    [self _wisdk_application:application didReceiveRemoteNotification:userInfo];
}

@end