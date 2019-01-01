//
//   _______  ______ _____     _     _
//  | ____\ \/ /  _ \_   _|_ _| |__ | | ___
//  |  _|  \  /| |_) || |/ _` | '_ \| |/ _ \
//  | |___ /  \|  __/ | | (_| | |_) | |  __/
//  |_____/_/\_\_|    |_|\__,_|_.__/|_|\___|
//
//  EXPTable.h
//  testOCR
//
//  Created by Dave Scruton on 12/17/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "AppDelegate.h"
#import "EXPObject.h"
#import "DBKeys.h"

@protocol EXPTableDelegate;


@interface EXPTable : NSObject
{
    NSMutableArray *expos;
    NSMutableArray *objectIDs;
    NSMutableArray *recordStrings;
    NSMutableArray *productNames;
    NSString *tableName;
    NSString *EXPDumpCSVList;
    int returnCount;
}

@property (nonatomic, unsafe_unretained) id <EXPTableDelegate> delegate; // receiver of completion messages

@property (nonatomic , strong) NSString* versionNumber;

-(void) clear;

-(void) addRecord : (NSDate*) fdate : (NSString *) category : (NSString *) month : (NSString *) item : (NSString *) uom : (NSString *) bulk : (NSString *) vendor : (NSString *) productName : (NSString *) processed : (NSString *) local : (NSString *) lineNumber : (NSString *) invoiceNumber : (NSString *) quantity : (NSString *) pricePerUOM : (NSString *) total : (NSString *) batch : (NSString *) errStatus : (NSString *) PDFFile;

-(void) saveToParse;
-(void) readFromParse : (NSString *) invoiceNumberstring;
-(void) readFromParseByObjIDs : (BOOL) dumptoCSV : (NSString *)vendor : (NSString *)soids;
-(void) readFromParseAsStrings : (BOOL) dumptoCSV : (NSString *)vendor : (NSString *)batch;
-(NSString *)getRecord : (int) index;
-(NSMutableArray *)getAllRecords;


@end

@protocol EXPTableDelegate <NSObject>
@required
@optional
- (void)didReadEXPTable;
- (void)didReadEXPTableAsStrings : (NSString *)s;
- (void)didSaveEXPTable : (NSArray *)a;
@end

