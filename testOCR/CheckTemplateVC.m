//
//  CheckTemplateVC.m
//  testOCR
//
//  Created by Dave Scruton on 12/26/18.
//  Copyright © 2018 huedoku. All rights reserved.
//

#import "CheckTemplateVC.h"

@interface CheckTemplateVC ()

@end

@implementation CheckTemplateVC

//=============CheckTemplate VC=====================================================
-(id)initWithCoder:(NSCoder *)aDecoder {
    if ( !(self = [super initWithCoder:aDecoder]) ) return nil;
    
    //   _versionNumber    = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    oto = [OCRTopObject sharedInstance];
    oto.delegate = self;

    return self;
}

//=============CheckTemplate VC=====================================================
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _imageView.image = _photo;
    _scrollView.delegate=self;
    oto.imageFileName = @"test.jpg";
    NSLog(@" NOTE: Filename needs to be added here at OCR call for cacheing!!");
    [oto performOCROnImage : oto.imageFileName : _photo : nil];
}

//=============CheckTemplate VC=====================================================
-(void) loadView
{
    [super loadView];
    CGSize csz   = [UIScreen mainScreen].bounds.size;
    viewWid = (int)csz.width;
    viewHit = (int)csz.height;
    viewW2  = viewWid/2;
    viewH2  = viewHit/2;

    int xi,yi,xs,ys;
    xs = viewWid;
    ys = xs;
    xi = viewW2 - xs/2;
    yi = 70;
    _scrollView.frame = CGRectMake(xi, yi, xs, ys);
    //Zoom up by 8x
    UIView *v = _imageView;
    int vw = v.bounds.size.width;
    int vh = v.bounds.size.height;
    CGAffineTransform t = v.transform;
    t = CGAffineTransformMakeScale(8, 8);
    v.transform = t;
    v.center = CGPointMake(vw*4, vh*4);
    _scrollView.contentSize = CGSizeMake(vw*8, vh*8);
    [_scrollView setContentOffset:CGPointMake(0,0) animated:NO];

    yi+= ys+10;
    xs = viewWid * 0.95;
    ys = 200; //Too Tall?
    xi = viewW2 - xs/2;
    _outputLabel.frame = CGRectMake(xi, yi, xs, ys);
    _outputLabel.text  = @"...";
}


//=============CheckTemplate VC=====================================================
-(void) dismiss
{
    //[_sfx makeTicSoundWithPitch : 8 : 52];
    [self dismissViewControllerAnimated : YES completion:nil];
    
}


//=============CheckTemplate VC=====================================================
- (IBAction)backSelect:(id)sender
{
    [self dismiss];
}

//=============CheckTemplate VC=====================================================
- (IBAction)nextSelect:(id)sender
{
}



//=============CheckTemplate VC=====================================================
-(UIView *) viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}



//=============CheckTemplate VC=====================================================


#pragma mark - OCRTopObjectDelegate

//=============(BatchObject)=====================================================
- (void)didPerformOCR : (NSString *) result
{
    NSLog(@" OCR OK");
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_outputLabel.text = [self->oto getParsedText];
    });

}


//=============(BatchObject)=====================================================
- (void)errorPerformingOCR : (NSString *) errMsg
{
    NSLog(@" OCR err %@",errMsg);
}

@end
