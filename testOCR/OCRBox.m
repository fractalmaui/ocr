//
//  OCRBox.m
//  testOCR
//
//  Created by Dave Scruton on 12/5/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import "OCRBox.h"

@implementation OCRBox

-(void) dump
{
    NSLog(@"  fname  %@",_fieldName);
    NSLog(@"  format %@",_fieldFormat);
    NSLog(@"  frame  (%d,%d) (%d,%d)",
          (int)_frame.origin.x  ,(int)_frame.origin.y,
          (int)_frame.size.width,(int)_frame.size.height);
}

@end
