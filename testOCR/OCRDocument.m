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
-(void) clearAllColumnStringData
{
    [columnStringData removeAllObjects];
    _longestColumn = 0;
}


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
    rr.origin.x +=_docRect.origin.x;
    rr.origin.y +=_docRect.origin.y;
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
// Uses rr to get column L/R boundary, uses rowY's to get top area to look at...
-(NSMutableArray*)  getColumnStrings: (CGRect)rr : (NSMutableArray*)rowYs
{
    rr.origin.x += _docRect.origin.x; //Don't forget document top left offset!
    rr.origin.y += (_docRect.origin.y);
    
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
        //NSLog(@" yc %d topy %d boty %d",i,thisY,nextY);
        //Assemble a string now from this column item, may be multiline
        NSString *s = @"";
        for ( NSNumber *n in a)
        {
            OCRWord *ow = [allWords objectAtIndex:n.longValue];
            int owy = ow.top.intValue;
            if (owy >= thisY && owy < nextY) //Word within row bounds?
            {
                s = [s stringByAppendingString:[NSString stringWithFormat:@"%@ ",ow.wordtext]];
            }
        }
        //NSLog(@"  ...nextColumnWord: %@  ", s);
        [resultStrings addObject:s];
    }
    return resultStrings;
} //end getColumnStrings

//=============(OCRTemplate)=====================================================
-(NSMutableArray *) getColumnYPositionsInRect : (CGRect )rr
{
    NSMutableArray *yP = [[NSMutableArray alloc] init];
    //Get all content within this rect, assume one item per line!
    rr.origin.x += _docRect.origin.x; //Don't forget document top left offset!
    rr.origin.y += _docRect.origin.y;
    NSMutableArray *a = [self findAllWordsInRect:rr];
    //NSLog(@" gcYPs %d,%d : %d,%d",(int)rr.origin.x,(int)rr.origin.y,(int)rr.size.width,(int)rr.size.height);
    
    for (NSNumber* n  in a)
    {
        OCRWord *ow = [allWords objectAtIndex:n.longValue];
        //NSLog(@" ow is %@ , add yp %d",ow.wordtext,ow.top.intValue);
        [yP addObject:ow.top];
    }
    return yP;
    
}

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
    [headerNames removeAllObjects];
    BOOL firstField = TRUE;
    int acrossX,lastX,xwid;
    int hcount = 0;
    NSString *hstr = @"";
    acrossX = lastX = 0;
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
        else if (acrossX - lastX < 40) //Another word nearby? append!
        {
            hstr = [hstr stringByAppendingString:[NSString stringWithFormat:@" %@",wstr]];
        }
        else //Big skip between words? Add header column
        {
            //NSLog(@" add %@",hstr);
            [headerNames addObject:hstr];
            if (hcount == (int)aof.count-1) //Last column? add one more (we are always one behind)
                [headerNames addObject:wstr];
            hstr = wstr;
        }
        lastX   = acrossX + xwid;
        hcount++;
    }
    //NSLog(@" Column Headers: %@",headerNames);
} //end parseHeaderColumns



//=============OCRDocument=====================================================
-(void) parseJSONfromDict : (NSDictionary *)d
{
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
    //NSLog(@" overall image wh %d,%d",_width,_height);
} //end parseJSONfromDict

//=============OCR VC=====================================================
-(void) setupDocument : (NSString*) ifname : (NSDictionary *)d
{
    _scannedImage = [UIImage imageNamed:ifname];
    _scannedName  = ifname;
    _width        = _scannedImage.size.width;
    _height       = _scannedImage.size.height;
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
