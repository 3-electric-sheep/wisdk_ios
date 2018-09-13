# WiSDK

## About

This Wi SDK allows integration of native mobile apps with the Welcome Interruption (Wi) servers.  It allows for the collecting
location information from a mobile device to the Wi Servers and allow the receipt of notifications from Wi servers.

The SDK also provides various interfaces to the REST api suported by the Wi servers.

The SDK is available for IOS and Android and is available an:-

* Objective C library (IOS)
* Java library (Android)
* React Native library (IOS + Android)

This document specifically for the  Objective-C version of the library

## Requirements

Currently the WiSDK has the following requirements:-

* IOS version 9.0+
* XCode Version 9.0+

It also requires, the following pods as dependencies

* AFNetworking Version 3.0+

Note: push notification are only available on real IOS devices - they are not supported in IOS simulators (this is a simulator limitation)


## SDK Installation and Setup
There are a few important steps to get out of the way when integrating Wi with your app for the first time.
Follow these instructions carefully to ensure that you will have a smooth development experience.

### CocoaPods
Before you begin, ensure that you have CocoaPods installed. If you are having troubles with CocoaPods, check out the troubleshooting guide.

```ruby
$ gem install cocoapods
```

### Private Repository setup
WiSDK is available through a private repository to allow access to this repository you need to do the following:-

1. Create the private repository in your cocoa installation

```ruby
pod repo add wi-specs https://3es-Integrator:3zrUfjvVBW@github.com/3-electric-sheep/wi-specs.git
```

2. Add the source directive at the top of your pos file. This goes to the wi-spec repository then the master cocoapod repository:-

```
source 'https://3es-Integrator:3zrUfjvVBW@github.com/3-electric-sheep/wi-specs.git'
source 'https://github.com/CocoaPods/Specs.git'
```

### SDK Cocoapod
WiSDK is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'WiSDK'
```

If this is not sufficient we can assist to setup manually

### APNS and Location Permission Setup
While you are setting up your development and production apps, you need to configure them for push services.
For detailed instructions on this process, please see the APNS Setup documentation. The APNS certificates must also be
converted to PEM format and setup on the Wi servers. (this is usually part of the client setup on Wi servers)

Wi will ask for "Always and when in use location permissions" so that it can collect location information while the app is not in use.
You will  need to specify a description for NSLocationAlwaysAndWhenInUseUsageDescription in your info.plist to enable the asking for this permission.

NOTE: NSLocationWhenInUseUsageDescription can be specified if you don't want to allow such location gathering in backgroun
but this will serverly limit what Wi is capable of.

**IMPORTANT: do *NOT* set the background location checkbox on the background capabilities option.
Wi does not use it and setting this will adversely affect battery life.**

## Getting Started

Welcome interruption is a platform for real time digital reach. By using the WiSDK you can turn any mobile application into an
effective mobile marketting tool that can target customers based on their real time location.

To get started we need to explain some terminoloy. In Welcome Interruption there are a number of key entities:-

 - Provider - A provider is the main entity which controls which offers gets sent to where, when and who. This is usually the owner of
 the users of the system (ie. the company that owns the app the Wi Sdk will be added too)
 - Place of interest (POI) - A defined geographic area that the provider sets up.
 - Event - A real time offer created by a Provider that is targeted to one or more POI's that they previously created
 - Users - A customer of the provider. Users can be anonymous and have a link to an external system or they can be full users (ie. email, name, etc)
 - Device - Links a phone and user to a provider. Contains reference to a user, current Lat/Lng of a phone as well as preferred
 notification mechanisms.
 - Campaign - the ability to target users/devices using external attributes as well as geo information.


Typically to setup a Client in Welcome Interruption we do the following:-

1. add a provider to Welcome interruption and configure it with a campaign schema, external system intergration details and push
certificates and API keys. This will require us to have your clients APNS push cerificates and any API key for Googles FCM serivce.
2. Once the provider is setup you will be provided with a provider key and certificate keys which **MUST** be specified as
part of the WiSDK configuration.
3. Start Integrating the WiSDK

## WiSDK integration

Typically integration is done as follows:-

1. Configure SDK
2. Create listener / delegate (optional)
3. Start Wi up
4. Use the API to list offers, update profiles, etc (optional)
5. Permissions and capabilities

Wi works silently in background sending location updates to our servers as users go about their daily business. You can even close the app and
everything just keeps working

A minimal integration is just include the TESWiApp.h header and adding code to the didFinishLaunchingWithOptions method in the app delegate.

```objective-c
#import "WiAppDelegate.h"
#import "WiSDK/TESWIApp.h"

@implementation WiAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // the provider key this application is tied too (provider to you by 3es)
    NSString * PROVIDER_KEY = @"5b53e675ec8d831eb30242d3";

    // first thing to do is create a configuration object and overwrite values to suit your environment.
    // most defaults are sensible.
    TESConfig * config = [[TESConfig alloc] initWithProviderKey:PROVIDER_KEY];
    config.authAutoAuthenticate = YES;
    config.authCredentials = @{
           @"anonymous_user": @YES,
    };
    config.deviceTypes = deviceTypeAPN | deviceTypeWallet;

    // IOS has the concept of production and developement APNS servers - we need to ensure the right keys
    // are setup if we are running in debug mode or production mode.
#ifdef DEBUG
    config.testPushProfile = @"wisdk-example-aps-dev";  // test profile name (allocted by 3es)
    config.pushProfile = @"wisdk-example-aps-dev"; // prod profile name (allocated by 3es)
#endif
#ifndef DEBUG
    config.testPushProfile = @"wisdk-example-aps-prod";  // test profile name (allocted by 3es)
    config.pushProfile = @"wisdk-example-aps-prod"; // prod profile name (allocated by 3es)
#endif

    // next we create our singleton app object
    TESWIApp * app = [TESWIApp manager];

    // if we have a delegate listener class set it up here
    app.delegate = self;

     // start things up - this will setup push notificatons, setup fg and bg location montioring and authenticate
     // with Wi servers.
    [app start:config withLaunchOptions:launchOptions];

    return YES;
}
```

### configure

Configuration is done completely through the TESConfig object.  It is used to bind a provider with an app and describe how the WiSDK should
interact with the device and Wi Servers.

Typically a config object is created at app startup and then passed to the TESWIApp object start method. The config object can set the
sensitivty of geo regions monitored, how users and devices are created and the type of notification mechanism that should be used by the sdk


```objective-c
    TESConfig * config = [[TESConfig alloc] initWithProviderKey:PROVIDER_KEY];
    config.authAutoAuthenticate = YES;
    config.authCredentials = @{
           @"anonymous_user": @YES,
           @"external_id:: @”1234567890”,  // external system user/member id
    };
    config.deviceTypes = deviceTypeAPN | deviceTypeWallet;
    config.testPushProfile = @"wisdk-example-aps-prod";  // test profile name (allocted by 3es)
    config.pushProfile = @"wisdk-example-aps-prod"; // prod profile name (allocated by 3es

```

if you want to add user specific information you can also ammend the authCredentials section of the config data with the following fields:-

* email =  email for the device
* password = password (only supported if anonymous_user is false)
* first_name = users first name
* last_name = users last name
* profile_image = url of profile image

If interfacing to an external system you can also enter

* external_id - any string value (should be unique)
* program_attr - a dictionary of name value pairs - only available if a program is setup for a provider

```objective-c

    TESConfig * config = [[TESConfig alloc] initWithProviderKey:PROVIDER_KEY];
    config.authAutoAuthenticate = YES;
    config.authCredentials = @{
        @"anonymous_user": @YES,
        @"email": @"test@acme.com",
        @"first_name": @"Test",
        @"last_name": @"User",
        @"external_id:: @”1234567890”,  // external system user/member id
        @"program_attr": @{
             @"name": @"3esCampaignDemo",
             @"gender": @"F",
             @"DOB": @"1964-12-04"
        }
    };
```

if you need to get / update the user details after the user has been created and authenticated you can use the following api calls

```objective-c

-(void) getAccountProfile: (TESApiCallback) completionBlock;
-(void) updateAccountProfile: (nullable NSDictionary *)params onCompletion:(TESApiCallback) completionBlock;

```

Both of these calls make an async network call and will return a JSON result dictionary signifying success or failure. An example on usage follows:-

```objective-c

    NSDictionary * params = @{
        @"email": @"test@acme.com",
        @"first_name": @"Test",
        @"last_name": @"User",
        @"external_id": @"666123666",
        @"program_attr": @{
             @"name": @"3esCampaignDemo",
             @"gender": @"F",
             @"DOB": @"1964-12-04"
        }
    };
    [wiapp updateAccountProfile:params onCompletion:^ void (TESCallStatus  status, NSDictionary * _Nullable result) {
        switch (status) {
            case TESCallSuccessOK: {
                NSString *data = [result valueForKey:@"data"];
                break;
            }
            case TESCallSuccessFAIL: {
                NSNumber *code = [result valueForKey:@"code"];
                NSString *msg = [result valueForKey:@"msg"];
                break;
            }
            case TESCallError: {
                NSString *msg = [result valueForKey:@"msg"];
                break;
            }
        }
    }];


```

NOTE: these calls will fail unless you have successfully authenticated with the system


### Listeners

The WiSDK supports a protocol or listener class that can be used to get information about what the WiSDK is doing behind the scenes.
Implmenting this protocol is optional but may be useful depending on the app you are integrating with.

this protocol is defined in WiSDK/TESWiApp.h as follows:-

```objective-c

 @protocol TESWIAppDelegate <NSObject>

    /*
     sent when authorization has failed (401)
    */
    - (void) authorizeFailure: (NSInteger) httpStatus;

    @@optional

    /*
     sent when authorization is complete
    */
    - (void) onAutoAuthenticate:(TESCallStatus)status withResponse: (nonnull NSDictionary *) responseObeject;

    /*
     sent when a new access token is returned
    */
    - (void) newAccessToken: (nullable NSString *) token;

    /*
     sent when a new device token has been created
     */
    - (void) newDeviceToken: (nullable NSString *) token;

    /*
      sent when a new push token is returned
     */
    - (void) newPushToken: (nullable NSString *) token;

    /*
      Called when a remmote notification needs to be processed
     */
    - (void) processRemoteNotification: (nullable NSDictionary *) userDictionary;

    /*
      Called when remote notifications is registered or fails to register
     */
    -(void) onRemoteNoficiationRegister:(TESCallStatus)status withResponse: (nonnull NSDictionary *) responseObeject;

 @end

```

### Start Wi up

The Wi SDK revolves around the TESWIApp singleton object. It is created once for an app and is used to for location monitoring, authentication with Wi servers,
notification management and all sorts of communication to/from the Wi Servers.

```objective-c

    TESWIApp * app = [TESWIApp manager];
    app.delegate = self; // Only needed if you implement the listener protocol
    [app start:config withLaunchOptions:launchOptions];
```

NOTE: start asks for necessary permissions, registers push tokens and uses https to authenticate and communicate with the WI servers. It is asyncrohnous and
in nature.

### Push notification format

A push notification is created when a device enter in an active radius of an events geofence.  The event detail determines
the layout of the push notification and what fields are returned as part of the push notification.

The event fields support customisation in 2 ways :-

* by template substition (for most string fields)
* by plugin integrations (requires server development and is used to inteface directly to back end systems)

#### Templates
Template substitution allows for special field inserts to be added to most text fields. At runtime the field inserts
are substituted with the device details (as setup in config or by calling the updateAccountProfile api call). The following
field inserts are supported:-

* user_name
* email
* first_name
* last_name
* full_name
* external_id
* All program defined field as per provider program

The following items in an event are templatable:-

 * title
 * detail
 * extract
 * media_external_url
 * media_thumbnail_url
 * notification_channel
 * offer_code

 To specify a insert in one of these field simply wrap the field insert around {}
 eg.  To add first name to the media url you would write something like this:-

> ‘https://x.y.z/videoxxx?name={first_name}

if first_name for the device was set to Phillip then it would resolve to:-

> https://x.y.z/videoxxx?name=Phillip)

On IOS, the following fields are special:-

* notification_channel will be translated to *category*  in the apn section of the notification
* media_external_url will cause the *mutable-content* flag to be set in the apn section of the notification


#### Plugins
Plugin integration are outside of the scope of this document but allow much flexibilty in modifying an events detail for
individual devices.

A plugin can be used to

* add integration spectific items to an event record
* custom an event for each device so its notification is unique
* communicate with a back end system at event creation and device notification
* allow for backend systems to call back to wi.

#### push format
The payload for a push notification on android is is divided into a notification section and data section.

An example follows:-

```json
    {
      "aps": {
        "alert": "A notification\r\nThis is a test notification",
        "sound": "default"
        "mutable-content": 1,
        "category": "WiCategoryPush",
      },
      "event-id": "5b9a0b36f26f9f7104cd089c",
      "type": "deal",
      "title": "A notification",
      "detail": "This is a test notification",
      "event-category": "General",
      "further-info": "",
      "starts": "2018-09-13T07:00:00+0000",
      "expires": "2018-09-13T08:00:00+0000",
      "broadcast-band": "auto",
      "poi-id": "5b5ea71bf26f9fffdf92058e",
      "poi-lng": 144.52037359999997,
      "poi-lat": -37.36093909999999,
      "enactable": False,
      "provider-id": "5b5ea71bf26f9fffdf92058d",
      "media-external-url": "https://www.youtube.com/watch?v=xLCn88bfW1o",
      "media-thumbnail-url": "http://i3.ytimg.com/vi/xLCn88bfW1o/maxresdefault.jpg",
      "notification-channel": "WiCategoryPush",
      "event-history-id": "5b9a0b36f26f9f7104cd089b",
      "event-group-id": "bf059e8d-06cd-400d-ac99-cfddfc0aa88c"
    }

```

### Using thie API

The remainder of the WiSDK wraps the Wi Rest based API. This API can be used to

* view live/historical events
* events that have been taken up by this user
* setting up inclusions/exclusions for event notification
* searching for events

### Permissions and capabilites

Ensure that your info.plist has the correct location privacy entries

```xml
    <key>
        NSLocationAlwaysUsageDescription
    </key>
    <string>
        We use your location to notify you of great offers near you. Please select always as this gives you welcome interuptions near you.
    </string>
    <key>
        NSLocationAlwaysAndWhenInUseUsageDescription
    </key>
    <string>
        We use your location to notify you of great offers near you. Please select always as this gives you welcome interuptions near you.
    </string>
    <key>
       NSLocationWhenInUseUsageDescription
    </key>
    <string>
        We use your location to notify you of great offers near you. Please select always as this gives you welcome interuptions near you.
    </string>
```

Ensure that in the capabilites you have

* Push Notifications enabled
* Wallet services enabled (optional if you want to support wallet services)
* Background services - and tick allow remote notifications

** NOTE: do NOT tick allow background location as this will drain battery very quickly.

## API documentation

For further API documentation, clone the repo and open the doc/html/index.html file

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first. This example is useful as it has a
project correctly configured to run Wi.

It is a bare bones project that will send location information from the device to the Wi Servers.  It also
has a demo provider key  which can be used to send offers from wi to the device.

## Author

Welcome Interruption and the WiSDK are developed by the 3-electric-sheep pty ltd.

for support please contact:-

pfrantz, pfrantz@3-elecric-sheep.com

## License

WiSDK is available under the Welcome Interruption SDK License. See the LICENSE file for more info.
