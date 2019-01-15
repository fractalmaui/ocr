//
//   _______  ________     ______
//  | ____\ \/ /  _ \ \   / / ___|
//  |  _|  \  /| |_) \ \ / / |
//  | |___ /  \|  __/ \ V /| |___
//  |_____/_/\_\_|     \_/  \____|
//
//  EXPViewController
//  testOCR
//
//  Created by Dave Scruton on 12/19/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//
//  1/9 add pull to refresh

#import "EXPViewController.h"

@interface EXPViewController ()

@end

@implementation EXPViewController

//=============EXP VC=====================================================
-(id)initWithCoder:(NSCoder *)aDecoder {
    if ( !(self = [super initWithCoder:aDecoder]) ) return nil;
    
//    od = [[OCRDocument alloc] init];
    ot = [[OCRTemplate alloc] init];
    ot.delegate = self;
    
    it = [[invoiceTable alloc] init];
    it.delegate = self;
    et = [[EXPTable alloc] init];
    et.delegate     = self;
    et.selectBy     = @"*";
    et.selectValue  = @"*";
    tableName       = @"";
    dbResults       = [[NSMutableArray alloc] init];
    dbMode          = DB_MODE_NONE;
    vendorLookup    = @"*";
    _detailMode     = FALSE;

    barnIcon    = [UIImage imageNamed:@"barnIcon"];
    bigbuxIcon  = [UIImage imageNamed:@"bigbuxIcon"];
    centIcon    = [UIImage imageNamed:@"centIcon"];
    dollarIcon  = [UIImage imageNamed:@"dollarIcon"];
    factoryIcon = [UIImage imageNamed:@"factoryIcon"];
    globeIcon   = [UIImage imageNamed:@"globeIcon"];
    hiIcon      = [UIImage imageNamed:@"hiIcon"];

    refreshControl = [[UIRefreshControl alloc] init];

    sortAscending = TRUE;
    return self;
}

//=============EXP VC=====================================================
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _table.delegate = self;
    _table.dataSource = self;
    _table.refreshControl = refreshControl;
    [refreshControl addTarget:self action:@selector(refreshIt) forControlEvents:UIControlEventValueChanged];

    [self activityIndicatorOnOff : FALSE];
    // Do any additional setup after loading the view.
    _titleLabel.text = @"Touch Menu to perform query...";
    _sortButton.hidden   = TRUE;
    _selectButton.hidden = TRUE;
} //end viewDidLoad

//=============OCR MainVC=====================================================
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    batchIDLookup = @"*";
    vendorLookup  = @"*";
    //Only for detail mode...
    if (!_detailMode) //Normal mode?
    {
        if (_actData.length > 1) //Incoming data?
        {
            NSArray *sitems =  [_actData componentsSeparatedByString:@":"];
            vendorLookup = @"*";
            if (sitems[0] != nil) batchIDLookup = sitems[0];
            if (sitems[1] != nil) vendorLookup  = sitems[1];
        }
        sortBy = @"";
    }
    else
    {
        vendorLookup  = _searchType;
        batchIDLookup = _actData;
    }
    [self loadEXP];
}


//=============EXP VC=====================================================
-(void)refreshIt
{
    NSLog(@" pull to refresh...");
    [self loadEXP];
}


//=============EXP VC=====================================================
-(void)activityIndicatorOnOff:(BOOL) onoff
{
    self->_activityIndicator.hidden = !onoff;
    if (onoff) [self->_activityIndicator startAnimating];
    else       [self->_activityIndicator stopAnimating];
}

//=============EXP VC=====================================================
- (IBAction)doneSelect:(id)sender
{
    [self dismiss];
}

//=============EXP VC=====================================================
- (IBAction)menuSelect: (id)sender
{
    batchIDLookup = @"*";

    NSMutableAttributedString *tatString = [[NSMutableAttributedString alloc]initWithString:@"Select Database Operation"];
    [tatString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:25] range:NSMakeRange(0, tatString.length)];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Select Database Operation",nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert setValue:tatString forKey:@"attributedTitle"];
    
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Load EXP Table",nil)
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              [self loadEXP];
                                                          }];
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Load EXP Table By Vendor...",nil)
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               [self promptForEXPVendor];
                                                           }];
    UIAlertAction *thirdAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Export CSV...",nil)
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              [self setupEmailAndSendit];
                                                          }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           }];
    //DHS 3/13: Add owner's ability to delete puzzle
    [alert addAction:firstAction];
    [alert addAction:secondAction];
    [alert addAction:thirdAction];
    //[alert addAction:fourthAction];
    //    [alert addAction:fifthAction];
    //    [alert addAction:sixthAction];
    //    [alert addAction:seventhAction];
    //    [alert addAction:eighthAction];
    
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
} //end menuSelect

//=============EXP VC=====================================================
- (IBAction)sortSelect: (id)sender
{
    batchIDLookup = @"*";
    NSMutableAttributedString *tatString = [[NSMutableAttributedString alloc]initWithString:@"Sort EXP Table By..."];
    [tatString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:25] range:NSMakeRange(0, tatString.length)];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Sort EXP Table By...",nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert setValue:tatString forKey:@"attributedTitle"];
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


//=============EXP VC=====================================================
- (IBAction)selectSelect: (id)sender
{
    batchIDLookup = @"*";
    et.selectBy     = @"*";
    et.selectValue  = @"*";

    NSMutableAttributedString *tatString = [[NSMutableAttributedString alloc]initWithString:@"Select By..."];
    [tatString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:25] range:NSMakeRange(0, tatString.length)];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select By..."
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    [alert addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"Vendor:HPF",nil)
                                               style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                   self->et.selectBy = PInv_Vendor_key;
                                                   self->et.selectValue = @"HFM";
                                                   [self loadEXP];
                                               }]];
    [alert addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"Vendor:Hawaii Beef Producers",nil)
                                               style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                   self->et.selectBy = PInv_Vendor_key;
                                                   self->et.selectValue = @"Hawaii Beef Producers";
                                                   [self loadEXP];
                                               }]];
    [alert addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"Local",nil)
                                               style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                   self->et.selectBy = PInv_Local_key;
                                                   self->et.selectValue = @"Yes";
                                                   [self loadEXP];
                                               }]];
    [alert addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"Not Local",nil)
                                               style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                   self->et.selectBy = PInv_Local_key;
                                                   self->et.selectValue = @"No";
                                                   [self loadEXP];
                                               }]];
    [alert addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"Processed",nil)
                                               style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                   self->et.selectBy = PInv_Processed_key;
                                                   self->et.selectValue = @"PROCESSED";
                                                   [self loadEXP];
                                               }]];
    [alert addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"UnProcessed",nil)
                                               style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                   self->et.selectBy = PInv_Processed_key;
                                                   self->et.selectValue = @"UNPROCESSED";
                                                   [self loadEXP];
                                               }]];
    [alert addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"All Fields",nil)
                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                      [self loadEXP];
                                                  }]];
    [alert addAction: [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                  }]];
    [self presentViewController:alert animated:YES completion:nil];
    
} //end selectSelect

//=============EXP VC=====================================================
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


//=============EXP VC=====================================================
-(NSString*) getVendorNameForPrompt : (int) i
{
    NSString *vends[] = {@"HFM",@"Hawaii Beef Producers"};
    if (i < 0) return @"";
    return vends[i];
} //end getVendorNameForPrompt


//=============EXP VC=====================================================
-(void) promptForEXPVendor
{
    
    int nvends = 2; //getVendorNameForPrompt above must match!
    
    UIAlertAction *actions[8]; //May need more...

    NSMutableAttributedString *tatString = [[NSMutableAttributedString alloc]initWithString:@"Select Vendor"];
    [tatString addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:25] range:NSMakeRange(0, tatString.length)];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Select Vendor",nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    [alert setValue:tatString forKey:@"attributedTitle"];

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




//=============OCR VC=====================================================
-(void) dismiss
{
    //[_sfx makeTicSoundWithPitch : 8 : 52];
    [self dismissViewControllerAnimated : YES completion:nil];
    
}

//=============EXP VC=====================================================
-(void) loadEXP
{
    [self activityIndicatorOnOff : TRUE];
    _titleLabel.text = @"Loading EXP table...";

    tableName = @"EXP";
    dbMode = DB_MODE_EXP;
    et.sortBy = sortBy;

    if (!_detailMode) //Normal EXP table examination?
    {
        [et readFromParseAsStrings : FALSE : vendorLookup : batchIDLookup];
    }
    else //Just look at one invoice? (comes w/ list of objectIDs)
    {
        [et readFromParseAsStrings : FALSE : vendorLookup : batchIDLookup];
    }
    [self updateUI];
}

//=============EXP VC=====================================================
-(void) loadInvoices
{
    [self activityIndicatorOnOff : TRUE];
    _titleLabel.text = @"Loading Invoices...";
    
    tableName = @"Invoices";
    dbMode = DB_MODE_INVOICE;
    [it readFromParseAsStrings : vendorLookup  : batchIDLookup]; //All invoices for vendor
    [self updateUI];
}


//=============EXP VC=====================================================
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

//=============EXP VC=====================================================
-(void) loadInvoiceByVendor : (NSString *)v
{
    [self activityIndicatorOnOff : TRUE];
    _titleLabel.text = @"Loading Invoices...";
    tableName = @"Invoices";
    dbMode = DB_MODE_INVOICE;
    [it readFromParseAsStrings : vendorLookup : @"*" ]; //All invoices for vendor
    [self updateUI];
}

//=============EXP VC=====================================================
-(void) loadTemplates
{
    tableName = @"Templates";
    dbMode = DB_MODE_TEMPLATE;
    [ot readFromParseAsStrings];
    [self updateUI];
}

//=============EXP VC=====================================================
-(void) setLoadedTitle : (NSString *)tableName
{
    NSString *xtra = @"";
    if ([_searchType isEqualToString:@"E"]) xtra = [NSString stringWithFormat:@" Batch:%@",batchIDLookup];
    if ([_searchType isEqualToString:@"I"]) xtra = [NSString stringWithFormat:@" Batch:%@",batchIDLookup];
    NSString *s;
    if ([sortBy isEqualToString:@""]) //No particular sort...
        s = [NSString stringWithFormat:@"[%@%@] (latest 100)",tableName,xtra];
    else{
        if (!_detailMode) s = [NSString stringWithFormat:@"Sort by %@",sortBy];
        else  s = [NSString stringWithFormat:@"Invoice %@",_actData];
    }
    if (dbResults.count == 0) s = @"No Records Found...";
    _titleLabel.text = s;
} //end setLoadedTitle

//=============EXP VC=====================================================
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


//=============EXP VC=====================================================
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
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    return cell;
} //end cellForRowAtIndexPath


//=============EXP VC=====================================================
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return (int)dbResults.count;
}

//=============EXP VC=====================================================
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}


//=============EXP VC=====================================================
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    selectedRow = (int)indexPath.row;
    //sdata  = [act getData:row];
    EXPObject *e = [et.expos objectAtIndex:selectedRow];
    [self performSegueWithIdentifier:@"expDetailSegue" sender:e];

}

//=============EXP VC=====================================================
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"expDetailSegue"])
    {
        //Just hand all our PFObjects to the detailVC...
        EXPDetailVC *vc = (EXPDetailVC*)[segue destinationViewController];
        vc.allObjects  = [[NSArray alloc]initWithArray:et.expos];
        vc.detailIndex = selectedRow;
    }
} //end prepareForSegue


#pragma mark - EXPTableDelegate

//=============EXP VC=====================================================
- (void)didReadEXPTableAsStrings : (NSString *)s
{
    dbResults = [et getAllRecords];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_table reloadData];
        [self activityIndicatorOnOff : FALSE];
        [self setLoadedTitle : @"EXP"];
        self->_sortButton.hidden   = FALSE;
        self->_selectButton.hidden = FALSE;
    });
}

#pragma mark - invoiceTableDelegate

//=============EXP VC=====================================================
- (void)didReadInvoiceTableAsStrings : (NSMutableArray*)a
{
    dbResults = a;
    [_table reloadData];
    [self activityIndicatorOnOff : FALSE];
    [self setLoadedTitle : @"Invoices"];

}

#pragma mark - OCRTemplateDelegate

//=============EXP VC=====================================================
- (void)didReadTemplateTableAsStrings : (NSMutableArray*) a
{
    dbResults = a;
    [_table reloadData];

}

//=============OCR VC=====================================================
-(void) setupEmailAndSendit
{
    NSString* csvlist = [et dumpToCSV];
    [self mailit:csvlist];
}

//=============OCR VC=====================================================
//Doesn't work in simulator??? huh??
-(void) mailit : (NSString *)s
{
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:@"EXP CSV output"];
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



@end
