//
//  CheckTemplateVC.h
//  testOCR
//
//  Created by Dave Scruton on 12/26/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OCRTopObject.h"
NS_ASSUME_NONNULL_BEGIN

@interface CheckTemplateVC : UIViewController <UIScrollViewDelegate,OCRTopObjectDelegate>
{
    int viewWid,viewHit,viewW2,viewH2;
    int photoPixWid,photoPixHit;
    OCRTopObject *oto;

}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *outputLabel;
- (IBAction)backSelect:(id)sender;
- (IBAction)nextSelect:(id)sender;

@property (nonatomic , strong) UIImage* photo;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;


@end

NS_ASSUME_NONNULL_END
