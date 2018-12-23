//
//   ____        _       _      ___  _     _           _
//  | __ )  __ _| |_ ___| |__  / _ \| |__ (_) ___  ___| |_
//  |  _ \ / _` | __/ __| '_ \| | | | '_ \| |/ _ \/ __| __|
//  | |_) | (_| | || (__| | | | |_| | |_) | |  __/ (__| |_
//  |____/ \__,_|\__\___|_| |_|\___/|_.__// |\___|\___|\__|
//                                      |__/
//
//  BatchObject.m
//  testOCR
//
//  Created by Dave Scruton on 12/22/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import "BatchObject.h"

@implementation BatchObject

static BatchObject *sharedInstance = nil;

//=============(BatchObject)=====================================================
// Get the shared instance and create it if necessary.
+ (BatchObject *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

//=============(BatchObject)=====================================================
-(instancetype) init
{
    if (self = [super init])
    {
        vendorFileCounts = [[NSMutableArray alloc] init];
        vendorFolders    = [[NSMutableDictionary alloc] init];

        dbt = [[DropboxTools alloc] init];
        dbt.delegate = self;
        
        ot  = [[OCRTemplate alloc] init];
        ot.delegate = self;
        batchFolder = @"latestBatch";
        
        oto = [OCRTopObject sharedInstance];
        oto.delegate = self;

        vv  = [Vendors sharedInstance];

        _authorized = FALSE;
        
//        catCSV = [[NSMutableArray alloc] init]; //CSV data as read in from csv.txt
//        _catProducts = [[NSMutableArray alloc] init]; //CSV data as read in from csv.txt
//        [self loadCategoriesFile];
        //        tableName = @"";
        //        _versionNumber    = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    }
    return self;
}

//=============(BatchObject)=====================================================
// Loop over vendors, get counts...
-(void) getBatchCounts
{
    [vendorFileCounts removeAllObjects];
    [vendorFolders removeAllObjects];
    for (NSString *vn in vv.vFolderNames)
    {
        [dbt countEntries : batchFolder : vn];
    }
}

//=============(BatchObject)=====================================================
-(void) getNewBatchID
{
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"MMM_dd_HH_mm"];
    _batchID = [NSString stringWithFormat:@"B_%@", [df stringFromDate:[NSDate date]]];
}

//=============(BatchObject)=====================================================
// index -1 means run ALL
-(void) runOneOrMoreBatches : (NSString *)vname : (int) index
{
    if (!_authorized) return; //can't get at dropbox w/o login!
    [self getNewBatchID];

    vendorName = vname;
    if (index >= 0)
    {
        gotTemplate = FALSE;
        [ot readFromParse:vendorName]; //Get our template
        [dbt getBatchList : batchFolder : vv.vFolderNames[index]];
    }
    else
    {
        NSLog(@" run ALL batches...");
    }
} //end runOneOrMoreBatches


//=============(BatchObject)=====================================================
// Given a list of PDF's in one vendor folder, download pDF and
//  run OCR on all pages...
-(void) downloadAndProcessFiles : (NSArray *)a
{
    int i=0;
    for (DBFILESMetadata *entry in a)
    {
        NSString *itemName = [NSString stringWithFormat:@"%@/%@",dbt.prefix,entry.name];
        //NSLog(@" ...item[%d] %@",i,itemName);
        [dbt downloadImages:itemName]; //Asyncbonous, need to finish before handling results
        i++;
    }
} //end downloadAndProcessFiles

//=============(BatchObject)=====================================================
-(int) getVendorFileCount : (NSString *)vfn
{
    for (NSDictionary *d in vendorFileCounts)
    {
        if ([d[@"Vendor"] isEqualToString:vfn])
        {
            NSNumber *n = d[@"Count"];
            return n.intValue;
        }
    }
    return 0;
}

//=============(BatchObject)=====================================================
// Handles each page that came back from one PDF as an UIImage...
-(void) processFiles : (NSArray *)a
{
    if (!gotTemplate)
    {
        NSLog(@" ERROR: tried to process images w/o template");
        return;
    }
    for (UIImage *ii in a) //Handle all images that came back from latest PDF...
    {
        NSLog(@" ...do OCR on image [%@][%@]",vendorName,ii);
//        [oto performOCROnImage : @"empty" : ii : ot];
        [oto stubbedOCR : @"empty" : ii : ot];
        
    }
} //end processFiles


//=============(BatchObject)=====================================================
// Just passes the buck dpown to dropbox, which needs err msg support
-(void) setParent : (UIViewController*) p
{
    [dbt setParent : p];
}


#pragma mark - DropboxToolsDelegate

//=============(BatchObject)=====================================================
// Returns with a list of all PDF's in the vendor folder
- (void)didGetBatchList : (NSArray *)a
{
    [self downloadAndProcessFiles : a];
}

//=============(BatchObject)=====================================================
- (void)errorGettingBatchList : (NSString *)s
{
    NSLog(@" batch err %@",s);
}

//=============(BatchObject)=====================================================
// coming back from dropbox : # files in a folder
-(void) didCountEntries:(NSString *)vname :(int)count
{
    [vendorFileCounts addObject:@{@"Vendor": vname,@"Count":[NSNumber numberWithInt:count]}];
    [vendorFolders setObject:dbt.entries forKey:vname];
    if (vendorFileCounts.count == vv.vFolderNames.count)
    {
        [self->_delegate didGetBatchCounts];
    }
}


//=============(BatchObject)=====================================================
- (void)didDownloadImages : (NSArray *)a
{
    //At this point we have all the images for a file, ready to process!
    NSLog(@" ...downloaded all images? %d",(int) a.count);
    [self processFiles : a];
}

#pragma mark - OCRTemplateDelegate

//=============(BatchObject)=====================================================
- (void)didReadTemplate
{
    NSLog(@" got template...");
    gotTemplate = TRUE;
}

//=============(BatchObject)=====================================================
- (void)errorReadingTemplate : (NSString *)errmsg
{
    NSString *s = [NSString stringWithFormat:@"%@ Template Error [%@]",vendorName,errmsg];
    [dbt errMsg : @"Error reading template" : s];
    gotTemplate = FALSE;
}


#pragma mark - OCRTopObjectDelegate

//=============(BatchObject)=====================================================
- (void)didPerformOCR : (NSString *) result
{
    NSLog(@" OCR OK");
}


//=============(BatchObject)=====================================================
- (void)errorPerformingOCR : (NSString *) errMsg
{
    NSLog(@" OCR ERR %@",errMsg);
}



@end
