//
//  AppDelegate.h
//  testOCR
//
//  Created by Dave Scruton on 12/3/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//
//  12/21 add dropbox SDK

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SessionManager.h"
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>
{

}

@property(nonatomic) BOOL authSuccessful;

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic , strong) NSString* versionNumber;


@end

