//
//  invoiceTable.h
//  testOCR
//
//  Created by Dave Scruton on 12/17/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "DBKeys.h"
#import "invoiceObject.h"


@protocol invoiceTableDelegate;

@interface invoiceTable : NSObject
{
    
    NSMutableArray *iobjs;
    int dog;
    NSString *tableName;
    NSString *packedOIDs;
}

@property (nonatomic , strong) NSDate* idate;
@property (nonatomic , strong) NSString* inumber;
@property (nonatomic , strong) NSString* itotal;
@property (nonatomic , strong) NSString* ivendor;
@property (nonatomic , strong) NSString* icustomer;
@property (nonatomic , strong) NSString* versionNumber;

@property (nonatomic, unsafe_unretained) id <invoiceTableDelegate> delegate; // receiver of completion messages


-(void) addInvoiceItemByObjectID:(NSString *)oid;
-(void) setBasicFields : (NSDate *) ddd : (NSString*)num : (NSString*)total : (NSString*)vendor : (NSString*)customer;
-(void) clear;
-(int) getItemCount;
-(void) saveToParse;
-(void) setupVendorTableName : (NSString *)vname;


@end

@protocol invoiceTableDelegate <NSObject>
@required
@optional
- (void)didReadInvoiceTable;
- (void)didSaveInvoiceTable;
@end

