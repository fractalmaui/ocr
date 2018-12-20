//
//  CatObject.m
//  testOCR
//
//  Created by Dave Scruton on 12/19/18.
//  Copyright © 2018 huedoku. All rights reserved.
//

#import "CatObject.h"

@implementation CatObject

- (id) initWithCategory : (NSString*) c : (NSString*) i : (NSString*) p : (NSString*) l
{
    if (self = [super init])
    {
        _category  = c.lowercaseString;
        //Items with commas have colons replacing commas in the data file, to avoid CSV confusion...
        //  restore commas here
        _item      = [i.lowercaseString stringByReplacingOccurrencesOfString:@":" withString:@","];
        _processed = p.lowercaseString;
        _local     = l.lowercaseString;
        if ([_processed isEqualToString:@"processed"])
        {
            _isProcessed = TRUE;
            _processed   = @"PROCESSED";
        }
        else if ([_processed isEqualToString:@"processed"])
        {
            _isProcessed = FALSE;
            _processed   = @"UNPROCESSED";
        }
        else //Bad data from CSV?
            NSLog(@" bogus CSV processed entry :%@",_item);
        if ([_local isEqualToString:@"yes"])
        {
            _isLocal = TRUE;
            _local   = @"YES";
        }
        else if ([_local isEqualToString:@"no"])
        {
            _isLocal = FALSE;
            _local   = @"NO";
        }
        else //Bad data from CSV?
            NSLog(@" bogus CSV local entry :%@",_item);

    }
    return self;
}




@end
