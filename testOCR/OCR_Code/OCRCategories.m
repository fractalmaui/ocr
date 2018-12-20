//
//  OCRCategories.m
//  testOCR
//
//  Created by Dave Scruton on 12/19/18.
//  Copyright © 2018 huedoku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OCRCategories.h"
@implementation OCRCategories


static OCRCategories *sharedInstance = nil;


//=============(OCRCategories)=====================================================
// Get the shared instance and create it if necessary.
+ (OCRCategories *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}



//=============(OCRCategories)=====================================================
-(instancetype) init
{
    if (self = [super init])
    {
        catCSV = [[NSMutableArray alloc] init]; //CSV data as read in from csv.txt
        _catProducts = [[NSMutableArray alloc] init]; //CSV data as read in from csv.txt
        [self loadCategoriesFile];
//        tableName = @"";
//        _versionNumber    = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    }
    return self;
}

//=============(OCRCategories)=====================================================
-(void) loadCategoriesFile
{
    NSError *error;
    NSArray *sItems;
    NSString *fileContentsAscii;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"cat" ofType:@"txt" inDirectory:@"txt"];
    NSURL *url = [NSURL fileURLWithPath:path];
    fileContentsAscii = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:&error];
    if (error != nil)
    {
        NSLog(@" error reading categories init file");
        return;
    }
    sItems    = [fileContentsAscii componentsSeparatedByString:@"\n"];
    [catCSV removeAllObjects];
//    NSLog(@" sitems %@",sItems);
    
    BOOL firstRecord = TRUE;
    for (NSString*s in sItems)
    {
        NSArray* lineItems    = [s componentsSeparatedByString:@","];
        if (lineItems.count >= 4)
        {
            if (!firstRecord)
            {
                CatObject *c = [[CatObject alloc] initWithCategory:
                                lineItems[0] : lineItems[1] :
                                lineItems[2] : lineItems[3] ];
                [catCSV addObject : c]; //Add 2nd... records (1st is metadata)
                NSString *ps = lineItems[1];
                [_catProducts addObject:ps.lowercaseString]; //separate list of products for matching
            }
            firstRecord = FALSE;
        }
    }
    
    return;
} //end loadCategoriesFile


//=============(OCRCategories)=====================================================
-(NSMutableArray *)matchCategory : (NSString *)product
{
    NSMutableArray *result = [[NSMutableArray alloc] init];
    int i = 0;
    for (NSString *s in _catProducts)
    {
       
        if ([product containsString:s]) //Try raw match...
        {
            CatObject *co = [catCSV objectAtIndex:i];
            [result addObject:co.category];
            [result addObject:co.item];
            [result addObject:co.processed];
            [result addObject:co.local];
        }
        i++;
    }
    return result;
} //end matchCategory


//=============(OCRCategories)=====================================================



@end

