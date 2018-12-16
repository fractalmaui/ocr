//
//    ___   ____ ____  ____                                        _
//   / _ \ / ___|  _ \|  _ \  ___   ___ _   _ _ __ ___   ___ _ __ | |_
//  | | | | |   | |_) | | | |/ _ \ / __| | | | '_ ` _ \ / _ \ '_ \| __|
//  | |_| | |___|  _ <| |_| | (_) | (__| |_| | | | | | |  __/ | | | |_
//   \___/ \____|_| \_\____/ \___/ \___|\__,_|_| |_| |_|\___|_| |_|\__|
//
//  OCRDocument.m
//  testOCR
//
//  Created by Dave Scruton on 12/5/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import "OCRDocument.h"

@implementation OCRDocument


//=============(OCRDocument)=====================================================
-(instancetype) init
{
    if (self = [super init])
    {
        allWords             = [[NSMutableArray alloc] init];
        headerNames          = [[NSMutableArray alloc] init];
        columnStringData     = [[NSMutableArray alloc] init];
        ignoreList           = [[NSMutableArray alloc] init];

        gT10  = [[NSMutableSet alloc] init];
        gB10  = [[NSMutableSet alloc] init];
        gL10  = [[NSMutableSet alloc] init];
        gR10  = [[NSMutableSet alloc] init];
        gH20  = [[NSMutableSet alloc] init];
        gV20  = [[NSMutableSet alloc] init];
        gT50  = [[NSMutableSet alloc] init];
        gL50  = [[NSMutableSet alloc] init];
        useIgnoreList        = FALSE;
        srand((unsigned int)time(NULL));
    }
    return self;
}

//=============(OCRDocument)=====================================================
-(void) addColumnStringData : (NSMutableArray*)stringArray
{
    int clen = (int)stringArray.count; //Keep track of longest column...
    if (clen > _longestColumn) _longestColumn = clen;
    [columnStringData addObject:stringArray];
}

//=============(OCRDocument)=====================================================
-(void) clearGroups
{
    [gT10 removeAllObjects];
    [gB10 removeAllObjects];
    [gL10 removeAllObjects];
    [gR10 removeAllObjects];
    [gH20 removeAllObjects];
    [gV20 removeAllObjects];
    [gT50 removeAllObjects];
    [gL50 removeAllObjects];
}

//=============(OCRDocument)=====================================================
// Exhaustive pass over words,funnels them into various groups...
-(void) assembleGroups
{
    [self clearGroups];
    int index,dxmin,dymin,dxmax,dymax; //Make these properties?
    dxmin = dymin = 99999;
    dxmax = dymax = -99999;
    int xspread,yspread;
    int dx10,dy10,dx50,dy50,dx90,dy90;

    for (OCRWord *ow  in allWords)
    {
        int x = ow.left.intValue;
        int y = ow.top.intValue;
        if (x < dxmin) dxmin = x;
        if (y < dymin) dymin = y;
        if (x > dxmax) dxmax = x;
        if (y > dymax) dymax = y;
    }
    xspread = dxmax - dxmin;
    yspread = dymax - dymin;
    //Now get some stats...
    dx10 = dxmin + xspread/10;
    dy10 = dymin + yspread/10;
    dx50 = dxmin + xspread/2;
    dy50 = dymin + yspread/2;
    dx90 = dxmax - dx10;
    dy90 = dymax - dy10;
    index = 0;
    for (OCRWord *ow  in allWords)
    {
        NSNumber* inum = [NSNumber numberWithInt:index];
        NSNumber* xn = ow.left;
        NSNumber* yn = ow.top;
        int x = xn.intValue;
        int y = yn.intValue;
        if (x < dx10) [gL10 addObject:inum];  //Near L/R/T/B
        if (x > dx90) [gR10 addObject:inum];
        if (y < dy10) [gT10 addObject:inum];
        if (y > dy90) [gB10 addObject:inum];
        if (abs(x - dx50) < dx10) [gH20 addObject:inum]; //Near H center
        if (abs(y - dy50) < dy10) [gV20 addObject:inum]; //Near V Center
        if (x < dx50) [gL50 addObject:inum];  //Left half of page
        if (x < dy50) [gT50 addObject:inum];  //Top half
        index++;
    }
    //[self dumpGroup:gL50];
    //NSLog(@" duh done assssembling");
//    NSArray *dog = [self findTLWords];
    
} //end assembleGroups

//=============(OCRDocument)=====================================================
-(NSArray*) findTLWords
{
    NSMutableSet *set1 = [NSMutableSet setWithSet:gT10];
    [set1 intersectSet: gL10];
    return [set1 allObjects];
}

//=============(OCRDocument)=====================================================
-(NSArray*) findTRWords
{
    NSMutableSet *set1 = [NSMutableSet setWithSet:gT10];
    [set1 intersectSet: gR10];
    return [set1 allObjects];
}

//=============(OCRDocument)=====================================================
-(int) findStringInHeaders : (NSString*)s
{
    int index = 0;
    for (NSString *h in headerNames)
    {
        if ([h.lowercaseString isEqualToString:s]) return index;
    }
    return -1;
}
//=============(OCRDocument)=====================================================
-(int) findQuantityColumn
{
    int found = [self findStringInHeaders:@"quantity" ];
    if (found < 0) found = 0;
    return found;
}

//=============(OCRDocument)=====================================================
-(int) findItemColumn
{
    int found = [self findStringInHeaders:@"item" ];
    if (found < 0) found = 1;
    return found;
}


//=============(OCRDocument)=====================================================
-(int) findDescriptionColumn
{
    int found = [self findStringInHeaders:@"description" ];
    if (found < 0) found = 2;
    return found;
}


//=============(OCRDocument)=====================================================
-(int) findPriceColumn
{
    int found = [self findStringInHeaders:@"price" ];
    if (found < 0) found = 3;
    return found;
}

//=============(OCRDocument)=====================================================
-(int) findAmountColumn
{
    int found = [self findStringInHeaders:@"amount" ];
    if (found < 0) found = 4;
    return found;
}

//=============(OCRDocument)=====================================================
-(void) dumpGroup : (NSMutableSet*)g
{
   for (NSNumber *n in g)
   {
       OCRWord *ow = allWords[n.longValue];
       NSLog(@" w[%d] %@",n.intValue,ow.wordtext);
   }
}
//=============(OCRDocument)=====================================================
-(void) dumpArray : (NSArray*)a
{
    for (NSNumber *n in a)
    {
        OCRWord *ow = allWords[n.longValue];
        NSLog(@" w[%d] %@",n.intValue,ow.wordtext);
    }
}

//=============(OCRDocument)=====================================================
// Fix OCR errors in numeric strings...
//    $ assumed to mean 5 for instance...
//    assumed to be ONE NUMBER in the string!
-(NSString*) cleanUpNumberString : (NSString *)nstr
{
    NSString *outstr;
    outstr = [nstr stringByReplacingOccurrencesOfString:@"%" withString:@"5"];
    outstr = [outstr stringByReplacingOccurrencesOfString:@" " withString:@""]; //No spaces in number...
    return outstr;
}

//=============(OCRDocument)=====================================================
// Fix OCR errors in name strings...
-(NSString*) cleanUpProductNameString : (NSString *)pstr
{
    NSString *outstr;
    outstr = [pstr stringByReplacingOccurrencesOfString:@"|" withString:@""]; //No vertical bars
    outstr = [outstr stringByReplacingOccurrencesOfString:@"_" withString:@""]; //No underbars!
    return outstr;
}


//=============(OCRDocument)=====================================================
-(void) clear
{
    [allWords removeAllObjects];
}


//=============(OCRDocument)=====================================================
-(void) clearAllColumnStringData
{
    [columnStringData removeAllObjects];
    _longestColumn = 0;
}

//=============(OCRDocument)=====================================================
// Date formatter returns nil date on bogus input...
-(NSDate *) isItADate : (NSString *)tstr
{
    NSString *dformat1 = @"yyyy-MM-dd";
    NSString *dformat2 = @"MM-dd-yy";
    NSString *dformat3 = @"MM/dd/yy";
    NSString *dformat4 = @"dd-MMM-yy";
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    //OK try some different formats...
    [dateFormatter setDateFormat:dformat1];
    NSDate *dtest = [dateFormatter dateFromString:tstr];
    if (dtest != nil) return dtest;
    [dateFormatter setDateFormat:dformat2];
    dtest = [dateFormatter dateFromString:tstr];
    if (dtest != nil) return dtest;
    [dateFormatter setDateFormat:dformat3];
    dtest = [dateFormatter dateFromString:tstr];
    if (dtest != nil) return dtest;
    [dateFormatter setDateFormat:dformat4];
    dtest = [dateFormatter dateFromString:tstr];
    if (dtest != nil) return dtest;
    return nil;
    
} //end isItADate

//=============OCRDocument=====================================================
// Assumes r is in document coords, exhaustive search.
//  are words' origin at top left or bottom left?
-(NSMutableArray *) findAllWordStringsInRect : (CGRect )rr
{
    NSMutableArray *a = [self findAllWordsInRect:rr];
    if (a == nil) return nil;
    NSMutableArray *result = [[NSMutableArray alloc] init];
    //Process, get words...
    for (NSNumber *n in a)
    {
        OCRWord *ow  = [allWords objectAtIndex:n.longValue];
        [result addObject:ow.wordtext];
    }
    return result;
} //end findAllWordStringsInRect

//=============OCRDocument=====================================================
// Assumes r is in document coords, exhaustive search.
//  are words' origin at top left or bottom left?
-(NSMutableArray *) findAllWordsInRect : (CGRect )rr
{
    int xi,yi,x2,y2,index;
    xi = (int)rr.origin.x;  //Get bounding box limits...
    yi = (int)rr.origin.y;
    x2 = xi + (int)rr.size.width;
    y2 = yi + (int)rr.size.height;
    NSMutableArray *aout = [[NSMutableArray alloc] init]; //Results go here
    index = 0;
    for (OCRWord *ow  in allWords)
    {
        int x = (int)ow.left.intValue; //Get top left corner?
        int y = (int)ow.top.intValue;
        if (x >= xi && x <= x2 && y >= yi && y <= y2) //Hit!
        {
            NSNumber *n = [NSNumber numberWithInt:index];
            // There is a list of words to ignore in ignore boxes...
            if (!useIgnoreList || ([ignoreList indexOfObject:n] == NSNotFound))
            {
                [aout addObject:n]; // OK? add to result
            }
        }
        index++;
    } //end for ow
    return aout;
} //end findAllWordsInRect


//=============(OCRTemplate)=====================================================
-(void) addIgnoreBoxItems  : (CGRect )rr
{
    useIgnoreList = FALSE;
  //  rr.origin.x +=_docRect.origin.x;
  //  rr.origin.y +=_docRect.origin.y;
    NSMutableArray *ir = [self findAllWordsInRect:rr];
    [ignoreList addObjectsFromArray:ir];
    useIgnoreList = TRUE;
} //end addIgnoreBoxItems

//=============(OCRTemplate)=====================================================
// Look at some random words, get average height thereof
-(void) getAverageGlyphHeight
{
    int maxlim = (int)allWords.count - 1;
    int count = 8;
    int sum = 0;
    for (int i=0;i<count;i++) //let's hope we have 8 words here!
    {
        int testIndex = (int)(drand(1.0,(double)maxlim));
        OCRWord *ow = [allWords objectAtIndex:testIndex];
        sum += ow.height.intValue;
    }
    glyphHeight = sum / count;
} //end getAverageGlyphHeight


//=============(OCRTemplate)=====================================================
// Uses rr to get column L/R boundary, uses rowY's to get top area to look at...
-(NSArray*)  getHeaderNames
{
    return headerNames;
} //end getHeaderNames


//=============(OCRTemplate)=====================================================
// Array of words is coming in from a box, take all words and make a sentence...
//  Numeric means don't padd with spaces...
-(NSString *) assembleWordFromArray : (NSMutableArray *) a : (BOOL) numeric
{
    NSMutableArray *wordPairs = [[NSMutableArray alloc] init];
    for (NSNumber *n in a)
    {
        OCRWord *ow = [allWords objectAtIndex:n.longValue];
        int y = ow.top.intValue;
        y = glyphHeight * (y / glyphHeight); //Get nearest row Y only
        int abspos = _width * y + ow.left.intValue; //Abs pixel position in document
        //add dict of string / y pairs
        [wordPairs addObject:@{@"Word": ow.wordtext,@"XY":[NSNumber numberWithInt:abspos]}];
    }
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"XY" ascending:YES];
    [wordPairs sortUsingDescriptors:@[descriptor]];
    //All sorted! Now pluck'em out!
    NSString *s = @"";
    for (NSDictionary *d in wordPairs)
    {
        s = [s stringByAppendingString:[d objectForKey:@"Word"]];
        if (!numeric) s = [s stringByAppendingString:@" "];
    }
    return s;
} //end assembleWordFromArray


//=============(OCRTemplate)=====================================================
// Uses rr to get column L/R boundary, uses rowY's to get top area to look at...
-(NSMutableArray*)  getColumnStrings: (CGRect)rr : (NSMutableArray*)rowYs
{
    //NSLog(@" ColRect %d,%d : %d,%d",(int)rr.origin.x,(int)rr.origin.y,(int)rr.size.width,(int)rr.size.height);
    NSMutableArray *a = [self findAllWordsInRect:rr];
    NSMutableArray *resultStrings = [[NSMutableArray alloc] init];
    int yc = (int)rowYs.count;
    for (int i=0;i<yc;i++)
    {
        NSNumber *ny = rowYs[i];
        int thisY = ny.intValue - glyphHeight/2; //Fudge by half glyph height
        int nextY = rr.origin.y + rr.size.height;
        if (i < yc-1)
        {
            NSNumber *nyy = rowYs[i+1];
            nextY = nyy.intValue - 1;
        }
        NSLog(@" yc %d topy %d boty %d",i,thisY,nextY);
        //Assemble a string now from this column item, may be multiline
        NSString *s = @"";
        NSMutableArray *stuffToCombine = [[NSMutableArray alloc] init];
        for ( NSNumber *n in a)
        {
            OCRWord *ow = [allWords objectAtIndex:n.longValue];
            int owy = ow.top.intValue;
            if (owy >= thisY && owy < nextY) //Word within row bounds?
            {
                [stuffToCombine addObject:n];
            }
        }
        NSLog(@" %d items in box",(int)stuffToCombine.count);
        //OK we have all the stuff to put together...
        if (stuffToCombine.count == 1)
        {
            NSNumber *n = [stuffToCombine objectAtIndex:0];
            OCRWord *ow = [allWords objectAtIndex:n.longValue];
            s = ow.wordtext;
        }
        else if (stuffToCombine.count > 1)
        {
            NSNumber *n = [stuffToCombine objectAtIndex:0];
            OCRWord *ow = [allWords objectAtIndex:n.longValue];
            s = ow.wordtext;
            //Check to see if we are dealing with words or split numbers
            s = [s stringByReplacingOccurrencesOfString:@"." withString:@""];
            BOOL numeric = [self isStringAnInteger:s]; //Split numbers
            NSLog(@" numeric %d",numeric);
            s = [self assembleWordFromArray : stuffToCombine : numeric];
            if (numeric) //Fix common OCR errs
            {
                s = [s stringByReplacingOccurrencesOfString:@"B" withString:@"8"];
                s = [s stringByReplacingOccurrencesOfString:@"," withString:@""];
            }
        }
        [resultStrings addObject:s];
    }
    return resultStrings;
} //end getColumnStrings


//=============(OCRTemplate)=====================================================
-(NSMutableArray *) getColumnYPositionsInRect : (CGRect )rr : (BOOL) numeric
{
    //Get all content within this rect, assume one item per line!
    NSMutableArray *a = [self findAllWordsInRect:rr];
    [self dumpArray:a];
    //NSLog(@" gcYPs %d,%d : %d,%d",(int)rr.origin.x,(int)rr.origin.y,(int)rr.size.width,(int)rr.size.height);
    NSMutableArray *colPairs = [[NSMutableArray alloc] init];
    int oldy = -99999;
    //Get each item in our column box...
    for (NSNumber* n  in a)
    {
        OCRWord *ow = [allWords objectAtIndex:n.longValue];
        int ty = ow.top.intValue;
        if (abs(ty - oldy) > glyphHeight) //Check Y for new row? (rows may be out of order)
        {
            oldy = ty;
            NSString *s = ow.wordtext;
            [colPairs addObject:@{@"Field": s,@"Y":ow.top}]; //add dict of string / y pairs
        }
    }
    //Perform sort of dictionary based on the Y coordinate ...
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"Y" ascending:YES];
    [colPairs sortUsingDescriptors:@[descriptor]];
    NSMutableArray *yP = [[NSMutableArray alloc] init];
    for (NSDictionary *d in colPairs) [yP addObject:[d objectForKey:@"Y"]];
    return yP;
    
} //end getColumnYPositionsInRect

//=============(OCRTemplate)=====================================================
// Assumes 2D column array fully populated....
-(NSMutableArray *) getRowFromColumnStringData : (int)index
{
    int nc = (int)columnStringData.count; //Number of columns
    NSMutableArray *a = [[NSMutableArray alloc] init];
    for (int i=0;i<nc;i++)
    {
        NSArray*ac     = [columnStringData objectAtIndex:i]; //Column of strings...
        NSString *item = [ac objectAtIndex:index]; //Get row... (may be blank string)
        [a addObject:item];
    }
    return a;
} //end getRowFromColumnStringData

//=============(OCRTemplate)=====================================================
// Gets absolute limit for all text found on document, stores in CGRect
-(CGRect) getDocRect
{
    int minx,miny,maxx,maxy;
    minx = miny = 99999;
    maxx = maxy = -99999;
    for (OCRWord *ow  in allWords)
    {
        int x1 = (int)ow.left.intValue;
        int y1 = (int)ow.top.intValue;
        int x2 = x1 + (int)ow.width.intValue;
        int y2 = y1 + (int)ow.height.intValue;
        if (x1 < minx) minx = x1;
        if (y1 < miny) miny = y1;
        if (x2 > maxx) maxx = x2;
        if (y2 > maxy) maxy = y2;
    } //end for loop
    _docRect = CGRectMake(minx, miny, maxx-minx, maxy-miny);
    //NSLog(@" doc lims (%d,%d) to (%d,%d)",minx, miny, maxx , maxy );
    return _docRect;
} //end getDocRect

//=============(OCRTemplate)=====================================================
-(CGRect) getWordRectByIndex : (int) index
{
    if (index < 0 || index >= allWords.count) return CGRectMake(0,0, 0, 0);
    OCRWord *ow = [allWords objectAtIndex:index];
    return CGRectMake(ow.left.intValue,  ow.top.intValue,
                      ow.width.intValue, ow.height.intValue);
}

//=============(OCRTemplate)=====================================================
-(CGRect) getBLRect
{
    int minx,maxy,index,foundit;
    minx = 99999;
    maxy = -99999;
    index   = 0;
    foundit = -1;
    for (OCRWord *ow  in allWords)
    {
        int x1 = (int)ow.left.intValue;
        int y1 = (int)ow.top.intValue + (int)ow.height.intValue;
        if (x1 < minx && y1 > maxy) {
            minx = x1;
            maxy = y1;
            foundit = index;
        }
        index++;
    }
    return  [self getWordRectByIndex:foundit];
} //end getBLRect

//=============(OCRTemplate)=====================================================
-(CGRect) getBRRect
{
    int maxx,maxy,index,foundit;
    maxx = -99999;
    maxy = -99999;
    index   = 0;
    foundit = -1;
    for (OCRWord *ow  in allWords)
    {
        int x1 = (int)ow.left.intValue + (int)ow.width.intValue;
        int y1 = (int)ow.top.intValue  + (int)ow.height.intValue;
        if (x1 > maxx && y1 > maxy) {
            maxx = x1;
            maxy = y1;
            foundit = index;
        }
        index++;
    }
    return  [self getWordRectByIndex:foundit];
} //end getBRRect


//=============(OCRTemplate)=====================================================
-(CGRect) getTLRect
{
    int minx,miny,index,foundit;
    minx = miny = 99999;
    index   = 0;
    foundit = -1;
    for (OCRWord *ow  in allWords)
    {
        int x1 = (int)ow.left.intValue;
        int y1 = (int)ow.top.intValue;
        // Look for farthest left near the top
        if (x1 < minx && y1 < _height/10) {
            minx = x1;
            miny = y1;
            foundit = index;
        }
        index++;
    }
    return  [self getWordRectByIndex:foundit];
} //end getTLRect

//=============(OCRTemplate)=====================================================
-(CGRect) getTRRect
{
    int maxx,miny,index,foundit;
    maxx = -99999;
    miny = 99999;
    index   = 0;
    foundit = -1;
    for (OCRWord *ow  in allWords)
    {
        int x1 = (int)ow.left.intValue + (int)ow.width.intValue;
        int y1 = (int)ow.top.intValue;
        //NSLog(@" word [%@] xy %d %d",ow.wordtext,x1,y1);
        //Look for farthest right near the top!
        if (x1 > maxx && y1 < _height/10) {
            //NSLog(@" bing: Top Right");
            maxx = x1;
            miny = y1;
            foundit = index;
        }
        index++;
    }
    return  [self getWordRectByIndex:foundit];
} //end getTRRect

//=============(OCRTemplate)=====================================================
-(BOOL) isStringAnInteger : (NSString *)s
{
    NSCharacterSet *alphaNums = [NSCharacterSet decimalDigitCharacterSet];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:s];
    return [alphaNums isSupersetOfSet:inStringSet];
} //end isStringAnInteger

//=============(OCRTemplate)=====================================================
-(BOOL) isStringAPrice : (NSString *)s
{
    NSCharacterSet *alphaNums = [NSCharacterSet characterSetWithCharactersInString:@"0123456789."];
    NSCharacterSet *inStringSet = [NSCharacterSet characterSetWithCharactersInString:s];
    return [alphaNums isSupersetOfSet:inStringSet];
} //end isStringAnInteger

//=============(OCRTemplate)=====================================================
-(NSString*)getNthWord : (NSNumber*)n
{
    OCRWord *ow = [allWords objectAtIndex:n.longValue];
    return ow.wordtext;
}

//=============(OCRTemplate)=====================================================
-(NSNumber*)getNthXCoord : (NSNumber*)n
{
    OCRWord *ow = [allWords objectAtIndex:n.longValue];
    return ow.left;
}

//=============(OCRTemplate)=====================================================
-(NSNumber*)getNthXWidth : (NSNumber*)n
{
    OCRWord *ow = [allWords objectAtIndex:n.longValue];
    return ow.width;
}

//=============(OCRTemplate)=====================================================
-(NSNumber*)getNthYCoord : (NSNumber*)n
{
    OCRWord *ow = [allWords objectAtIndex:n.longValue];
    return ow.top;
}

//=============(OCRTemplate)=====================================================
-(NSString*)getStringStartingAtXY : (NSNumber*)n : (NSNumber*)minx : (NSNumber*)miny
{
    int lastx   = minx.intValue;
    int acrossx = lastx;
    NSString *s = @"";
    int index   = n.intValue;
    int wcount  = 0;
    BOOL done   = FALSE;
    while (!done) //spread of 40 = too much space between words, end of phrase?
    {
        OCRWord *ow = [allWords objectAtIndex:index];
        acrossx = ow.left.intValue;
        if ((acrossx - lastx < 40) &&  (acrossx >= lastx) && wcount < 8) //max 8 words increasing across X...
        {
            s = [s stringByAppendingString:[NSString stringWithFormat:@" %@",ow.wordtext]];
            lastx+= ow.width.intValue;
            index++;
            wcount++;
        }
        else done=TRUE;
    }
    return s;
} //end getStringStartingAtXY


//=============(OCRTemplate)=====================================================
// Given array of field numbers, looks for date-like strings...
-(NSDate *) findDateInArrayOfFields : (NSArray*)aof
{    
    for (NSNumber* n in aof)
    {
        NSString *testText = [self getNthWord:n];
        if ([testText containsString:@"/"]) //Is this good enough?
        {
            return [self parseDateFromString:testText];
        }
    }
    return nil;
} //end findDateInArrayOfFields


//=============(OCRTemplate)=====================================================
// Given array of field numbers, finds first string which is a legit integer...
-(int) findIntInArrayOfFields : (NSArray*)aof
{
    int foundInt = 0;
    for (NSNumber* n in aof)
    {
        NSString *testText = [self getNthWord:n];
        testText = [testText stringByReplacingOccurrencesOfString:@"\"" withString:@""]; //No quotes please
        if ([self isStringAnInteger:testText] )
            foundInt = [testText intValue];
    }
    return foundInt;
} //end findIntInArrayOfFields

//=============(OCRTemplate)=====================================================
// Given array of field numbers, finds first string which is a legit integer...
-(float) findPriceInArrayOfFields : (NSArray*)aof
{
    float foundFloat = 0.0f;
    for (NSNumber* n in aof)
    {
        NSString *testText = [self getNthWord:n];
        testText = [testText stringByReplacingOccurrencesOfString:@"$" withString:@""]; //No dollars please
        testText = [testText stringByReplacingOccurrencesOfString:@"\"" withString:@""]; //No quotes please
        if ([self isStringAPrice:testText] )
            foundFloat = testText.floatValue;
    }
    return foundFloat;
} //end findIntInArrayOfFields


//=============(OCRTemplate)=====================================================
-(NSString *) findTopStringInArrayOfFields : (NSArray*)aof
{
    //First make sure we get top field...
    NSNumber* topn;
    int minx = 999999;
    int miny = 999999;
    for (NSNumber* n in aof)
    {
        int xoff = [self getNthXCoord:n].intValue; // Get word's XY coord
        int yoff = [self getNthYCoord:n].intValue;
        if (yoff < miny && xoff < minx) //Is it top left item?
        {
            minx = xoff; //Store xy position and index
            miny = yoff;
            topn = n;
        }
    } //end for n
    return [self getStringStartingAtXY : topn :
            [NSNumber numberWithInt:minx] : [NSNumber numberWithInt:miny]];
} //end findTopStringInArrayOfFields


//=============(OCRTemplate)=====================================================
// From stackoverflow...
-(NSDate*) parseDateFromString : (NSString*) s
{
    NSError *error = NULL;
    NSDataDetector *detector = [NSDataDetector dataDetectorWithTypes:(NSTextCheckingTypes)NSTextCheckingTypeDate error:&error];
    
    NSArray *matches = [detector matchesInString:s
                                         options:0
                                           range:NSMakeRange(0, [s length])];
    
    for (NSTextCheckingResult *match in matches) {
        if ([match resultType] == NSTextCheckingTypeDate) {
            NSDate *date = [match date];
            return date;
        }}
    return nil;
} //end parseDateFromString

//=============(OCRTemplate)=====================================================
// Sets up internal header column names based on passed array of words forming header
-(void)  parseHeaderColumns  : (NSArray*)aof
{
    BOOL firstField = TRUE;
    int acrossX,lastX,xwid;
    int hcount = 0;
    NSString *hstr = @"";
    acrossX = lastX = 0;
    NSMutableArray *headerPairs = [NSMutableArray array];
    while (hcount < aof.count)
    {
        NSNumber* n = [aof objectAtIndex:hcount];
        int index = n.intValue;
        NSString * wstr = [self getNthWord:[NSNumber numberWithInt:index]];
        NSNumber *xc = [self getNthXCoord:[NSNumber numberWithInt:index]];
        NSNumber *xw = [self getNthXWidth:[NSNumber numberWithInt:index]];
        acrossX = xc.intValue;
        xwid    = xw.intValue;
        //NSLog(@" %@ hc %d ac %d xw %d",wstr,hcount,acrossX,xwid);
        if (firstField)
        {
            firstField = FALSE;
            hstr = wstr;
        }
        else if (acrossX - lastX < 40 && (acrossX > lastX)) //Another word nearby? append!
        {
            hstr = [hstr stringByAppendingString:[NSString stringWithFormat:@" %@",wstr]];
        }
        else //Big skip between words? Add header column
        {
            //NSLog(@" add %@",hstr);
            hstr = [hstr stringByReplacingOccurrencesOfString:@"\"" withString:@""]; //No quotes please
            NSDictionary *dict = @{@"Field": hstr,@"X":[NSNumber numberWithInt:lastX]};
            [headerPairs addObject:dict];
//            [headerNames addObject:hstr];
            if (hcount == (int)aof.count-1) //Last column? add one more (we are always one behind)
            {
                wstr = [wstr stringByReplacingOccurrencesOfString:@"\"" withString:@""]; //No quotes please
                NSDictionary *dict = @{@"Field": wstr,@"X":[NSNumber numberWithInt:(lastX+xwid)]};
                [headerPairs addObject:dict];
//                [headerNames addObject:wstr];
            }
            hstr = wstr;
        }
        lastX   = acrossX + xwid;
        hcount++;
    }
    //Perform sort of dictionary based on the X item... (make sure headers are in correct order)
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"X" ascending:YES];
    [headerPairs sortUsingDescriptors:@[descriptor]];
    [headerNames removeAllObjects];
    for (NSDictionary *d in headerPairs)
    {
        [headerNames addObject:[d objectForKey:@"Field"]];
    }
} //end parseHeaderColumns



//=============OCRDocument=====================================================
-(void) parseJSONfromDict : (NSDictionary *)d
{
    [self clear];
    rawJSONDict          = d;
    NSDictionary *pr     = [d valueForKey:@"ParsedResults"];
    //NSNumber* exitCode   = [d valueForKey:@"OCRExitCode"];

    parsedText           = [pr valueForKey:@"ParsedText"]; //Everything lumped together...
    NSDictionary *to     = [pr valueForKey:@"TextOverlay"];
    NSArray *lines       = [[to valueForKey:@"Lines"]objectAtIndex:0]; //array of "Words"
    for (NSDictionary *d in lines)
    {
        //  NSLog(@"duhh: %@",d);
        NSArray *words = [d valueForKey:@"Words"];
        for (NSDictionary *w in words) //loop over each word
        {
            OCRWord *ow = [[OCRWord alloc] init];
            [ow packFromDictionary:w];
            //[ow dump];
            [allWords addObject:ow];
        }
    }
    [self getAverageGlyphHeight];
    [self assembleGroups];
    //NSLog(@" overall image wh %d,%d",_width,_height);
} //end parseJSONfromDict

//=============OCR VC=====================================================
-(void) setupDocument : (NSString*) ifname : (NSDictionary *)d : (BOOL) flipped90
{
    _scannedImage = [UIImage imageNamed:ifname];
    _scannedName  = ifname;
    if (!flipped90)
    {
        _width        = _scannedImage.size.width;
        _height       = _scannedImage.size.height;
    }
    else
    {
        _height      = _scannedImage.size.width;
        _width       = _scannedImage.size.height;
    }

    [self parseJSONfromDict:d];
}

//=============(OCRTemplate)=====================================================
-(void) computeScaling:(CGRect )tlr : (CGRect )trr
{
    [self setScalingRects];
    tlOriginalRect = tlr;
    trOriginalRect = trr;
    
    double hsizeOrig   = (double)(trOriginalRect.origin.x + trOriginalRect.size.width) -
                         (double)(tlOriginalRect.origin.x);
    double hsizeScaled = (double)(trScalingRect.origin.x + trScalingRect.size.width) -
                         (double)(tlScalingRect.origin.x);
    if (hsizeOrig == 0) //error!
    {
        hScale = vScale = 1.0;
    }
    else
    {
        hScale = vScale = hsizeScaled / hsizeOrig;
    }
    NSLog(@" sizeorig %f scaled %f  hvScale %f",hsizeOrig,hsizeScaled,hScale);
    
}


//=============(OCRTemplate)=====================================================
-(void) setScalingRects
{
    tlScalingRect = [self getTLRect];
    trScalingRect = [self getTRRect];
}





/*-----------------------------------------------------------*/
/*-----------------------------------------------------------*/
double drand(double lo_range,double hi_range )
{
    int rand_int;
    double tempd,outd;
    
    rand_int = rand();
    tempd = (double)rand_int/(double)RAND_MAX;  /* 0.0 <--> 1.0*/
    
    outd = (double)(lo_range + (hi_range-lo_range)*tempd);
    return(outd);
}   //end drand



@end
