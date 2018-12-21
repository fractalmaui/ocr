//
//  AppDelegate.h
//  testOCR
//
//  Created by Dave Scruton on 12/3/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SessionManager.h"
#import <DropboxOSX/DropboxOSX.h>
#import <WebKit/WebKit.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    DBRestClient *restClient;
}

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic , strong) NSString* versionNumber;


@end

