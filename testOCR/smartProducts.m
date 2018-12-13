//
//  smartProducts.m
//  testOCR
//
//  Created by Dave Scruton on 12/12/18.
//  Copyright © 2018 huedoku. All rights reserved.
//

#import "smartProducts.h"

@implementation smartProducts


//=============(smartProducts)=====================================================
-(instancetype) init
{
    if (self = [super init])
    {
        proteinTable = [[NSMutableArray alloc] init];
        [self loadTables];
    }
    return self;
}

//=============(smartProducts)=====================================================
//STUBBED FOR NOW, use DB
-(void) loadTables
{
    proteinNames = @[ //CANNED
                     @"beef",
                     @"steak",
                     @"pork",
                     @"chicken",
                     @"fish"
                     ];
   [proteinTable addObjectsFromArray : proteinNames];
}

//=============(smartProducts)=====================================================
-(void) clear
{
    fullProductName = @"";
    vendor = @"";
    _latestCategory = @"";
    _latestUOM = @"";
    _latestBulkOrIndividual = @"";
    _latestQuantity = @"";
    _latestPricePerUOM = @"";
    _latestTotalPrice = @"";
    _latestProcessed = @"";
    _latestLocal = @"";
    _invoiceDate = [NSDate date];
    _invoiceDateString = @"";
    _latestLineNumber  = @"";
    lineNumber = 0;
}

//=============(smartProducts)=====================================================
-(void) addDate : (NSDate*)ndate
{
    invoiceDate = ndate;
}

//=============(smartProducts)=====================================================
-(void) addLineNumber : (int)n
{
    lineNumber = n;
}

//=============(smartProducts)=====================================================
-(void) addRawPrice : (NSString*)price
{
    rawPrice = price; //String
}

//=============(smartProducts)=====================================================
// Inputs to analyzer: keep inputs private!
-(void) addProductName : (NSString*)pname;
{
    fullProductName = pname;
}


//=============(smartProducts)=====================================================
-(void) addVendor : (NSString*)vname;
{
    vendor = vname;
}

//=============(smartProducts)=====================================================
-(void) analyze
{
    BOOL found = FALSE;
    _analyzeOK = FALSE;
    processed = FALSE;
    local     = FALSE;
    bulk      = FALSE;
    NSString *foundResult = @"EMPTY";
    //Take a look at the product name, see if we can figger it out!
    NSArray *pItems    = [fullProductName componentsSeparatedByString:@" "]; //Separate words
    for (NSString *nextWord in pItems)
    {
        if (found) break;
        NSString *lowerCase = [nextWord lowercaseString]; //Always match on lowercase
        if ([proteinTable indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            foundResult = PROTEIN_CATEGORY;
            _latestUOM = @"lb";
            processed = FALSE; //Is ground beef processed?
            bulk = TRUE; //Is this ok for all meat?
        }
    }
    if (!found) return;
    _latestCategory = foundResult;
    
    //price per uom!
    
    _latestTotalPrice = rawPrice;
    if (![_latestTotalPrice containsString:@"."]) _latestTotalPrice = [_latestTotalPrice stringByAppendingString:@".00"];//super unformatted? add cents
    // No dollar sign? add one
    if (![_latestTotalPrice containsString:@"$"]) _latestTotalPrice =
        [@"$" stringByAppendingString:_latestTotalPrice];
    
    //Handle flags...
    if (processed) _latestProcessed = @"PROCESSED";
    else           _latestProcessed = @"UNPROCESSED";
    
    if (local) _latestLocal = @"Yes";
    else       _latestLocal = @"No";
    
    if (bulk) _latestBulkOrIndividual = @"Bulk";
    else      _latestBulkOrIndividual = @"Individual";
    
    _latestDateString = [self getDateAsString:invoiceDate];
    _latestShortDateString = [self getDateAsShortString:invoiceDate];
    _latestLineNumber = [NSString stringWithFormat:@"%d",lineNumber];
    //Just pass across from private -> public here
    _latestVendor = vendor;
    
    // _latestDateString = [invoiceDate string
    NSLog(@"duh %@",_latestLocal);
    _analyzeOK = TRUE;
}



//=============(smartProducts)=====================================================
-(NSString*) getCategoryByProduct : (NSString*)pname
{
    BOOL found = FALSE;
    NSString *foundResult = @"EMPTY";
    NSArray *pItems    = [pname componentsSeparatedByString:@" "]; //Separate words
    for (NSString *nextWord in pItems)
    {
        if (found) break;
        NSString *lowerCase = [nextWord lowercaseString];
        if ([proteinTable indexOfObject:nextWord] != NSNotFound) //Found?
        {
            found = TRUE;
            foundResult = PROTEIN_CATEGORY;
            _latestUOM = @"lb";
        }
    }
    _latestCategory = foundResult;
    return foundResult;
}

//=============(smartProducts)=====================================================
-(NSString*) getCategoryByProductAndVendor : (NSString*)pname : (NSString*)vname
{
    return @"EMPTY";
}

//=============(smartProducts)=====================================================
-(NSString *)getDateAsShortString : (NSDate *) ndate
{
    NSDateFormatter * formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"dd-MMM"];
    return [formatter stringFromDate:ndate]; 

}

//=============(smartProducts)=====================================================
-(NSString *)getDateAsString : (NSDate *) ndate
{
    NSDateFormatter * formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yy"];
//    [formatter setDateFormat:@"yyyy-MMM-dd HH:mm:ss"];
    NSString *dateString = [formatter stringFromDate:ndate];//pass the date you get from UIDatePicker
    return dateString;
}
                         

@end
