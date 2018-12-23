//
//   __  __       _    __     ______
//  |  \/  | __ _(_)_ _\ \   / / ___|
//  | |\/| |/ _` | | '_ \ \ / / |
//  | |  | | (_| | | | | \ V /| |___
//  |_|  |_|\__,_|_|_| |_|\_/  \____|
//
//  MainVC.h
//  testOCR
//
//  Created by Dave Scruton on 12/5/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NavButtons.h"
#import "SessionManager.h"


NS_ASSUME_NONNULL_BEGIN

@interface MainVC : UIViewController <NavButtonsDelegate>
{
    NavButtons *nav;
    int viewWid,viewHit,viewW2,viewH2;

}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;



@end

NS_ASSUME_NONNULL_END
