//
//  DropboxTools.h
//  testOCR
//
//  Created by Dave Scruton on 12/21/18.
//  Copyright © 2018 huedoku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>

NS_ASSUME_NONNULL_BEGIN

@interface DropboxTools : NSObject
{
    UIViewController *parent;
    DBUserClient *client;
//    NSMutableArray *batchFileList;
}
@property (nonatomic , strong) NSMutableArray* batchFileList;
@property (nonatomic , strong) NSMutableArray* batchImages;


+ (id)sharedInstance;
-(void) setParent : (UIViewController*) p;
-(void) getBatchList;



@end

NS_ASSUME_NONNULL_END
