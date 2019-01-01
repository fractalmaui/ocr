//
//  AppDelegate.m
//  testOCR
//
//  Created by Dave Scruton on 12/3/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//
//  Dec 18: add PDF support in info.plist (CFBundleDocumentTypes setup)
//          change bundle id to com.bgpcloud.testOCR,
//          for setup with google cloud API

#import "AppDelegate.h"

@interface AppDelegate () 

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Parse initializeWithConfiguration:[ParseClientConfiguration configurationWithBlock:^(id<ParseMutableClientConfiguration> configuration) {
        //This is the AWS -> Mongo configuration...
        configuration.applicationId = @"jT8oJdg7ySCQrHazHQml6JHEnCoKAiYh5ON5leQk";
        configuration.clientKey     = @"hxSXfyhuz3xik85xRZlmC2XrhQ5URkOlLNAioGeY";
        configuration.server        = @"https://pg-app-jhg70nkxzqetipfyic66ks9q3kq41y.scalabl.cloud/1/";
        NSLog(@" parse DB at sashido.io connected");
    }]];
    
    //Dropbox?
    NSString *appKey = @"ltqz6bwzqfskfwj";
    NSString *registeredUrlToHandle = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleURLTypes"][0][@"CFBundleURLSchemes"][0];
    if (!appKey || [registeredUrlToHandle containsString:@"<"]) {
        NSString *message = @"You need to set `appKey` variable in `AppDelegate.m`, as well as add to `Info.plist`, before you can use DBRoulette.";
        NSLog(@"%@", message);
        NSLog(@"Terminating...");
        exit(1);
    }
    [DBClientsManager setupWithAppKey:appKey];
    NSLog(@" ...logged into dropbox...");

    //Settings...
    _settings = [OCRSettings sharedInstance];
    
    //Load Vendors from parse db
    [Vendors sharedInstance];
    
    
    _versionNumber    = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];

    // Override point for customization after application launch.
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
    [SessionManager sharedSession].savedCompletionHandler = completionHandler;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    DBOAuthResult *authResult = [DBClientsManager handleRedirectURL:url];
    if (authResult != nil) {
        if ([authResult isSuccess]) {
            NSLog(@"Success! User is logged into Dropbox.");
            UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
            _authSuccessful = YES;
            return YES;
        } else if ([authResult isCancel]) {
            NSLog(@"Authorization flow was manually canceled by user!");
        } else if ([authResult isError]) {
            NSLog(@"Error: %@", authResult);
        }
    }
    
    return NO;
}



@end
