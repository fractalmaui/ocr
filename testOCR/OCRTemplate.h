//
//  OCRTemplate.h
//  testOCR
//
//  Created by Dave Scruton on 12/5/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
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

-(void) clearFields;
-(void) clearHeaders;
-(void) addBox : (CGRect) frame : (NSString *)fname : (NSString *)format;
-(int) getBoxCount;
-(CGRect) getBoxRect :(int) index;
-(NSString*) getBoxFieldName :(int) index;
-(NSString*) getBoxFieldFormat :(int) index;
-(int) getColumnCount;
-(CGRect) getColumnByIndex : (int) index;
-(void) addHeaderColumnToSortedArray : (int) index;
-(void) dump;
-(void) loadTemplatesFromDisk;
-(void) saveTemplatesToDisk;
-(BOOL) gotFieldAlready : (NSString*)fname;

@end

NS_ASSUME_NONNULL_END
