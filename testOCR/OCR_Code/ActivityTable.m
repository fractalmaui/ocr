//
//  ActivityTable.m
//  testOCR
//
//  Created by Dave Scruton on 12/22/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//
//  Should this be a singleton?

#import "ActivityTable.h"

@implementation ActivityTable


//=============(ActivityTable)=====================================================
-(instancetype) init
{
    if (self = [super init])
    {
        tableName = @"activity";
        recordStrings = [[NSMutableArray alloc] init]; //output area for table dump
        _versionNumber    = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    }
    return self;
}


//=============(ActivityTable)=====================================================
-(void) saveActivityToParse : (NSString*) actType : (NSString *)actData
{
    PFObject *aRecord = [PFObject objectWithClassName:tableName];
    aRecord[PInv_ActivityType]  = actType;
    aRecord[PInv_ActivityData]  = actData;
    aRecord[PInv_VersionNumber] = _versionNumber;
    NSLog(@" activity savetoParse...");
    [aRecord saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@" ...activity[%@] saved to parse",actType );
            [self.delegate didSaveActivity];
        } else {
            NSLog(@" ERROR: saving activity: %@",error.localizedDescription);
        }
    }];
} //end saveToParse


@end
