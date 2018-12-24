//
//   ____        _       _      ___  _     _           _
//  | __ )  __ _| |_ ___| |__  / _ \| |__ (_) ___  ___| |_
//  |  _ \ / _` | __/ __| '_ \| | | | '_ \| |/ _ \/ __| __|
//  | |_) | (_| | || (__| | | | |_| | |_) | |  __/ (__| |_
//  |____/ \__,_|\__\___|_| |_|\___/|_.__// |\___|\___|\__|
//                                      |__/
//
//  BatchObject.h
//  testOCR
//
//  Created by Dave Scruton on 12/22/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
#import <Parse/Parse.h>
#import "ActivityTable.h"
#import "DropboxTools.h"
#import "OCRTemplate.h"
#import "Vendors.h"
#import "OCRTopObject.h"
#import "UIImageExtras.h"

@protocol batchObjectDelegate;


#define BATCH_STATUS_RUNNING    @"Running"
#define BATCH_STATUS_HALTED     @"Halted"
#define BATCH_STATUS_FAILED     @"Failed"
#define BATCH_STATUS_COMPLETED  @"Completed"

@interface BatchObject : NSObject <DropboxToolsDelegate,OCRTemplateDelegate,OCRTopObjectDelegate>
{
    DropboxTools *dbt;
    Vendors *vv;
    OCRTemplate *ot;
    ActivityTable *act;
    
    UIViewController *parent;
    
    BOOL gotTemplate;
    NSString *batchFolder;

    NSString *vendorName; //Whose batch we're running
    NSString *batchFiles; //CSV list of all files processed
    NSString *batchStatus;
    NSString *batchProgress;
    NSString *batchErrors;
    
    NSMutableArray *vendorFileCounts;
    NSMutableDictionary *vendorFolders;
    OCRTopObject *oto;
    int batchCount;
    int batchTotal;
    int batchPage;
    int batchTotalPages;
    NSString *tableName;


}
@property (nonatomic , strong) NSString* batchID;
@property (nonatomic , assign) BOOL authorized;

@property (nonatomic, unsafe_unretained) id <batchObjectDelegate> delegate; // receiver of completion messages

+ (id)sharedInstance;
-(void) getBatchCounts;
-(int)  getVendorFileCount : (NSString *)vfn;

-(void) runOneOrMoreBatches : (NSString *)vname : (int) index;
-(void) setParent : (UIViewController*) p;

@end

@protocol batchObjectDelegate <NSObject>
@required
@optional
- (void)batchUpdate : (NSString *) s;
- (void)didGetBatchCounts;
- (void)didCompleteBatch;
- (void)didFailBatch;
@end


