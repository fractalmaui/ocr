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
// Pull OIDs stuff asap

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
        errorList        = [[NSMutableArray alloc] init];

        dbt = [[DropboxTools alloc] init];
        dbt.delegate = self;
        [dbt setParent:parent];
        
        ot  = [[OCRTemplate alloc] init];
        ot.delegate = self;
        AppDelegate *bappDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        batchFolder = bappDelegate.settings.batchFolder;        //@"latestBatch";
        
        oto = [OCRTopObject sharedInstance];
        oto.delegate = self;

        vv  = [Vendors sharedInstance];

        act = [[ActivityTable alloc] init];

        tableName = @"Batch";
        
        _authorized = FALSE;
        
        _versionNumber    = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];

    }
    return self;
}


//=============(BatchObject)=====================================================
-(void) addError : (NSString *) errDesc : (NSString *) objectID
{
    //Format error and add it to array
    NSString *errStr = [NSString stringWithFormat:@"%@:%@",errDesc,objectID];
    [errorList addObject:errStr];
}


//=============(BatchObject)=====================================================
// Loop over vendors, get counts...
-(void) getBatchCounts
{
    [vendorFileCounts removeAllObjects];
    [vendorFolders removeAllObjects];
    returnCount = 0;
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
// vendor vindex -1 means run ALL
-(void) runOneOrMoreBatches : (int) vindex
{
    if (vindex < 0)
    {
        NSLog(@" all vendors not implemented yet!");
        return;
    }
    if (vindex >= vv.vFolderNames.count)
    {
        NSLog(@" ERROR: illegal vendor index");
        return;
    }
    if (!_authorized) return; //can't get at dropbox w/o login!
    [self getNewBatchID];
    AppDelegate *bappDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    bappDelegate.batchID = _batchID; //This way everyone can see the batch
    batchStatus   = BATCH_STATUS_RUNNING;
    batchErrors   = @"";
    batchFiles    = @"";
    batchProgress = @"";
    [errorList removeAllObjects]; //This is where errors accumulate...
    [self.delegate batchUpdate : @"Started Batch..."];
    oto.batchID    = _batchID; //Make sure OCR toplevel has batchID...
    vendorName     = vv.vNames[vindex];
    vendorRotation = vv.vRotations[vindex];
    [self updateParse];
    NSString *actData = [NSString stringWithFormat:@"%@:%@",_batchID,vendorName];
    [act saveActivityToParse:@"Batch Started" : actData];
    if (index >= 0)
    {
        //DHS XMAS BYPASS...  assume template loaded locally
        //gotTemplate = TRUE;
        //[ot loadTemplatesFromDisk:vendorName];

        gotTemplate = FALSE;
        [ot readFromParse:vendorName]; //Get our template
        // This performs handoff to the actual running ...
        [dbt getBatchList : batchFolder : vv.vFolderNames[vindex]];
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
-(void) startProcessingFiles
{
    batchTotal = (int)pdfEntries.count;
    batchCount = 0;
    [self processNextFile];
} //end startProcessingFiles


//=============(BatchObject)=====================================================
-(void) processNextFile
{
    //add Punctuation to batch names if 2nd... file
    if (batchCount > 1) batchFiles = [batchFiles stringByAppendingString:@","];
    batchCount++;
    //Last file? Bail... we are now waiting on asynchronous operations to complete...
    if (batchCount > batchTotal)  return;

    int i = batchCount-1; //Batch Count is 1...n
    if (i < 0 || i >= pdfEntries.count) return; //Out of bounds!
    DBFILESMetadata *entry = pdfEntries[i];
    NSString *itemName = [NSString stringWithFormat:@"%@/%@",dbt.prefix,entry.name];
    //Check for "skip" string, ignore file if so...
    if ([itemName.lowercaseString containsString:@"skip"]) //Skip this file?
    {
        [self processNextFile];                           //Re-entrant call, should be OK
        batchFiles = [batchFiles stringByAppendingString:itemName];
    }
    else
        [dbt downloadImages:itemName];                   //Asyncbonous, need to finish before handling results

} //end processNextFile

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
} //end getVendorFileCount

//=============(BatchObject)=====================================================
// We have to pre-process PDF pages, one by one, assuming a different
//  skew per page. OUCH
-(void) processPDFPages
{
    if (!gotTemplate) //Handle obvious errors
    {
        NSLog(@" ERROR: tried to process images w/o template");
        return;
    }
    //Notify UI of progress...
    imageTools *it = [[imageTools alloc] init];
    
    int MustUseImagesBecauseWeCantDeskewData = 0;
    if (MustUseImagesBecauseWeCantDeskewData!=0)
    {
        int numPages = 1; //(int)dbt.batchImages.count;
        for (int page=0;page<numPages;page++)
        {
            batchProgress = [NSString stringWithFormat:@"File %d/%d Page %d/%d",batchCount,batchTotal,page+1,numPages];
            [self.delegate batchUpdate : batchProgress];

            NSLog(@" OCR Image(not pdf) page %d of %d",page,numPages);
            UIImage *ii =  dbt.batchImages[page];
            if ([vendorRotation isEqualToString:@"-90"]) //Stupid, make this better!
                ii = [it rotate90CCW:ii];
            UIImage *deskewedImage = [it deskew:ii];
            //OUCH! THis has to be decoupled to handle the OCR returning on each image!
            [oto performOCROnImage:@"test.png" :ii :ot];
        }

    }
    else //OLD PDF DATA, potentially skewed!
    {
        NSData *data = dbt.batchImageData[0];  //Raw PDF data, need to process...
        NSString *ipath = dbt.batchFileList[0]; //[paths objectAtIndex:batchPage];
        NSValue *rectObj = dbt.batchImageRects[0]; //PDF size (hopefully!)
        CGRect imageFrame = [rectObj CGRectValue];
        NSLog(@"  ...PDF imageXYWH %d %d, %d %d",
              (int)imageFrame.origin.x,(int)imageFrame.origin.y,
              (int)imageFrame.size.width,(int)imageFrame.size.height);
        oto.vendor = vendorName;
        oto.imageFileName = ipath; //@"hawaiiBeefInvoice.jpg"; //ipath;
        [oto performOCROnData : ipath : data : imageFrame : ot];

    }
    


} //end processPDFPages

//=============(BatchObject)=====================================================
// Handles each page that came back, sends data to OCR scanner, called
//  asynchronously when dropboxTools calls delegate method didDownloadImages below
-(void) processPDFPagesOLD
{
    NSLog(@" batch:processPDFPages");
    if (!gotTemplate)
    {
        NSLog(@" ERROR: tried to process images w/o template");
        return;
    }
    batchProgress = [NSString stringWithFormat:@"Process File %d of %d",batchCount,batchTotal];
    [self.delegate batchUpdate : batchProgress];

    //Template MUST be ready at this point!
    batchPage = 0;
    NSData *data = dbt.batchImageData[0];  //Only one data set per file: MULTIPAGE!
    NSString *ipath = dbt.batchFileList[0]; //[paths objectAtIndex:batchPage];
    NSValue *rectObj = dbt.batchImageRects[0]; //PDF size (hopefully!)
    CGRect imageFrame = [rectObj CGRectValue];
    NSLog(@"  ...PDF imageXYWH %d %d, %d %d",
          (int)imageFrame.origin.x,(int)imageFrame.origin.y,
          (int)imageFrame.size.width,(int)imageFrame.size.height);
    oto.vendor = vendorName;
    oto.imageFileName = ipath; //@"hawaiiBeefInvoice.jpg"; //ipath;
    [oto performOCROnData : ipath : data : imageFrame : ot];
    //  [oto stubbedOCR : oto.imageFileName : [UIImage imageNamed:oto.imageFileName]  : ot];
} //end processPDFPages

//=============(BatchObject)=====================================================
// Hook up all errors into one CSV string for saving to parse
-(NSString *)packErrors
{
    NSString *errStr = @"";
    int i = 0;
    for (NSString *s in errorList)
    {
        errStr =  [errStr stringByAppendingString:s];
        if (i < errorList.count-1) errStr =  [errStr stringByAppendingString:@","];
        i++;
    }
    return errStr;
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
            pfo[PInv_BatchErrors_key]   = [self packErrors];  //There may be multiple errs in a batch...
            pfo[PInv_VersionNumber]     = self->_versionNumber;
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
    pdfEntries = a;
    [self startProcessingFiles];
}

//=============(BatchObject)=====================================================
- (void)errorGettingBatchList : (NSString *)s
{
    [self addError : s : @"n/a"];
}

//=============(BatchObject)=====================================================
// coming back from dropbox : # files in a folder
-(void) didCountEntries:(NSString *)vname :(int)count
{
    //NSLog(@" didcountp[%@]  %d",vname,count);
    if (count != 0)
    {
        [vendorFileCounts addObject:@{@"Vendor": vname,@"Count":[NSNumber numberWithInt:count]}];
        [vendorFolders setObject:dbt.entries forKey:vname];
    }
    returnCount++; //Count returns, did we hit all the vendors? let delegate know
    if (returnCount == vv.vFolderNames.count)
    {
        [self->_delegate didGetBatchCounts];
    }
} //end didCountEntries


//=============(BatchObject)=====================================================
- (void)didDownloadImages
{
    NSLog(@" ...downloaded all images? got %d",(int)dbt.batchImages.count);
    batchProgress = [NSString stringWithFormat:@"Fetch File %d of %d",batchCount,batchTotal];
    //At this point we have all the images for a file, ready to process!
    [self.delegate batchUpdate : batchProgress];
    [self updateParse];
    [self processPDFPages];
}


//=============(BatchObject)=====================================================
- (void)errorDownloadingImages : (NSString *)s
{
    [self addError : s : @"n/a"];
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
    [self addError : s : @"n/a"];
}


#pragma mark - OCRTopObjectDelegate

//=============(BatchObject)=====================================================
- (void)batchUpdate : (NSString *) s
{
    [self.delegate batchUpdate : s]; // pass the buck to parent
}


//=============(BatchObject)=====================================================
- (void)didPerformOCR : (NSString *) result
{
    NSLog(@" OCR OK page %d tp %d  count %d total %d",batchPage,batchTotalPages,batchCount,batchTotal);
    batchPage++;
    if (batchPage >= batchTotalPages)
    {
        [self processNextFile];
    }
}


//=============(BatchObject)=====================================================
- (void)errorPerformingOCR : (NSString *) errMsg
{
    [self addError : errMsg : @"n/a"];
}

//=============(BatchObject)=====================================================
- (void)didSaveOCRDataToParse : (NSString *) s
{
    NSLog(@" OK: full OCR -> DB done, invoice %@",s);
    batchStatus = BATCH_STATUS_COMPLETED;
    [self updateParse];
    NSString *actData = [NSString stringWithFormat:@"%@:%@",_batchID,vendorName];
    [act saveActivityToParse:@"Batch Completed" : actData];
    [self.delegate didCompleteBatch];
}


//=============(BatchObject)=====================================================
- (void)errorSavingEXP : (NSString *) errMsg : (NSString*) objectID
{
    //Record this error , gets saved with batch record
    [self addError : errMsg : objectID];
}



@end
