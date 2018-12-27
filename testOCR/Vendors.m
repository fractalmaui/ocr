//
//  __     __             _
//  \ \   / /__ _ __   __| | ___  _ __ ___
//   \ \ / / _ \ '_ \ / _` |/ _ \| '__/ __|
//    \ V /  __/ | | | (_| | (_) | |  \__ \
//     \_/ \___|_| |_|\__,_|\___/|_|  |___/
//
//  Vendors.m
//  
//
//  Created by Dave Scruton on 12/21/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import "Vendors.h"

@implementation Vendors
static Vendors *sharedInstance = nil;


//=============(Vendors)=====================================================
// Get the shared instance and create it if necessary.
+ (Vendors *)sharedInstance {
    if (sharedInstance == nil) {
        sharedInstance = [[super allocWithZone:NULL] init];
    }
    
    return sharedInstance;
}

//=============(Vendors)=====================================================
-(instancetype) init
{
    if (self = [super init])
    {
        _vNames       = [[NSMutableArray alloc] init]; // Vendor names
        _vFolderNames = [[NSMutableArray alloc] init]; //  and matching folder names
        [self readFromParse];
    }
    return self;
}

//=============(Vendors)=====================================================
-(NSString *) getFolderName : (NSString *)vmatch
{
    NSInteger n = [_vNames indexOfObject:vmatch];
    if (n != NSNotFound) return [_vFolderNames objectAtIndex:n];
    return @"";
}

//=============(Vendors)=====================================================
-(void) readFromParse
{
    PFQuery *query = [PFQuery queryWithClassName:@"Vendors"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) { //Query came back...
            [self->_vNames       removeAllObjects];
            [self->_vFolderNames removeAllObjects];
            for( PFObject *pfo in objects)  //Save all our vendor names...
            {
                NSString *s = [pfo objectForKey:PInv_Vendor_key];
                [self->_vNames addObject:s];
                //Generate a legal filename, too, no whitespace, dots, apostrophes or commas...
                NSString *sf = [s  stringByReplacingOccurrencesOfString:@" " withString:@"_"];
                sf = [sf stringByReplacingOccurrencesOfString:@"." withString:@"_"];
                sf = [sf stringByReplacingOccurrencesOfString:@"," withString:@"_"];
                sf = [sf stringByReplacingOccurrencesOfString:@"\'" withString:@"_"];
                [self->_vFolderNames addObject:sf];

            }
            //NSLog(@" ...read all vendors");
            [self.delegate didReadVendorsFromParse];
        }
    }];
} //end readFromParse

//=============(Vendors)=====================================================
// Return index if matching, -1 for no match
-(int) stringHasVendorName : (NSString *)s
{
    int i = 0;
    for (NSString *ts in _vNames)
    {
        if ([s.lowercaseString containsString:ts.lowercaseString]) return i;
        i++;
    }
    return -1;
} //end stringHasVendorName

@end
