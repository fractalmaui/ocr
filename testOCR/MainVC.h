//
//  MainVC.h
//  testOCR
//
//  Created by Dave Scruton on 12/14/18.
//  Copyright © 2018 huedoku. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavButtons.h"
NS_ASSUME_NONNULL_BEGIN

@interface MainVC : UIViewController <NavButtonsDelegate>
{
    NavButtons *nav;
    int viewWid,viewHit,viewW2,viewH2;

}
@end

NS_ASSUME_NONNULL_END
