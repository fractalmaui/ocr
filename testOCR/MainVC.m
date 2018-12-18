//
//  MainVC.m
//  testOCR
//
//  Created by Dave Scruton on 12/5/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import "MainVC.h"

@interface MainVC ()

@end

@implementation MainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    int xi,yi,xs,ys;
    xs = viewWid;
    ys = 60;
    xi = 0;
    yi = viewHit - ys;
    nav = [[NavButtons alloc] initWithFrameAndCount: CGRectMake(xi, yi, xs, ys) : 4];
    nav.delegate = self;
    [self.view addSubview: nav];
    [self setupNavBar];


}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


//=============OCR VC=====================================================
-(void) loadView
{
    [super loadView];
    CGSize csz   = [UIScreen mainScreen].bounds.size;
    viewWid = (int)csz.width;
    viewHit = (int)csz.height;
    viewW2  = viewWid/2;
    viewH2  = viewHit/2;
}
//==========feedVC=================================================================
- (void)viewDidAppear:(BOOL)animated {
    //NSLog(@"Feed viewDidAppear...");
    [super viewDidAppear:animated];



    [self performSegueWithIdentifier:@"templateSegue" sender:@"mainVC"];
}

#define NAV_HOME_BUTTON 0
#define NAV_DB_BUTTON 1
#define NAV_SETTINGS_BUTTON 2
#define NAV_SETTINGS2_BUTTON 3

//==========FeedVC=========================================================================
-(void) setupNavBar
{
    // Menu Button...
    [nav setHotNot         : NAV_HOME_BUTTON : [UIImage imageNamed:@"HamburgerNOT"]  :
     [UIImage imageNamed:@"HamburgerHOT"] ];
    [nav setLabelText      : NAV_HOME_BUTTON : NSLocalizedString(@"MENU",nil)];
    [nav setLabelTextColor : NAV_HOME_BUTTON : [UIColor blackColor]];
    [nav setHidden         : NAV_HOME_BUTTON : FALSE];
    // DB access button...
    [nav setHotNot         : NAV_DB_BUTTON : [UIImage imageNamed:@"dbNOT"]  :
     [UIImage imageNamed:@"dbHOT"] ];
    //[nav setCropped        : NAV_DB_BUTTON : 0.01 * PORTRAIT_PERCENT];
    [nav setLabelText      : NAV_DB_BUTTON : NSLocalizedString(@"DB",nil)];
    [nav setLabelTextColor : NAV_DB_BUTTON : [UIColor blackColor]];
    [nav setHidden         : NAV_DB_BUTTON : FALSE];
    // other button...
    [nav setHotNot         : NAV_SETTINGS_BUTTON : [UIImage imageNamed:@"gearHOT"]  :
     [UIImage imageNamed:@"gearNOT"] ];
    [nav setLabelText      : NAV_SETTINGS_BUTTON : NSLocalizedString(@"Settings",nil)];
    [nav setLabelTextColor : NAV_SETTINGS_BUTTON : [UIColor blackColor]];
    [nav setHidden         : NAV_SETTINGS_BUTTON : FALSE]; //10/16 show create even logged out...

    [nav setHotNot         : NAV_SETTINGS2_BUTTON : [UIImage imageNamed:@"gearHOT"]  :
     [UIImage imageNamed:@"gearNOT"] ];
    [nav setLabelText      : NAV_SETTINGS2_BUTTON : NSLocalizedString(@"Settings",nil)];
    [nav setLabelTextColor : NAV_SETTINGS2_BUTTON : [UIColor blackColor]];
    [nav setHidden         : NAV_SETTINGS2_BUTTON : FALSE]; //10/16 show create even logged out...

    [nav setSolidBkgdColor:[UIColor whiteColor] :1];
    
    //REMOVE FOR FINAL DELIVERY
    //    vn = [[UIVersionNumber alloc] initWithPlacement:UI_VERSIONNUMBER_TOPRIGHT];
    //    [nav addSubview:vn];
    
}


#pragma mark - NavButtonsDelegate
//==========FeedVC=========================================================================
-(void)  didSelectNavButton: (int) which
{
    NSLog(@"   didselectNavButton %d",which);
    // [_sfx makeTicSoundWithPitch : 8 : 50 + which];
    
    if (which == 0) //THis is now a multi-function popup...
    {
        NSLog(@"b0");
        //[self performSegueWithIdentifier:@"cloudSegue" sender:@"feedCell"];
        
    }
    else if (which == 1) //THis is now a multi-function popup...
    {
        NSLog(@"db");
        //[self performSegueWithIdentifier:@"cloudSegue" sender:@"feedCell"];
        
    }
    if (which == 3) //THis is now a multi-function popup...
    {
        NSLog(@"settings");
        [self performSegueWithIdentifier:@"templateSegue" sender:@"mainVC"];
        
    }

} //end didSelectNavButton


@end
