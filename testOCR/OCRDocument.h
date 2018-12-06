//
//  OCRDocument.h
//  testOCR
//
//  Created by Dave Scruton on 12/5/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OCRWord.h"

NS_ASSUME_NONNULL_BEGIN

@interface OCRDocument : NSObject
{
    NSMutableArray *allWords;
    OCRWord *workWord;
    NSString *documentType;
    NSDictionary *rawJSONDict;
    NSString *parsedText;
    NSMutableArray *headerNames;
    NSMutableArray *columnStringData; //Array of Arrays...
    int glyphHeight;
}
@property (nonatomic , strong) UIImage* scannedImage;
@property (nonatomic , strong) NSString* scannedName;

@property (nonatomic , assign) int width;
@property (nonatomic , assign) int height;
@property (nonatomic , assign) int longestColumn;
@property (nonatomic , assign) CGRect docRect;


-(void) clearAllColumnStringData;
-(void) addColumnStringData : (NSMutableArray*)stringArray;
-(NSMutableArray *) findAllWordsInRect : (CGRect )rr;
-(NSMutableArray*)  getColumnStrings: (CGRect)rr : (NSMutableArray*)rowYs;
-(CGRect) getDocRect;
-(void) getAverageGlyphHeight;
-(NSMutableArray *) getRowFromColumnStringData : (int)index;
-(NSMutableArray *) getColumnYPositionsInRect : (CGRect )rr;
-(void)setJSON : (NSString *)json;
-(void) parseJSONfromDict : (NSDictionary *)d;
-(int) findIntInArrayOfFields : (NSArray*)aof;
-(float) findPriceInArrayOfFields : (NSArray*)aof;
-(NSDate *) findDateInArrayOfFields : (NSArray*)aof;
-(NSString *) findTopStringInArrayOfFields : (NSArray*)aof;
-(void) parseHeaderColumns : (NSArray*)aof;

@end

NS_ASSUME_NONNULL_END
