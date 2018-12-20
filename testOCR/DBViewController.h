//
//   ____  ______     ______
//  |  _ \| __ ) \   / / ___|
//  | | | |  _ \\ \ / / |
//  | |_| | |_) |\ V /| |___
//  |____/|____/  \_/  \____|
//
//  DBViewController.h
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
#import "EXPTable.h"

NS_ASSUME_NONNULL_BEGIN


#define DB_MODE_NONE 200
#define DB_MODE_EXP 201
#define DB_MODE_INVOICE 202

@interface DBViewController : UIViewController <invoiceTableDelegate,EXPTableDelegate,UITableViewDelegate,UITableViewDataSource>
{
    invoiceTable *it;
    EXPTable *et;
    
    NSMutableArray *dbResults;
    NSString *vendor;
    NSString *tableName;
    int dbMode;

}
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (weak, nonatomic) IBOutlet UITableView *table;
- (IBAction)doneSelect:(id)sender;
- (IBAction)menuSelect:(id)sender;

@end

NS_ASSUME_NONNULL_END
