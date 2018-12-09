//
//  ViewController.m
//  testOCR
//
//  Created by Dave Scruton on 12/3/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//
// Here's more info:
//   https://ocr.space/ocrapi/confirmation
//   https://github.com/A9T9/OCR.Space-OCR-API-Code-Snippets/blob/master/ocrapi.m
// OUCH: deskew!
//   https://stackoverflow.com/questions/48792790/calculating-skew-angle-using-opencv-in-ios
//  needs openCV?
//  https://www.codeproject.com/Articles/104248/%2fArticles%2f104248%2fDetect-image-skew-angle-and-deskew-image
//  simple deskew?
//  Code
//  https://github.com/A9T9/OCR.Space-OCR-API-Code-Snippets/blob/master/ocrapi.m
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
    NSLog(@" ... hit %d",adjustSelect); //asdf
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
                NSLog(@" invoice# %d",invoiceNumber);
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
    
} //end applyTemplate

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
- (void)callOCRSpace : (NSString*)imageName
{
    // Create URL request
    NSURL *url = [NSURL URLWithString:@"https://api.ocr.space/Parse/Image"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"POST"];
    NSString *boundary = @"randomString";
    [request addValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary] forHTTPHeaderField:@"Content-Type"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    // Image file and parameters
    NSData *imageData = UIImageJPEGRepresentation([UIImage imageNamed:imageName], 0.6);
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
    fieldName = [ot getBoxFieldName:adjustSelect]; //asdf
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

@end
