//
//  ViewController.m
//  testOCR
//
//  Created by Dave Scruton on 12/3/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//
//  CSV Columns for Exp Sheet Example.xlsx
// Category,Month,Item,Quantity, Unit of Measure, Bulk/Individual Pack , Vendor Name, Total Price, Price/UOM , Processed, Local, Invoice Date, Line#
// Here's more info:
//   https://ocr.space/ocrapi/confirmation
//   https://github.com/A9T9/OCR.Space-OCR-API-Code-Snippets/blob/master/ocrapi.m
// OUCH: deskew!
//   https://stackoverflow.com/questions/48792790/calculating-skew-angle-using-opencv-in-ios
//  needs openCV?
//  https://www.codeproject.com/Articles/104248/%2fArticles%2f104248%2fDetect-image-skew-angle-and-deskew-image
//  simple deskew?
//
//  In Adjust mode, zoom in??
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

//=============OCR VC=====================================================
-(id)initWithCoder:(NSCoder *)aDecoder {
    if ( !(self = [super initWithCoder:aDecoder]) ) return nil;

    od = [[OCRDocument alloc] init];
    ot = [[OCRTemplate alloc] init];
    arrowStepSize = 5;
    editing = adjusting = FALSE;
    invoiceDate = [[NSDate alloc] init];
    rowItems    = [[NSMutableArray alloc] init];
    EXPDump     = [[NSMutableArray alloc] init];
    smartp      = [[smartProducts alloc] init];
    return self;
}


//=============OCR VC=====================================================
-(void) loadView
{
    [super loadView];
    CGSize csz   = [UIScreen mainScreen].bounds.size;
    viewWid = (int)csz.width;
    viewHit = (int)csz.height;
    viewW2  = viewWid/2;
    viewH2  = viewHit/2;
}

//=============OCR VC=====================================================
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    //parse test
    [self testit];
    _LHArrowView.hidden = TRUE;
    _RHArrowView.hidden = TRUE;
    pageRect = _inputImage.frame;

}

//=============OCR VC=====================================================
- (void)viewWillLayoutSubviews {
    //Make sure screen has settled before adding overlays!
    [self refreshOCRBoxes];
    if (selectBox == nil) //Add selection box...
    {
        selectDocRect = CGRectMake(0, 0, 100, 100); //
        selectBox = [[UIView alloc] initWithFrame:[self documentToScreenRect:selectDocRect]];
        selectBox.backgroundColor = [UIColor colorWithRed:0.5 green:0.0 blue:0.0 alpha:0.5];
        [_selectOverlayView addSubview:selectBox];
        selectBox.hidden = TRUE;

    }
}

//=============OCR VC=====================================================
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    dragging = YES;
//    CGPoint center;
//    int i,tx,ty,xoff,yoff,xytoler;
    UITouch *touch  = [[event allTouches] anyObject];
    touchLocation   = [touch locationInView:_inputImage];
    touchX          = touchLocation.x;
    touchY          = touchLocation.y;
    touchDocX = [self screenToDocumentX : touchX ];
    touchDocY = [self screenToDocumentY : touchY ];
    int docXoff = od.docRect.origin.x; //Top left text corner in document...
    int docYoff = od.docRect.origin.y;
    touchDocX+=docXoff;
    touchDocY+=docYoff;
    NSLog(@" touchDown xy %d %d doc %d %d", touchX, touchY,touchDocX,touchDocY);
    adjustSelect = [ot hitField:touchDocX :touchDocY];
    NSLog(@" ... hit %d",adjustSelect);
    if (adjustSelect != -1)
    {
        [self promptForAdjust:self];
    }
}

//=============OCR VC=====================================================
- (void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event allTouches] anyObject];
    touchLocation = [touch locationInView:_inputImage];
    //int   xi,yi;
    touchX = touchLocation.x;
    touchY = touchLocation.y;
    touchDocX = [self screenToDocumentX : touchX ];
    touchDocY = [self screenToDocumentY : touchY ];
    
    NSLog(@" touchMoved xy %d %d doc %d %d", touchX, touchY,touchDocX,touchDocY);
    int hitIndex = [ot hitField:touchDocX :touchDocY];
    NSLog(@" ... hit %d",hitIndex);

}

//==========createVC=========================================================================
- (void) touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    dragging = NO;
    NSLog(@" touchEnded");
} //end touchesEnded


//=============OCR VC=====================================================
// Clears and adds OCR boxes as defined in the OCRTemplate
-(void) refreshOCRBoxes
{
    //Clear overlay...
    NSArray *viewsToRemove = [_overlayView subviews];
    for (UIView*v in viewsToRemove) [v removeFromSuperview];
    for (int i=0;i<[ot getBoxCount];i++)
    {
        CGRect rr = [ot getBoxRect:i]; //In document coords!
        //Add in top/left doc text corner to get absolute doc XY
        int docXoff = od.docRect.origin.x; //Top left text corner in document...
        int docYoff = od.docRect.origin.y;
        rr.origin.x += docXoff;
        rr.origin.y += docYoff;
        int xi = [self documentToScreenX:rr.origin.x];
        int yi = [self documentToScreenY:rr.origin.y];
        int xs = (int)((double)rr.size.width  / docXConv);
        int ys = (int)((double)rr.size.height / docYConv);
        UIView *v =  [[UIView alloc] initWithFrame:CGRectMake(xi, yi, xs, ys)];
        NSString *fieldName = [ot getBoxFieldName : i];
        if ([fieldName isEqualToString:INVOICE_IGNORE_FIELD])
            v.backgroundColor = [UIColor colorWithRed:0.8 green:0.9 blue:0.0 alpha:0.6]; //Yellowish
        else if (
                 [fieldName isEqualToString:INVOICE_NUMBER_FIELD] ||
                 [fieldName isEqualToString:INVOICE_DATE_FIELD] ||
                 [fieldName isEqualToString:INVOICE_CUSTOMER_FIELD] ||
                 [fieldName isEqualToString:INVOICE_HEADER_FIELD] ||
                 [fieldName isEqualToString:INVOICE_TOTAL_FIELD]
                 )
            v.backgroundColor = [UIColor colorWithRed:0.0 green:0.8 blue:0.8 alpha:0.6];  //Cyan
        else
            v.backgroundColor = [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:0.6];  //Grey
        [_overlayView addSubview:v];
    }
} //end refreshOCRBoxes

//=============OCR VC=====================================================
-(void) testit
{
    NSLog(@" Load stubbed OCR data...");
    NSDictionary *d = [self readTxtToJSON:@"beef"];
    supplierName = @"Hawaii Beef Producers";
    selectFname  = @"hawaiiBeefInvoice.jpg";
    [od setupDocument : selectFname : d];
    tlRect = [od getTLRect];
    trRect = [od getTRRect];
    //NOTE: BL rect may be same as TLrect because it looks for leftmost AND bottommost!
    blRect = [od getBLRect];
    brRect = [od getBRRect];
    docRect = [od getDocRect]; //Get min/max limits of printed text
    CGRect r = _inputImage.frame;
    //Screen -> Document conversion
    docXConv = (double)od.width  / (double)r.size.width;
    docYConv = (double)od.height / (double)r.size.height;

}



//=============OCR VC=====================================================
// Loop over template, find stuff in document?
- (void)applyTemplate
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
        int docXoff = od.docRect.origin.x; //Top left text corner in document...
        int docYoff = od.docRect.origin.y;
        //Add in top/left doc text corner to get absolute doc XY
        rr.origin.x += docXoff;
        rr.origin.y += docYoff;
        NSMutableArray *a = [od findAllWordsInRect:rr];
        //OK, let's go and get the field name to figure out what to do w data...
        NSString* fieldName = [ot getBoxFieldName:i];
        if (a.count > 0) //Found a match!
        {
            if ([fieldName isEqualToString:INVOICE_NUMBER_FIELD]) //Looking for a number?
            {
                invoiceNumber = [od findIntInArrayOfFields:a];
                //This will have to be more robust
                invoiceNumberString = [NSString stringWithFormat:@"%d",invoiceNumber];
                NSLog(@" invoice# %d [%@]",invoiceNumber,invoiceNumberString);
            }
            else if ([fieldName isEqualToString:INVOICE_DATE_FIELD]) //Looking for a date?
            {
                invoiceDate = [od findDateInArrayOfFields:a]; //Looks for things with slashes in them?
                NSLog(@" invoice date %@",invoiceDate);
            }
            else if ([fieldName isEqualToString:INVOICE_CUSTOMER_FIELD]) //Looking for customer?
            {
                invoiceCustomer = [od findTopStringInArrayOfFields:a]; //Just get first line of template area
                NSLog(@" customer %@",invoiceCustomer);
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
    //Look at RH most column, that dictates row tops...
    int numCols = [ot getColumnCount];
    CGRect rrright = [ot getColumnByIndex:numCols-1];
    rowYs = [od getColumnYPositionsInRect:rrright];
    for (int i=0;i<numCols;i++)
    {
        CGRect rr = [ot getColumnByIndex:i];
        NSMutableArray *stringArray = [od getColumnStrings : rr : rowYs];
        [od addColumnStringData:stringArray];
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
    
    //Let's try getting a form for pam now...
    [self writeEXPToParse];
} //end applyTemplate

//=============OCR VC=====================================================
-(void) writeEXPToParse
{
    for (int i=0;i<od.longestColumn;i++)
    {
        NSMutableArray *ac = [od getRowFromColumnStringData : i];
        NSLog(@" ac %@",ac);
        [smartp clear];
        [smartp addVendor:supplierName]; //Is this the right string?
        NSString *productName = ac[2]; //3rd column?
        [smartp addProductName:productName];
        [smartp addDate:invoiceDate];
        [smartp addLineNumber:i+1];
        [smartp addRawPrice: ac[4]]; //column 5: RH total price
        [smartp analyze]; //fills out fields -> smartp.latest...
        if (smartp.analyzeOK) //Only save valid stuff!
        {
            //Package up our fields...
            PFObject *nextEXPRecord = [PFObject objectWithClassName:@"EXPFullTable"];
            nextEXPRecord[PInv_Category_key]    = smartp.latestCategory;
            nextEXPRecord[PInv_Month_key]       = smartp.latestShortDateString; //DD-MMM?
            nextEXPRecord[PInv_Quantity_key]    = ac[0]; //Quantity:first column from invoice table
            nextEXPRecord[PInv_Item_key]        = ac[1]; //item code:2nd column
            nextEXPRecord[PInv_UOM_key]         = smartp.latestUOM;
            nextEXPRecord[PInv_Bulk_or_Individual_key] = smartp.latestBulkOrIndividual;
            nextEXPRecord[PInv_Vendor_key]      = smartp.latestVendor;
            nextEXPRecord[PInv_TotalPrice_key]  = smartp.latestTotalPrice;
            nextEXPRecord[PInv_PricePerUOM_key] = ac[3]; //column 4, next to RH!
            nextEXPRecord[PInv_Processed_key]   = smartp.latestProcessed;
            nextEXPRecord[PInv_Local_key]       = smartp.latestLocal;
            nextEXPRecord[PInv_Date_key]        = smartp.invoiceDate; //ONLY column that ain't a String!
            nextEXPRecord[PInv_LineNumber_key]  = smartp.latestLineNumber;
            nextEXPRecord[PInv_InvoiceNumber_key]  = invoiceNumberString;

            [nextEXPRecord saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    NSLog(@" ...nextEXP: saved to parse %@",self->smartp.latestLineNumber);
                    //  [self.delegate didSaveUniqueUserToParse];
                } else {
                    NSLog(@" ...nextEXP: ERROR: %@",error.localizedDescription);
                }
            }]; //end saveinBackground

        } //end analyzeOK
    } //end for loop
} //end getEXPForm


//=============OCR VC=====================================================
-(void) loadEXPFromParseAsStrings : (BOOL) dumptoCSV
{
    if (dumptoCSV) EXPDumpCSVList = @"CATEGORY,Month,Item,Quantity,Unit Of Measure,BULK/ INDIVIDUAL PACK,Vendor Name, Total Price ,PRICE/ UOM,PROCESSED ,Local (L),Invoice Date,Line #,Invoice #,\n";
    PFQuery *query = [PFQuery queryWithClassName:@"EXPFullTable"];
    [query orderByAscending:PInv_LineNumber_key];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) { //Query came back...
            [self->EXPDump removeAllObjects];
            int i     = 0;
            //int count = (int)objects.count;
            
            for( PFObject *pfo in objects)
            {
                NSString *quantity = @"";
                NSString *item     = @"";
                self->smartp.latestShortDateString = [pfo objectForKey:PInv_Month_key];
                self->smartp.latestCategory        = [pfo objectForKey:PInv_Category_key];
                quantity                     = [pfo objectForKey:PInv_Quantity_key];
                item                         = [pfo objectForKey:PInv_Item_key];
                self->smartp.latestUOM              = [pfo objectForKey:PInv_UOM_key];
                self->smartp.latestBulkOrIndividual = [pfo objectForKey:PInv_Bulk_or_Individual_key];
                self->smartp.latestVendor           = [pfo objectForKey:PInv_Vendor_key];
                self->smartp.latestTotalPrice       = [pfo objectForKey:PInv_TotalPrice_key];
                self->smartp.latestPricePerUOM      = [pfo objectForKey:PInv_PricePerUOM_key];
                self->smartp.latestProcessed        = [pfo objectForKey:PInv_Processed_key];
                self->smartp.latestLocal            = [pfo objectForKey:PInv_Local_key];
                self->smartp.latestLineNumber       = [pfo objectForKey:PInv_LineNumber_key];
                invoiceNumberString                 = [pfo objectForKey:PInv_InvoiceNumber_key];
                NSString *s = [NSString stringWithFormat:@"%@,",self->smartp.latestCategory];
                s = [s stringByAppendingString:
                     [NSString stringWithFormat:@"%@,",self->smartp.latestShortDateString]];
                s = [s stringByAppendingString:
                     [NSString stringWithFormat:@"%@,",quantity]];
                s = [s stringByAppendingString:
                     [NSString stringWithFormat:@"%@,",item]];
                s = [s stringByAppendingString:
                     [NSString stringWithFormat:@"%@,",self->smartp.latestUOM]];
                s = [s stringByAppendingString:
                     [NSString stringWithFormat:@"%@,",self->smartp.latestBulkOrIndividual]];
                s = [s stringByAppendingString:
                     [NSString stringWithFormat:@"%@,",self->smartp.latestVendor]];
                s = [s stringByAppendingString:
                     [NSString stringWithFormat:@"%@,",self->smartp.latestTotalPrice]];
                s = [s stringByAppendingString:
                     [NSString stringWithFormat:@"%@,",self->smartp.latestPricePerUOM]];
                s = [s stringByAppendingString:
                     [NSString stringWithFormat:@"%@,",self->smartp.latestProcessed]];
                s = [s stringByAppendingString:
                     [NSString stringWithFormat:@"%@,",self->smartp.latestLocal]];
                NSDateFormatter * formatter =  [[NSDateFormatter alloc] init];
                [formatter setDateFormat:@"MM/dd/yy"];
                NSString *sfd = [formatter stringFromDate:[pfo objectForKey:PInv_Date_key]];
                s = [s stringByAppendingString:
                     [NSString stringWithFormat:@"%@,",sfd]];
                s = [s stringByAppendingString:
                     [NSString stringWithFormat:@"%@,",self->smartp.latestLineNumber]];
                //LAST FIELD: note it has a comma after it in final CSV!
                s = [s stringByAppendingString:
                     [NSString stringWithFormat:@"%@",self->invoiceNumberString]];
                [self->EXPDump addObject:s];
                if (dumptoCSV)
                {
                    self->EXPDumpCSVList = [self->EXPDumpCSVList stringByAppendingString: s];
                    //if (i < count-1) //Not at end? add LF
                    self->EXPDumpCSVList = [self->EXPDumpCSVList stringByAppendingString: @",\n"];
                }
                i++;
            }
            NSLog(@" ...loaded EXP OK %@",self->EXPDump);
        }
        NSLog(@" annnd csv is %@",self->EXPDumpCSVList);
        [self mailit: self->EXPDumpCSVList];
    }];
} //end loadEXPFromParseAsStrings

//=============OCR VC=====================================================
// if start is -1, dump all
-(NSString *) dumpEXPToCSV : (int)start : (int) size
{
    NSString *csvout = @"";
    return csvout;
    
}

//=============OCR VC=====================================================
-(void) dumpResults
{
    NSString *r = @"Invoice Parsed Results\n";
    r = [r stringByAppendingString:
         [NSString stringWithFormat: @"Number %d  Date %@\n",invoiceNumber,invoiceDate]];
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
    [self alertMessage:@"Invoice Dump" :r];

}

//=============OCR VC=====================================================
// Sends a JPG to the OCR server, and receives JSON text data back...
- (void)callOCRSpace : (NSString*)imageName
{
    // Create URL request
    NSURL *url = [NSURL URLWithString:@"https://api.ocr.space/Parse/Image"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"randomString";
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Image file and parameters, use hi compression quality?
    NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:imageName], 0.8);
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
        NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data
                                                               options:kNilOptions
                                                                 error:&myError];
        if (error != nil) //Task came back w/ error?
        {
            NSNumber* exitCode     = [result valueForKey:@"OCRExitCode"];
            NSString* errDesc;
            switch(exitCode.intValue)
            {
                case 2: errDesc = @"OCR only parsed partially";break;
                case 3: errDesc = @"OCR failed to parse image";break;
                case 4: errDesc = @"OCR internal error";break;
            }
        }
        // Handle result: load up document and apply template here
        //NSLog(@" annnnd result is %@",result);
    }];
    [task resume];
}

//=============OCR VC=====================================================
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

//=============OCR VC=====================================================
- (IBAction)testSelect:(id)sender {
    [self applyTemplate];
    

//    -(NSDate *) findDateInArrayOfFields : (NSArray*)aof;

    
    //_inputImage.image = j;
    //[self callOCRSpace : selectFname];
//    [self callOCRSpace : @"hawaiiBeefInvoice.jpg"];
}

//======(Hue-Do-Ku allColorPacks)==========================================
- (IBAction)testEmail:(id)sender
{
    
    [self loadEXPFromParseAsStrings : TRUE];
    
}


//======(Hue-Do-Ku allColorPacks)==========================================
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

//=============OCR VC=====================================================
-(NSDictionary*) getJSON : (NSString *)s
{
    NSData *jsonData = [s dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
    return dict;
}


//=============OCR VC=====================================================
-(void) clearFields  
{
    [ot clearFields];
    // Set limits where text was found at top / left / right,
    //  used for re-scaling if invoice was shrunk or whatever
    NSLog(@" clear fields: set template boundaries");
    [ot setOriginalRects:tlRect :trRect];
    [self refreshOCRBoxes];
}



//=============OCR VC=====================================================
-(void) addNewField : (NSString*) ftype
{
    //Multiple columns are desired, other types of fields are one-only!
    if (![ftype isEqualToString:INVOICE_COLUMN_FIELD] &&
        ![ftype isEqualToString:INVOICE_IGNORE_FIELD] &&
        [ot gotFieldAlready:ftype])
    {
        [self alertMessage:@"Field in Use" :@"This field is already used."];
        return;
    }
    _LHArrowView.hidden = FALSE;
    _RHArrowView.hidden = FALSE;
    _instructionsLabel.text = @"Move/Resize box with arrows";
    fieldName = ftype;
    [self getShortFieldName];
    editing = TRUE;
    arrowStepSize = 10;
    [self moveOrResizeSelectBox : -1000 : -1000 : 0 : 0];
    [self resetSelectBox];
    // Change bottom button so user knows they can cancel...
    [_addFieldButton setTitle:@"Cancel" forState:UIControlStateNormal];

} //end addNewField

//=============OCR VC=====================================================
-(void) adjustField
{
    _LHArrowView.hidden = FALSE;
    _RHArrowView.hidden = FALSE;
    _instructionsLabel.text = @"Adjust box with arrows";
    fieldName = [ot getBoxFieldName:adjustSelect];
    [self getShortFieldName];
    adjusting = TRUE;
    arrowStepSize = 1;
    CGRect rr = [ot getBoxRect:adjustSelect];
    [ot dumpBox:adjustSelect];
    int docXoff = od.docRect.origin.x; //Top left text corner in document...
    int docYoff = od.docRect.origin.y;
    rr.origin.x += docXoff;
    rr.origin.y += docYoff;
    int xi = [self documentToScreenX:rr.origin.x];
    int yi = [self documentToScreenY:rr.origin.y];
    int xs = (int)((double)rr.size.width  / docXConv);
    int ys = (int)((double)rr.size.height / docYConv);
    selectBox.frame =  CGRectMake(xi, yi, xs, ys);
    selectBox.hidden = FALSE;
    // Change bottom button so user knows they can cancel...
    [_addFieldButton setTitle:@"Cancel" forState:UIControlStateNormal];
    

}

//=============OCR VC=====================================================
// Internal stuff...
-(void) getShortFieldName
{
    fieldNameShort = @"Number";
    if ([fieldName isEqualToString:INVOICE_DATE_FIELD])       fieldNameShort = @"Date";
    if ([fieldName isEqualToString:INVOICE_CUSTOMER_FIELD])   fieldNameShort = @"Cust";
    if ([fieldName isEqualToString:INVOICE_HEADER_FIELD])     fieldNameShort = @"Header";
    if ([fieldName isEqualToString:INVOICE_COLUMN_FIELD])     fieldNameShort = @"Column";
    if ([fieldName isEqualToString:INVOICE_IGNORE_FIELD])     fieldNameShort = @"Ignore";
    if ([fieldName isEqualToString:INVOICE_TOTAL_FIELD])      fieldNameShort = @"Total";
}

//=============OCR VC=====================================================
-(void) resetSelectBox
{
    int xs = od.width/4;
    int ys = od.height/10;
    int xi = od.width/2  - xs/2;
    int yi = od.height/2 - ys/2;
    selectDocRect   = CGRectMake(xi, yi, xs, ys);
    selectBox.frame = [self documentToScreenRect:selectDocRect];
    selectBox.hidden = FALSE;
}



//=============OCR VC=====================================================
- (IBAction)clearSelect:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:
                                NSLocalizedString(@"Clear All Fields: Are you sure?",nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK",nil)
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              [self clearFields];
                                                          }];
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           }];
    //DHS 3/13: Add owner's ability to delete puzzle
    [alert addAction:firstAction];
    [alert addAction:secondAction];
    
    [self presentViewController:alert animated:YES completion:nil];

}

//=============OCR VC=====================================================
// Handles add field OR cancel adding field
- (IBAction)addFieldSelect:(id)sender {
    
    if (editing || adjusting) //Cancel?
    {
        editing = adjusting = FALSE;
        [self clearScreenAfterEdit];
        return;
    }
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Add New Field",nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add Invoice Number",nil)
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              [self addNewField : INVOICE_NUMBER_FIELD];
                                                          }];
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add Invoice Date",nil)
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              [self addNewField : INVOICE_DATE_FIELD];
                                                          }];
    UIAlertAction *thirdAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add Invoice Customer",nil)
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               [self addNewField : INVOICE_CUSTOMER_FIELD];
                                                           }];
    UIAlertAction *fourthAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add Invoice Column Header",nil)
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              [self addNewField : INVOICE_HEADER_FIELD];
                                                          }];
    UIAlertAction *fifthAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add a Column",nil)
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              [self addNewField : INVOICE_COLUMN_FIELD];
                                                          }];
    UIAlertAction *sixthAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add Invoice Total",nil)
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              [self addNewField : INVOICE_TOTAL_FIELD];
                                                          }];
    UIAlertAction *seventhAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Ignore this Area",nil)
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              [self addNewField : INVOICE_IGNORE_FIELD];
                                                          }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                          }];
    //DHS 3/13: Add owner's ability to delete puzzle
    [alert addAction:firstAction];
    [alert addAction:secondAction];
    [alert addAction:thirdAction];
    [alert addAction:fourthAction];
    [alert addAction:fifthAction];
    [alert addAction:sixthAction];
    [alert addAction:seventhAction];

    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:nil];

} //end addFieldSelect

//=============OCR VC=====================================================
- (IBAction)promptForAdjust:(id)sender {
    
    NSString *title = [NSString stringWithFormat:@"Selected %@\n[%@]",
                       [ot getBoxFieldName:adjustSelect],[ot getAllTags:adjustSelect]];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(title,nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Adjust Position and Size",nil)
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              [self adjustField];
                                                          }];
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Adjust Position and Size",nil)
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              [self adjustField];
                                                          }];
    UIAlertAction *thirdAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add Tag...",nil)
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               [self promptForNewTagToAdd:self];
          
                                                           }];
    UIAlertAction *fourthAction;
    if ([ot getTagCount:adjustSelect] > 0)
        fourthAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Clear Tags",nil)
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              [self->ot clearTags:self->adjustSelect];
                                                              [self->ot saveTemplatesToDisk];
                                                          }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           }];
    //DHS 3/13: Add owner's ability to delete puzzle
    [alert addAction:firstAction];
    [alert addAction:secondAction];
    [alert addAction:thirdAction];
    if ([ot getTagCount:adjustSelect] > 0) [alert addAction:fourthAction];
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:nil];
    
} //end promptForAdjust

//=============OCR VC=====================================================
- (IBAction)promptForNewTagToAdd:(id)sender {
    NSArray*actions = [[NSArray alloc] initWithObjects:
                       TOP_TAG_TYPE,BOTTOM_TAG_TYPE,LEFT_TAG_TYPE,RIGHT_TAG_TYPE,
                       TOPMOST_TAG_TYPE,BOTTOMMOST_TAG_TYPE,LEFTMOST_TAG_TYPE,RIGHTMOST_TAG_TYPE,
                       ABOVE_TAG_TYPE,BELOW_TAG_TYPE,LEFTOF_TAG_TYPE,RIGHTOF_TAG_TYPE,
                       HCENTER_TAG_TYPE,HALIGN_TAG_TYPE,VCENTER_TAG_TYPE,VALIGN_TAG_TYPE , nil];
    NSArray *actionNames = [[NSArray alloc] initWithObjects:
                            @"Top",@"Bottom",@"Left",@"Right",
                            @"Topmost",@"Bottommost",@"Leftmost",@"Rightmost",
                            @"Above",@"Below",@"Leftof",@"Rightof",
                            @"HCenter",@"VCenter",@"HAlign",@"VAlign",nil];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Select A Tag",nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    int index=0;
    for (NSString *aname in actionNames)
    {
        UIAlertAction *nextAction = [UIAlertAction actionWithTitle:NSLocalizedString(aname,nil)
                                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                                  [self addTag:[actions objectAtIndex:index]];
                                                              }];
        [alert addAction:nextAction];
        index++;
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           }];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
    
} //end promptForInvoiceNumberFormat

//=============OCR VC=====================================================
-(void) addTag : (NSString*)tag
{
    NSLog(@" addTag %@",tag);
    [ot addTag:adjustSelect:tag];
    [ot saveTemplatesToDisk];
    [ot saveToParse:supplierName];
} //end addTag

//=============OCR VC=====================================================
- (IBAction)promptForInvoiceNumberFormat:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Select Invoice Number Format",nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Value Below Title",nil)
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              self->fieldFormat = VALUE_BELOW_TITLE_FIELD_FORMAT;
                                                              [self finishAndAddBox];
                                                          }];
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Default",nil)
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               self->fieldFormat = DEFAULT_FIELD_FORMAT;
                                                               [self finishAndAddBox];
                                                           }];
    //DHS 3/13: Add owner's ability to delete puzzle
    [alert addAction:firstAction];
    [alert addAction:secondAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
} //end promptForInvoiceNumberFormat

//=============OCR VC=====================================================
- (IBAction)promptForInvoiceDateFormat:(id)sender {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Select Invoice Date Format",nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"DD/MM/YY(YY)",nil)
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              self->fieldFormat = DATE_DDMMYYYY_FIELD_FORMAT;
                                                              [self finishAndAddBox];
                                                          }];
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"MM/DD/YY(YY)",nil)
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               self->fieldFormat = DEFAULT_FIELD_FORMAT;
                                                               [self finishAndAddBox];
                                                           }];
    //DHS 3/13: Add owner's ability to delete puzzle
    [alert addAction:firstAction];
    [alert addAction:secondAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
} //end promptForInvoiceNumberFormat


//=============OCR VC=====================================================
- (IBAction)doneSelect:(id)sender {
    if (editing || adjusting)
    {
        //Hmm let's leave all fields automatic for now, no formatting prompts...
        //if ([fieldName isEqualToString:INVOICE_NUMBER_FIELD])
        //    [self promptForInvoiceNumberFormat:self];
        //else
        //if ([fieldName isEqualToString:INVOICE_DATE_FIELD])
        //    [self promptForInvoiceDateFormat:self];
        //else
        {
            fieldFormat = DEFAULT_FIELD_FORMAT;
            [self finishAndAddBox];
        }
    }
} //end doneSelect

//=============OCR VC=====================================================
-(void) finishAndAddBox
{
    //NOTE: this rect has to be scaled and offset for varying page sizes
    //  and text offsets!
    CGRect r = [self getDocumentFrameFromSelectBox];
    if (adjusting) [ot deleteBox:adjustSelect]; //Adjust? Replace box
    [ot addBox : r : fieldName : fieldFormat];
    editing = adjusting = FALSE;
    [ot dump];
    [ot saveTemplatesToDisk];
    [self clearScreenAfterEdit];
}

//=============OCR VC=====================================================
-(void) clearScreenAfterEdit
{
    _LHArrowView.hidden     = TRUE;
    _RHArrowView.hidden     = TRUE;
    selectBox.hidden        = TRUE;
    _instructionsLabel.text = @"...";
    [_addFieldButton setTitle:@"Add Field" forState:UIControlStateNormal];
    [self refreshOCRBoxes];
}

//=============OCR VC=====================================================
-(int) screenToDocumentX : (int) xin
{
    double dx = ((double)xin - _inputImage.frame.origin.x) * docXConv;
    return (int)floor(dx + 0.5);  //This is needed to get NEAREST INT!
}

//=============OCR VC=====================================================
-(int) screenToDocumentY : (int) yin
{
    double dy = ((double)yin - _inputImage.frame.origin.y) * docYConv;
    return (int)floor(dy + 0.5);  //This is needed to get NEAREST INT!
}

//=============OCR VC=====================================================
-(int) documentToScreenX : (int) xin
{
    double dx = ((double)xin / docXConv + _inputImage.frame.origin.x);
    return (int)floor(dx + 0.5);  //This is needed to get NEAREST INT!
}

//=============OCR VC=====================================================
-(int) documentToScreenY : (int) yin
{
    double dy = ((double)yin / docYConv + _inputImage.frame.origin.y);
    return (int)floor(dy + 0.5);  //This is needed to get NEAREST INT!
}

//=============OCR VC=====================================================
-(CGRect) documentToScreenRect : (CGRect) docRect
{
    int xi,yi,xs,ys;
    xi = [self documentToScreenX:docRect.origin.x];
    yi = [self documentToScreenY:docRect.origin.y];
    double dx = (double)docRect.size.width / docXConv;
    xs = (int)floor(dx + 0.5);  //This is needed to get NEAREST INT!
    double dy = (double)docRect.size.height / docYConv;
    ys = (int)floor(dy + 0.5);  //This is needed to get NEAREST INT!
    return CGRectMake(xi, yi, xs, ys);
} //documentToScreenRect



//=============OCR VC=====================================================
-(CGRect) getDocumentFrameFromSelectBox
{
    CGRect r = _inputImage.frame;
    int xi,yi,xs,ys;
    xi = r.origin.x;
    yi = r.origin.y;
    xs = r.size.width;
    ys = r.size.height;
    CGRect rs = selectBox.frame;
    NSLog(@" inxy %d %d",(int)rs.origin.x,(int)rs.origin.y);
    int docx = [self screenToDocumentX : rs.origin.x];
    int docy = [self screenToDocumentY : rs.origin.y];
    int docw = (int)(double)(rs.size.width  * docXConv);
    int doch = (int)(double)(rs.size.height * docYConv);
    NSLog(@"docxy %d %d  wh %d %d",docx,docy,docw,doch);
    int docXoff = od.docRect.origin.x; //Top left text corner in document...
    int docYoff = od.docRect.origin.y;
    docx -= docXoff;
    docy -= docYoff;
    _instructionsLabel.text = [NSString stringWithFormat:
                               @"%@:XY(%d,%d)WH(%d,%d)",fieldNameShort,docx,docy,docw,doch];
    return CGRectMake(docx, docy, docw, doch);
}


//=============OCR VC=====================================================
// Handles arrow up/down/etc
-(void) moveOrResizeSelectBox : (int) xdel : (int) ydel : (int) xsdel : (int) ysdel
{
    CGRect r = selectBox.frame;
    int xi,yi,xs,ys;
    xi = r.origin.x;
    yi = r.origin.y;
    xs = r.size.width;
    ys = r.size.height;
    yi+=ydel;
    xi+=xdel;
    ys+=ysdel;
    xs+=xsdel;
    int dx = pageRect.origin.x;
    int dy = pageRect.origin.y;
    int dw = pageRect.size.width;
    int dh = pageRect.size.height;
    if (xs<arrowStepSize) xs = arrowStepSize;
    if (ys<arrowStepSize) ys = arrowStepSize;
    if (xs>dw) xs = dw;
    if (ys>dh) ys = dh;
    dy+=24; //NOTCH?
    if (xi < dx) xi = dx;
    if (yi < dy) yi = dy;
    if (xi+xs > dx+dw) xi = (dx+dw) - xs;
    if (yi+ys > dy+dh) yi = (dy+dh) - ys;
    selectBox.frame = CGRectMake(xi, yi, xs, ys);
    [self getDocumentFrameFromSelectBox]; //Just updates screen/ toss return val
}



//=============OCR VC=====================================================
- (IBAction)arrowDownSelect:(id)sender {
    UIButton *b = (UIButton *)sender;
    if (b.tag > 100) //LH arrows
        [self moveOrResizeSelectBox:0 :arrowStepSize:0:0];
    else
        [self moveOrResizeSelectBox:0:0:0 :arrowStepSize];
}


//=============OCR VC=====================================================
- (IBAction)arrowUpSelect:(id)sender {
    UIButton *b = (UIButton *)sender;
    if (b.tag > 100) //LH arrows
        [self moveOrResizeSelectBox:0 :-arrowStepSize:0:0];
    else
        [self moveOrResizeSelectBox:0:0:0 :-arrowStepSize];
}


//=============OCR VC=====================================================
- (IBAction)arrowLeftSelect:(id)sender {
    UIButton *b = (UIButton *)sender;
    if (b.tag > 100) //LH arrows
        [self moveOrResizeSelectBox:-arrowStepSize:0:0:0];
    else
        [self moveOrResizeSelectBox:0:0:-arrowStepSize:0 ];
}

//=============OCR VC=====================================================
- (IBAction)arrowRightSelect:(id)sender {
    UIButton *b = (UIButton *)sender;
    if (b.tag > 100) //LH arrows
        [self moveOrResizeSelectBox:arrowStepSize:0:0:0];
    else
        [self moveOrResizeSelectBox:0:0:arrowStepSize:0 ];
}


//======(PixUtils)==========================================
-(void) alertMessage : (NSString *) title : (NSString *) message
{
    UIAlertController * alert = [UIAlertController
                                 alertControllerWithTitle:title
                                 message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"OK"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                }];
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
} //end alertMessage

//=============OCR VC=====================================================
//Doesn't work in simulator??? huh??
-(void) mailit : (NSString *)s
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"Test CSV output"];
        [mail setMessageBody:s isHTML:NO];
        [mail setToRecipients:@[@"fraktalmaui@gmail.com"]];
        
        [self presentViewController:mail animated:YES completion:NULL];
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
}

#pragma mark - MFMailComposeViewControllerDelegate


//==========FeedVC=========================================================================
- (void) mailComposeController:(MFMailComposeViewController *)controller    didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    NSLog(@" mailit: didFinishWithResult...");
    switch (result)
    {
        case MFMailComposeResultSent:
            NSLog(@" mail sent OK");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    [controller dismissViewControllerAnimated:YES completion:NULL];
}



//=============OCR VC=====================================================
//- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
//                 didFinishWithResult:(MessageComposeResult)result
//{
//    [self dismissViewControllerAnimated:YES completion:NULL];
//}

@end
