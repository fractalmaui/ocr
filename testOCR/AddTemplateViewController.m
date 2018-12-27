//
//      _       _     _ _____                    _       _     __     ______
//     / \   __| | __| |_   _|__ _ __ ___  _ __ | | __ _| |_ __\ \   / / ___|
//    / _ \ / _` |/ _` | | |/ _ \ '_ ` _ \| '_ \| |/ _` | __/ _ \ \ / / |
//   / ___ \ (_| | (_| | | |  __/ | | | | | |_) | | (_| | ||  __/\ V /| |___
//  /_/   \_\__,_|\__,_| |_|\___|_| |_| |_| .__/|_|\__,_|\__\___| \_/  \____|
//                                        |_|
//
//  AddTemplateViewController.m
//  testOCR
//
//  Created by Dave Scruton on 12/20/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import "AddTemplateViewController.h"

@interface AddTemplateViewController ()

@end

@implementation AddTemplateViewController


NSString * steps[] = {
    @"Step 1: Choose a document image...",
    @"Step 2: Rotate / Deskew...",
    @"Step 3: Enhance..."

};


//=============OCR VC=====================================================
-(id)initWithCoder:(NSCoder *)aDecoder {
    if ( !(self = [super initWithCoder:aDecoder]) ) return nil;
    
 //   _versionNumber    = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
     it = [[imageTools alloc] init];
    
    brightness  =  0.0;
    contrast    = saturation = 1.0;
    removeColor = FALSE;
    enhancing   = FALSE;
    coreImage   = [[CIImage alloc] init];

    return self;
}



//=============AddTemplate VC=====================================================
- (void)viewDidLoad {
    [super viewDidLoad];
    gotPhoto = FALSE;
    //Hide some stuff at the beginning
    _rotateView.hidden        = TRUE;
    _gridOverlay.hidden       = TRUE;
    _loadButton.hidden        = TRUE;
    _nextButton.hidden        = TRUE;
    _activityIndicator.hidden = TRUE;
    _enhanceView.hidden       = TRUE;
    [_removeColorButton setTitle:@"Remove Color" forState:UIControlStateNormal];
    // Do any additional setup after loading the view.
}

//=============AddTemplate VC=====================================================
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //First, are we coming back from something??
    if (_step != 0)
    {
        _step = 1; //Set back to deskew...
    }
    else if (_step == 0)
    {
        [self displayPhotoPicker];
    }

    [self updateUI];
}

//=============AddTemplate VC=====================================================
-(void) loadView
{
    [super loadView];
    CGSize csz   = [UIScreen mainScreen].bounds.size;
    viewWid = (int)csz.width;
    viewHit = (int)csz.height;
    viewW2  = viewWid/2;
    viewH2  = viewHit/2;
}


//=============AddTemplate VC=====================================================
-(void) scaleImageViewToFitDocument
{
    int iwid = _templateImage.image.size.width;
    int ihit = _templateImage.image.size.height;
    int xi,yi,xs,ys;
    double xscale = (double)viewWid / (double)iwid;
    yi = 90;
    xs = xscale * iwid;
    ys = xscale * ihit;
    xi = viewW2 - xs/2;
    CGRect rr = CGRectMake(xi, yi, xs, ys);
    NSLog(@" r %@",NSStringFromCGRect(rr));
    _templateImage.frame = rr;
} //end scaleImageViewToFitDocument


//=============AddTemplate VC=====================================================
- (IBAction)resetSelect:(id)sender
{
    [self resetRotation];
    _step = 1;
    rotAngle = rotAngleRadians = 0.0;
    showRotatedImage = FALSE;
    [self updateUI];
}



//=============AddTemplate VC=====================================================
- (IBAction)resetEnhanceSelect:(id)sender
{
    contrast    = 1.0;
    brightness  = 0.0;
    saturation  = 1.0;
    removeColor = FALSE;
    [self updateUI];
}

//=============AddTemplate VC=====================================================
- (IBAction)cancelSelect:(id)sender
{
    [self dismiss];

}

//=============AddTemplate VC=====================================================
- (IBAction)loadSelect:(id)sender
{
     [self displayPhotoPicker];
}

//=============AddTemplate VC=====================================================
- (IBAction)deskewSelect:(id)sender
{
    UIImage *inputImage = _photo;
    if (showRotatedImage) inputImage = _rphoto;
    
    [it deskew:inputImage]; //This returns an image, but gets an error if i try getting it!
    double dskew = it.skewAngleFound;
    rotAngleRadians = dskew;
    rotAngle = 180.0 * (dskew / 3.141592627);
    showRotatedImage = TRUE;
    // Note: this may be using a pre-rotated image!
    //  for instance, if input was obviously 90 degrees off, then there will be a 90 deg
    //  starting rotation... it still may be skewed tho...
    _rphoto =  [it imageRotatedByRadians:rotAngleRadians img:inputImage];
    [self updateUI];

    NSLog(@" found skew angle %f (%fdeg)",rotAngleRadians,rotAngle);
//    UIImage *iskew = [it deskew:inputImage];
    //_skewAngleFound
}



//=============AddTemplate VC=====================================================
- (IBAction)p90Select:(id)sender
{
    [self rotateTemplatePhoto : 90.0];
}

//=============AddTemplate VC=====================================================
- (IBAction)p10Select:(id)sender {
    [self rotateTemplatePhoto : 10.0];
}

//=============AddTemplate VC=====================================================
- (IBAction)p1Select:(id)sender {
    [self rotateTemplatePhoto : 0.1];
}

//=============AddTemplate VC=====================================================
- (IBAction)m1Select:(id)sender {
    [self rotateTemplatePhoto : -0.1];
}

//=============AddTemplate VC=====================================================
- (IBAction)m10Select:(id)sender {
    [self rotateTemplatePhoto : -10.0];
}

//=============AddTemplate VC=====================================================
- (IBAction)m90Select:(id)sender {
    [self rotateTemplatePhoto : -90.0];
}

//=============AddTemplate VC=====================================================
- (IBAction)nextSelect:(id)sender
{
    if (_step == 1)
    {
        _step = 2;
    }
    else if (_step == 2)
    {
        //_step = 3;
        [self performSegueWithIdentifier:@"checkTemplateSegue" sender:@"addTemplateVC"];
    }
    [self updateUI];
}

//=============AddTemplate VC=====================================================
-(void) dismiss
{
    //[_sfx makeTicSoundWithPitch : 8 : 52];
    [self dismissViewControllerAnimated : YES completion:nil];
    
}

//=============AddTemplate VC=====================================================
// Handles last minute VC property setups prior to segues
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSLog(@" prepareForSegue: %@ sender %@",[segue identifier], sender);
    if([[segue identifier] isEqualToString:@"checkTemplateSegue"])
    {
        CheckTemplateVC *vc = (CheckTemplateVC*)[segue destinationViewController];
        vc.photo = _templateImage.image;
    }
}


//=============AddTemplate VC=====================================================
-(void) updateUI
{
    NSLog(@" updateui step %d showr %d",_step,showRotatedImage);
    if (_step == 1)  //Rotate: two possible states here...
    {
        if (showRotatedImage)
            _titeLabel.text = [NSString stringWithFormat:@"Rotated by %f degrees",rotAngle];
        else
            _titeLabel.text = steps[_step];
    }
    else //other steps...
    {
        _titeLabel.text = _titeLabel.text = steps[_step];
        if (_step == 2) //enhance?
        {
            _bSlider.value = brightness;
            _cSlider.value = contrast;
            _briLabel.text = [NSString stringWithFormat:@"Brightness %3.2f",brightness];
            _conLabel.text = [NSString stringWithFormat:@"Contrast   %3.2f",contrast];
            if (removeColor)
            {
                [_removeColorButton setTitle:@"Restore Color" forState:UIControlStateNormal];
            }
            else
            {
                [_removeColorButton setTitle:@"Remove Color" forState:UIControlStateNormal];
            }

        }
    }
    

    //Show / hide stuff based on step and states...
    _rotateView.hidden  = (_step != 1);
    _loadButton.hidden  = (_step < 1);
    _nextButton.hidden  = (_step < 1);
    _gridOverlay.hidden = !(showRotatedImage && _step == 1);
    _enhanceView.hidden = (_step < 2);

    if (!showRotatedImage)
    {
        _templateImage.image = _photo;
    }
    else
    {
        _templateImage.image = _rphoto;
    }
    [self scaleImageViewToFitDocument];

} //end updateUI



//=============AddTemplate VC=====================================================
-(void) resetRotation
{
    rotAngle = 0.0; //Degrees
    showRotatedImage = FALSE;
}

//=============AddTemplate VC=====================================================
-(void) rotateTemplatePhoto : (double) aoff
{
    rotAngle +=aoff;
    rotAngleRadians = 3.141592627 * (float)rotAngle / 180.0  ;
    
    _rphoto =  [it imageRotatedByRadians:rotAngleRadians img:_photo];
    showRotatedImage = TRUE;
    _step = 1;
    [self updateUI];

}


//=============AddTemplate VC=====================================================
-(void) displayPhotoPicker
{
    //NSLog(@" photo picker...");
    UIImagePickerController *imgPicker;
    imgPicker = [[UIImagePickerController alloc] init];
    imgPicker.allowsEditing = NO;
    imgPicker.delegate      = self;
    imgPicker.sourceType    = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:imgPicker animated:NO completion:nil];
    gotPhoto = TRUE;
} //end displayPhotoPicker

//=============AddTemplate VC=====================================================
// OK? load / process image as needed
- (void)imagePickerController:(UIImagePickerController *)Picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //Makes poppy squirrel sound!
    NSLog(@" ok...");
    _step = 1;
    //[_sfx makeTicSoundWithPitchandLevel:7 :70 : 40];
    [Picker dismissViewControllerAnimated:NO completion:^{
        self->_photo = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage ];
        self->photoPixWid = self->_photo.size.width;
        self->photoPixHit = self->_photo.size.height;
        self->photoScreenWid = self->_templateImage.frame.size.width;
        self->photoScreenHit = self->_templateImage.frame.size.height;
        self->photoToUIX = (float)self->photoScreenWid/(float)self->_photo.size.width;
        self->photoToUIY = (float)self->photoScreenHit/(float)self->_photo.size.height;
//        NSLog(@" set img");
        [self resetRotation];
        [self updateUI];
    }];
} //end didFinishPickingMediaWithInfo

//==========createVC=================================================================
// Dismiss back to parent on cancel...
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)Picker
{
    [Picker dismissViewControllerAnimated:NO completion:nil];
    if (!gotPhoto) //No Photo -> Just bouncing back out? Dismiss this VC too
        [self dismissViewControllerAnimated : YES completion:nil];
    
} //end imagePickerControllerDidCancel

//=========-createVC=========================================================================
-(void) getProcessedImageBkgd
{
    if (enhancing) return;

    // _createButton.hidden = TRUE;
    _activityIndicator.hidden = FALSE;
    [_activityIndicator startAnimating];
    UIImage *inputImage = _photo;
    if (showRotatedImage) inputImage = _rphoto;
    enhancing = TRUE;
    coreImage = [coreImage initWithImage:inputImage];
    NSLog(@" process bcs %f %f %f",brightness,contrast,saturation);
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       dispatch_sync(dispatch_get_main_queue(), ^{
                           float cont_intensity  = self->contrast;   // some are 0 - 1, some are 0-2
                           float sat_intensity   = self->saturation;
                           float brit_intensity  = self->brightness;
                           NSNumber *workNumCont = [NSNumber numberWithFloat:cont_intensity];
                           NSNumber *workNumSat  = [NSNumber numberWithFloat:sat_intensity];
                           NSNumber *workNumBrit = [NSNumber numberWithFloat:brit_intensity];
                           CIFilter *filterCont  = [CIFilter filterWithName:@"CIColorControls"
                                                              keysAndValues: kCIInputImageKey, self->coreImage,
                                                    @"inputBrightness", workNumBrit,
                                                    @"inputSaturation", workNumSat,
                                                    @"inputContrast",   workNumCont,
                                                    nil];
                           CIImage *workCoreImage = [filterCont outputImage];
                           CIContext *context = [CIContext contextWithOptions:nil];
                           CGImageRef cgimage = [context createCGImage:workCoreImage fromRect:[workCoreImage extent] format:kCIFormatRGBA8 colorSpace:CGColorSpaceCreateDeviceRGB()];
                           self->_prphoto = [UIImage imageWithCGImage:cgimage scale:0 orientation:[self->_photo imageOrientation]];
                           CGImageRelease(cgimage);
                           [self->_activityIndicator stopAnimating];
                           self->_activityIndicator.hidden = TRUE;
                           //[self handleProcessedResults];
                           //OK we got our image, show it!
                           self->_templateImage.image = self->_prphoto;
//                           self->_needProcessedImage = FALSE;
                           self->enhancing = FALSE;
                           [context clearCaches];
                       });
                       
                   }
                   ); //END outside dispatch
    
} //end getProcessedImageBkgd

//=============AddTemplate VC=====================================================
- (IBAction)bSliderChanged:(id)sender
{
    UISlider *s = (UISlider*)sender;
    brightness = s.value;
    [self getProcessedImageBkgd];
    _briLabel.text = [NSString stringWithFormat:@"Brightness %3.2f",brightness];

}

//=============AddTemplate VC=====================================================
- (IBAction)cSliderChanged:(id)sender
{
    UISlider *s = (UISlider*)sender;
    contrast = s.value;
    [self getProcessedImageBkgd];
    _conLabel.text = [NSString stringWithFormat:@"Contrast   %3.2f",contrast];
}


//=============AddTemplate VC=====================================================
- (IBAction)removeColorSelect:(id)sender
{
    removeColor = !removeColor;
    if (removeColor)
    {
        saturation = 0.0;
        [_removeColorButton setTitle:@"Restore Color" forState:UIControlStateNormal];
    }
    else
    {
        saturation = 1.0;
        [_removeColorButton setTitle:@"Remove Color" forState:UIControlStateNormal];
    }
    [self getProcessedImageBkgd];


}
@end
