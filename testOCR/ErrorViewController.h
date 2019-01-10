//
//   _____                   __     ______
//  | ____|_ __ _ __ ___  _ _\ \   / / ___|
//  |  _| | '__| '__/ _ \| '__\ \ / / |
//  | |___| |  | | | (_) | |   \ V /| |___
//  |_____|_|  |_|  \___/|_|    \_/  \____|
//
//  ErrorViewController.h
//  testOCR
//
//  Created by Dave Scruton on 1/4/19.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BatchObject.h"
#import "DropboxTools.h"
#import "errorCell.h"
#import "EXPTable.h"
#import "imageTools.h"
#import "PDFCache.h"
#import "Vendors.h"
#import "smartProducts.h"

@interface ErrorViewController : UIViewController <batchObjectDelegate,
                                UITableViewDelegate,UITableViewDataSource,EXPTableDelegate,
                                UITextFieldDelegate, DropboxToolsDelegate>
{
    BatchObject *bbb;
    DropboxTools *dbt;
    smartProducts *sp;
    NSString *berrs;
    NSMutableArray *errorList;
    NSMutableArray *fixedList;
    NSMutableArray *expList;
    NSMutableArray *objectIDs;
    NSMutableDictionary *expRecordsByID;
    int selectedRow;
    EXPTable *et;
    NSMutableArray *allErrorsInEXPRecord;
    PDFCache *pc;
    Vendors *vv;
    imageTools *it;
    
    int errorPage;
    NSString *vendorName;
    
    UIImage *xIcon;
    UIImage *okIcon;

    int viewWid,viewHit,viewW2,viewH2;

    //Keys used to look thru pf object and find errors,
    //  and types of error correction each field will need
    NSArray *errKeysToCheck;
    NSArray *errKeysNumeric;
    NSArray *errKeysBinary;
    NSString *qText;
    NSString *pText;
    NSString *tText;
    BOOL kbUp;
    NSString *fixingObjectKey;
    NSString *fixingObjectField;
    NSString *fixingObjectID;
    NSString *batchID;
    PFObject *pfoWork;
    BOOL isNumeric;
}

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIImageView *pdfView;
@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UIView *fixNumberView;
@property (weak, nonatomic) IBOutlet UILabel *fieldName;
@property (weak, nonatomic) IBOutlet UIView *numericPanelView;
@property (weak, nonatomic) IBOutlet UITextField *fieldValue;
@property (weak, nonatomic) IBOutlet UITextField *field2Value;
@property (weak, nonatomic) IBOutlet UITextField *field3Value;
@property (weak, nonatomic) IBOutlet UILabel *productName;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

- (IBAction)fieldCancelSelect:(id)sender;
- (IBAction)fieldFixSelect:(id)sender;

- (IBAction)textChanged:(id)sender;





@property (nonatomic , strong) NSString* batchData;
//@property (nonatomic , strong) EXPObject* eobj;
//@property (nonatomic , strong) NSArray* allObjects;
//@property (nonatomic , assign) int detailIndex;

- (IBAction)backSelect:(id)sender;

@end

 
