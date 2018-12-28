//
//  AppDelegate.h
//  testOCR
//
//  Created by Dave Scruton on 12/3/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//
//  12/21 add dropbox SDK

#import <UIKit/UIKit.h>
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
#import <Parse/Parse.h>
#import "BatchObject.h"
#import "SessionManager.h"
#import "Vendors.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{

}

@property(nonatomic) BOOL authSuccessful;
@property (strong, nonatomic) BatchObject *bbb;

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic , strong) NSString* versionNumber;


@end

