//
//                            _   ____                _            _
//   ___ _ __ ___   __ _ _ __| |_|  _ \ _ __ ___   __| |_   _  ___| |_ ___
//  / __| '_ ` _ \ / _` | '__| __| |_) | '__/ _ \ / _` | | | |/ __| __/ __|
//  \__ \ | | | | | (_| | |  | |_|  __/| | | (_) | (_| | |_| | (__| |_\__ \
//  |___/_| |_| |_|\__,_|_|   \__|_|   |_|  \___/ \__,_|\__,_|\___|\__|___/
//
//
//  smartProducts.h
//  testOCR
//
//  Created by Dave Scruton on 12/12/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN


#define BEVERAGE_CATEGORY @"BEVERAGE"
#define BREAD_CATEGORY @"BREAD"
#define DAIRY_CATEGORY @"DAIRY"
#define DRY_GOODS_CATEGORY @"DRY GOODS"
#define EQUIPMENT_CATEGORY @"EQUIPMENT"
#define MISC_CATEGORY @"MISC"
#define PAPER_GOODS_CATEGORY @"PAPER GOODS"
#define PROTEIN_CATEGORY @"PROTEIN"
#define PRODUCE_CATEGORY @"PRODUCE"
#define SNACKS_CATEGORY @"SNACKS"
#define SUPPLEMENTS_CATEGORY @"SUPPLEMENTS"
#define SUPPLIES_CATEGORY @"SUPPLIES"

@interface smartProducts : NSObject
{
    //These tables of product listings get loaded from DB
    NSString *fullProductName;
    NSString *vendor;
    NSString *rawPrice;
    BOOL processed;
    BOOL local;
    BOOL bulk;
    int lineNumber;
    NSArray *beverageNames;
    NSArray *dairyNames;
    NSArray *dryGoodsNames;
    NSArray *miscNames;    
    NSArray *proteinNames;
    NSArray *produceNames;
    NSArray *suppliesNames;
    NSDate* invoiceDate;
}
//These props get set by analyze for public access...
@property (nonatomic , strong) NSString* latestDateString;
@property (nonatomic , strong) NSString* latestShortDateString;
@property (nonatomic , strong) NSString* latestCategory;
@property (nonatomic , strong) NSString* latestUOM;
@property (nonatomic , strong) NSString* latestBulkOrIndividual;
@property (nonatomic , strong) NSString* latestQuantity;
@property (nonatomic , strong) NSString* latestPricePerUOM;
@property (nonatomic , strong) NSString* latestTotalPrice;
@property (nonatomic , strong) NSString* latestProcessed;
@property (nonatomic , strong) NSString* latestLocal;
@property (nonatomic , strong) NSString* latestVendor;
@property (nonatomic , strong) NSDate* invoiceDate;
@property (nonatomic , strong) NSString* invoiceDateString;
@property (nonatomic , strong) NSString* latestLineNumber; //String?
@property (nonatomic , assign) BOOL analyzeOK;



-(void) clear;
-(void) addProductName : (NSString*)pname;
-(void) addVendor : (NSString*)vname;
-(void) addDate : (NSDate*)ndate;
-(void) addLineNumber : (int)n;
-(void) addRawPrice : (NSString*)price;
-(void) analyze;
-(void) dump;


@end

NS_ASSUME_NONNULL_END