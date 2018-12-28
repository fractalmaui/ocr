//
//   _______  ______ _____     _     _
//  | ____\ \/ /  _ \_   _|_ _| |__ | | ___
//  |  _|  \  /| |_) || |/ _` | '_ \| |/ _ \
//  | |___ /  \|  __/ | | (_| | |_) | |  __/
//  |_____/_/\_\_|    |_|\__,_|_.__/|_|\___|
//
//  EXPTable.m
//  testOCR
//
//  Created by Dave Scruton on 12/17/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import "EXPTable.h"

@implementation EXPTable

//=============(EXPTable)=====================================================
-(instancetype) init
{
    if (self = [super init])
    {
        expos         = [[NSMutableArray alloc] init]; //Invoice Objects
        objectIDs     = [[NSMutableArray alloc] init]; //Invoice Objects
        recordStrings = [[NSMutableArray alloc] init]; //Invoice Objects
        productNames  = [[NSMutableArray alloc] init]; //Invoice Objects
        tableName = @"EXPFullTable";

        //bbb = [BatchObject sharedInstance];

        _versionNumber    = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    }
    return self;
}

//=============(EXPTable)=====================================================
-(void) clear
{
    [expos removeAllObjects];
    [objectIDs removeAllObjects];
}

#define PInv_Local_key @"Local"
#define PInv_LineNumber_key @"LineNumber"


//=============(EXPTable)=====================================================
-(void) addRecord : (NSDate*) fdate : (NSString *) category : (NSString *) month : (NSString *) item : (NSString *) uom : (NSString *) bulk : (NSString *) vendor : (NSString *) productName : (NSString *) processed : (NSString *) local : (NSString *) lineNumber : (NSString *) invoiceNumber : (NSString *) quantity : (NSString *) pricePerUOM : (NSString*) total : (NSString *) batch : (NSString *) errStatus : (NSString *) PDFFile
{
    NSString *errstr = @"";
    //ERR Check! Look for nils! Clumsy but it's all we can do w/ all these args!
    if (fdate == nil)       errstr = PInv_Date_key;
    if (category == nil)    errstr = PInv_Category_key;
    if (month == nil)       errstr = PInv_Month_key;
    if (item == nil)        errstr = PInv_Item_key;
    if (uom == nil)         errstr = PInv_UOM_key;
    if (bulk == nil)        errstr = PInv_Bulk_or_Individual_key;
    if (vendor == nil)      errstr = PInv_Vendor_key;
    if (productName == nil) errstr = PInv_ProductName_key;
    if (processed == nil)   errstr = PInv_Processed_key;
    if (local == nil)       errstr = PInv_Local_key;
    if (lineNumber == nil)  errstr = PInv_LineNumber_key;
    if (pricePerUOM == nil) errstr = PInv_PricePerUOM_key;
    if (total == nil)       errstr = PInv_TotalPrice_key;
    if (batch == nil)       errstr = PInv_Batch_key;
    if (errStatus == nil)   errstr = PInv_ErrStatus_key;
    if (PDFFile == nil)     errstr = PInv_PDFFile_key;
    if (errstr.length > 1) //Got an error?
    {
        NSLog(@"%@",[NSString stringWithFormat:@"  EXPerr:null(%@)",errstr]);
        return;
    }
    
    EXPObject *exo = [[EXPObject alloc] init];
    exo.expdate = fdate;
    exo.category = category;
    exo.month = month;
    exo.item = item;
    exo.uom = uom;
    exo.bulk = bulk;
    exo.vendor = vendor;
    exo.productName = productName;
    exo.processed = processed;
    exo.local = local;
    exo.lineNumber = lineNumber;
    exo.invoiceNumber = invoiceNumber;
    exo.quantity = quantity;
    exo.pricePerUOM = pricePerUOM;
    exo.total = total;
    exo.batch = batch;
    exo.errStatus = errStatus;
    exo.PDFFile = PDFFile;

    [expos addObject:exo];
    
} //end addRecord

//=============(EXPTable)=====================================================
-(NSString *) stringFromKeyedItems : (PFObject *)pfo : (NSArray *)kitems
{
    NSString *s = @"";
    int i = 0;
    int kc = (int)kitems.count;
    for (NSString *skey in kitems)
    {
        s = [s stringByAppendingString:
             [NSString stringWithFormat:@"%@",[pfo objectForKey:skey]]];
        if (i < kc-1)
             s = [s stringByAppendingString:@","];
        i++;
    }
    return s;
    
}


//=============(EXPTable)=====================================================
-(NSMutableArray *)getAllRecords
{
    return recordStrings;
}

//=============(EXPTable)=====================================================
-(NSString *)getRecord : (int) index
{
    if (index < 0 || index >= recordStrings.count) return @"";
    return [recordStrings objectAtIndex:index];
}


//=============(EXPTable)=====================================================
-(void) handleCSVInit : (BOOL) dumptoCSV
{
    if (dumptoCSV) EXPDumpCSVList = @"CATEGORY,Month,Item,Quantity,Unit Of Measure,BULK/ INDIVIDUAL PACK,Vendor Name, Total Price ,PRICE/ UOM,PROCESSED ,Local (L),Invoice Date,Line #,Invoice #,\n";
    else EXPDumpCSVList = @"";
} //end handleCSVInit

//=============(EXPTable)=====================================================
-(void) handleCSVAdd : (BOOL) dumptoCSV : (NSString *)s
{
    if (dumptoCSV)
    {
        self->EXPDumpCSVList = [self->EXPDumpCSVList stringByAppendingString: s];
        //if (i < count-1) //Not at end? add LF
        self->EXPDumpCSVList = [self->EXPDumpCSVList stringByAppendingString: @",\n"];
    }
} //end handleCSVAdd


//=============(EXPTable)=====================================================
-(NSString *) getCSVFromObject : (PFObject *)pfo
{
    NSArray *sitems1 = [NSArray arrayWithObjects:
                        PInv_Category_key,PInv_Month_key,PInv_Quantity_key,PInv_Item_key,
                        PInv_UOM_key,PInv_Bulk_or_Individual_key,PInv_Vendor_key,PInv_TotalPrice_key,
                        PInv_PricePerUOM_key,PInv_Processed_key,PInv_Local_key,PInv_LineNumber_key,
                        PInv_InvoiceNumber_key,
                        nil];
    NSString *s = [self stringFromKeyedItems : pfo :sitems1];
    //Inject date into this mess (it's special!)
    NSDateFormatter * formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yy"];
    NSString *sfd = [formatter stringFromDate:[pfo objectForKey:PInv_Date_key]];
    s = [s stringByAppendingString:
         [NSString stringWithFormat:@"%@,",sfd]];
    NSArray *sitems2 = [NSArray arrayWithObjects:
                        PInv_LineNumber_key,PInv_InvoiceNumber_key,
                        nil];
    s = [s stringByAppendingString:
         [NSString stringWithFormat:@",%@",[self stringFromKeyedItems : pfo :sitems2]]];
    return s;
}

//=============OCR VC=====================================================
-(void) readFromParseByObjIDs : (BOOL) dumptoCSV : (NSString *)vendor : (NSString *)soids
{
    [self handleCSVInit:dumptoCSV];
    NSMutableArray *a = [[NSMutableArray alloc] init];
    NSArray *sitems =  [soids componentsSeparatedByString:@","];
    PFQuery *query = [PFQuery queryWithClassName:@"EXPFullTable"];
    for (NSString *s in sitems)  //incoming should look like X_OBJID,X_OBJID, etc
    {
        NSArray *s2 =  [s componentsSeparatedByString:@"_"];
        if (s2.count == 2)
        {
            NSString *oid = s2[1];  //THis should be the object ID
            [a addObject:oid];
            NSLog(@" .. fetch objid [%@]",oid);
            PFObject *pfo = [query getObjectWithId:oid];  //Fetch by object ID,
            NSString *s = [self getCSVFromObject:pfo];    // handle as usual...
            [self->recordStrings addObject:s];
            [self->productNames addObject:[pfo objectForKey:PInv_ProductName_key]];
            [self handleCSVAdd : dumptoCSV : s];
        }
    }
    [self.delegate didReadEXPTableAsStrings : self->EXPDumpCSVList];
}


//=============OCR VC=====================================================
-(void) readFromParseAsStrings : (BOOL) dumptoCSV : (NSString *)vendor
{
    [self handleCSVInit:dumptoCSV];
    PFQuery *query = [PFQuery queryWithClassName:@"EXPFullTable"];
    if (![vendor isEqualToString:@"*"]) //Wildcard means get everything...
        [query whereKey:PInv_Vendor_key equalTo:vendor];
    [query orderByAscending:PInv_LineNumber_key];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) { //Query came back...
            [self->recordStrings removeAllObjects];
            [self->productNames  removeAllObjects];
//            int i     = 0;
            for( PFObject *pfo in objects)
            {
                NSString *s = [self getCSVFromObject:pfo];
                [self->recordStrings addObject:s];
                [self->productNames addObject:[pfo objectForKey:PInv_ProductName_key]];
                [self handleCSVAdd : dumptoCSV : s];
 //               i++;
            }
            NSLog(@" ...loaded EXP OK %@",self->recordStrings);
            [self.delegate didReadEXPTableAsStrings : self->EXPDumpCSVList];
        }
    }];
} //end readFromParseAsStrings


//=============(EXPTable)=====================================================
-(void) readFromParse : (NSString *) invoiceNumberstring
{
    
}

//=============(EXPTable)=====================================================
-(void) saveToParse
{
    
    if (expos.count < 1) return; //Nothing to write!
    int i=0;
    int ecount = (int)expos.count;
    returnCount = 0;
    for (EXPObject *exo in expos)
    {
        
        PFObject *exoRecord = [PFObject objectWithClassName:tableName];
        exoRecord[PInv_Category_key]            = exo.category;
        exoRecord[PInv_Month_key]               = exo.month;
        exoRecord[PInv_Item_key]                = exo.item;
        exoRecord[PInv_UOM_key]                 = exo.uom;
        exoRecord[PInv_Bulk_or_Individual_key]  = exo.bulk;
        exoRecord[PInv_Vendor_key]              = exo.vendor;
        exoRecord[PInv_ProductName_key]         = exo.productName;
        exoRecord[PInv_Processed_key]           = exo.processed;
        exoRecord[PInv_Local_key]               = exo.local;
        exoRecord[PInv_Date_key]                = exo.expdate; //ONLY column that ain't a String!
        exoRecord[PInv_LineNumber_key]          = exo.lineNumber;
        exoRecord[PInv_InvoiceNumber_key]       = exo.invoiceNumber;
        exoRecord[PInv_Quantity_key]            = exo.quantity;;
        exoRecord[PInv_TotalPrice_key]          = exo.total;
        exoRecord[PInv_PricePerUOM_key]         = exo.pricePerUOM;
        exoRecord[PInv_Batch_key]               = exo.batch;
        exoRecord[PInv_ErrStatus_key]           = exo.errStatus;
        exoRecord[PInv_PDFFile_key]             = exo.PDFFile;
        exoRecord[PInv_VersionNumber]           = _versionNumber;
        //NSLog(@" exp savetoParse...");
        [exoRecord saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@" ...EXP[%d] [%@/%@]->parse",i,exo.vendor,exo.productName);
                NSString *objID = exoRecord.objectId;
                //AppDelegate *gappDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                //[gappDelegate.bbb addOID:objID : self->tableName]; //Links current batcself->h to this record
                [self->objectIDs addObject:objID];
                self->returnCount++;
                if (self->returnCount == ecount)
                {
                    //NSLog(@" ...nextEXP: saved all recs to parse %d %@",i ,self->objectIDs);
                    [self.delegate didSaveEXPTable : self->objectIDs];
                }
            } else {
                NSLog(@" ERROR: saving EXP: %@",error.localizedDescription);
            }
        }];
        i++;
    } //end for loop
} //end saveToParse



@end
