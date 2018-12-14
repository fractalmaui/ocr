//
//                            _   ____                _            _
//   ___ _ __ ___   __ _ _ __| |_|  _ \ _ __ ___   __| |_   _  ___| |_ ___
//  / __| '_ ` _ \ / _` | '__| __| |_) | '__/ _ \ / _` | | | |/ __| __/ __|
//  \__ \ | | | | | (_| | |  | |_|  __/| | | (_) | (_| | |_| | (__| |_\__ \
//  |___/_| |_| |_|\__,_|_|   \__|_|   |_|  \___/ \__,_|\__,_|\___|\__|___/
//
//  smartProducts.m
//  testOCR
//
//  Created by Dave Scruton on 12/12/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import "smartProducts.h"

@implementation smartProducts


//=============(smartProducts)=====================================================
-(instancetype) init
{
    if (self = [super init])
    {
        [self loadTables];
    }
    return self;
}

//=============(smartProducts)=====================================================
//STUBBED FOR NOW, use DB
-(void) loadTables
{
    beverageNames = @[   //CANNED
                      @"apple juice",
                      @"bottled water",
                      @"cocoa",
                      @"coffee",
                      @"coke",
                      @"cream",
                      @"drink mix",
                      @"ginger ale",
                      @"grape juice",
                      @"juice",
                      @"mg guava nectar",   // Need multiple words?",
                      @"mg pass organic nectar",   // Multiple words?
                      @"orange juice",
                      @"raspberry tea",
                      @"sprite",
                      @"sprite zero",
                      @"tea",
                      @"vegetable soup", //WTF???
                      @"yogurt",
                      @"zico natural"
                      ];
    dairyNames = @[   //CANNED
                   @"buttermilk",
                   @"cheese",
                   @"cream",
                   @"creamer",
                   @"ice cream",
                   @"milk",
                   @"PP CS",   //WTF???
                   @"sherbert",
                   @"yogurt"
                   ];
    dryGoodsNames = @[   //CANNED
                      @"applesauce",
                      @"apple sauce",
                      @"beans, black",  //vs. green beans as produce?
                      @"beans, kidney",  //vs. green beans as produce?
                      @"beef base",
                      @"beef consume",
                      @"bread",
                      @"broth",
                      @"butter prints",
                      @"canned",
                      @"catsup",
                      @"cereal",
                      @"chicken base",
                      @"chowder",
                      @"coconut milk",
                      @"condensed milk",
                      @"corn meal",
                      @"cracker",
                      @"crackers",
                      @"cranberry juice",
                      @"creamer",
                      @"crisco",
                      @"crouton",
                      @"cumin",
                      @"dressing",
                      @"dressings",
                      @"filling",
                      @"filling cherry pie",
                      @"filling blueberry",
                      @"flour",
                      @"fruit tropical mix",
                      @"fruit bowl",
                      @"fruit cocktail",
                      @"garlic, granulated",
                      @"granola",
                      @"granulated",
                      @"gravy",
                      @"jelly",
                      @"ketchup",
                      @"margarine",
                      @"mashed potatoes",
                      @"mayonnaise",
                      @"mustard",
                      @"oats",
                      @"oil",
                      @"olives",
                      @"onion powder",
                      @"oranges, mandarin",
                      @"pasta",
                      @"paste",
                      @"pepper",
                      @"peaches", //NEVER FRESH?
                      @"pears, bartlett",
                      @"pickle",
                      @"potato pearls",
                      @"powder",
                      @"pudding",
                      @"pursed broccoli",
                      @"rice",
                      @"salt",
                      @"seasoning",
                      @"shoyu",
                      @"soup",
                      @"sugar",
                      @"syrup",
                      @"tahini",
                      @"thickener",
                      @"tortilla",
                      @"topping",
                      @"vanilla",
                      @"vienna sausage", //WHY NOT PROTEIN?
                      @"vinegar",
                      @"wafer"
                      ];
    miscNames = @[ //CANNED
                      @"charges",
                      @"taxes"
                     ];
    proteinNames = @[ //CANNED
                     @"beef",
                     @"chicken",
                     @"eggs",
                     @"fish",
                     @"fishcake",
                     @"pork",
                     @"spam",
                     @"steak",
                     @"tuna"    //here or dry goods?
                     ];
    produceNames = @[ //CANNED, need to check plurals too!
                     @"apple",
                     @"banana",
                     @"basil",
                     @"bok choy",
                     @"broccoli",
                     @"cantaloupe",
                     @"cabbage",
                     @"celery",
                     @"corn IFQ",  //???WTF?
                     @"cranberry",
                     @"cucumber",
                     @"garlic",
                     @"green beans",
                     @"honeydew",
                     @"lemon",
                     @"lettuce",
                     @"mushroom",
                     @"onion",
                     @"orange",  //confusion w/ orange juice?
                     @"papaya",
                     @"peas",
                     @"pineapple",
                     @"potato",
                     @"potatoes",
                     @"spinach",
                     @"squash",
                     @"strawberries",
                     @"strawberry",
                     @"tomato",
                     @"tomatoes",
                     @"vegetable blend",
                     @"watermelon"
                     ];
    suppliesNames = @[ //CANNED
                      @"degreaser",
                      @"delimer",
                      @"detergent",
                      @"filter",
                      @"fork",
                      @"hairnet",
                      @"knives",
                      @"knife",
                      @"lid",
                      @"presoak",
                      @"rinse aid",
                      @"refill",
                      @"sanitizer",
                      @"spoon",
                      @"teaspoon",
                      @"wiper"
                  ];
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
        if ([beverageNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            foundResult = BEVERAGE_CATEGORY;
            _latestUOM = @"case";
            processed = TRUE;
            bulk = TRUE;
        }
        else if ([dairyNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            foundResult = DAIRY_CATEGORY;
            _latestUOM = @"qt";  //THis varies widely! maybe second array should be:
            processed = TRUE;    //   UOM/processed/bulk, matching product names one for one
            bulk = TRUE;
        }
        else if ([dryGoodsNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            foundResult = DRY_GOODS_CATEGORY;
            _latestUOM = @"lb";  //THis varies widely! see dairy
            processed = TRUE;
            bulk = TRUE;
        }
        else if ([miscNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            foundResult = MISC_CATEGORY;
            _latestUOM = @"n/a";   
            processed = FALSE;
            bulk = FALSE;
        }
        else if ([produceNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            foundResult = PRODUCE_CATEGORY;
            _latestUOM = @"lb";
            processed = FALSE;
            bulk = TRUE;
        }
        else if ([proteinNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            foundResult = PROTEIN_CATEGORY;
            _latestUOM = @"lb";
            processed = FALSE; //Is ground beef processed?
            bulk = TRUE; //Is this ok for all meat?
        }
        else if ([suppliesNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            foundResult = SUPPLIES_CATEGORY;
            _latestUOM = @"n/a";
            processed = FALSE;
            bulk = FALSE;
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
    if (local) _latestLocal = @"Yes";
    else       _latestLocal = @"No";
    
    if (bulk) _latestBulkOrIndividual = @"Bulk";
    else      _latestBulkOrIndividual = @"Individual";
    
    if (processed) _latestProcessed = @"PROCESSED";
    else           _latestProcessed = @"UNPROCESSED";
    
    if ([_latestUOM isEqualToString: @"n/a"])
    {
        _latestBulkOrIndividual = @"n/a";
        _latestLocal            = @"n/a";
        _latestProcessed        = @"n/a";
    }
    
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
        NSString *lowerCase = [nextWord lowercaseString]; //Match lowercase only
        if ([proteinNames indexOfObject:lowerCase] != NSNotFound) //Found?
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
