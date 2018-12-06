//
//  OCRBox.h
//  testOCR
//
//  Created by Dave Scruton on 12/5/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface OCRBox : NSObject
{
    
}
@property (nonatomic , strong) NSString* fieldName;
@property (nonatomic , strong) NSString* fieldFormat;
@property (nonatomic , assign) CGRect frame;
@property (nonatomic , strong) NSString* stringValue;
@property (nonatomic , strong) NSNumber* numericValue;

-(void) dump;

@end

NS_ASSUME_NONNULL_END
