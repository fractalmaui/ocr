//
//    ___   ____ ____ _____                    _       _
//   / _ \ / ___|  _ \_   _|__ _ __ ___  _ __ | | __ _| |_ ___
//  | | | | |   | |_) || |/ _ \ '_ ` _ \| '_ \| |/ _` | __/ _ \
//  | |_| | |___|  _ < | |  __/ | | | | | |_) | | (_| | ||  __/
//   \___/ \____|_| \_\|_|\___|_| |_| |_| .__/|_|\__,_|\__\___|
//                                      |_|
//
//  OCRTemplate.h
//  testOCR
//
//  Created by Dave Scruton on 12/5/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import "OCRBox.h"
#import "DBKeys.h"
NS_ASSUME_NONNULL_BEGIN

@protocol OCRTemplateDelegate;


@interface OCRTemplate : NSObject
{
    NSMutableArray *ocrBoxes;
    NSString *fileLocation;
    NSString *fileWorkString;
    CGRect headerColumns[32]; //Overkill
    int headerColumnCount;
    //Comes from templated document (original)
    CGRect tlDocRect,trDocRect;

}

#define INVOICE_NUMBER_FIELD   @"INVOICE_NUMBER"
#define INVOICE_DATE_FIELD     @"INVOICE_DATE"
#define INVOICE_SUPPLIER_FIELD @"INVOICE_SUPPLIER"
#define INVOICE_CUSTOMER_FIELD @"INVOICE_CUSTOMER"
#define INVOICE_HEADER_FIELD   @"INVOICE_HEADER"
#define INVOICE_COLUMN_FIELD   @"INVOICE_COLUMN"
#define INVOICE_IGNORE_FIELD   @"INVOICE_IGNORE"
#define INVOICE_TOTAL_FIELD    @"INVOICE_TOTAL"

@property (nonatomic , strong) NSString* versionNumber;
@property (nonatomic , strong) NSString* supplierName;

@property (nonatomic, unsafe_unretained) id <OCRTemplateDelegate> delegate; // receiver of completion messages


-(void) addBox : (CGRect) frame : (NSString *)fname : (NSString *)format;
-(void) addTag : (int) index : (NSString*)tag;
-(void) clearFields;
-(void) clearHeaders;
-(void) clearTags : (int) index;
-(void) deleteBox : (int) index;
-(NSString *) getAllTags :(int) index;
-(int) getBoxCount;
-(CGRect) getBoxRect :(int) index;
-(NSString*) getBoxFieldName :(int) index;
-(NSString*) getBoxFieldFormat :(int) index;
-(CGRect) getTLOriginalRect;
-(CGRect) getTROriginalRect;
-(int) getColumnCount;
-(CGRect) getColumnByIndex : (int) index;
-(int)  getTagCount : (int) index;
-(void) addHeaderColumnToSortedArray : (int) index;
-(void) dump;
-(void) dumpBox : (int) index;
-(BOOL) isSupplierAMatch : (NSString *)stest;
-(void) loadTemplatesFromDisk;
-(void) setOriginalRects : (CGRect) tlr : (CGRect) trr;
-(void) saveTemplatesToDisk;
-(void) saveToParse   : (NSString *)vendorName;
-(void) readFromParse : (NSString *)vendorName;
-(BOOL) gotFieldAlready : (NSString*)fname;
-(int) hitField :(int) tx : (int) ty;
@end

NS_ASSUME_NONNULL_END

@protocol OCRTemplateDelegate <NSObject>
@required
@optional
- (void)didReadTemplate;
- (void)didSaveTemplate;
@end

