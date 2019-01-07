//
//   _____                   __     ______
//  | ____|_ __ _ __ ___  _ _\ \   / / ___|
//  |  _| | '__| '__/ _ \| '__\ \ / / |
//  | |___| |  | | | (_) | |   \ V /| |___
//  |_____|_|  |_|  \___/|_|    \_/  \____|
//
//  ErrorViewController.m
//  testOCR
//
//  Created by Dave Scruton on 1/4/19.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import "ErrorViewController.h"

@interface ErrorViewController ()

@end

@implementation ErrorViewController


//=============Error VC=====================================================
-(id)initWithCoder:(NSCoder *)aDecoder {
    if ( !(self = [super initWithCoder:aDecoder]) ) return nil;
    
    bbb = [BatchObject sharedInstance];
    bbb.delegate = self;
    [bbb setParent:self];
    errorList = [[NSMutableArray alloc] init];
    allErrorsInEXPRecord = [[NSMutableArray alloc] init];

    sp = [[smartProducts alloc] init];
    
    //For loading PDF images...
    pc = [PDFCache sharedInstance];
    // For getting page rotation by vendor...
    vv = [Vendors sharedInstance];
    et = [[EXPTable alloc] init];
    it = [[imageTools alloc] init];
    
    et.delegate = self;
    [self initErrorKeys];
    kbUp = FALSE;
//??    vv  = [Vendors sharedInstance];
    return self;
}

//=============Error VC=====================================================
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _table.delegate   = self;
    _table.dataSource = self;
    
    //Scrolling zoomed PDF viewer
    _scrollView.delegate=self;

    _fieldValue.delegate = self;
    _field2Value.delegate = self;
    _field3Value.delegate = self;

} //end viewDidLoad

//=============Error VC=====================================================
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
//    [act readActivitiesFromParse:nil :nil];
    NSLog(@"ERRVC: adata %@",_batchData);
    NSArray* bItems    = [_batchData componentsSeparatedByString:@":"];
    if (bItems.count > 0)
    {
        NSString *bID = bItems[0];
        [bbb readFromParseByID : bID];
    }
    
    _fixNumberView.hidden = TRUE;

    
} //end viewWillAppear

//=============Error VC=====================================================
-(void) loadView
{
    [super loadView];
    CGSize csz   = [UIScreen mainScreen].bounds.size;
    viewWid = (int)csz.width;
    viewHit = (int)csz.height;
    viewW2  = viewWid/2;
    viewH2  = viewHit/2;
    
    int xi,yi,xs,ys;
    xs = viewWid;
    ys = xs;
    xi = viewW2 - xs/2;
    yi = 60;
    _scrollView.frame = CGRectMake(xi, yi, xs, ys);

    //Zoom up by 4x
    UIView *v = _pdfView;
    int vw = v.bounds.size.width;
    int vh = v.bounds.size.height;
    CGAffineTransform t = v.transform;
    t = CGAffineTransformMakeScale(4, 4);
    v.transform = t;
    v.center = CGPointMake(vw*2, vh*2);
    _scrollView.contentSize = CGSizeMake(vw*4, vh*4);
    [_scrollView setContentOffset:CGPointMake(0,0) animated:NO];
    
//    yi+= ys+10;
//    xs = viewWid * 0.95;
//    ys = 200; //Too Tall?
//    xi = viewW2 - xs/2;
//    _outputLabel.frame = CGRectMake(xi, yi, xs, ys);
//    _outputLabel.text  = @"...";
} //end loadView


//=============Error VC=====================================================
-(void) initErrorKeys
{
    errKeysToCheck= @[   //CANNED
                      PInv_Month_key ,
                      PInv_Category_key ,
                      PInv_Quantity_key ,
                      PInv_Item_key ,
                      PInv_UOM_key ,
                      PInv_Bulk_or_Individual_key ,
                      PInv_Vendor_key ,
                      PInv_TotalPrice_key ,
                      PInv_ProductName_key ,
                      PInv_PricePerUOM_key ,
                      PInv_Processed_key ,
                      PInv_Local_key ,
                      //NOT A STRING PInv_Date_key ,
                      PInv_LineNumber_key ,
                      PInv_InvoiceNumber_key ,
                      PInv_Batch_key ,
                      PInv_ErrStatus_key ,
                      PInv_PDFFile_key
                      //NOT A STRING PInv_Page_key
                      
                      ];
    errKeysNumeric = @[   //CANNED
                       PInv_Quantity_key ,
                       PInv_TotalPrice_key ,
                       PInv_PricePerUOM_key
                       ];
    errKeysBinary = @[   //CANNED
                      PInv_Bulk_or_Individual_key ,
                      PInv_Processed_key ,
                      PInv_Local_key
                      ];
} //end initErrorKeys


//=============Error VC=====================================================
- (IBAction)backSelect:(id)sender
{
    [self dismiss];
}


//=============Error VC=====================================================
- (IBAction)fieldCancelSelect:(id)sender {
    //Hide sub-panel for fixing fields... table should show up
    _fixNumberView.hidden = TRUE;

}

//=============Error VC=====================================================
- (IBAction)fieldFixSelect:(id)sender
{
    NSLog(@" fix: new value %@ SAVE TO PARSE...",qText);
    [self textFieldDidEndEditing:_fieldValue];
    // save new field to parse...
    if (isNumeric) //Fix q/p/t fields?
    {
        //get stuff first:
        double qd = qText.doubleValue;
        double pd = pText.doubleValue;
        double td = tText.doubleValue;
        td = qd * pd; //Force amount to be correct...
        tText = [sp getDollarsAndCentsString : (float) td]; //Re-format total...
        pText = [sp getDollarsAndCentsString : pText.floatValue]; //Re-format price...
        [et fixPricesInObjectByID : fixingObjectID : qText : pText : tText];
    }
    _fixNumberView.hidden = TRUE;
    [_table reloadData];

} //end fieldFixSelect


//=============Error VC=====================================================
-(void) UpdateUI
{
}


//=============Error VC=====================================================
-(void) updateUI
{
}


//=============Error VC=====================================================
-(void) dismiss
{
    //[_sfx makeTicSoundWithPitch : 8 : 52];
    [self dismissViewControllerAnimated : YES completion:nil];
    
}



#pragma mark - UITableViewDelegate
//=============Error VC=====================================================
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    int row = (int)indexPath.row;
    errorCell *cell = (errorCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[errorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.backgroundColor  = [UIColor yellowColor];
    cell.errorLabel.text = [errorList objectAtIndex:row];
    NSLog(@" cell %d %@",row,[errorList objectAtIndex:row]);
    cell.label2.text = @"duh";
    return cell;
} //end cellForRowAtIndexPath


//=============Error VC=====================================================
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (int)errorList.count;
}

//=============Error VC=====================================================
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}


//=============Error VC=====================================================
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedRow        = (int)indexPath.row;
    NSString *allErrs  = [errorList objectAtIndex:selectedRow];
    NSArray *sItems    = [allErrs componentsSeparatedByString:@":"];
    if (sItems.count > 1)
    {
        fixingObjectID = sItems[1];
        NSLog(@" duh %@",fixingObjectID);
        [et getObjectByID:fixingObjectID];
    }
    //EXPObject *e = [et.expos objectAtIndex:selectedRow];
    //[self performSegueWithIdentifier:@"expDetailSegue" sender:e];
    
} //end didSelectRowAtIndexPath


#pragma mark - batchObjectDelegate

//=============<batchObjectDelegate>=====================================================
- (void)didReadBatchByID : (NSString *)oid
{
    berrs = [bbb getErrors];
    NSLog(@" ok batch read %@:%@",oid,berrs);
    errorList = [berrs componentsSeparatedByString:@","]; //Break up errors...
    [_table reloadData];
    [self updateUI];
}

//=============<batchObjectDelegate>=====================================================
- (void)errorReadingBatchByID : (NSString *)err
{
    
    
}

//=============Error VC=====================================================
// Opens up a subpanel which will vary based on the error
//
// Quantity / Price / Amount Error(s) use a 3-field numeric UI
//
-(void) setupPanelForError : (NSString*) key
{
    NSLog(@"show fixit view...");
    //Show error fixing view...
    _fixNumberView.hidden = FALSE;
    fixingObjectKey = key;
    isNumeric = [errKeysNumeric containsObject:key];
    _numericPanelView.hidden = !isNumeric;
    _productName.text = pfoWork[PInv_ProductName_key];
    
    vendorName = [bbb getVendor];
    
    NSString *pdfName = pfoWork[PInv_PDFFile_key];
    NSString *pdfPage = pfoWork[PInv_Page_key];
    int page = pdfPage.intValue;
    UIImage *ii = [pc getImageByID:pdfName:page+1];
    //Does this vendor usually have XY flipped scans?
    NSString *rot = [vv getRotationByVendorName:vendorName];
    if ([rot isEqualToString:@"-90"]) ii = [it rotate90CCW : ii];
    _pdfView.image = ii;
    if (isNumeric) //Is this a numeric field?
    {
        NSString *q = pfoWork[PInv_Quantity_key];
        if (q.length < 1) q = @"$ERR";
        [_fieldValue setKeyboardType:UIKeyboardTypeDecimalPad];
        [_fieldValue setText : q];
        [_field2Value setKeyboardType:UIKeyboardTypeDecimalPad];
        NSString *p = pfoWork[PInv_PricePerUOM_key];
        if (p.length < 1) p = @"$ERR";
        [_field2Value setText : p];
        [_field3Value setKeyboardType:UIKeyboardTypeDecimalPad];
        NSString *t = pfoWork[PInv_TotalPrice_key];
        if (t.length < 1) t = @"$ERR";
        [_field3Value setText : t];
    }
    else{ // Characters and numbers?
        [_fieldValue setKeyboardType:UIKeyboardTypeDefault];
    }
} //end setupPanelForError



#pragma mark - EXPTableDelegate

//=============<EXPTableDelegate>=====================================================
- (void)didReadEXPObjectByID :(EXPObject *)e  : (PFObject*)pfo
{
    NSLog(@" e is %@",e);
    pfoWork = pfo;
    [allErrorsInEXPRecord removeAllObjects];

    //What about stuff that isn't in this set, like page or date?
    // there is no error marking there yet
    for (NSString * key in errKeysToCheck)
    {
        //Check for a flagged error in a field...
        if ([[pfo objectForKey:key] isEqualToString:@"$ERR"])
        {
            NSLog(@" hit err on %@",key);
            [allErrorsInEXPRecord addObject:key];
        }
    }
    //Did we get any errors?
    if (allErrorsInEXPRecord.count > 0)
    {
        [self setupPanelForError : allErrorsInEXPRecord[0]]; //0th item in list of keys <-- DBKeys.h
    }
    //Controls need to be set up for these fields, what if there are over 3 errors?
    //Maybe show only 3 at a time?
    
    //for ()
}


//=============<EXPTableDelegate>==================================asdf===================
- (void)didFixPricesInObjectByID : (NSString *)oid
{
    NSLog(@" OK: saved qpt for object %@ , delete from error list",oid);
    [errorList removeObjectAtIndex:selectedRow];
    [_table reloadData];


} //end didFixPricesInObjectByID


#pragma mark - UITextFieldDelegate

//==========<UITextFieldDelegate Helper>================================================================
- (void) animateTextField: (UITextField*) textField up: (BOOL) up
{
    if (up == kbUp) return;
    const int movementDistance = 300; // tweak as needed
    const float movementDuration = 0.3f; // tweak as needed
    
    int movement = (up ? -movementDistance : movementDistance);
    
    [UIView beginAnimations: @"anim" context: nil];
    [UIView setAnimationBeginsFromCurrentState: YES];
    [UIView setAnimationDuration: movementDuration];
    self.view.frame = CGRectOffset(self.view.frame, 0, movement);
    [UIView commitAnimations];
    kbUp = up;

} //end animateTextField

//==========<UITextFieldDelegate>================================================================
-(void) loadFields : (int) tag : (UITextField*) tfield
{
//    if (tag == 101)
        qText = _fieldValue.text;
//    else if (tag == 102)
        pText = _field2Value.text;
//    else if (tag == 103)
        tText = _field3Value.text;
    NSLog(@" qpt %@ x %@ = %@",qText,pText,tText);

} //end loadFields

//==========<UITextFieldDelegate>================================================================
- (IBAction)textChanged:(id)sender
{
    UITextField *tt = (UITextField*)sender;
    int tag = (int)tt.tag;
    [self loadFields:tag:tt];
} //end commentChanged

//==========<UITextFieldDelegate>================================================================
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{

    return YES;
}



//==========<UITextFieldDelegate>================================================================
- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    NSLog(@" shdclear");
    return YES;
}
//==========<UITextFieldDelegate>================================================================
// It is important for you to hide the keyboard
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSLog(@" shdreturn");
    //NSLog(@" textFieldShouldReturn");
    [textField resignFirstResponder];
    return YES;
}


//==========<UITextFieldDelegate>================================================================
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSLog(@" begedit");
    [self animateTextField: textField up: YES];
    [textField setText:@""];
} //end textFieldDidBeginEditing


//==========<UITextFieldDelegate>================================================================
- (void)textFieldDidEndEditing:(UITextField *)textField
{
    NSLog(@" endedit");
    [self animateTextField: textField up: NO];
    [textField resignFirstResponder];
    int tag = (int)textField.tag;
    [self loadFields:tag:textField];
} //end textFieldDidEndEditing







@end
