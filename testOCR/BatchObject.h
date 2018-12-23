//
//   ____        _       _      ___  _     _           _
//  | __ )  __ _| |_ ___| |__  / _ \| |__ (_) ___  ___| |_
//  |  _ \ / _` | __/ __| '_ \| | | | '_ \| |/ _ \/ __| __|
//  | |_) | (_| | || (__| | | | |_| | |_) | |  __/ (__| |_
//  |____/ \__,_|\__\___|_| |_|\___/|_.__// |\___|\___|\__|
//                                      |__/
//
//  BatchObject.h
//  testOCR
//
//  Created by Dave Scruton on 12/22/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ObjectiveDropboxOfficial/ObjectiveDropboxOfficial.h>
#import "DropboxTools.h"
#import "OCRTemplate.h"
#import "Vendors.h"
#import "OCRTopObject.h"

@protocol batchObjectDelegate;


@interface BatchObject : NSObject <DropboxToolsDelegate,OCRTemplateDelegate,OCRTopObjectDelegate>
{
    DropboxTools *dbt;
    Vendors *vv;
    OCRTemplate *ot;
    NSString *vendorName;
    BOOL gotTemplate;
    NSString *batchFolder;
    
    NSMutableArray *vendorFileCounts;
    NSMutableDictionary *vendorFolders;
    OCRTopObject *oto;

}
@property (nonatomic , strong) NSString* batchID;
@property (nonatomic , assign) BOOL authorized;

@property (nonatomic, unsafe_unretained) id <batchObjectDelegate> delegate; // receiver of completion messages

+ (id)sharedInstance;
-(void) getBatchCounts;
-(int)  getVendorFileCount : (NSString *)vfn;

-(void) runOneOrMoreBatches : (NSString *)vname : (int) index;

@end

@protocol batchObjectDelegate <NSObject>
@required
@optional
- (void)didGetBatchCounts;
@end


