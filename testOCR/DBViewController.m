//
//   ____  ______     ______
//  |  _ \| __ ) \   / / ___|
//  | | | |  _ \\ \ / / |
//  | |_| | |_) |\ V /| |___
//  |____/|____/  \_/  \____|
//
//  DBViewController.m
//  testOCR
//
//  Created by Dave Scruton on 12/19/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import "DBViewController.h"

@interface DBViewController ()

@end

@implementation DBViewController

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
    vendor = @"";
    tableName = @"";
    dbResults = [[NSMutableArray alloc] init];
    dbMode = DB_MODE_NONE;
    
    return self;
}






//=============DB VC=====================================================
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _table.delegate = self;
    _table.dataSource = self;
    // Do any additional setup after loading the view.
    _titleLabel.text = @"Touch Menu to perform query...";

}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */




//=============DB VC=====================================================
- (IBAction)doneSelect:(id)sender
{
    [self dismiss];
}

//=============DB VC=====================================================
- (IBAction)menuSelect: (id)sender
{
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
    
} //end addFieldSelect

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
    tableName = @"EXP";
    vendor = @"All Vendors";
    dbMode = DB_MODE_EXP;
    [et readFromParseAsStrings : FALSE : @"*"];
    [self updateUI];
}


//=============DB VC=====================================================
-(void) loadEXPByVendor : (NSString *)v
{
    tableName = @"EXP";
    vendor = v;
    dbMode = DB_MODE_EXP;
    [et readFromParseAsStrings : FALSE : v];
    [self updateUI];
}

//=============DB VC=====================================================
-(void) loadInvoiceByVendor : (NSString *)v
{
    tableName = @"Invoices";
    vendor = v;
    dbMode = DB_MODE_INVOICE;
    [it readFromParseAsStrings : v ]; //All invoices for vendor
    [self updateUI];
}

//=============DB VC=====================================================
-(void) loadTemplates
{
    tableName = @"Templates";
    vendor = @"All Vendors";
    dbMode = DB_MODE_TEMPLATE;
    [ot readFromParseAsStrings];
    [self updateUI];
}



//=============DB VC=====================================================
-(void) updateUI
{
    NSString *vlab = @"";
    if ([vendor isEqualToString:@""] )
        vlab = @"Touch Menu to begin...";
    else
        vlab = [NSString stringWithFormat:@"%@:%@",tableName,vendor];
    _titleLabel.text = vlab;
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
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
//    NSString *comment      = [_workActivity getNthComment  : row];
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



#pragma mark - EXPTableDelegate

//=============DB VC=====================================================
- (void)didReadEXPTableAsStrings : (NSString *)s
{
    dbResults = [et getAllRecords];
    [_table reloadData];
    
}

//=============DB VC=====================================================
- (void)didReadInvoiceTableAsStrings : (NSMutableArray*)a
{
    NSLog(@" dri");
    dbResults = a;
    [_table reloadData];

}

#pragma mark - OCRTemplateDelegate

//=============DB VC=====================================================
- (void)didReadTemplateTableAsStrings : (NSMutableArray*) a
{
    dbResults = a;
    [_table reloadData];

}


@end
