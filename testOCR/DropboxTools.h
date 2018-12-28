//
//   ____                  _               _____           _
//  |  _ \ _ __ ___  _ __ | |__   _____  _|_   _|__   ___ | |___
//  | | | | '__/ _ \| '_ \| '_ \ / _ \ \/ / | |/ _ \ / _ \| / __|
//  | |_| | | | (_) | |_) | |_) | (_) >  <  | | (_) | (_) | \__ \
//  |____/|_|  \___/| .__/|_.__/ \___/_/\_\ |_|\___/ \___/|_|___/
//                  |_|
//
//  DropboxTools.h
//  testOCR
//
//  Created by Dave Scruton on 12/21/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

@protocol DropboxToolsDelegate;

@interface DropboxTools : NSObject
{
    UIViewController *parent;
    DBUserClient *client;
//    NSMutableArray *batchFileList;
}

@property (nonatomic, unsafe_unretained) id <DropboxToolsDelegate> delegate; // receiver of completion messages

@property (nonatomic , strong) NSMutableArray* batchFileList;
@property (nonatomic , strong) NSMutableArray* batchImages;
@property (nonatomic , strong) NSMutableArray* batchImagePaths;
@property (nonatomic , strong) NSMutableArray* batchImageData;
@property (nonatomic , strong) NSMutableArray* batchImageRects;

@property (nonatomic , strong) NSString* prefix;
@property (nonatomic , strong) NSArray* entries;


+ (id)sharedInstance;

-(void) countEntries : (NSString *)batchFolder : (NSString *)vendorFolder;

- (void)downloadImages:(NSString *)imagePath;
-(void) errMsg : (NSString *)title : (NSString*)message;

-(void) setParent : (UIViewController*) p;
-(void) getBatchList : (NSString *) batchFolder : (NSString *) vendorFolder;



@end


@protocol DropboxToolsDelegate <NSObject>
@required
@optional
- (void)didGetBatchList : (NSArray *)a;
- (void)didCountEntries : (NSString *)vname : (int) count;
- (void)errorGettingBatchList : (NSString *)s;
- (void)didDownloadImages;
- (void)errorDownloadingImages : (NSString *)s;
@end
