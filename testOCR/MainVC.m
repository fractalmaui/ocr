//
//  MainVC.m
//  testOCR
//
//  Created by Dave Scruton on 12/5/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//
// PDF Image conversion?
//   https://github.com/a2/FoodJournal-iOS/tree/master/Pods/UIImage%2BPDF/UIImage%2BPDF


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

    
    // if you're going to use local notifications, you must request permission
    
   //DO I NEED THIS? UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil];
   //DO I NEED THIS? [[UIApplication sharedApplication] registerUserNotificationSettings:settings];


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
    //NSLog(@"mainvc viewDidAppear...");
    [super viewDidAppear:animated];



   // [self performSegueWithIdentifier:@"addTemplateSegue" sender:@"mainVC"];
}

#define NAV_HOME_BUTTON 0
#define NAV_DB_BUTTON 1
#define NAV_SETTINGS_BUTTON 2
#define NAV_BATCH_BUTTON 3

//=============OCR VC=====================================================
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

    [nav setHotNot         : NAV_BATCH_BUTTON : [UIImage imageNamed:@"multiNOT"]  :
     [UIImage imageNamed:@"multiHOT"] ];
    [nav setLabelText      : NAV_BATCH_BUTTON : NSLocalizedString(@"Batch",nil)];
    [nav setLabelTextColor : NAV_BATCH_BUTTON : [UIColor blackColor]];
    [nav setHidden         : NAV_BATCH_BUTTON : FALSE]; //10/16 show create even logged out...

    [nav setSolidBkgdColor:[UIColor whiteColor] :1];
    
    //REMOVE FOR FINAL DELIVERY
    //    vn = [[UIVersionNumber alloc] initWithPlacement:UI_VERSIONNUMBER_TOPRIGHT];
    //    [nav addSubview:vn];
    
}


//=============OCR VC=====================================================
-(void) testBatchShite
{
    if ([DBClientsManager authorizedClient] || [DBClientsManager authorizedTeamClient])
    {
        NSLog(@" dropbox authorized...");
        DropboxTools *dbt = [DropboxTools sharedInstance];
        [dbt setParent:self];
        [dbt getBatchList];
    }
    else
    {
        NSLog(@" need to be authorized...");
        [DBClientsManager authorizeFromController:[UIApplication sharedApplication]
                                       controller:self
                                          openURL:^(NSURL *url) {
                                              [[UIApplication sharedApplication] openURL:url];
                                          }];
        
    }
    

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
        [self testit];

        //[self performSegueWithIdentifier:@"cloudSegue" sender:@"feedCell"];
        
    }
    else if (which == 1) //THis is now a multi-function popup...
    {
        NSLog(@"db");
        [self performSegueWithIdentifier:@"dbSegue" sender:@"mainVC"];
        
    }
    else if (which == 2) //Templates / settings?
    {
        NSLog(@"test");
        [self performSegueWithIdentifier:@"templateSegue" sender:@"mainVC"];
//        [self performSegueWithIdentifier:@"addTemplateSegue" sender:@"mainVC"];
        
    }
    if (which == 3) //batch
    {
        NSLog(@"batch");
        [self testBatchShite];
        
      //  [self performSegueWithIdentifier:@"templateSegue" sender:@"mainVC"];
        
    }

} //end didSelectNavButton

-(void) testit
{
  //  NSString *gd = @"https://drive.google.com/open?id=1UF9Yh7kRNX8EuSzrLSSdCN00QO9TzVb4";
//    [self downloadPDF:gd];
    // Get the PDF Data from the url in a NSData Object
//    NSData *pdfData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:gd]];
//    NSLog(@" data is %@",pdfData);
   // UIImage *img = [ UIImage imageWithPDFURL:url atSize:CGSizeMake( 60, 60 ) atPage:1 ];

}







// https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_pdf/dq_pdf.html


// This produces a file but it doesn't open up in acrobat
-(void) downloadPDF : (NSString *) urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@" download PDF from [%@]",urlString);
    [[SessionManager sharedSession] startDownload:url];
    
}


@end
