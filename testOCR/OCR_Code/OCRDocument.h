//
//    ___   ____ ____  ____                                        _
//   / _ \ / ___|  _ \|  _ \  ___   ___ _   _ _ __ ___   ___ _ __ | |_
//  | | | | |   | |_) | | | |/ _ \ / __| | | | '_ ` _ \ / _ \ '_ \| __|
//  | |_| | |___|  _ <| |_| | (_) | (__| |_| | | | | | |  __/ | | | |_
//   \___/ \____|_| \_\____/ \___/ \___|\__,_|_| |_| |_|\___|_| |_|\__|
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
    NSMutableArray *ignoreList;
    BOOL useIgnoreList;
    //Comes from templated original document...
    CGRect tlOriginalRect, trOriginalRect;
    //Comes from each newly scanned document
    CGRect tlScalingRect,trScalingRect;
    double hScale,vScale; //For document scaling after template is made
    //Groups: Used to try to find fields if templates fail?
    NSMutableSet *gT10;   //Near top,bottom,left,right
    NSMutableSet *gB10;
    NSMutableSet *gL10;
    NSMutableSet *gR10;
    NSMutableSet *gH20; //Near H/V center
    NSMutableSet *gV20;
    NSMutableSet *gT50;   //Top half
    NSMutableSet *gL50;   //Left half
}
@property (nonatomic , strong) UIImage* scannedImage;
@property (nonatomic , strong) NSString* scannedName;

@property (nonatomic , assign) int width;
@property (nonatomic , assign) int height;
@property (nonatomic , assign) int longestColumn;
@property (nonatomic , assign) CGRect docRect;


-(void) clearAllColumnStringData;
-(NSString*) cleanUpNumberString : (NSString *)nstr;
-(NSString*) cleanUpProductNameString : (NSString *)pstr;
-(void) addColumnStringData : (NSMutableArray*)stringArray;
-(void) addIgnoreBoxItems  : (CGRect )rr;
-(NSMutableArray *) findAllWordsInRect : (CGRect )rr;
-(NSMutableArray *) findAllWordStringsInRect : (CGRect )rr;
-(int) findIntInArrayOfFields : (NSArray*)aof;
-(float) findPriceInArrayOfFields : (NSArray*)aof;
-(NSDate *) findDateInArrayOfFields : (NSArray*)aof;
-(NSString *) findTopStringInArrayOfFields : (NSArray*)aof;
-(int) findQuantityColumn;
-(int) findItemColumn;
-(int) findDescriptionColumn;
-(int) findPriceColumn;
-(int) findAmountColumn;
-(NSMutableArray*)  getColumnStrings: (CGRect)rr : (NSMutableArray*)rowYs;
-(NSArray*)  getHeaderNames;
-(CGRect) getDocRect;
-(CGRect) getTLRect;
-(CGRect) getTRRect;
-(CGRect) getBLRect;
-(CGRect) getBRRect;
-(void) getAverageGlyphHeight;
-(NSMutableArray *) getRowFromColumnStringData : (int)index;
-(NSMutableArray *) getColumnYPositionsInRect : (CGRect )rr : (BOOL) numeric;
-(void) parseJSONfromDict : (NSDictionary *)d;
-(NSDate *) isItADate : (NSString *)tstr;
-(void) parseHeaderColumns : (NSArray*)aof;
-(void) setupDocument : (NSString*) ifname : (NSDictionary *)d : (BOOL) flipped90;
-(void) computeScaling: (CGRect )tlr : (CGRect )trr;
-(void) setScalingRects;
@end

NS_ASSUME_NONNULL_END
