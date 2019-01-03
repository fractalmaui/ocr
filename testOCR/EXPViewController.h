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

#import <UIKit/UIKit.h>
#import "DBKeys.h"
#import "OCRWord.h"
#import "OCRDocument.h"
#import "OCRTemplate.h"
#import "invoiceTable.h"
#import "EXPObject.h"
#import "EXPTable.h"
#import "EXPCell.h"

NS_ASSUME_NONNULL_BEGIN


#define DB_MODE_NONE 200
#define DB_MODE_EXP 201
#define DB_MODE_INVOICE 202
#define DB_MODE_TEMPLATE 203

@interface EXPViewController : UIViewController <OCRTemplateDelegate,invoiceTableDelegate,EXPTableDelegate,UITableViewDelegate,UITableViewDataSource>
{
    invoiceTable *it;
    EXPTable *et;
    OCRTemplate *ot;
    
    NSMutableArray *dbResults;
    NSString *tableName;
    int dbMode;
    NSString *batchIDLookup;
    NSString *vendorLookup;
    UIImage *barnIcon;
    UIImage *bigbuxIcon;
    UIImage *centIcon;
    UIImage *dollarIcon;
    UIImage *factoryIcon;
    UIImage *globeIcon;
    UIImage *hiIcon;
    
    NSString *sortBy;
    BOOL sortAscending;

}
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *table;

@property (weak, nonatomic) IBOutlet NSString *actData;
@property (weak, nonatomic) IBOutlet NSString *searchType;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *sortButton;
@property (weak, nonatomic) IBOutlet UIButton *sortDirButton;

- (IBAction)doneSelect:(id)sender;
- (IBAction)menuSelect:(id)sender;
- (IBAction)sortSelect:(id)sender;
- (IBAction)sortDirSelect:(id)sender;

@end

NS_ASSUME_NONNULL_END
