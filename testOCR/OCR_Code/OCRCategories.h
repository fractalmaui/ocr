//
//  OCRCategories.h
//  testOCR
//
//  Created by Dave Scruton on 12/19/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CatObject.h"


#define BEVERAGE_CATEGORY @"BEVERAGE"
#define BREAD_CATEGORY @"BREAD"
#define DAIRY_CATEGORY @"DAIRY"
#define DRY_GOODS_CATEGORY @"DRY GOODS"
#define EQUIPMENT_CATEGORY @"EQUIPMENT"
#define MISC_CATEGORY @"MISC"
#define PAPER_GOODS_CATEGORY @"PAPER GOODS"
#define PROTEIN_CATEGORY @"PROTEIN"
#define PRODUCE_CATEGORY @"PRODUCE"
#define SNACKS_CATEGORY @"SNACKS"
#define SUPPLEMENTS_CATEGORY @"SUPPLEMENTS"
#define SUPPLIES_CATEGORY @"SUPPLIES"

@interface OCRCategories : NSObject
{
    
    NSMutableArray *catCSV;
//    int dog;
//    NSString *tableName;
//    NSString *packedOIDs;
    
}
@property (nonatomic , strong) NSMutableArray* catProducts;


+ (id)sharedInstance;
-(NSArray *)matchCategory : (NSString *)product;

@end

