//
//  imageTools.h
//  testOCR
//
//  Created by Dave Scruton on 12/5/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
#define MAXBINS 32768

@interface imageTools : NSObject
{
    CFDataRef pixelData;
    const UInt8* idata;
    int iwid,ihit;
    int bins[MAXBINS];
    int bgrad[MAXBINS];
    int absgrad[MAXBINS];

}

@end

NS_ASSUME_NONNULL_END
