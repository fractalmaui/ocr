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
//  12/31 add typos

#import "smartProducts.h"

@implementation smartProducts


//=============(smartProducts)=====================================================
-(instancetype) init
{
    if (self = [super init])
    {
        [self loadTables];
        occ      = [OCRCategories sharedInstance];
        typos    =  [[NSMutableArray alloc] init];
        fixed    =  [[NSMutableArray alloc] init];
        splits   =  [[NSMutableArray alloc] init];
        joined   =  [[NSMutableArray alloc] init];
        wilds    =  [[NSMutableArray alloc] init];
        notwilds =  [[NSMutableArray alloc] init];
        [self loadRulesTextFile : @"splits" : FALSE : splits : joined];
        [self loadRulesTextFile : @"typos"  : TRUE :  typos  : fixed];
        [self loadRulesTextFile : @"wild"   : TRUE :  wilds  : notwilds];
    }
    return self;
}

//=============(smartProducts)=====================================================
//STUBBED FOR NOW, use DB
-(void) loadTables
{
    nonProducts = @[  //CANNED stuff that never is a product
                    @"subtotal",
                    @"charge",
                    @"surcharge",
                    @"discount"
                    ];
        
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
                     @"apples",
                     @"bananas",
                     @"basil",
                     @"bok choy",
                     @"broccoli",
                     @"cantaloupes",
                     @"cabbage",
                     @"carrots",
                     @"celery",
                     @"corn IFQ",  //???WTF?
                     @"cranberry",
                     @"cucumbers",
                     @"garlic",
                     @"green beans",
                     @"honeydew",
                     @"lemons",
                     @"lettuce",
                     @"melons",
                     @"mushrooms",
                     @"onions",
                     @"oranges",  //confusion w/ orange juice?
                     @"papaya",
                     @"papayas",
                     @"peas",
                     @"pineapples",
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
    //MISSING: Equipment,Paper Goods, Snacks, Supplement, Bread, Labor, Other Exp, Services, Transfer
    

}

//=============(smartProducts)=====================================================
-(void) clearOutputs
{
    _latestCategory = @"";
    _latestUOM = @"";
    _latestBulkOrIndividual = @"";
    _latestQuantity = @"";
    _latestPricePerUOM = @"";
    _latestPrice = @"";
    _latestProcessed = @"";
    _latestLocal = @"";
    _latestLineNumber  = @"";
    _latestProductName = @"";
    _latestVendor = @"";
    _latestAmount = @"";
    _latestShortDateString = @"";
    _latestDateString = @"";

}

//=============(smartProducts)=====================================================
-(void) clear
{
    fullProductName = @"";
    vendor = @"";
    _invoiceDate = [NSDate date];
    _invoiceDateString = @"";
    lineNumber = 0;
}

//=============(smartProducts)=====================================================
-(void) addDate : (NSDate*)ndate
{
    _invoiceDate = ndate;
}

//=============(smartProducts)=====================================================
-(void) addLineNumber : (int)n
{
    lineNumber = n;
}

//=============(smartProducts)=====================================================
-(void) addAmount : (NSString*)s
{
    amount = s; //String
}

//=============(smartProducts)=====================================================
-(void) addPrice : (NSString*)s
{
    price = s; //String
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
-(void) addQuantity:(NSString *)qstr
{
    quantity = qstr;
}


//=============(smartProducts)=====================================================
-(NSString*) getErrDescription : (int) aerr
{
    NSString *result = @"Bad Errcode";
    switch(aerr)
    {
        case ANALYZER_BAD_PRICE_COLUMNS: result = @"Bad Price Columns";
            break;
        case ANALYZER_MATH_ERROR:        result = @"Math Err";
            break;
        case ANALYZER_NO_PRODUCT_FOUND:  result =[NSString stringWithFormat:@"No Product Found (%@)",fullProductName];
            break;
        case ANALYZER_ZERO_AMOUNT:       result = @"Zero Amount";
            break;
        case ANALYZER_ZERO_PRICE:        result = @"Zero Price";
            break;
        case ANALYZER_ZERO_QUANTITY:     result = @"Zero Quantity";
            break;
    }
    
    return result;
}

//=============(smartProducts)=====================================================
-(BOOL) analyzeProductName
{
    BOOL found = FALSE;
    _latestCategory = @"EMPTY";
    _nonProduct = FALSE;

    if ([fullProductName.lowercaseString containsString:@"elat"])
    {
        NSLog(@" weird elat string");
    }
    //Bail on any weird product names, or obviously NON-product items found in this column...
    for (NSString *nps in nonProducts)
    {
        if ([fullProductName.lowercaseString containsString:nps])
        {
            NSLog(@" non product %@",fullProductName);
            _nonProduct = TRUE;
            return false;
        }
    }
    //Fix typos...
    NSString* opn = fullProductName;
    fullProductName = [self fixSentenceTypo:fullProductName];
    //NSLog(@" cleanup product name %@ -> %@",opn,fullProductName);
    NSArray *pItems    = [fullProductName componentsSeparatedByString:@" "]; //Separate words

    //Try matching with built-in CSV file cat.txt first...
    NSArray *a = [occ matchCategory:fullProductName];
    if (a != nil && a.count > 0)  //Hit?  
    {
        if (a.count >= 4)
        {
            _latestCategory  = a[0]; //Get canned data out from array...
            _latestProcessed = a[2];
            _latestLocal     = a[3];
            processed = ([_latestProcessed.lowercaseString isEqualToString:@"processed"]);
            local     = ([_latestLocal.lowercaseString isEqualToString:@"yes"]);
            _latestProductName = fullProductName; //Set output product name!
            return TRUE;
        }
    }
    //Miss? Try matching words in the product name with some generic lists of items...
    //  Must do it word-by-word, so it's SLOW...
    for (NSString *nextWord in pItems)
    {
        if (found) break;
        NSString *lowerCase = [nextWord lowercaseString]; //Always match on lowercase
        lowerCase = [lowerCase   stringByReplacingOccurrencesOfString:@"/" withString:@""]; //Get rid of illegal stuff!
        if ([beverageNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            _latestCategory = BEVERAGE_CATEGORY;
            _latestUOM = @"case";
            processed = TRUE;
            bulk = TRUE;
        }
        else if ([dairyNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            _latestCategory = DAIRY_CATEGORY;
            _latestUOM = @"qt";  //THis varies widely! maybe second array should be:
            processed = TRUE;    //   UOM/processed/bulk, matching product names one for one
            bulk = TRUE;
        }
        else if ([dryGoodsNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            _latestCategory = DRY_GOODS_CATEGORY;
            _latestUOM = @"lb";  //THis varies widely! see dairy
            processed = TRUE;
            bulk = TRUE;
        }
        else if ([miscNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            _latestCategory = MISC_CATEGORY;
            _latestUOM = @"n/a";
            processed = FALSE;
            bulk = FALSE;
        }
        else if ([produceNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            _latestCategory = PRODUCE_CATEGORY;
            _latestUOM = @"lb";
            processed = FALSE;
            bulk = TRUE;
        }
        else if ([proteinNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            _latestCategory = PROTEIN_CATEGORY;
            _latestUOM = @"lb";
            processed = FALSE; //Is ground beef processed?
            bulk = TRUE; //Is this ok for all meat?
        }
        else if ([suppliesNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            _latestCategory = SUPPLIES_CATEGORY;
            _latestUOM = @"n/a";
            processed = FALSE;
            bulk = FALSE;
        }
    }
    _latestProductName = fullProductName;
    return found;
    
} //end analyzeProductName

//=============(smartProducts)=====================================================
// Does ALL analyzing...non-zero return value means FAIL: Don't ADD!
-(int) analyze
{
    [self clearOutputs]; //Get rid of residue from last pass...
    _analyzeOK = FALSE;
    processed  = FALSE;
    local      = FALSE;
    bulk       = FALSE;
    int aerror = 0;

    //Bail on any weird product names, or obviously NON-product items found in this column...
    for (NSString *nps in nonProducts)
    {
        if ([fullProductName.lowercaseString containsString:nps])
        {
            NSLog(@" non product %@",fullProductName);
            _nonProduct = TRUE;
            return ANALYZER_NONPRODUCT;
        }
    }
    //Fix typos...
//    NSString* opn = fullProductName;
    //DHS 12/31: Fix common misspellings, like "ananas" or "apaya"...
    fullProductName = [self fixSentenceTypo:fullProductName];
    //DHS 1/1 fix split words like "hawai ian"
    fullProductName = [self fixSentenceSplits:fullProductName];
    
    _latestCategory = @"EMPTY";

    //NSLog(@" cleanup product name %@ -> %@",opn,fullProductName);
    NSArray *pItems    = [fullProductName componentsSeparatedByString:@" "]; //Separate words
    
    // Get product category / processed / local / bulk / etc....
    //Try matching with built-in CSV file cat.txt first...
    BOOL found = FALSE;
    NSArray *a = [occ matchCategory:fullProductName];
    if (a != nil && a.count > 0)  //Hit?
    {
        if (a.count >= 4)
        {
            _latestCategory  = a[0]; //Get canned data out from array...
            _latestProcessed = a[2];
            _latestLocal     = a[3];
            processed = ([_latestProcessed.lowercaseString isEqualToString:@"processed"]);
            local     = ([_latestLocal.lowercaseString isEqualToString:@"yes"]);
            _latestProductName = fullProductName; //Set output product name!
            found = TRUE;
        }
    }
    //Miss? Try matching words in the product name with some generic lists of items...
    //  Must do it word-by-word, so it's SLOW...
    for (NSString *nextWord in pItems) //Note we bail this section immediately if found is true
    {
        if (found) break;
        NSString *lowerCase = [nextWord lowercaseString]; //Always match on lowercase
        lowerCase = [lowerCase   stringByReplacingOccurrencesOfString:@"/" withString:@""]; //Get rid of illegal stuff!
        if ([beverageNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            _latestCategory = BEVERAGE_CATEGORY;
            _latestUOM = @"case";
            processed = TRUE;
            bulk = TRUE;
        }
        else if ([dairyNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            _latestCategory = DAIRY_CATEGORY;
            _latestUOM = @"qt";  //THis varies widely! maybe second array should be:
            processed = TRUE;    //   UOM/processed/bulk, matching product names one for one
            bulk = TRUE;
        }
        else if ([dryGoodsNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            _latestCategory = DRY_GOODS_CATEGORY;
            _latestUOM = @"lb";  //THis varies widely! see dairy
            processed = TRUE;
            bulk = TRUE;
        }
        else if ([miscNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            _latestCategory = MISC_CATEGORY;
            _latestUOM = @"n/a";
            processed = FALSE;
            bulk = FALSE;
        }
        else if ([produceNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            _latestCategory = PRODUCE_CATEGORY;
            _latestUOM = @"lb";
            processed = FALSE;
            bulk = TRUE;
        }
        else if ([proteinNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            _latestCategory = PROTEIN_CATEGORY;
            _latestUOM = @"lb";
            processed = FALSE; //Is ground beef processed?
            bulk = TRUE; //Is this ok for all meat?
        }
        else if ([suppliesNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            _latestCategory = SUPPLIES_CATEGORY;
            _latestUOM = @"n/a";
            processed = FALSE;
            bulk = FALSE;
        }
    }
    _latestProductName = fullProductName; //asdf

    //REDUNDANT: see above! found = [self analyzeProductName];
    if (!found)
    {
        //NSLog(@" analyze ... no product found %@",fullProductName);
        return ANALYZER_NO_PRODUCT_FOUND; //Indicate failure
    }
    
    
    if ( //Got a product of Hawaii in description? set local flag
        [fullProductName.lowercaseString containsString:@"hawaii"] ||
        [fullProductName.lowercaseString containsString:@"hawa11"]
        )
        local = TRUE;
    
    //Sanity Check: quantity * price = amount?
    int   qint       = [quantity intValue];
    float pfloat     = [price floatValue];
    float afloat     = [amount floatValue];
    if (afloat > 1000.0) //Huge Amount? Assume decimal error
    {
        NSLog(@" ERROR: amount over $1000!!");
        afloat = afloat / 100.0;
    }
    if (pfloat > 1000.0) //Huge Price? Assume decimal error
    {
        NSLog(@" ERROR: price over $1000!!");
        pfloat = pfloat / 100.0;
    }
    float testAmount = (float)qint * pfloat;
    
    NSLog(@" above [%@] priceFix q p a %d %f %f",fullProductName,qint,pfloat,afloat);
    if (pfloat == 0.0 && afloat == 0.0) //Bad! no price no dice!
    {
        NSLog(@" ... bad price columns!");
        aerror = ANALYZER_BAD_PRICE_COLUMNS;
    }
    else if (afloat != testAmount || qint == 0)
    {
        NSLog(@" ...price err: q * p not equal to a!");
        if (afloat == 0.0 && qint != 0)
        {
            amount = [self getDollarsAndCentsString:(float)qint * pfloat];
            aerror = ANALYZER_ZERO_AMOUNT;
        }
        else if (afloat != 0.0 && qint == 0)
        {
            NSLog(@" ...ZERO QUANTITY: FIX");
            qint = (int)floor((afloat / pfloat) + 0.5);
            quantity = [NSString stringWithFormat:@"%d", qint]; //pf better be != 0!
            aerror = ANALYZER_ZERO_QUANTITY;
        }
        else if (pfloat == 0.0)
        {
            NSLog(@" ...ZERO PRICE: FIX");
            price = [self getDollarsAndCentsString:afloat / (float)qint];
            //price  = [NSString stringWithFormat:@"%4.2f",afloat / (float)qint];
            aerror = ANALYZER_ZERO_PRICE;
        }
        else //All fields present but still bad math? Assume quantity is wrong?
        {
            NSLog(@" ...bad math?");
            if (qint == 1) //Check mismatch price/amount, defer to amount
            {
                pfloat = afloat;
                price = [self getDollarsAndCentsString  : pfloat];
                amount = [self getDollarsAndCentsString : afloat];
            }
            else //Bogus quantity maybe?
            {
                qint = (int)floor((afloat / pfloat) + 0.5);
            }
        }
    }
    //pass to outputs...
    _latestQuantity = quantity;
    _latestPrice    = price;
    _latestAmount   = amount;
    NSLog(@" latest qpa %@ / %@ / %@",quantity,price,amount);
    
    //super unformatted price/amount? add cents
//    if (![_latestPrice containsString:@"."])  _latestPrice  = [_latestPrice  stringByAppendingString:@".00"];
//    if (![_latestAmount containsString:@"."]) _latestAmount = [_latestAmount stringByAppendingString:@".00"];
    // No dollar sign? add one
    //Do we really need a dollar sign?
    //if (![_latestPrice containsString:@"$"]) _latestPrice =
    //    [@"$" stringByAppendingString:_latestPrice];
    
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
    
    _latestDateString = [self getDateAsString:_invoiceDate];
    _latestShortDateString = [self getDateAsShortString:_invoiceDate];
    _latestLineNumber = [NSString stringWithFormat:@"%d",lineNumber];
    //Just pass across from private -> public here
    _latestVendor = vendor;
    
    _analyzeOK = TRUE;
    _minorError = aerror;
    return 0;
} //end analyze

//=============(smartProducts)=====================================================
//Second pass...
-(BOOL) analyzeFinal
{
    [self clearOutputs]; //Get rid of residue from last pass...
    _analyzeOK = FALSE;
    processed = FALSE;
    local     = FALSE;
    bulk      = FALSE;
    //DHS 12/31: Fix common misspellings, like "ananas" or "apaya"...
    fullProductName = [self fixSentenceTypo:fullProductName];
    //DHS 1/1 fix split words like "hawai ian"
    fullProductName = [self fixSentenceSplits:fullProductName];

    BOOL found = [self analyzeProductName];
    if (!found)
    {
        _analyzeOK = FALSE;
        return _analyzeOK;
    }
    
    if ( //Got a product of Hawaii in description? set local flag
        [fullProductName.lowercaseString containsString:@"local"]    ||
        [fullProductName.lowercaseString containsString:@"hawaii"]   ||
        ([fullProductName containsString:@"hawaii"]
         &&
         [fullProductName containsString:@"produce"])                ||
        [fullProductName.lowercaseString containsString:@"hawa11"]
        )
        local = TRUE;
    
    //NOTE: quantity / price / amount NOT SET HERE!!
    //  must use postOCR stuff from document instead (assumed to be saved)

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
    
    _latestDateString = [self getDateAsString:_invoiceDate];
    _latestShortDateString = [self getDateAsShortString:_invoiceDate];
    _latestLineNumber = [NSString stringWithFormat:@"%d",lineNumber];
    //Just pass across from private -> public here
    _latestVendor = vendor;
    
    _analyzeOK = TRUE;
    return _analyzeOK;
} //end analyzeFinal

//=============(smartProducts)=====================================================
-(int) analyzeFull
{
    int aerror = 0;
    _analyzeOK = FALSE;
    processed  = FALSE;
    local      = FALSE;
    bulk       = FALSE;
    NSString *foundResult = @"EMPTY";
    BOOL found = [self analyzeProductName];
    if (!found)
    {
        //NSLog(@" analyze ... no product found %@",fullProductName);
        return ANALYZER_NO_PRODUCT_FOUND; //Indicate failure
    }
    
    _latestCategory = foundResult;
    
    if ( //Got a product of Hawaii in description? set local flag
        [fullProductName.lowercaseString containsString:@"hawaii"] ||
        [fullProductName.lowercaseString containsString:@"hawa11"]
        )
        local = TRUE;

    //Sanity Check: quantity * price = amount?
    int   qint       = [quantity intValue];
    float pfloat     = [price floatValue];
    float afloat     = [amount floatValue];
    if (afloat > 1000.0) //Huge Number? Assume decimal error
    {
        NSLog(@" ERROR: price over $1000!!: Assume misplaced decimal");
        afloat = afloat / 100.0;
        if (pfloat > 1000.0) pfloat = pfloat / 1000.0;
    }
    float testAmount = (float)qint * pfloat;
    
    NSLog(@" above [%@] priceFix q p a %d %f %f",fullProductName,qint,pfloat,afloat);
    if (pfloat == 0.0 && afloat == 0.0) //Bad! no price no dice!
    {
        NSLog(@" ... bad price columns!"); //asdf
        aerror = ANALYZER_BAD_PRICE_COLUMNS;
    }
    else if (afloat != testAmount)
    {
        NSLog(@" ...price err: q * p not equal to a!");
        if (afloat == 0.0 && qint != 0)
        {
            amount = [self getDollarsAndCentsString:(float)qint * pfloat];
            aerror = ANALYZER_ZERO_AMOUNT;
        }
        else if (afloat != 0.0 && qint == 0)
        {
            NSLog(@" ...ZERO QUANTITY: FIX");
            qint = (int)floor((afloat / pfloat) + 0.5);
            quantity = [NSString stringWithFormat:@"%d", qint]; //pf better be != 0!
            aerror = ANALYZER_ZERO_QUANTITY;
        }
        else if (pfloat == 0.0)
        {
            NSLog(@" ...ZERO PRICE: FIX");
            price = [self getDollarsAndCentsString:afloat / (float)qint];
            //price  = [NSString stringWithFormat:@"%4.2f",afloat / (float)qint];
            aerror = ANALYZER_ZERO_PRICE;
        }
        else //All fields present but still bad math? Assume quantity is wrong?
        {
            NSLog(@" ...bad math?");
            if (qint == 1) //Check mismatch price/amount, defer to amount
            {
                pfloat = afloat;
                price = [self getDollarsAndCentsString  : pfloat];
                amount = [self getDollarsAndCentsString : afloat];
            }
            else //Bogus quantity maybe?
            {
                qint = (int)floor((afloat / pfloat) + 0.5);
            }
        }
    }
    //pass to outputs...
    _latestQuantity = quantity;
    _latestPrice    = price;
    _latestAmount   = amount;
    NSLog(@" latest qpa %@ / %@ / %@",quantity,price,amount);
    
    //super unformatted price/amount? add cents
    if (![_latestPrice containsString:@"."])  _latestPrice  = [_latestPrice  stringByAppendingString:@".00"];
    if (![_latestAmount containsString:@"."]) _latestAmount = [_latestAmount stringByAppendingString:@".00"];
    // No dollar sign? add one
    //Do we really need a dollar sign?
    //if (![_latestPrice containsString:@"$"]) _latestPrice =
    //    [@"$" stringByAppendingString:_latestPrice];
    
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
    
    _latestDateString = [self getDateAsString:_invoiceDate];
    _latestShortDateString = [self getDateAsShortString:_invoiceDate];
    _latestLineNumber = [NSString stringWithFormat:@"%d",lineNumber];
    //Just pass across from private -> public here
    _latestVendor = vendor;
    
    _analyzeOK = TRUE;
    _minorError = aerror;
    return aerror;
} //end analyze



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

//=============(smartProducts)=====================================================
-(NSString*) getDollarsAndCentsString : (float) fin
{
    //NSLog(@" getDollarsAndCentsString %f",fin);
    int d = (int) fin;
    float hcf = 100.0 * fin;
    hcf -= (float)(100*d);
    int c = (int)floor(hcf + 0.5);
    //NSLog(@" dollars %d cents %d",d,c);
    return [NSString stringWithFormat:@"%d.%2.2d",d,c];
}

//=============(smartProducts)=====================================================
// Loads a canned text file containing "a=b" pairs, removes whitespace if needed
-(void) loadRulesTextFile : (NSString*) fname : (BOOL) noWhitespace :
                            (NSMutableArray *) lha : (NSMutableArray *) rha
{
    if (lha == nil || rha == nil) return;
    NSError *error;
    NSArray *sItems;
    NSString *fileContentsAscii;
    NSString *path = [[NSBundle mainBundle] pathForResource:fname ofType:@"txt" inDirectory:@"txt"];
    NSURL *url = [NSURL fileURLWithPath:path];
    fileContentsAscii = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:&error];
    if (error != nil)
    {
        NSLog(@" error reading %@ file",fname);
        return;
    }
    sItems    = [fileContentsAscii componentsSeparatedByString:@"\n"];
    [lha removeAllObjects];
    [rha removeAllObjects];
    for (NSString*s in sItems)
    {
        NSArray* lineItems    = [s componentsSeparatedByString:@"="];
        if (lineItems.count == 2) //Got a something = something type string?
        {
            NSString *lhand = lineItems[0];
            NSString *rhand = lineItems[1];
            if (noWhitespace) //Need to change anything?
            {
                lhand = [lhand stringByReplacingOccurrencesOfString:@" " withString:@""];
                rhand = [rhand stringByReplacingOccurrencesOfString:@" " withString:@""];
            }
            [lha addObject:lhand];
            [rha addObject:rhand];
        }
    }
    return;

} //end loadRulesTextFile


//=============(smartProducts)=====================================================
// Goes over splits list,  splits in the sentence are replaced by joined
-(NSString *) fixSentenceSplits : (NSString *)sentence
{
    //Look for common OCR splits (words with splits in them)
    NSString *output = sentence;
    for (int i=0;i<splits.count;i++)
    {
        if ([output containsString:splits[i]])
            output = [output stringByReplacingOccurrencesOfString:splits[i] withString:joined[i]];

    }
    return output;
} //end fixSentenceSplits

//=============(smartProducts)=====================================================
// Disassembles / reassembles a sentence, fixes any product name typos therein
-(NSString *) fixSentenceTypo : (NSString *)sentence
{
    //1/10: Dashes muck up word-by-word parsing, replace w/ whitespace
    NSString *sentenceNoDashes = [sentence stringByReplacingOccurrencesOfString:@"-" withString:@" "];
    NSArray *sItems = [[sentenceNoDashes lowercaseString] componentsSeparatedByString:@" "]; //Separate words
    BOOL bing = FALSE;
    int wcount = (int)sItems.count;
    NSMutableArray *outputWords = [[NSMutableArray alloc] init];
    for (int i=0;i<wcount;i++)
    {
        NSString *s = sItems[i];
        NSString *t = [self fixTypo:s];
        NSString *w = [self fixWildSplits:t];
        if (![s isEqualToString:t])  bing = TRUE; //Typo got fixed?
        if (![w isEqualToString:t])  bing = TRUE; //Wildcard got fixed?
        [outputWords addObject:w];
    }
    NSString *output = [outputWords componentsJoinedByString:@" "];
    //NSLog(@" fixit %@ -> %@",sentence,output);
    return output;
} //end fixSentenceTypo

//=============(smartProducts)=====================================================
// Looking for strange OCR errors with non-ascii characters...
-(NSString *) fixWildSplits : (NSString *)testString
{
    int i=0;
    for (NSString *s in wilds) //Assume abc*def  format...
    {
        NSArray *wslr    = [s componentsSeparatedByString:@"*"]; //Lh/Rh sides of *
        //Crude, check for both halves... but really should check to make sure
        //  RH side is TO RIGHT of LH side!
        if ([testString containsString:wslr[0]] && [testString containsString:wslr[1]])
            return [notwilds objectAtIndex:i];
        i++;
    }
    return testString; //Nothing to fix
} //end fixWildSplits

//=============(smartProducts)=====================================================
// 2 table lookup: typos and fixed spellings, simple array match / replace
-(NSString *) fixTypo : (NSString *)testString
{
    NSUInteger index = [typos indexOfObject:testString];
    if (index != NSNotFound)
    {
        return [fixed objectAtIndex:index];
    }
    return testString; //Nothing to fix
} //end fixTypo


@end
