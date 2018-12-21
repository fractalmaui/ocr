//
//  AddTemplateViewController.h
//  testOCR
//
//  Created by Dave Scruton on 12/20/18.
//  Copyright © 2018 huedoku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "ImageTools.h"

NS_ASSUME_NONNULL_BEGIN

@interface AddTemplateViewController : UIViewController <UIImagePickerControllerDelegate,UINavigationControllerDelegate>
{
    int viewWid,viewHit,viewW2,viewH2;


    int photoPixWid,photoPixHit;
    int photoScreenWid,photoScreenHit;
    float photoToUIX,photoToUIY;
    BOOL gotPhoto;
    int step;
    double rotAngle;
    double rotAngleRadians;
    BOOL showRotatedImage;
    imageTools *it;
    
    
    CIImage *coreImage;
    float brightness;
    float contrast;
    float saturation;
    BOOL removeColor;
    BOOL enhancing;
}
// UI stuff
@property (weak, nonatomic) IBOutlet UIImageView *gridOverlay;
@property (nonatomic , strong) UIImage *photo;
@property (nonatomic , strong) UIImage *rphoto;
@property (nonatomic , strong) UIImage *prphoto;
@property (weak, nonatomic) IBOutlet UILabel *titeLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;
@property (weak, nonatomic) IBOutlet UIImageView *templateImage;
@property (weak, nonatomic) IBOutlet UIView *rotateView;
@property (weak, nonatomic) IBOutlet UILabel *skewLabel;
@property (weak, nonatomic) IBOutlet UIButton *removeColorButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UIButton *loadButton;
@property (weak, nonatomic) IBOutlet UIView *enhanceView;
@property (weak, nonatomic) IBOutlet UISlider *bSlider;
@property (weak, nonatomic) IBOutlet UISlider *cSlider;
@property (weak, nonatomic) IBOutlet UILabel *briLabel;
@property (weak, nonatomic) IBOutlet UILabel *conLabel;

// sharable properties...


- (IBAction)resetSelect:(id)sender;
- (IBAction)cancelSelect:(id)sender;
- (IBAction)loadSelect:(id)sender;
- (IBAction)deskewSelect:(id)sender;
- (IBAction)p90Select:(id)sender;
- (IBAction)p10Select:(id)sender;
- (IBAction)p1Select:(id)sender;
- (IBAction)m1Select:(id)sender;
- (IBAction)m10Select:(id)sender;
- (IBAction)m90Select:(id)sender;
- (IBAction)nextSelect:(id)sender;
- (IBAction)bSliderChanged:(id)sender;
- (IBAction)cSliderChanged:(id)sender;
- (IBAction)removeColorSelect:(id)sender;
- (IBAction)resetEnhanceSelect:(id)sender;


@end

NS_ASSUME_NONNULL_END