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
#import "AppDelegate.h"
#import "ActivityTable.h"
#import "DropboxTools.h"
#import "imageTools.h"
#import "OCRTemplate.h"
#import "Vendors.h"
#import "UIImageExtras.h"
#import "OCRTopObject.h"

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
    OCRTopObject *oto;

    UIViewController *parent;
    
    BOOL gotTemplate;
    NSString *batchFolder;

    NSString *vendorName; //Whose batch we're running
    NSString *vendorRotation; //Are pages rotated typically?
    NSString *batchFiles; //CSV list of all files processed
    NSString *batchStatus;
    NSString *batchProgress;
    NSString *batchErrors;
    NSString *batchFixed;
    NSString *cachesDirectory;
    NSMutableArray *vendorFileCounts;
    NSMutableDictionary *vendorFolders;
    NSArray *pdfEntries;  //Fetched list of PDF files from batch folder
    NSMutableArray *errorList;
    NSMutableArray *fixedList;
    int batchCount;
    int batchTotal;
    int batchPage;
    int batchTotalPages;
    NSString *tableName;
    int returnCount;
}
@property (nonatomic , strong) NSString* batchID;
@property (nonatomic , assign) BOOL authorized;
@property (nonatomic , strong) NSString* versionNumber;

@property (nonatomic, unsafe_unretained) id <batchObjectDelegate> delegate; // receiver of completion messages

+ (id)sharedInstance;

-(void) addError : (NSString *) errDesc : (NSString *) objectID;
-(void) fixError : (int) index;
-(BOOL) isErrorFixed :(NSString *)errStr;
-(void) getBatchCounts;
-(NSString *) getErrors;
-(NSString *) getVendor;
-(int)  getVendorFileCount : (NSString *)vfn;
-(void) readFromParseByID : (NSString *) bID;
-(void) readFromParseByIDs : (NSArray *) bIDs;
-(void) runOneOrMoreBatches  : (int) vindex;
-(void) setParent : (UIViewController*) p;
-(void) updateParse;
-(void) writeBatchReport;

@end

@protocol batchObjectDelegate <NSObject>
@required
@optional
- (void)batchUpdate : (NSString *) s;
- (void)didGetBatchCounts;
- (void)didCompleteBatch;
- (void)didFailBatch;
- (void)didReadBatchByID : (NSString *)oid;
- (void)didUpdateParse;
- (void)errorReadingBatchByID : (NSString *)err;
@end


