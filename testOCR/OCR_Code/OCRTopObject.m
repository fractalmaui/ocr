//
//  OCRTopObject.m
//  testOCR
//
//  Created by Dave Scruton on 12/22/18.
//  Copyright © 2018 huedoku. All rights reserved.
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
                _invoiceNumber = [od findLongInArrayOfFields:a];
                //This will have to be more robust
                _invoiceNumberString = [NSString stringWithFormat:@"%ld",_invoiceNumber];
                NSLog(@" invoice# %ld [%@]",_invoiceNumber,_invoiceNumberString);
            }
            else if ([fieldName isEqualToString:INVOICE_DATE_FIELD]) //Looking for a date?
            {
                [od dumpArray:a];
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
                    NSLog(@" error: NO HEADER FOUND!");
                    return;
                }
                columnDataTop = [od doc2templateY:headerY] + 1.5*od.glyphHeight;
                headerY -= 10;  //littie jiggle up...
                rr.origin.y = [od doc2templateY:headerY];  //Adjust our header rect to new header position!
                a = [od findAllWordsInRect:rr]; //Do another search now...
                NSLog(@"1: on headery...%d",(int)rr.origin.y);
                [od dumpArray:a];
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
            //[od dumpArray:a];
            [ot addHeaderColumnToSortedArray : i : headerY + od.glyphHeight];
        }
    }
    //We can only do columns after they are all loaded
    [od clearAllColumnStringData];
    NSMutableArray* rowYs; //overkill on rows too!
    NSMutableArray* rowY2s; //overkill on rows too!
    //Look at RH most column, that dictates row tops...
    int numCols = [ot getColumnCount];
    CGRect rrright = [ot getColumnByIndex:3];  //][od findPriceColumn]];
    rrright.origin.y = columnDataTop;
    rowYs = [od getColumnYPositionsInRect:rrright : TRUE];
    CGRect rrright2 = [ot getColumnByIndex:4] ; //[od findAmountColumn]];
    rrright2.origin.y = columnDataTop;
    rowY2s = [od getColumnYPositionsInRect:rrright2 : TRUE];
    //Assemble our columns...
    for (int i=0;i<numCols;i++)
    {
        CGRect rr = [ot getColumnByIndex:i];
        rr.origin.y = columnDataTop; //Adjust Y according to found header!
        NSMutableArray *stringArray;
        if (rowY2s.count > rowYs.count) //Get the column using the largest y row array we have
            stringArray = [od getColumnStrings : rr : rowY2s : i];
        else
            stringArray = [od getColumnStrings : rr : rowYs : i];
        NSMutableArray *cleanedUpArray = [od cleanUpPriceColumns : i : stringArray];
        [od addColumnStringData:cleanedUpArray];
    }
    
    //Now, columns are ready: let's dig them out!
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
    
    
    NSLog(@" OTO:invoice rows %@",rowItems);
    [self dumpResults];
    
} //end applyTemplate

//=============(OCRTopObject)=====================================================
// Fix things like missing prices, price typos, etc...
-(void) cleanupInvoice
{
    //NSLog(@"cleanupInvoice");
//DHS BOGUS!!! works only for HFM invoices!
    //    if (od.quantityColumn == 0) //Usually this is an error , item should be 0 and descr should be 2 for instance...
//        od.quantityColumn = od.itemColumn + 1;
    smartCount = 0;
    for (int i=0;i<od.longestColumn;i++)
    {
        NSMutableArray *ac = [od getRowFromColumnStringData : i];
        if (ac.count < 5)
        {
            NSLog(@" bad row pulled in EXP save!");
            return;
        }
        //NSLog(@" rec[%d] %@",i,ac);
        [smartp clear];
        [smartp addVendor:_vendor]; //Is this the right string?
        NSString *productName = ac[2]; //3rd column?
        [smartp addProductName:productName];
        [smartp addDate:_invoiceDate];
        [smartp addLineNumber:i+1];
        [smartp addAmount: ac[od.amountColumn]]; //column 5: RH total price
        [smartp addPrice: ac[od.priceColumn]]; //column 5: RH total price
        [smartp addQuantity : ac[od.quantityColumn]];
        int aerr = [smartp analyzeFull]; //fills out fields -> smartp.latest...
        if (smartp.analyzeOK) smartCount++;
        BOOL needNewPrices = TRUE; //Store in doc's postOCR area?
        if (aerr != 0)
        {
            NSLog(@" analyze error %@",[smartp getErrDescription:aerr]);
            if (aerr == ANALYZER_ZERO_PRICE || aerr == ANALYZER_ZERO_AMOUNT || aerr == ANALYZER_ZERO_QUANTITY)
            {
            }
            else if (aerr == ANALYZER_BAD_PRICE_COLUMNS)
            {
                needNewPrices = FALSE; //We are setting new prices here...
                [od setPostOCRQPA:i :smartp.latestQuantity : @"$ERR" : @"$ERR"];
            }
        }
        if (needNewPrices)
        {
            [od setPostOCRQPA:i :smartp.latestQuantity :smartp.latestPrice :smartp.latestAmount];
        }
    }
} //end cleanupInvoice


//=============(OCRTopObject)=====================================================
-(NSString *) getParsedText
{
    return parsedText;
}

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
    NSData *imageData = UIImageJPEGRepresentation(imageToOCR,0.0);
    CGRect r = CGRectMake(0, 0, imageToOCR.size.width, imageToOCR.size.height);
    [self performOCROnData: fname : imageData : r : ot];
} //end performOCROnImage


//=============(OCRTopObject)=====================================================
// Sends a JPG to the OCR server, and receives JSON text data back...
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
        OCRJSONResult = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&e];
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
//  informs delegate when done...
-(void) performFinalOCROnDocument : (CGRect) r : (OCRTemplate *)ot
{
    NSArray* pta = [self->OCRJSONResult valueForKey:@"ParsedText"];
    if (pta.count > 0) self->parsedText = pta[0];
    if (ot != nil) //Template needs to be applied?
    {
        NSLog(@" ...final OCR");
        //STUBBED!!! The document needs to XY limits of the image basically,
        //  WHERE do they come from? The PDF???
        [self setupDocument : r];    //Document page size, etc...
        [self applyTemplate : ot];   //Does OCR analysis
        [self cleanupInvoice];       //Fixes weird numbers, typos, etc...
        [self writeEXPToParse];      //Saves all EXP rows, then invoice as well
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
    //asdf
    CGRect r = CGRectMake(0, 0, imageToOCR.size.width, imageToOCR.size.height);
    [self setupDocument : r];
    [self applyTemplate:ot];
    [self cleanupInvoice];
    [self writeEXPToParse];

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
    NSDictionary *jdict = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&e];
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
-(void) setupDocument : (CGRect) r
{
    NSLog(@" setup doc...");
    //Do I need anything but the dictionary here??
    [od setupDocumentWithRect : r : OCRJSONResult ];
    tlRect = [od getTLRect];
    trRect = [od getTRRect];
    //NOTE: BL rect may be same as TLrect because it looks for leftmost AND bottommost!
    blRect = [od getBLRect];
    brRect = [od getBRRect];
    NSLog(@" Top LR from PDF %@ / %@",NSStringFromCGRect(tlRect),NSStringFromCGRect(trRect));
    
//    docRect = [od getDocRect]; //Get min/max limits of printed text
}


//=============(OCRTopObject)=====================================================
// Assumes invoice prices are in cleaned-up post OCR area...
//  also smartCount must be set!
-(void) writeEXPToParse
{
    [et clear];
    NSLog(@"  writeEXP...");
    for (int i=0;i<od.longestColumn;i++) //OK this does multiple parse saves at once!
    {
        NSMutableArray *ac = [od getRowFromColumnStringData : i];
        if (ac.count < 5)
        {
            NSLog(@" bad row pulled in EXP save!");
            return;
        }
        [smartp clear];
        [smartp addVendor:_vendor]; //Is this the right string?
        NSString *productName = ac[od.descriptionColumn]; //3rd column?
        [smartp addProductName:productName];
        [smartp addDate:_invoiceDate];
        [smartp addLineNumber:i+1];
        [smartp analyzeSimple]; //fills out fields -> smartp.latest...
        //NSLog(@" analyze OK %d",smartp.analyzeOK);
        if (smartp.analyzeOK) //Only save valid stuff!
        {
            [et addRecord:smartp.invoiceDate : smartp.latestCategory : smartp.latestShortDateString :
             ac[od.itemColumn] : smartp.latestUOM : smartp.latestBulkOrIndividual :
             _vendor : productName : smartp.latestProcessed :
             smartp.latestLocal : smartp.latestLineNumber : _invoiceNumberString :
             [od getPostOCRQuantity:i] : [od getPostOCRAmount:i] : [od getPostOCRPrice:i] :
             @"NoBatch" : @"NoErr" : _imageFileName];
        } //end analyzeOK
    } //end for loop
    [et saveToParse];
    
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
- (void)didSaveEXPTable  : (NSArray *)a
{
    //Time to setup invoice object too!
    [it clear];
    [it setupVendorTableName : _vendor];
    NSString *its = [NSString stringWithFormat:@"%4.2f",_invoiceTotal];
    its = [od cleanupPrice:its]; //Make sure total is formatted!
    [it setupVendorTableName:_vendor];
    [it setBasicFields:_invoiceDate : _invoiceNumberString : its : _vendor : _invoiceCustomer];
    for (NSString *objID in a) [it addInvoiceItemByObjectID : objID];
    [it saveToParse];
} //end didSaveEXPTable


//=============(OCRTopObject)=====================================================
- (void)didReadEXPTableAsStrings : (NSString *)s
{
    //spinner.hidden = TRUE;
    //[spinner stopAnimating];
    
    //[self mailit: s];
}

#pragma mark - invoiceTableDelegate
//=============OCR VC=====================================================
- (void)didSaveInvoiceTable:(NSString *) s
{
    [self->_delegate didSaveOCRDataToParse:s];
}



@end
