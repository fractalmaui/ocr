//
//  OCRTemplate.m
//  testOCR
//
//  Created by Dave Scruton on 12/5/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import "OCRTemplate.h"

@implementation OCRTemplate

//=============(OCRTemplate)=====================================================
-(instancetype) init
{
    if (self = [super init])
    {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        //2) Create the full file path by appending the desired file name
        fileLocation  = [documentsDirectory stringByAppendingPathComponent:@"templates.dat"];
        ocrBoxes      = [[NSMutableArray alloc] init];
        [self loadTemplatesFromDisk];
        //[self dump];
    }
    return self;
}

//=============(OCRTemplate)=====================================================
-(void) clearFields
{
    NSLog(@" clear document template...");
    [ocrBoxes removeAllObjects];
    [self saveTemplatesToDisk];
}

//=============(OCRTemplate)=====================================================
-(void) clearHeaders
{
    for (int i=0;i<32;i++) headerColumns[i] = CGRectMake(0, 0, 0, 0);
    headerColumnCount = 0;
}

//=============(OCRTemplate)=====================================================
-(void) addBox : (CGRect) frame : (NSString *)fname : (NSString *)format
{
    NSLog(@" clear document template...");
    OCRBox *ob = [[OCRBox alloc] init];
    if (frame.origin.x < 0) frame.origin.x = 0; //Don't allow off-document frmaes!
    if (frame.origin.y < 0) frame.origin.y = 0;
    ob.frame = frame;
    ob.fieldName = fname;
    ob.fieldFormat = format;
    [ocrBoxes addObject:ob];
}

//=============(OCRTemplate)=====================================================
-(void) addHeaderColumnToSortedArray : (int) index
{
    //NSLog(@" addhc %d ",index);
    OCRBox *ob = ocrBoxes[index];
    int xleft =  ob.frame.origin.x;
    int whereToAdd = headerColumnCount;
    for (int i=0;i<headerColumnCount;i++)
    {
        CGRect rr = headerColumns[i];
        if (xleft < rr.origin.x)  //Found a header to left of this one? insert...
        {
            for (int j=i+1;j<headerColumnCount+1;j++)
            {
                headerColumns[j] = headerColumns[j-1];
            }
            whereToAdd = i;
            break;
        }
    }
    headerColumns[whereToAdd] = ob.frame; //OK add it
    headerColumnCount++;
} //end addHeaderColumnToSortedArray


//=============(OCRTemplate)=====================================================
-(void) dump
{
    NSLog(@"Dump Template...");
    int i = 0;
    for (OCRBox *ob in ocrBoxes)
    {
        NSLog(@"t[%d]",i);
        i++;
        [ob dump];
    }
} //end dump

//=============(OCRTemplate)=====================================================
// assumes string is OK!
-(void) unpackFromString : (NSString *)s
{
    [ocrBoxes removeAllObjects];
    NSArray *sitems =  [s componentsSeparatedByString:@";"];
    for (NSString *substr in sitems)
    {
        NSArray *titems =  [substr componentsSeparatedByString:@","];
        if (titems.count == 6) //Legal only please...
        {
            OCRBox *ob = [[OCRBox alloc] init];
            int ptr = 0;
            ob.fieldName   = titems[ptr++];
            ob.fieldFormat = titems[ptr++];
            int xi,yi,xs,ys;
            NSString *ss = titems[ptr++];
            xi = [ss intValue];
            if (xi < 0) xi = 0; //Err check: should never occor
            ss = titems[ptr++];
            yi = [ss intValue];
            if (yi < 0) yi = 0; //Err check: should never occor
            ss = titems[ptr++];
            xs = [ss intValue];
            ss = titems[ptr++];
            ys = [ss intValue];
            ob.frame = CGRectMake(xi, yi, xs, ys);
            //NSLog(@" ..add box %d,%d",xi,yi);
            if (![self isDupeFrame:ob.frame]) [ocrBoxes addObject:ob];
        }
    }
    //NSLog(@" unpacked %d items",(int)ocrBoxes.count);
} //end unpackFromString

//=============(OCRTemplate)=====================================================
-(BOOL) isDupeFrame : (CGRect)rrtest
{
    BOOL dupe = FALSE;
    for (OCRBox *ob in ocrBoxes)
    {
        CGRect rr = ob.frame;
        if (
            rr.origin.x    == rrtest.origin.x    &&
            rr.origin.y    == rrtest.origin.y    &&
            rr.size.width  == rrtest.size.width  &&
            rr.size.height == rrtest.size.height
            )
            return TRUE;
    }
    return dupe;
}

//=============(OCRTemplate)=====================================================
-(NSString *)packToString
{
    NSString *s = @"";
    for (OCRBox *ob in ocrBoxes)
    {
        s = [s stringByAppendingString:[NSString stringWithFormat:@"%@,",ob.fieldName]];
        s = [s stringByAppendingString:[NSString stringWithFormat:@"%@,",ob.fieldFormat]];
        CGRect r = ob.frame;
        s = [s stringByAppendingString:[NSString stringWithFormat:@"%d,%d,%d,%d;",
                                        (int)r.origin.x,(int)r.origin.y,(int)r.size.width,(int)r.size.height]];
    }
    return s;
} //end packToString



//=============(OCRTemplate)=====================================================
-(int) getBoxCount
{
    return (int)ocrBoxes.count;
}

//=============(OCRTemplate)=====================================================
-(CGRect) getBoxRect :(int) index
{
    if (index < 0 || index >= ocrBoxes.count) return CGRectMake(0, 0, 0, 0);
    OCRBox *ob = ocrBoxes[index];
    return ob.frame;
}

//=============(OCRTemplate)=====================================================
-(NSString*) getBoxFieldName :(int) index
{
    if (index < 0 || index >= ocrBoxes.count) return @"";
    OCRBox *ob = ocrBoxes[index];
    return ob.fieldName;
}

//=============(OCRTemplate)=====================================================
-(NSString*) getBoxFieldFormat :(int) index
{
    if (index < 0 || index >= ocrBoxes.count) return @"";
    OCRBox *ob = ocrBoxes[index];
    return ob.fieldFormat;
}


//=============(OCRTemplate)=====================================================
-(int) getColumnCount
{
    return headerColumnCount;
}

//=============(OCRTemplate)=====================================================
-(CGRect) getColumnByIndex : (int) index
{
    if (index < 0 || index >= headerColumnCount) return CGRectMake(0, 0, 0, 0  );
    return headerColumns[index];
}

//=============(OCRTemplate)=====================================================
-(BOOL) gotFieldAlready : (NSString*)fname
{
    for (OCRBox *ob in ocrBoxes)
    {
        if ([fname isEqualToString:ob.fieldName]) return TRUE; //Got a match already?
    }
    return FALSE;
}


//=============(OCRTemplate)=====================================================
-(void) loadTemplatesFromDisk
{
    //Load the array if anything exists...
    NSError *err;
    fileWorkString = [[NSString alloc] initWithContentsOfFile:fileLocation encoding:NSUTF8StringEncoding error:&err];
    if (fileWorkString != nil)
        [self unpackFromString:fileWorkString];
    else{
        NSLog(@" ...no template found ");
    }
}  //end loadTemplatesFromDisk


//=============(OCRTemplate)=====================================================
-(void) saveTemplatesToDisk
{
    NSError *err;
    fileWorkString = [self packToString];
    [fileWorkString writeToFile:fileLocation atomically:YES encoding:NSUTF8StringEncoding error:&err];
    
     
    // writeToFile:fileLocation atomically:YES];
    NSLog(@" ...saved templates to %@ [%@]",fileLocation,fileWorkString);
}
@end
