//
//  invoiceTable.m
//  testOCR
//
//  Created by Dave Scruton on 12/17/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import "invoiceTable.h"

@implementation invoiceTable

//=============(invoiceTable)=====================================================
-(instancetype) init
{
    if (self = [super init])
    {
        iobjs = [[NSMutableArray alloc] init]; //Invoice Objects
        tableName = @"";
        _versionNumber    = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    }
    return self;
}

//=============(invoiceTable)=====================================================
-(void) clear
{
    [iobjs removeAllObjects];
}

//=============(invoiceTable)=====================================================
-(void) addInvoiceItemByObjectID:(NSString *)oid
{
    //Overkill: this object only has one field for now...
    invoiceObject *io = [[invoiceObject alloc] init];
    io.objectID = oid;
    [iobjs addObject: io];
}

//=============(invoiceTable)=====================================================
-(int) getItemCount
{
    return (int)iobjs.count;
}


//=============(invoiceTable)=====================================================
// There is one table per vendor, its name comes from vendor name,
//  for example, "Hawaii Dawg" would be "I_Hawaii_Dawg".
// I is always there, and spaces are replaced with underbars
-(void) setupVendorTableName : (NSString *)vname
{
    NSString *v = [vname stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    tableName = [NSString stringWithFormat:@"I_%@",v];
}

//=============(invoiceTable)=====================================================
-(void) unpackInvoiceOids
{
    [iobjs removeAllObjects];
    NSArray *sitems =  [packedOIDs componentsSeparatedByString:@","];
    for (NSString *s in sitems)
    {
        invoiceObject *io = [[invoiceObject alloc] init];
        io.objectID = s;
        [iobjs addObject:io];
    }
} //end unpackInvoiceOids

//=============(invoiceTable)=====================================================
-(void) packInvoiceOids
{
    packedOIDs =  @"";
    int i = 0;
    for (invoiceObject *io in iobjs)
    {
        packedOIDs = [packedOIDs stringByAppendingString:io.objectID];
        if (i < iobjs.count-1)
            packedOIDs = [packedOIDs stringByAppendingString:@","];
        i++;
    }
    
} //end packInvoiceOids

//=============(invoiceTable)=====================================================
-(void) readFromParse : (NSString *)vendor : (NSString *)instring
{
    [self setupVendorTableName:vendor];
    if (tableName.length < 1) return; //No table name!
    PFQuery *query = [PFQuery queryWithClassName:tableName];
    [query whereKey:PInv_InvoiceNumber_key equalTo:instring];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) { //Query came back...
            [self->iobjs removeAllObjects];
            for( PFObject *pfo in objects) //Should only be one?
            {
                self->_idate         = pfo[PInv_Date_key];
                self->_inumber       = pfo[PInv_InvoiceNumber_key];
                self->_icustomer     = pfo[PInv_CustomerKey];
                self->_ivendor       = pfo[PInv_Vendor_key];
                self->_versionNumber = pfo[PInv_VersionNumber];
                self->packedOIDs     = pfo[PInv_EXPObjectID_key];
                [self unpackInvoiceOids];
            }
        }
    }];
    
} //end readFromParse

//=============(invoiceTable)=====================================================
-(void) saveToParse
{
    if (tableName.length < 1) return; //No table name!
    [self packInvoiceOids]; //Set up packedOIDs string
    PFObject *iRecord = [PFObject objectWithClassName:tableName];
    iRecord[PInv_Date_key]          = _idate;
    iRecord[PInv_InvoiceNumber_key] = _inumber;
    iRecord[PInv_CustomerKey]       = _icustomer;
    iRecord[PInv_Vendor_key]        = _ivendor;
    iRecord[PInv_EXPObjectID_key]   = packedOIDs;
    iRecord[PInv_VersionNumber]     = _versionNumber;
    NSLog(@" itable savetoParse...");
    [iRecord saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@" ...invoiceTable [vendor:%@] saved to parse",self->_ivendor);
            [self.delegate didSaveInvoiceTable];
        } else {
            NSLog(@" ERROR: saving invoice: %@",error.localizedDescription);
        }
    }];
} //end saveToParse

//=============(invoiceTable)=====================================================
-(void) setBasicFields : (NSDate *) ddd : (NSString*)num : (NSString*)total : (NSString*)vendor : (NSString*)customer
{
    _idate  = ddd;
    _inumber    = num;
    _itotal     = total;
    _ivendor    = vendor;
    _icustomer  = customer;
} //end setBasicFields


@end
