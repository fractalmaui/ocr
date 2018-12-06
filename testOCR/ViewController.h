//
//  ViewController.h
//  testOCR
//
//  Created by Dave Scruton on 12/3/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCRWord.h"
#import "OCRDocument.h"
#import "OCRTemplate.h"

#define DEFAULT_FIELD_FORMAT @"DEFAULT"
#define VALUE_BELOW_TITLE_FIELD_FORMAT @"VALUE_BELOW_TITLE"
#define DATE_MMDDYYYY_FIELD_FORMAT @"DATE_MMDDYYYY"
#define DATE_DDMMYYYY_FIELD_FORMAT @"DATE_DDMMYYYY"

#define INVOICE_NUMBER_FIELD   @"INVOICE_NUMBER"
#define INVOICE_DATE_FIELD     @"INVOICE_DATE"
#define INVOICE_CUSTOMER_FIELD @"INVOICE_CUSTOMER"
#define INVOICE_HEADER_FIELD   @"INVOICE_HEADER"
#define INVOICE_COLUMN_FIELD   @"INVOICE_COLUMN"
#define INVOICE_IGNORE_FIELD   @"INVOICE_IGNORE"
#define INVOICE_TOTAL_FIELD    @"INVOICE_TOTAL"

@interface ViewController : UIViewController
{
    NSString *selectFname;
    CFDataRef pixelData;
    OCRDocument *od;
    OCRTemplate *ot;
    UIView *selectBox;
    CGRect pageRect;
    CGRect docRect;
    int arrowStepSize;
    int viewWid,viewHit,viewW2,viewH2;
    BOOL editing;
    float docXConv,docYConv;
    NSString *supplierName;
    NSString *fieldName;
    NSString *fieldFormat;
    
    //INvoice-specific fields (MOVE TO SEPARATE OBJECT)
    int invoiceNumber;
    NSDate *invoiceDate;
    NSString *invoiceCustomer;
    float invoiceTotal;
    NSMutableArray *rowItems;

}

@property (weak, nonatomic) IBOutlet UIButton *arrowRightSelect;
@property (weak, nonatomic) IBOutlet UIImageView *inputImage;
@property (weak, nonatomic) IBOutlet UIView *LHArrowView;
@property (weak, nonatomic) IBOutlet UIView *RHArrowView;
@property (weak, nonatomic) IBOutlet UIView *selectOverlayView;

@property (weak, nonatomic) IBOutlet UILabel *instructionsLabel;
@property (weak, nonatomic) IBOutlet UIView *overlayView;

- (IBAction)arrowDownSelect:(id)sender;
- (IBAction)arrowUpSelect:(id)sender;
- (IBAction)arrowLeftSelect:(id)sender;
- (IBAction)testSelect:(id)sender;
- (IBAction)clearSelect:(id)sender;
- (IBAction)addFieldSelect:(id)sender;
- (IBAction)doneSelect:(id)sender;
- (IBAction)arrowRightSelect:(id)sender;

@end

