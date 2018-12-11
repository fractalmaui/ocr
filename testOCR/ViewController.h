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

//Tags: used to get hints about field placement
#define TOP_TAG_TYPE        @"TOP_TAG"
#define BOTTOM_TAG_TYPE     @"BOTTOM_TAG"
#define LEFT_TAG_TYPE       @"LEFT_TAG"
#define RIGHT_TAG_TYPE      @"RIGHT_TAG"
#define TOPMOST_TAG_TYPE    @"TOPMOST_TAG"
#define BOTTOMMOST_TAG_TYPE @"BOTTOMMOST_TAG"
#define LEFTMOST_TAG_TYPE   @"LEFTMOST_TAG"
#define RIGHTMOST_TAG_TYPE  @"RIGHTMOST_TAG"
#define ABOVE_TAG_TYPE      @"ABOVE_TAG"
#define BELOW_TAG_TYPE      @"BELOW_TAG"
#define LEFTOF_TAG_TYPE     @"LEFTOF_TAG"
#define RIGHTOF_TAG_TYPE    @"RIGHTOF_TAG"
#define HCENTER_TAG_TYPE    @"HCENTER_TAG"
#define HALIGN_TAG_TYPE     @"HALIGN_TAG"
#define VCENTER_TAG_TYPE    @"VCENTER_TAG"
#define VALIGN_TAG_TYPE     @"VALIGN_TAG"


#define TOP_TAG_TYPE @"TOP_TAG"
#define TOP_TAG_TYPE @"TOP_TAG"

@interface ViewController : UIViewController
{
    NSString *selectFname;
    CFDataRef pixelData;
    OCRDocument *od;
    OCRTemplate *ot;
    UIView *selectBox;
    CGRect selectDocRect;
    CGRect pageRect;
    CGRect docRect;
    int arrowStepSize;
    int viewWid,viewHit,viewW2,viewH2;
    BOOL editing;
    BOOL adjusting;
    double docXConv,docYConv;
    NSString *supplierName;
    NSString *fieldName;
    NSString *fieldNameShort;
    NSString *fieldFormat;
    
    NSArray *columnHeaders;
    
    //INvoice-specific fields (MOVE TO SEPARATE OBJECT)
    int invoiceNumber;
    NSDate *invoiceDate;
    NSString *invoiceCustomer;
    float invoiceTotal;
    NSMutableArray *rowItems;
    
    CGPoint touchLocation;
    int touchX,touchY;
    int touchDocX,touchDocY;
    BOOL dragging;
    int adjustSelect;

}

@property (weak, nonatomic) IBOutlet UIButton *arrowRightSelect;
@property (weak, nonatomic) IBOutlet UIImageView *inputImage;
@property (weak, nonatomic) IBOutlet UIView *LHArrowView;
@property (weak, nonatomic) IBOutlet UIView *RHArrowView;
@property (weak, nonatomic) IBOutlet UIView *selectOverlayView;
@property (weak, nonatomic) IBOutlet UIButton *addFieldButton;

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

