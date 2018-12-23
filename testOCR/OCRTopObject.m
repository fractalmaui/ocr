//
//  OCRTopObject.m
//  testOCR
//
//  Created by Dave Scruton on 12/22/18.
//  Copyright © 2018 huedoku. All rights reserved.
//

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
        smartp      = [[smartProducts alloc] init];

    }
    return self;
}



//=============(OCRTopObject)=====================================================
// Loop over template, find stuff in document?
- (void)applyTemplate : (OCRTemplate *)ot
{
    [ot clearHeaders];
    //Get invoice top left / top right limits from document, will be using
    // these to scale invoice by:
    CGRect tlOriginal = [ot getTLOriginalRect];
    CGRect trOriginal = [ot getTROriginalRect];
    [od setScalingRects];
    [od computeScaling : tlOriginal : trOriginal];
    
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
    
    for (int i=0;i<[ot getBoxCount];i++) //Loop over our boxes...
    {
        CGRect rr = [ot getBoxRect:i]; //In document coords!
        NSMutableArray *a = [od findAllWordsInRect:rr];
        //OK, let's go and get the field name to figure out what to do w data...
        NSString* fieldName = [ot getBoxFieldName:i];
        if (a.count > 0) //Found a match!
        {
            if ([fieldName isEqualToString:INVOICE_NUMBER_FIELD]) //Looking for a number?
            {
                invoiceNumber = [od findLongInArrayOfFields:a];
                //This will have to be more robust
                invoiceNumberString = [NSString stringWithFormat:@"%ld",invoiceNumber];
                NSLog(@" invoice# %ld [%@]",invoiceNumber,invoiceNumberString);
            }
            else if ([fieldName isEqualToString:INVOICE_DATE_FIELD]) //Looking for a date?
            {
                invoiceDate = [od findDateInArrayOfFields:a]; //Looks for things with slashes in them?
                NSLog(@" invoice date %@",invoiceDate);
            }
            else if ([fieldName isEqualToString:INVOICE_CUSTOMER_FIELD]) //Looking for Customer?
            {
                invoiceCustomer = [od findTopStringInArrayOfFields:a]; //Just get first line of template area
                NSLog(@" Customer %@",invoiceCustomer);
            }
            else if ([fieldName isEqualToString:INVOICE_SUPPLIER_FIELD]) //Looking for Supplier?
            {
                invoiceSupplier = [od findTopStringInArrayOfFields:a]; //Just get first line of template area
                BOOL matches = [ot isSupplierAMatch:invoiceSupplier]; //Check for rough match
                NSLog(@" Supplier %@, match %d",invoiceSupplier,matches);
            }
            else if ([fieldName isEqualToString:INVOICE_HEADER_FIELD]) //Header is SPECIAL!
            {
                [od parseHeaderColumns : a];
                columnHeaders = [od getHeaderNames];
                NSLog(@" headers %@",columnHeaders);
            }
            else if ([fieldName isEqualToString:INVOICE_TOTAL_FIELD]) //Looking for a number?
            {
                invoiceTotal = [od findPriceInArrayOfFields:a];
                NSLog(@" invoice Total %4.2f [%@]",invoiceTotal,[NSString stringWithFormat:@"%4.2f",invoiceTotal]);
            }
            
        } //end if a.count
        if ([fieldName isEqualToString:INVOICE_COLUMN_FIELD]) //Columns must be resorted from L->R...
        {
            [ot addHeaderColumnToSortedArray : i];
        }
    }
    //We can only do columns after they are all loaded
    [od clearAllColumnStringData];
    NSMutableArray* rowYs; //overkill on rows too!
    NSMutableArray* rowY2s; //overkill on rows too!
    //Look at RH most column, that dictates row tops...
    int numCols = [ot getColumnCount];
    CGRect rrright = [ot getColumnByIndex:3];  //][od findPriceColumn]];
    rowYs = [od getColumnYPositionsInRect:rrright : TRUE];
    CGRect rrright2 = [ot getColumnByIndex:4] ; //[od findAmountColumn]];
    rowY2s = [od getColumnYPositionsInRect:rrright2 : TRUE];
    //Assemble our columns...
    for (int i=0;i<numCols;i++)
    {
        CGRect rr = [ot getColumnByIndex:i];
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
    
    
    NSLog(@" invoice rows %@",rowItems);
    [self dumpResults];
    
} //end applyTemplate

//=============(OCRTopObject)=====================================================
// Fix things like missing prices, price typos, etc...
-(void) cleanupInvoice
{
    NSLog(@"cleanupInvoice");
    if (od.quantityColumn == 0) //Usually this is an error , item should be 0 and descr should be 2 for instance...
        od.quantityColumn = od.itemColumn + 1;
    smartCount = 0;
    for (int i=0;i<od.longestColumn;i++)
    {
        NSMutableArray *ac = [od getRowFromColumnStringData : i];
        if (ac.count < 5)
        {
            NSLog(@" bad row pulled in EXP save!");
            return;
        }
        NSLog(@" rec[%d] %@",i,ac);
        [smartp clear];
        [smartp addVendor:supplierName]; //Is this the right string?
        NSString *productName = ac[2]; //3rd column?
        [smartp addProductName:productName];
        [smartp addDate:invoiceDate];
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
    NSLog(@" dun %@",od);
} //end cleanupInvoice


//=============(OCRTopObject)=====================================================
// Sends a JPG to the OCR server, and receives JSON text data back...
- (void)performOCROnImage : (NSString*)imageName : (UIImage *)imageToOCR : (OCRTemplate *)ot
{
    // Create URL request
    NSURL *url = [NSURL URLWithString:@"https://api.ocr.space/Parse/Image"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"randomString";
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Image file and parameters, use hi compression quality?
    NSData *imageData = UIImageJPEGRepresentation(imageToOCR,0.0);  //[UIImage imageNamed:imageName], 0.8);
    NSDictionary *parametersDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                          @"99bb6b410288957", @"apikey",
                                          @"True", @"isOverlayRequired",
                                          @"True", @"isTable",
                                          @"True", @"scale",
                                          @"True", @"detectOrientation",
                                          @"eng", @"language", nil];
    
    // Create multipart form body
    NSData *data = [self createBodyWithBoundary:boundary
                                     parameters:parametersDictionary
                                      imageData:imageData
                                       filename:@"yourImage.jpg"];
    NSLog(@" send OCR request...");
    [request setHTTPBody:data];
    
    // Start data session
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        NSError* myError;
        NSLog(@" got response from server...");
        self->rawOCRResult = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        self->OCRJSONResult = [NSJSONSerialization JSONObjectWithData:data
                                                               options:kNilOptions
                                                                 error:&myError];
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
            // Handle result: load up document and apply template here
            NSLog(@" annnnd result is %@",self->OCRJSONResult);
            [self setupDocument];
            [self applyTemplate : ot];
            [self cleanupInvoice];
            ///NEED TO WRITE EXP TOO!!
            [self->_delegate didPerformOCR:@"OCR OK?"];
        }
    }];
    [task resume];
} //end callOCRSpace

//=============(OCRTopObject)=====================================================
-(void) stubbedOCR: (NSString*)imageName : (UIImage *)imageToOCR : (OCRTemplate *)ot
{
    NSString * stubbedDocName = @"beef";
    OCRJSONResult = [self readTxtToJSON:stubbedDocName];
    [self setupDocument];
    [self applyTemplate : ot];

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
        [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
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
-(void) setupDocument
{
    NSLog(@" setup doc...");
    //Do I need anything but the dictionary here??
    [od setupDocument : _imageFileName : OCRJSONResult : FALSE];
    tlRect = [od getTLRect];
    trRect = [od getTRRect];
    //NOTE: BL rect may be same as TLrect because it looks for leftmost AND bottommost!
    blRect = [od getBLRect];
    brRect = [od getBRRect];
//    docRect = [od getDocRect]; //Get min/max limits of printed text
}


//=============(OCRTopObject)=====================================================
-(void) dumpResults
{
    NSString *r = @"Invoice Parsed Results\n";
    r = [r stringByAppendingString:
         [NSString stringWithFormat:@"Supplier %@\n",invoiceSupplier]];
    r = [r stringByAppendingString:
         [NSString stringWithFormat: @"Number %ld  Date %@\n",invoiceNumber,invoiceDate]];
    r = [r stringByAppendingString:
         [NSString stringWithFormat:@"Customer %@  Total %f\n",invoiceCustomer,invoiceTotal]];
    r = [r stringByAppendingString:
         [NSString stringWithFormat:@"Columns:%@\n",columnHeaders]];
    r = [r stringByAppendingString:@"Invoice Rows:\n"];
    for (NSString *rowi in rowItems)
    {
        r = [r stringByAppendingString:[NSString stringWithFormat:@"[%@]\n",rowi]];
    }
    NSLog(@"dump[%@]",r);
    //[self alertMessage:@"Invoice Dump" :r];
    
}


@end
