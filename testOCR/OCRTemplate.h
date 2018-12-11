//
//    ___   ____ ____ _____                    _       _
//   / _ \ / ___|  _ \_   _|__ _ __ ___  _ __ | | __ _| |_ ___
//  | | | | |   | |_) || |/ _ \ '_ ` _ \| '_ \| |/ _` | __/ _ \
//  | |_| | |___|  _ < | |  __/ | | | | | |_) | | (_| | ||  __/
//   \___/ \____|_| \_\|_|\___|_| |_| |_| .__/|_|\__,_|\__\___|
//                                      |_|
//
//  OCRTemplate.h
//  testOCR
//
//  Created by Dave Scruton on 12/5/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <UIKit/UIKit.h>
#import "OCRBox.h"
NS_ASSUME_NONNULL_BEGIN

@interface OCRTemplate : NSObject
{
    NSMutableArray *ocrBoxes;
    NSString *fileLocation;
    NSString *fileWorkString;
    CGRect headerColumns[32]; //Overkill
    int headerColumnCount;
}

@property (nonatomic , strong) NSString* versionNumber;


-(void) addBox : (CGRect) frame : (NSString *)fname : (NSString *)format;
-(void) addTag : (int) index : (NSString*)tag;
-(void) clearFields;
-(void) clearHeaders;
-(void) clearTags : (int) index;
-(void) deleteBox : (int) index;
-(NSString *) getAllTags :(int) index;
-(int) getBoxCount;
-(CGRect) getBoxRect :(int) index;
-(NSString*) getBoxFieldName :(int) index;
-(NSString*) getBoxFieldFormat :(int) index;
-(int) getColumnCount;
-(CGRect) getColumnByIndex : (int) index;
-(int)  getTagCount : (int) index;
-(void) addHeaderColumnToSortedArray : (int) index;
-(void) dump;
-(void) dumpBox : (int) index;
-(void) loadTemplatesFromDisk;
-(void) saveTemplatesToDisk;
-(void) saveToParse : (NSString *)vendorName;
-(BOOL) gotFieldAlready : (NSString*)fname;
-(int) hitField :(int) tx : (int) ty;
@end

NS_ASSUME_NONNULL_END
