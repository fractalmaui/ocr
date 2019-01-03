//
//   ____  ______     ______
//  |  _ \| __ ) \   / / ___|
//  | | | |  _ \\ \ / / |
//  | |_| | |_) |\ V /| |___
//  |____/|____/  \_/  \____|
//
//  EXPViewController
//  testOCR
//
//  Created by Dave Scruton on 12/19/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import "EXPViewController.h"

@interface EXPViewController ()

@end

@implementation EXPViewController

//=============DB VC=====================================================
-(id)initWithCoder:(NSCoder *)aDecoder {
    if ( !(self = [super initWithCoder:aDecoder]) ) return nil;
    
//    od = [[OCRDocument alloc] init];
    ot = [[OCRTemplate alloc] init];
    ot.delegate = self;
    
    it = [[invoiceTable alloc] init];
    it.delegate = self;
    et = [[EXPTable alloc] init];
    et.delegate = self;
    tableName = @"";
    dbResults = [[NSMutableArray alloc] init];
    dbMode = DB_MODE_NONE;
    vendorLookup = @"*";
    
    barnIcon    = [UIImage imageNamed:@"barnIcon"];
    bigbuxIcon  = [UIImage imageNamed:@"bigbuxIcon"];
    centIcon    = [UIImage imageNamed:@"centIcon"];
    dollarIcon  = [UIImage imageNamed:@"dollarIcon"];
    factoryIcon = [UIImage imageNamed:@"factoryIcon"];
    globeIcon   = [UIImage imageNamed:@"globeIcon"];
    hiIcon      = [UIImage imageNamed:@"hiIcon"];

    sortAscending = TRUE;
    return self;
}

//=============DB VC=====================================================
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _table.delegate = self;
    _table.dataSource = self;
    
    [self activityIndicatorOnOff : FALSE];
    // Do any additional setup after loading the view.
    _titleLabel.text = @"Touch Menu to perform query...";
    if (_actData.length > 1) //Incoming data?
    {
        NSArray *sitems =  [_actData componentsSeparatedByString:@":"];
        vendorLookup = @"*";
        if (sitems[0] != nil) batchIDLookup = sitems[0];
        if (sitems[1] != nil) vendorLookup  = sitems[1];
    }
    sortBy = @"";
    if ([_searchType isEqualToString:@"E"]) [self loadEXP];
    if ([_searchType isEqualToString:@"I"]) [self loadInvoices];
    _sortButton.hidden = TRUE;
}

//=============OCR MainVC=====================================================
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    batchIDLookup = @"*";
    vendorLookup  = @"*";
    [self loadEXP];//asdf
    
    
}



//=============DB VC=====================================================
-(void)activityIndicatorOnOff:(BOOL) onoff
{
    self->_activityIndicator.hidden = !onoff;
    if (onoff) [self->_activityIndicator startAnimating];
    else       [self->_activityIndicator stopAnimating];

}

//=============DB VC=====================================================
- (IBAction)doneSelect:(id)sender
{
    [self dismiss];
}

//=============DB VC=====================================================
- (IBAction)menuSelect: (id)sender
{
    batchIDLookup = @"*";

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Select Database Operation",nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Load EXP Table",nil)
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              [self loadEXP];
                                                          }];
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Load EXP Table By Vendor...",nil)
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               [self promptForEXPVendor];
                                                           }];
    UIAlertAction *thirdAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Load Invoice Table...",nil)
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              [self promptForInvoiceVendor];
                                                          }];
    UIAlertAction *fourthAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Load Templates Table...",nil)
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               [self loadTemplates];
                                                           }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           }];
    //DHS 3/13: Add owner's ability to delete puzzle
    [alert addAction:firstAction];
    [alert addAction:secondAction];
    [alert addAction:thirdAction];
    [alert addAction:fourthAction];
    //    [alert addAction:fifthAction];
    //    [alert addAction:sixthAction];
    //    [alert addAction:seventhAction];
    //    [alert addAction:eighthAction];
    
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
} //end menuSelect

//=============DB VC=====================================================
- (IBAction)sortSelect: (id)sender
{
    batchIDLookup = @"*";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Sort EXP Table By...",nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actions[32];
    int i=0;
    
    NSArray *sortOptions = @[
        @"Invoice Number",@"Item",@"Vendor",
        @"Product Name",@"Local",@"Processed",@"quantity",
        @"Price",@"Total"
    ];
    for (NSString *s in sortOptions)
    {
        UIAlertAction *action = [UIAlertAction actionWithTitle:s
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                  self->sortBy = s;
                                                  [self loadEXP];
                                              }];
        [alert addAction:action];
        i++;
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           }];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
} //end sortSelect

//=============DB VC=====================================================
- (IBAction)sortDirSelect:(id)sender
{
    sortAscending = !sortAscending;
    NSLog(@"ascending = %d",sortAscending);
    if (sortAscending)
        [_sortDirButton setBackgroundImage:[UIImage imageNamed:@"arrUp"] forState:UIControlStateNormal];
    else
        [_sortDirButton setBackgroundImage:[UIImage imageNamed:@"arrDown"] forState:UIControlStateNormal];
    et.sortAscending = sortAscending;
    [self loadEXP];

}



//=============DB VC=====================================================
-(NSString*) getVendorNameForPrompt : (int) i
{
    NSString *vends[] = {@"HFM",@"Hawaii Beef Producers"};
    if (i < 0) return @"";
    return vends[i];
} //end getVendorNameForPrompt


//=============DB VC=====================================================
-(void) promptForEXPVendor
{
    
    int nvends = 2; //getVendorNameForPrompt above must match!
    
    UIAlertAction *actions[8]; //May need more...
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Select Vendor",nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (int i = 0;i<nvends;i++)
    {
        NSString *vname = [self getVendorNameForPrompt:i];
        actions[i] = [UIAlertAction actionWithTitle:NSLocalizedString(vname,nil)
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              [self loadEXPByVendor : vname];
                                                          }];
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           }];

    for (int i = 0;i<nvends;i++)  [alert addAction:actions[i]];
    [alert addAction:cancelAction];

    [self presentViewController:alert animated:YES completion:nil];
    
} //end promptForEXPVendor


//=============DB VC=====================================================
-(void) promptForInvoiceVendor
{
    
    int nvends = 2; //getVendorNameForPrompt above must match!
    
    UIAlertAction *actions[8]; //May need more...
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Select Vendor",nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (int i = 0;i<nvends;i++)
    {
        NSString *vname = [self getVendorNameForPrompt:i];
        actions[i] = [UIAlertAction actionWithTitle:NSLocalizedString(vname,nil)
                                              style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                  [self loadInvoiceByVendor : vname];
                                              }];
    }
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           }];
    
    for (int i = 0;i<nvends;i++)  [alert addAction:actions[i]];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
} //end promptForInvoiceVendor



//=============OCR VC=====================================================
-(void) dismiss
{
    //[_sfx makeTicSoundWithPitch : 8 : 52];
    [self dismissViewControllerAnimated : YES completion:nil];
    
}

//=============DB VC=====================================================
-(void) loadEXP
{
    [self activityIndicatorOnOff : TRUE];
    _titleLabel.text = @"Loading EXP table...";

    tableName = @"EXP";
    dbMode = DB_MODE_EXP;
    et.sortBy = sortBy;
    

    [et readFromParseAsStrings : FALSE : vendorLookup : batchIDLookup];
    [self updateUI];
}

//=============DB VC=====================================================
-(void) loadInvoices
{
    [self activityIndicatorOnOff : TRUE];
    _titleLabel.text = @"Loading Invoices...";
    
    tableName = @"Invoices";
    dbMode = DB_MODE_INVOICE;
    [it readFromParseAsStrings : vendorLookup  : batchIDLookup]; //All invoices for vendor
    [self updateUI];
}


//=============DB VC=====================================================
-(void) loadEXPByVendor : (NSString *)v
{
    [self activityIndicatorOnOff : TRUE];
    _titleLabel.text = @"Loading EXP table...";

    tableName = @"EXP";
    vendorLookup = v;
    dbMode = DB_MODE_EXP;
    [et readFromParseAsStrings : FALSE : vendorLookup : batchIDLookup];
    [self updateUI];
}

//=============DB VC=====================================================
-(void) loadInvoiceByVendor : (NSString *)v
{
    [self activityIndicatorOnOff : TRUE];
    _titleLabel.text = @"Loading Invoices...";
    tableName = @"Invoices";
    dbMode = DB_MODE_INVOICE;
    [it readFromParseAsStrings : vendorLookup : @"*" ]; //All invoices for vendor
    [self updateUI];
}

//=============DB VC=====================================================
-(void) loadTemplates
{
    tableName = @"Templates";
    dbMode = DB_MODE_TEMPLATE;
    [ot readFromParseAsStrings];
    [self updateUI];
}

//=============DB VC=====================================================
-(void) setLoadedTitle : (NSString *)tableName
{
    NSString *xtra = @"";
    if ([_searchType isEqualToString:@"E"]) xtra = [NSString stringWithFormat:@" Batch:%@",batchIDLookup];
    if ([_searchType isEqualToString:@"I"]) xtra = [NSString stringWithFormat:@" Batch:%@",batchIDLookup];
    if ([sortBy isEqualToString:@""]) //No particular sort...
        _titleLabel.text = [NSString stringWithFormat:@"[%@%@]",tableName,xtra];
    else{
        NSString *s = [NSString stringWithFormat:@"Sort by %@",sortBy];
        _titleLabel.text = s;
    }
}

//=============DB VC=====================================================
-(void) updateUI
{
//    NSString *vlab = @"";
//    if ([vendor isEqualToString:@""] )
//        vlab = @"Touch Menu to begin...";
//    else
//        vlab = [NSString stringWithFormat:@"%@:%@",tableName,vendor];
//    _titleLabel.text = vlab;
}

#pragma mark - UITableViewDelegate

//- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
//    <#code#>
//}



//=============DB VC=====================================================
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    int row = (int)indexPath.row;
    if (dbMode == DB_MODE_EXP)
    {
        EXPCell *cell = (EXPCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
        {
            cell = [[EXPCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        
        EXPObject *e = [et.expos objectAtIndex:row];
        BOOL local     =  ([e.local.lowercaseString     isEqualToString:@"yes"]);
        BOOL processed =  ([e.processed.lowercaseString isEqualToString:@"processed"]);
        if (local) cell.localIcon.image         = hiIcon;
        else cell.localIcon.image               = globeIcon;
        if (processed) cell.processedIcon.image = factoryIcon;
        else cell.processedIcon.image           = barnIcon;

        double total = [e.total doubleValue];
        if (total > 100.0)      cell.priceIcon.image = bigbuxIcon;
        else if (total > 10.0)  cell.priceIcon.image = dollarIcon;
        else                    cell.priceIcon.image = centIcon;

        cell.label1.text = [NSString stringWithFormat:@"%@",e.productName];
        cell.label2.text = [NSString stringWithFormat:@"%@ at %@ = %@",
                            e.quantity,e.pricePerUOM,e.total];
        NSDateFormatter * formatter =  [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"MM/dd/yy"];
        NSString *sfd = [formatter stringFromDate:e.expdate];

        cell.label3.text = [NSString stringWithFormat:@"Invoice %@ Date %@ File %@",
                            e.invoiceNumber,sfd,e.PDFFile];
        cell.doblabel.text = e.vendor;
        //        cell.label4.text = e.vendor;
        return cell;
    }
//    NSString *comment      = [_workActivity getNthComment  : row];
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    return cell;
    UIColor *c;
    if (dbMode == DB_MODE_EXP)
        c  = [UIColor yellowColor];
    else if (dbMode == DB_MODE_INVOICE)
        c  = [UIColor cyanColor];
    else if (dbMode == DB_MODE_TEMPLATE)
        c  = [UIColor greenColor];

    cell.backgroundColor  = c;
    cell.textLabel.text = [dbResults objectAtIndex:row];
    return cell;
} //end cellForRowAtIndexPath


//=============DB VC=====================================================
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (int)dbResults.count;
}

//=============DB VC=====================================================
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

#pragma mark - EXPTableDelegate

//=============DB VC=====================================================
- (void)didReadEXPTableAsStrings : (NSString *)s
{
    dbResults = [et getAllRecords];
    [_table reloadData];
    [self activityIndicatorOnOff : FALSE];
    [self setLoadedTitle : @"EXP"];
    _sortButton.hidden = FALSE;

}

#pragma mark - invoiceTableDelegate

//=============DB VC=====================================================
- (void)didReadInvoiceTableAsStrings : (NSMutableArray*)a
{
    dbResults = a;
    [_table reloadData];
    [self activityIndicatorOnOff : FALSE];
    [self setLoadedTitle : @"Invoices"];

}

#pragma mark - OCRTemplateDelegate

//=============DB VC=====================================================
- (void)didReadTemplateTableAsStrings : (NSMutableArray*) a
{
    dbResults = a;
    [_table reloadData];

}


@end
