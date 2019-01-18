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
//  1/10  add analyze, get rid of old analyze stuff...
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
                    @"refrigerated",
                    @"discount"
                    ];
        
    beverageNames = @[
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
    breadNames = @[
                   @"bagel",
                   @"bread",
                   @"dough",
                   @"english",
                   @"muffin",
                   @"waffle"
                  ];
    dairyNames = @[
                   @"buttermilk",
                   @"cheese",
                   @"cream",
                   @"creamer",
                   @"ice cream",
                   @"milk",
                   @"mozz",
                   @"mozzerella",
                   @"parm",
                   @"parmesian",
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
                      @"paprika",
                      @"pasta",
                      @"paste",
                      @"penne",
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
                      @"sauce",
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
                     @"brst",
                     @"chicken",
                     @"eggs",
                     @"fish",
                     @"fishcake",
                     @"ham",
                     @"pork",
                     @"sknls",
                     @"spam",
                     @"sausage",
                     @"steak",
                     @"tuna"    //here or dry goods?
                     ];
    produceNames = @[ //CANNED, need to check plurals too!
                     @"apples",
                     @"bananas",
                     @"basil",
                     @"berries",
                     @"bok choy",
                     @"blueberries",
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
                     @"mango",
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
    _analyzedCategory = @"";
    _analyzedUOM = @"";
    _analyzedBulkOrIndividual = @"";
    _analyzedQuantity = @"";
    _analyzedPricePerUOM = @"";
    _analyzedPrice = @"";
    _analyzedProcessed = @"";
    _analyzedLocal = @"";
    _analyzedLineNumber  = @"";
    _analyzedProductName = @"";
    _analyzedVendor = @"";
    _analyzedAmount = @"";
    _analyzedShortDateString = @"";
    _analyzedDateString = @"";

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
        case ANALYZER_BAD_MATH:          result = @"Bad Math";
            break;
        case ANALYZER_NONPRODUCT:        result = @"Non-Product";
            break;
    }

    return result;
} //end getErrDescription

//=============(smartProducts)=====================================================
-(NSString*) getMinorErrorString
{
    return [self getErrDescription : _minorError];
}

//=============(smartProducts)=====================================================
-(NSString*) getMajorErrorString
{
    return [self getErrDescription : _majorError];
}


//=============(smartProducts)=====================================================
// Does ALL analyzing...non-zero return value means FAIL: Don't ADD!
-(int) analyze
{
    [self clearOutputs]; //Get rid of residue from last pass...
    _analyzeOK  = FALSE;
    processed   = FALSE;
    local       = FALSE;
    bulk        = FALSE;
    _nonProduct = FALSE;
    int aerror  = 0;
    _majorError = 0;
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
    //DHS 12/31: Fix common misspellings, like "ananas" or "apaya"...
    fullProductName = [self fixSentenceTypo:fullProductName];
    //DHS 1/1 fix split words like "hawai ian"
    fullProductName = [self fixSentenceSplits:fullProductName];
    _analyzedCategory = @"EMPTY";
    NSArray *pItems = [fullProductName componentsSeparatedByString:@" "]; //Separate words
    
    // Get product category / processed / local / bulk / etc....
    //Try matching with built-in CSV file cat.txt first...
    BOOL found = FALSE;
    NSArray *a = [occ matchCategory:fullProductName]; //Returns array[4] on matche...
    if (a != nil && a.count >=4)  //Hit?
    {
        _analyzedCategory  = a[0]; //Get canned data out from array...
        _analyzedProcessed = a[2];
        _analyzedLocal     = a[3];
        _analyzedUOM       = a[4];
        processed = ([_analyzedProcessed.lowercaseString isEqualToString:@"processed"]);
        local     = ([_analyzedLocal.lowercaseString isEqualToString:@"yes"]);
        _analyzedProductName = fullProductName; //Set output product name!
        found = TRUE;
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
            _analyzedCategory = BEVERAGE_CATEGORY;
            _analyzedUOM = @"case";
            processed = TRUE;
            bulk = TRUE;
        }
        else if ([breadNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            _analyzedCategory = BREAD_CATEGORY;
            _analyzedUOM = @"case";
            processed = TRUE;
            bulk = TRUE;
        }
        else if ([dairyNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            _analyzedCategory = DAIRY_CATEGORY;
            _analyzedUOM = @"qt";  //THis varies widely! maybe second array should be:
            processed = TRUE;    //   UOM/processed/bulk, matching product names one for one
            bulk = TRUE;
        }
        else if ([dryGoodsNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            _analyzedCategory = DRY_GOODS_CATEGORY;
            _analyzedUOM = @"lb";  //THis varies widely! see dairy
            processed = TRUE;
            bulk = TRUE;
        }
        else if ([miscNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            _analyzedCategory = MISC_CATEGORY;
            _analyzedUOM = @"n/a";
            processed = FALSE;
            bulk = FALSE;
        }
        else if ([produceNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            _analyzedCategory = PRODUCE_CATEGORY;
            _analyzedUOM = @"lb";
            processed = FALSE;
            bulk = TRUE;
        }
        else if ([proteinNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            _analyzedCategory = PROTEIN_CATEGORY;
            _analyzedUOM = @"lb";
            processed = FALSE; //Is ground beef processed?
            bulk = TRUE; //Is this ok for all meat?
        }
        else if ([suppliesNames indexOfObject:lowerCase] != NSNotFound) // Protein category Found?
        {
            found = TRUE;
            _analyzedCategory = SUPPLIES_CATEGORY;
            _analyzedUOM = @"n/a";
            processed = FALSE;
            bulk = FALSE;
        }
    }
    _analyzedProductName = fullProductName; // pass result to output

    if (!found)
    {
        //NSLog(@" analyze ... no product found %@",fullProductName);
        _majorError = ANALYZER_NO_PRODUCT_FOUND;
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
    if (afloat > 10000.0) //Huge Amount? Assume decimal error
    {
        NSLog(@" ERROR: amount over $10000!!");
        afloat = afloat / 1000.0;
    }
    if (afloat > 1000.0) //Huge Amount? Assume decimal error
    {
        NSLog(@" ERROR: amount over $1000!!");
        afloat = afloat / 100.0;
    }
    if (pfloat > 10000.0) //Huge Price? Assume decimal error
    {
        NSLog(@" ERROR: price over $10000!!");
        pfloat = pfloat / 1000.0;
    }
    if (pfloat > 1000.0) //Huge Price? Assume decimal error
    {
        NSLog(@" ERROR: price over $1000!!");
        pfloat = pfloat / 100.0;
    }
    float testAmount = (float)qint * pfloat;
    
    //NSLog(@" above [%@] priceFix q p a %d %f %f",fullProductName,qint,pfloat,afloat);
    //Missing 2 / 3 values is a failure...
    if ((pfloat == 0.0 && afloat == 0.0) || (qint == 0 && afloat == 0.0)  || (qint == 0 && pfloat == 0.0) )
    {
        NSLog(@" ... 2 out of 3 price columns are zero!");
        _majorError = ANALYZER_BAD_PRICE_COLUMNS;
    }
    else if (afloat != testAmount || qint == 0)
    {
        NSLog(@" ...price err: q * p not equal to a!");
        if (afloat == 0.0 && qint != 0)
        {
            NSLog(@" ...ZERO Amount: FIX");
            amount = [self getDollarsAndCentsString:(float)qint * pfloat];
            aerror = ANALYZER_ZERO_AMOUNT;
        }
        else if (afloat != 0.0 && qint == 0)
        {
            NSLog(@" ...ZERO QUANTITY: FIX");
            qint = (int)floor((afloat / pfloat) + 0.5);
            aerror = ANALYZER_ZERO_QUANTITY;
        }
        else if (pfloat == 0.0)
        {
            NSLog(@" ...ZERO PRICE: FIX");
            pfloat = afloat / (float)qint;
            aerror = ANALYZER_ZERO_PRICE;
        }
        else //All fields present but still bad math? Assume quantity is wrong?
        {
            NSLog(@" ...bad math?");
            if (qint == 1) //Check mismatch price/amount, defer to amount
            {
                //1/18 This is a cluge! Greco Invoices are more likely to have a good price and a bad amount!
                if ([vendor.lowercaseString isEqualToString:@"greco"])
                {
                    afloat = pfloat;
                }
                else //Most other vendors: defer to the amount column
                    pfloat = afloat;
            }
            else //Bogus quantity maybe?
            {
                qint = (int)floor((afloat / pfloat) + 0.5);
            }
            _majorError = ANALYZER_BAD_MATH;
        }
    }
    quantity = [NSString stringWithFormat:@"%d", qint]; //pf better be != 0!
    price    = [self getDollarsAndCentsString  : pfloat];
    amount   = [self getDollarsAndCentsString  : afloat];
    //pass to outputs...
    _analyzedQuantity = quantity;
    _analyzedPrice    = price;
    _analyzedAmount   = amount;
    NSLog(@" latest qpa %@ / %@ / %@",quantity,price,amount);
    //Handle flags...
    if (local) _analyzedLocal = @"Yes";
    else       _analyzedLocal = @"No";
    
    if (bulk) _analyzedBulkOrIndividual = @"Bulk";
    else      _analyzedBulkOrIndividual = @"Individual";
    
    if (processed) _analyzedProcessed = @"PROCESSED";
    else           _analyzedProcessed = @"UNPROCESSED";
    
    if ([_analyzedUOM isEqualToString: @"n/a"])
    {
        _analyzedBulkOrIndividual = @"n/a";
        _analyzedLocal            = @"n/a";
        _analyzedProcessed        = @"n/a";
    }
    
    _analyzedDateString = [self getDateAsString:_invoiceDate];
    _analyzedShortDateString = [self getDateAsShortString:_invoiceDate];
    _analyzedLineNumber = [NSString stringWithFormat:@"%d",lineNumber];
    //Just pass across from private -> public here
    _analyzedVendor = vendor;
    
    _analyzeOK = TRUE;
    if (_majorError != 0) aerror = 0; //Major errors trump minor ones!
    _minorError = aerror;
    return 0;
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
            _analyzedUOM = @"lb";
        }
    }
    _analyzedCategory = foundResult;
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
-(NSString*) removePunctuationFromString : (NSString *)s
{
    NSArray *punctuationz = @[@",",@".",@":",@";",@"-",@"_",@"~",@"`",
                              @"!",@"@",@"#",@"$",@"%",@"^",@"&",@"*",@"(",@")",@"+",@"="];
    NSString *sNoPunct = s;
    for (NSString *punc in punctuationz)
    {
        sNoPunct = [sNoPunct stringByReplacingOccurrencesOfString:punc withString:@" "];
    }
    return sNoPunct;
} //end removePunctuationFromString

//=============(smartProducts)=====================================================
// Disassembles / reassembles a sentence, fixes any product name typos therein
-(NSString *) fixSentenceTypo : (NSString *)sentence
{
    //1/18: Get rid of punctuation: ALL punctuation!
    NSString *sNoPunct = [self removePunctuationFromString:sentence];
    NSArray *sItems = [[sNoPunct lowercaseString] componentsSeparatedByString:@" "]; //Separate words
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
