//
//  OCRTopObject.m
//  testOCR
//
//  Created by Dave Scruton on 12/22/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//
//  This all revolves around OCR Space, an online free OCR system.
//   At higher data rates there is a fee, need more details
//   https://ocr.space/
//
//  12/28 integrated ocr cache

#import "OCRTopObject.h"

@implementation OCRTopObject

static OCRTopObject *sharedInstance = nil;

//=============(OCRTopObject)=====================================================
// Get the shared instance and create it if necessary.
+ (OCRTopObject *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    return sharedInstance;
}


//=============(OCRTopObject)=====================================================
-(instancetype) init
{
    if (self = [super init])
    {
        smartp      = [[smartProducts alloc] init];    // Product categorization / error checks
        od          = [[OCRDocument alloc] init];     // Document object: handles OCR searches/parsing
        rowItems    = [[NSMutableArray alloc] init]; // Invoice rows end up here
        oc          = [OCRCache sharedInstance];    // Cache: local OCR storage

        it = [[invoiceTable alloc] init];     // Parse DB: invoice storage
        it.delegate = self;
        et = [[EXPTable alloc] init];   // Parse DB: EXP line item storage
        et.delegate = self;
        act = [[ActivityTable alloc] init];


    }
    return self;
}



//=============(OCRTopObject)=====================================================
// Loop over template, find stuff in document?
// DOCUMENT MUST BE LOADED!!!
- (void)applyTemplate : (OCRTemplate *)ot
{
    [ot clearHeaders];
    //Get invoice top left / top right limits from document, will be using
    // these to scale invoice by:
    CGRect tlTemplate = [ot getTLOriginalRect];
    CGRect trTemplate = [ot getTROriginalRect];
    [od computeScaling : tlTemplate : trTemplate];
    
    _invoiceNumber   = 0L;
    _invoiceDate     = nil;
    _invoiceCustomer = nil;
    _invoiceVendor   = nil;
    
    //First add any boxes of content to ignore...
    for (int i=0;i<[ot getBoxCount];i++) //Loop over our boxes...
    {
        NSString* fieldName = [ot getBoxFieldName:i];
        if ([fieldName isEqualToString:INVOICE_IGNORE_FIELD])
        {
            CGRect rr = [ot getBoxRect:i]; //In document coords!
            [od addIgnoreBoxItems:rr];
        }
    }
    int headerY = 0;
    int columnDataTop = 0;
    for (int i=0;i<[ot getBoxCount];i++) //Loop over our boxes...
    {
        //OK, let's go and get the field name to figure out what to do w data...
        NSString* fieldName = [ot getBoxFieldName:i];
        CGRect rr = [ot getBoxRect:i]; //In document coords!
        NSMutableArray *a = [od findAllWordsInRect:rr];
        if (a.count > 0) //Found a match!
        {
            if ([fieldName isEqualToString:INVOICE_NUMBER_FIELD]) //Looking for a number?
            {
                //[od dumpArray:a];
                _invoiceNumber = [od findLongInArrayOfFields:a];
                //This will have to be more robust
                _invoiceNumberString = [NSString stringWithFormat:@"%ld",_invoiceNumber];
                NSLog(@" invoice# %ld [%@]",_invoiceNumber,_invoiceNumberString);
            }
            else if ([fieldName isEqualToString:INVOICE_DATE_FIELD]) //Looking for a date?
            {
                //[od dumpArray:a];
                _invoiceDate = [od findDateInArrayOfFields:a]; //Looks for things with slashes in them?
                NSLog(@" invoice date %@",_invoiceDate);
            }
            else if ([fieldName isEqualToString:INVOICE_CUSTOMER_FIELD]) //Looking for Customer?
            {
                _invoiceCustomer = [od findTopStringInArrayOfFields:a]; //Just get first line of template area
                NSLog(@" Customer %@",_invoiceCustomer);
            }
            else if ([fieldName isEqualToString:INVOICE_SUPPLIER_FIELD]) //Looking for Supplier?
            {
                _invoiceVendor = [od findTopStringInArrayOfFields:a]; //Just get first line of template area
                BOOL matches = [ot isSupplierAMatch:_invoiceVendor]; //Check for rough match
                NSLog(@" Supplier %@, match %d",_invoiceVendor,matches);
            }
            else if ([fieldName isEqualToString:INVOICE_HEADER_FIELD]) //Header is SPECIAL!
            {
                headerY = [od findHeader:rr :100]; //Get header ypos (document coords!!)
                if (headerY == -1)
                {
                    [self->_delegate errorPerformingOCR:@"Missing Invoice Header"];
                    return;
                }
                columnDataTop = [od doc2templateY:headerY] + 1.5*od.glyphHeight;
                headerY -= 10;  //littie jiggle up...
                rr.origin.y = [od doc2templateY:headerY];  //Adjust our header rect to new header position!
                a = [od findAllWordsInRect:rr]; //Do another search now...
                NSLog(@"1: on headery...%d",(int)rr.origin.y);
                //[od dumpArray:a];
                [od parseHeaderColumns : a];
                _columnHeaders = [od getHeaderNames];
                NSLog(@" headers %@",_columnHeaders);
            }
            else if ([fieldName isEqualToString:INVOICE_TOTAL_FIELD]) //Looking for a number?
            {
                _invoiceTotal = [od findPriceInArrayOfFields:a];
                NSLog(@" invoice Total %4.2f [%@]",_invoiceTotal,[NSString stringWithFormat:@"%4.2f",_invoiceTotal]);
            }
            
        } //end if a.count
        if ([fieldName isEqualToString:INVOICE_COLUMN_FIELD]) //Columns must be resorted from L->R...
        {
            //CGRect dr = [od template2DocRect:rr];
            //NSLog(@"templateRect %@",NSStringFromCGRect(rr));
            //NSLog(@"documentRect %@",NSStringFromCGRect(dr));
            //NSLog(@" column found==================");
            //[od dumpArrayFull:a];
            [ot addHeaderColumnToSortedArray : i : headerY + od.glyphHeight];
        }
    }
    //We can only do columns after they are all loaded
    [od clearAllColumnStringData];
    NSMutableArray* rowYs; //overkill on rows too!
    NSMutableArray* rowY2s; //overkill on rows too!
    //Look at RH most column, that dictates row tops...
    int numCols = [ot getColumnCount];
    if (numCols < 4)  //We need at least Quantity : Description : Price : Amount
    {
        [self->_delegate errorPerformingOCR:@"Missing Invoice Columns"];
        return;
    }
    //Get Y position of data in both price and amount columns...
    CGRect rrright = [ot getColumnByIndex:od.priceColumn];
    rrright.origin.y = columnDataTop;
    //NOTE: rowYs and rowY2s are already in DOCUMENT coords!
    rowYs = [od getColumnYPositionsInRect:rrright : TRUE];
    CGRect rrright2 = [ot getColumnByIndex:od.amountColumn] ;
    rrright2.origin.y = columnDataTop;
    rowY2s = [od getColumnYPositionsInRect:rrright2 : TRUE];
    //Merge these two together, toss dupes (redudancy in case of missing or smudged column data)
    NSMutableArray *allys = [NSMutableArray arrayWithArray:rowYs];
    [allys addObjectsFromArray:rowY2s]; //concatenate arrays...
    NSArray *sortedArray = [allys sortedArrayUsingSelector: @selector(compare:)];
    NSMutableArray *finalYs = [[NSMutableArray alloc] init];
    NSNumber *lastY = [NSNumber numberWithDouble:-9999.0];
    for (NSNumber *nextY in sortedArray)
    {
        int dy = nextY.doubleValue - lastY.doubleValue;
        if (dy > od.glyphHeight) [finalYs addObject:nextY];
        lastY = nextY;
    }
    
    // Get columns,use Y positions above to find each row...
    for (int i=0;i<numCols;i++)
    {
        CGRect rr = [ot getColumnByIndex:i];
        rr.origin.y = columnDataTop; //Adjust Y according to found header!
        NSMutableArray *stringArray;
        stringArray = [od getColumnStrings : rr : finalYs : i];
        NSMutableArray *cleanedUpArray = [od cleanUpPriceColumns : i : stringArray];
        [od addColumnStringData:cleanedUpArray];
        //NSLog(@" col[%d] cleanup %@",i,cleanedUpArray);
    }
    
    //Now, columns are ready: let's dig them out!
    if (od.longestColumn < 2) //Must be an error? Not enough rows!
    {
        [self->_delegate errorPerformingOCR:@"Missing Invoice Rows"];
        return;
    }

    [rowItems removeAllObjects];
    for (int i=0;i<od.longestColumn;i++)
    {
        NSMutableArray *ac = [od getRowFromColumnStringData : i];
        //NSLog(@"annnd row %d is %@",i,ac);
        NSString *rowString = @"";
        for (int j=0;j<(int)ac.count;j++)
        {
            NSString *formatStr = @"%@,";
            if (j == (int)ac.count-1) formatStr = @"%@"; //last field
            rowString = [rowString stringByAppendingString:
                         [NSString stringWithFormat:formatStr,[ac objectAtIndex:j]]];
        }
        [rowItems addObject:rowString];
    }
    
    
    //Report errs as needed... any or all may be possible!
    if (_invoiceNumber   == 0L)
        [self->_delegate errorPerformingOCR:@"Missing Invoice Number"];
    if (_invoiceDate     == nil)
        [self->_delegate errorPerformingOCR:@"Missing Invoice Date"];
    if (_invoiceCustomer     == nil)
        [self->_delegate errorPerformingOCR:@"Missing Invoice Customer"];
//Ignore for now
//    if (_invoiceVendor     == nil)
//        [self->_delegate errorPerformingOCR:@"Missing Invoice Vendor"];
    
    //NSLog(@" OTO:invoice rows %@",rowItems);
    [self dumpResults];
    
} //end applyTemplate



//=============(OCRTopObject)=====================================================
//-(NSString *) getParsedText
//{
//    return parsedText;
//}

//=============(OCRTopObject)=====================================================
-(NSString *) getRawResult
{
    return rawOCRResult;
}


//=============(OCRTopObject)=====================================================
// Sends a JPG to the OCR server, and receives JSON text data back...
- (void)performOCROnImage : (NSString *)fname : (UIImage *)imageToOCR : (OCRTemplate *)ot
{
    // Image file and parameters, use hi compression quality?
    NSData *imageData = UIImagePNGRepresentation(imageToOCR);
    CGRect r = CGRectMake(0, 0, imageToOCR.size.width, imageToOCR.size.height);
    _imageFileName = fname;
    [self performOCROnData: fname : imageData : r : ot];
} //end performOCROnImage


//=============(OCRTopObject)=====================================================
// Sends a JPG to the OCR server, and receives JSON text data back...
//  OCR handles multiple pages from PDF data!
- (void)performOCROnData : (NSString *)fname : (NSData *)imageDataToOCR : (CGRect) r :  (OCRTemplate *)ot
{
    //First, check cache: may already have downloaded OCR raw txt for this file...
    if ([oc txtExistsByID:fname])
    {
        NSLog(@" Cache HIT: perform OCR on cached file...%@",fname);
        rawOCRResult  = [oc getTxtByID:fname];  //Raw OCR'ed text, needs to goto JSON
        r             = [oc getRectByID:fname]; //Get cached image size too...
        NSData *jsonData = [rawOCRResult dataUsingEncoding:NSUTF8StringEncoding];
        NSError *e;
        OCRJSONResult = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers error:&e];
        if (e != nil) NSLog(@" ....json err? %@",e.localizedDescription);
        [self performFinalOCROnDocument : r : ot ]; //This calls delegate when done
        return; //Bail!
    }
    // Create URL request
    NSURL *url = [NSURL URLWithString:@"https://api.ocr.space/Parse/Image"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"randomString";
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    NSDictionary *parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          @"99bb6b410288957", @"apikey",
                                          @"True", @"isOverlayRequired",
                                          @"True", @"isTable",
                                          @"True", @"scale",
                                          @"True", @"detectOrientation",
                                          @"eng", @"language", nil];
    
    // Create multipart form body
    //NOTE We could be passing PDF directly here, just using the NSData alone!
    //  the OCR handles raw PDF data too!!!
    NSData *data = [self createBodyWithBoundary:boundary
                                     parameters:parametersDictionary
                                      imageData:imageDataToOCR
                                       filename:_imageFileName ];  //@"dog.jpg"]; ///imageName];
    NSLog(@" send OCR request... %@",_imageFileName);
    [request setHTTPBody:data];
    
    // Start data session
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError* myError;
        NSLog(@" got response from server...");
        if (error != nil) //Task came back w/ error?
        {
            NSNumber* exitCode     = [self->OCRJSONResult valueForKey:@"OCRExitCode"];
            NSString* errDesc;
            switch(exitCode.intValue)
            {
                case 2: errDesc = @"OCR only parsed partially";break;
                case 3: errDesc = @"OCR failed to parse image";break;
                case 4: errDesc = @"OCR internal error";break;
            }
            if (errDesc == nil)errDesc = error.localizedDescription;
            [self->_delegate errorPerformingOCR:errDesc];
        }
        else
        {
            self->rawOCRResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            [self->oc addOCRTxtWithRect:fname :r:self->rawOCRResult];
            self->OCRJSONResult = [NSJSONSerialization JSONObjectWithData:data
                                                                  options:kNilOptions
                                                                    error:&myError];
            // Handle result: load up document and apply template here
            //OUCH! need to look for the IsErroredOnProcessing item here, and  ErrorMessage!
            //  bad files set this and then have bogus data which crashes OCR below!
            NSNumber *isErr = [self->OCRJSONResult valueForKey:@"IsErroredOnProcessing"];
            NSArray* ea = [self->OCRJSONResult valueForKey:@"ErrorMessage"];
            NSString* errMsg = ea[0];
            if (isErr.boolValue)
            {
                [self->_delegate errorPerformingOCR:errMsg];
            }
            else
            {
                NSLog(@" annnnd result from OCR server is %@",self->OCRJSONResult);
                [self performFinalOCROnDocument : r : ot]; //This calls delegate when done
            }
        }
    }];
    [task resume];
} //end performOCROnData

//=============(OCRTopObject)=====================================================
// JSON result may be from OCR server return OR from cache hit. needs template.
//  informs delegate when done... called by performOCROnData
// NOTE: document may have multiple pages!
-(void) performFinalOCROnDocument : (CGRect) r : (OCRTemplate *)ot
{
    if (ot != nil) //Template needs to be applied?
    {
        NSLog(@" ...final OCR");
        pagesReturned = 0;
        // This eats up the json and creates a set of OCR boxes, in
        //  an array: one set per page...
        [od setupDocumentWithRect : r : OCRJSONResult ];
        pageCount = od.numPages; //OK! now we know how many pages we have
        totalLines = 0; //Overall line count...
        for (int page =0;page<pageCount;page++)
        {
            NSLog(@" Final OCR Page %d",page);
            //Hand progress up to parent for UI update...
            [self.delegate batchUpdate : [NSString stringWithFormat:@"Page %d/%d -> OCR",page+1,od.numPages]];
            [od setupPage:page];
            [self applyTemplate : ot];   //Does OCR analysis
            NSLog(@" Cleanup invoice...");
            [self writeEXPToParse : page];      //Saves all EXP rows, then invoice as well
        }
    }
    [self->_delegate didPerformOCR:@"OCR OK?"];

}

//=============(OCRTopObject)=====================================================
-(void) stubbedOCR: (NSString*)imageName : (UIImage *)imageToOCR : (OCRTemplate *)ot
{
    NSString * stubbedDocName = @"lilbeef";
    _imageFileName = imageName; //selectFnameForTemplate;
    OCRJSONResult = [self readTxtToJSON:stubbedDocName];
    [self setupTestDocumentJSON:OCRJSONResult];
    CGRect r = CGRectMake(0, 0, imageToOCR.size.width, imageToOCR.size.height);
    [od setupDocumentWithRect : r : OCRJSONResult ];
    [self applyTemplate:ot];
    [self writeEXPToParse : 0];

}


//=============(OCRTopObject)=====================================================
// for testing only
-(NSDictionary*) readTxtToJSON : (NSString *) fname
{
    NSError *error;
    NSArray *sItems;
    NSString *fileContentsAscii;
    NSString *path = [[NSBundle mainBundle] pathForResource:fname ofType:@"txt" inDirectory:@"txt"];
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [NSURL fileURLWithPath:path];
    fileContentsAscii = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:&error];
    sItems    = [fileContentsAscii componentsSeparatedByString:@"\n"];
    NSData *jsonData = [fileContentsAscii dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e;
    NSDictionary *jdict = [NSJSONSerialization JSONObjectWithData:jsonData
                                                          options:NSJSONReadingMutableContainers error:&e];
    if (e != nil) NSLog(@" Error: %@",e.localizedDescription);
    return jdict;
}

//=============(OCRTopObject)=====================================================
- (NSData *) createBodyWithBoundary:(NSString *)boundary parameters:(NSDictionary *)parameters imageData:(NSData*)data filename:(NSString *)filename
{
    NSMutableData *body = [NSMutableData data];
    
    if (data) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n", @"file", filename] dataUsingEncoding:NSUTF8StringEncoding]];
        //DHS TEST FOR PDF DATA ONLY
        [body appendData:[@"Content-Type: image/pdf\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
//        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:data];
        [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    for (id key in parameters.allKeys) {
        [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:[[NSString stringWithFormat:@"%@\r\n", parameters[key]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    return body;
}

//=============(OCRTopObject)=====================================================
-(void) setupTestDocumentJSON : (NSDictionary *) json
{
    OCRJSONResult = json;
}

//=============(OCRTopObject)=====================================================
// Just a handoff to outer objects that don't have the json result...
-(void) setupDocumentFrameAndParseJSON : (CGRect) r
{
    NSLog(@" setup doc...");
    [od setupDocumentWithRect : r : OCRJSONResult ];
}


//=============(OCRTopObject)=====================================================
// DOES FULL CLEANUP AND saves to EXP...
// Assumes invoice prices are in cleaned-up post OCR area...
//  also smartCount must be set!
-(void) writeEXPToParse : (int) page
{
    smartCount  = 0;
    [et clear]; //Set up EXP for new entries...
    NSLog(@"  writeEXP/cleanup...");
    if (page == pageCount-1) [self.delegate batchUpdate : [NSString stringWithFormat:@"Save EXP..."]];

    for (int i=0;i<od.longestColumn;i++) //OK this does multiple parse saves at once!
    {
        NSMutableArray *ac = [od getRowFromColumnStringData : i];
        if (ac.count < 5)
        {
            NSLog(@" bad row pulled in EXP save!");
            return;
        }
        //item,description ... Note: these columns are determined at runtime!
        //NSString *item        = ac[od.itemColumn];
        NSString *productName = ac[od.descriptionColumn];  
        [smartp clear];
        [smartp addVendor:_vendor]; //Is this the right string?
        [smartp addProductName:productName];
        [smartp addDate:_invoiceDate];
        [smartp addLineNumber:i+1];
        [smartp addVendor:_vendor]; //Is this the right string?
        //Quantity,Price,Amount ... Note: these columns are determined at runtime!
        [smartp addPrice: ac[od.priceColumn]];
        [smartp addAmount: ac[od.amountColumn]];
        [smartp addQuantity : ac[od.quantityColumn]];

        if ([productName containsString:@"ICED"])
            NSLog(@" asdf bing ICED");
        int aError = [smartp analyze]; //fills out fields -> smartp.analyzed...
        NSLog(@" analyze OK %d [%@]->%@",smartp.analyzeOK,productName, smartp.analyzedProductName);
        if (aError == 0) //Only save valid stuff!
        {
            NSString *errStatus = @"OK";
            if (smartp.majorError != 0) //Major error trumps minor one...
                errStatus = [NSString stringWithFormat:@"E:%@",[smartp getMajorErrorString]];
            else if (smartp.minorError != 0) //Minor error? encode!
                errStatus = [NSString stringWithFormat:@"W:%@",[smartp getMinorErrorString]];
            smartCount++;
            //Format line count to triple digits, max 999
            NSString *lineString = [NSString stringWithFormat:@"%3.3d",(totalLines + smartCount)];
            //Tons of args: adds allll this shit to the next EXP table entry for saving to parse...
            [et addRecord:smartp.invoiceDate : smartp.analyzedCategory : smartp.analyzedShortDateString :
             ac[od.itemColumn] : smartp.analyzedUOM : smartp.analyzedBulkOrIndividual :
             _vendor : smartp.analyzedProductName : smartp.analyzedProcessed :
             smartp.analyzedLocal : lineString : _invoiceNumberString :
             smartp.analyzedQuantity : smartp.analyzedPrice : smartp.analyzedAmount :
//             [od getPostOCRQuantity:i] : [od getPostOCRPrice:i] : [od getPostOCRAmount:i] :
                _batchID : errStatus : _imageFileName : [NSNumber numberWithInt:page]  ];
        } //end analyzeOK
        else //Bad product ID? Report error
        {
            if (!smartp.nonProduct) //Ignore non-products (charges, etc) else report error
            {
                NSLog(@" ---->ERROR: bad product name %@",productName);
                NSString *s = [NSString stringWithFormat:@"E:Bad Product Name (%@)",productName];
                [self->_delegate errorSavingEXP:s:@"n/a":productName];
            }
        }
    } //end for loop
    BOOL lastPageToDo = (page == pageCount-1);
    [et saveToParse : page : lastPageToDo];
    totalLines += smartCount;

    
} //end writeEXPToParse


//=============(OCRTopObject)=====================================================
-(NSString *) dumpResults
{
    NSString *r = @"Invoice Parsed Results\n";
    r = [r stringByAppendingString:
         [NSString stringWithFormat:@"Supplier %@\n",_vendor]];
    r = [r stringByAppendingString:
         [NSString stringWithFormat: @"Number %ld  Date %@\n",_invoiceNumber,_invoiceDate]];
    r = [r stringByAppendingString:
         [NSString stringWithFormat:@"Customer %@  Total %f\n",_invoiceCustomer,_invoiceTotal]];
    r = [r stringByAppendingString:
         [NSString stringWithFormat:@"Columns:%@\n",_columnHeaders]];
    r = [r stringByAppendingString:@"Invoice Rows:\n"];
    for (NSString *rowi in rowItems)
    {
        r = [r stringByAppendingString:[NSString stringWithFormat:@"[%@]\n",rowi]];
    }
    NSLog(@"dump[%@]",r);
    return r;
    //[self alertMessage:@"Invoice Dump" :r];
    
}

#pragma mark - EXPTableDelegate
//=============(OCRTopObject)=====================================================
// An EXP table set gets saved EACH PAGE. When we have done all the pages,
//  then the invoice gets saved!
- (void)didSaveEXPTable  : (NSArray *)a
{
    //NSLog(@"didsaveEXP, page %d of %d",pagesReturned,pageCount);
    if (pagesReturned == 0) //First page, set up invoice
    {
        NSLog(@"First page return: invoice init");
        //Time to setup invoice object too!
        [it clear];
        [it setupVendorTableName : _vendor];
        [it setupVendorTableName:_vendor];
        //Note: Total field is empty, we don't necessarily have it on first page!
        [it setBasicFields:_invoiceDate : _invoiceNumberString : @"" : _vendor : _invoiceCustomer];
    }
    pagesReturned++;
    NSString *astr = [NSString stringWithFormat:@"...save EXP page %d of %d",pagesReturned,pageCount];
    [act saveActivityToParse : astr : _invoiceNumberString];
} //end didSaveEXPTable


//=============(OCRTopObject)=====================================================
// called when Allll exps are saved in one invoice from all the pages
- (void)didFinishAllEXPRecords : (NSArray *)a;
{
    for (NSString *objID in a) [it addInvoiceItemByObjectID : objID];
    //NSLog(@" finished EXP saves, save invoice");
    //For every page, add entries to invoice...
    [self.delegate batchUpdate : [NSString stringWithFormat:@"Save Invoice %@",_invoiceNumberString]];
    [act saveActivityToParse:@"...save Invoice" : _invoiceNumberString];
    NSString *its = [NSString stringWithFormat:@"%4.2f",_invoiceTotal];
    its = [od cleanupPrice:its]; //Make sure total is formatted!
    [it saveToParse];

}

//=============(OCRTopObject)=====================================================
- (void)didReadEXPTableAsStrings : (NSString *)s
{
    //spinner.hidden = TRUE;
    //[spinner stopAnimating];
    
    //[self mailit: s];
}


//=============OCR VC=====================================================
// Error in an EXP record; pass on to batch for storage
- (void)errorInEXPRecord : (NSString *)err : (NSString *)oid : (NSString *)productName
{
    [self->_delegate errorSavingEXP : err : oid : productName];  // -> BatchObject (bbb)
}


#pragma mark - invoiceTableDelegate
//=============OCR VC=====================================================
- (void)didSaveInvoiceTable:(NSString *) s
{
    [self->_delegate didSaveOCRDataToParse:s];  // -> BatchObject (bbb)
}



@end
