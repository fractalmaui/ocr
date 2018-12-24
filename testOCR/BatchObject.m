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
        [dbt setParent:self];
        
        ot  = [[OCRTemplate alloc] init];
        ot.delegate = self;
        batchFolder = @"latestBatch";
        
        oto = [OCRTopObject sharedInstance];
        oto.delegate = self;

        vv  = [Vendors sharedInstance];

        act = [[ActivityTable alloc] init];

        tableName = @"Batch";
        
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
    batchStatus   = BATCH_STATUS_RUNNING;
    batchErrors   = @"";
    batchFiles    = @"";
    batchProgress = @"";
    [self.delegate batchUpdate : @"Started Batch..."];

    vendorName    = vname;
    [self updateParse];
    [act saveActivityToParse:@"Batch Started" : vname];
    if (index >= 0)
    {
        gotTemplate = FALSE;
        [ot readFromParse:vendorName]; //Get our template
        // This performs handoff to the actual running ...
        [dbt getBatchList : batchFolder : vv.vFolderNames[index]];
    }
    else
    {
        NSLog(@" run ALL batches...");
    }
} //end runOneOrMoreBatches

//=============(BatchObject)=====================================================
-(void) setParent : (UIViewController*) p
{
    parent = p;
    [dbt setParent:p];
}


//=============(BatchObject)=====================================================
// Given a list of PDF's in one vendor folder, download pDF and
//  run OCR on all pages...
-(void) downloadAndProcessFiles : (NSArray *)pdfEntries
{
    int i=0;
    batchTotal = (int)pdfEntries.count;
    batchCount = 1;
    for (DBFILESMetadata *entry in pdfEntries)
    {
        NSString *itemName = [NSString stringWithFormat:@"%@/%@",dbt.prefix,entry.name];
        //NSLog(@" ...item[%d] %@",i,itemName);
        [dbt downloadImages:itemName]; //Asyncbonous, need to finish before handling results
        i++;
        batchCount = i;
        batchProgress = [NSString stringWithFormat:@"Fetch File %d of %d",batchCount,batchTotal];
        [self.delegate batchUpdate : batchProgress];
        [self updateParse];
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
-(void) processFiles : (NSArray *)paths : (NSArray *)pdfPages
{
    if (!gotTemplate)
    {
        NSLog(@" ERROR: tried to process images w/o template");
        return;
    }
    batchProgress = [NSString stringWithFormat:@"Process File %d of %d",batchCount,batchTotal];
    [self.delegate batchUpdate : batchProgress];

    //Template MUST be ready at this point!
    batchPage = 0;
    batchTotalPages = (int)pdfPages.count;
    for (UIImage *nextPageImage in pdfPages) //Handle all images that came back from latest PDF...
    {
        NSString *ipath = [paths objectAtIndex:batchPage];
        //template was made w/ image 1275x1650y, try test scaling for now
        //KLUGE!!!! this only works for hawaii beef products!
        UIImage *imageToOCR =  [nextPageImage imageByScalingAndCroppingForSize : CGSizeMake(1650,1275)  ];  //DHS 3/26
        NSLog(@" ...do OCR on image [%@][%@]",vendorName,imageToOCR);
        //If filename doesn't have .pdf,.jpg,.png,.jpeg,.bmp,.gif the OCR fails!
        oto.imageFileName = ipath;
        [oto performOCROnImage : imageToOCR : ot];
//        [oto stubbedOCR : ipath : imageToOCR : ot];
    } //end for nextPageImage
} //end processFiles

//=============(BatchObject)=====================================================
-(void) handleBatchError : (NSString *) errstr
{
    batchErrors = errstr;
    [self updateParse];
    [self.delegate batchUpdate : @"Batch Failed"];
    [act saveActivityToParse:@"Batch Error" : batchErrors];
    [dbt errMsg : @"Error getting Batch List" : batchErrors];
    [self.delegate didFailBatch];
}


//=============(BatchObject)=====================================================
-(void) updateParse
{
    PFQuery *query = [PFQuery queryWithClassName:tableName];
    [query whereKey:PInv_BatchID_key equalTo:_batchID];   //Look for current batch
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) { //Query came back...
            PFObject *pfo;
            if (objects.count > 0) //Got something? Update...
                pfo = objects[0];
            else
                pfo = [PFObject objectWithClassName:self->tableName];
            pfo[PInv_BatchID_key]       = self->_batchID;
            pfo[PInv_BatchStatus_key]   = self->batchStatus;
            pfo[PInv_Vendor_key]        = self->vendorName;
            pfo[PInv_BatchFiles_key]    = self->batchFiles;
            pfo[PInv_BatchProgress_key] = self->batchProgress;
            pfo[PInv_BatchErrors_key]   = self->batchErrors;
            [pfo saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded)
                {
                    NSLog(@" ...batch updated[%@]->parse",self->_batchID);
                    //                    [self.delegate whateverdoIneedhere?];
                }
                else
                {
                    NSLog(@" ERROR: updating batch: %@",error.localizedDescription);
                }
            }]; //End save
        } //End !error
    }]; //End findobjects
} //end saveToParse


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
    [self handleBatchError : s];
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
} //end didCountEntries


//=============(BatchObject)=====================================================
- (void)didDownloadImages
{
    //At this point we have all the images for a file, ready to process!
    NSLog(@" ...downloaded all images? got %d",(int)dbt.batchImages.count);
    [self processFiles : dbt.batchImagePaths : dbt.batchImages];
}


//=============(BatchObject)=====================================================
- (void)errorDownloadingImages : (NSString *)s
{
    [self handleBatchError : s];
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
    gotTemplate = FALSE;
    [self handleBatchError : s];
}


#pragma mark - OCRTopObjectDelegate

//=============(BatchObject)=====================================================
- (void)didPerformOCR : (NSString *) result
{
    NSLog(@" OCR OK page %d tp %d  count %d total %d",batchPage,batchTotalPages,batchCount,batchTotal);
    batchPage++;
    if (batchPage == batchTotalPages)
    {
        batchCount++;
        if (batchCount == batchTotal)
        {
            batchStatus = BATCH_STATUS_COMPLETED;
            [self updateParse];
            [act saveActivityToParse:@"Batch Completed" : vendorName];
            [self.delegate didCompleteBatch];
        }
    }
}


//=============(BatchObject)=====================================================
- (void)errorPerformingOCR : (NSString *) errMsg
{
    [self handleBatchError : errMsg];
}



@end
