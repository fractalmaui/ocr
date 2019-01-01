//
//   __  __       _    __     ______
//  |  \/  | __ _(_)_ _\ \   / / ___|
//  | |\/| |/ _` | | '_ \ \ / / |
//  | |  | | (_| | | | | \ V /| |___
//  |_|  |_|\__,_|_|_| |_|\_/  \____|
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

//=============OCR MainVC=====================================================
-(id)initWithCoder:(NSCoder *)aDecoder {
    if ( !(self = [super initWithCoder:aDecoder]) ) return nil;
    act = [[ActivityTable alloc] init];
    act.delegate = self;
    emptyIcon = [UIImage imageNamed:@"emptyDoc.jpg"];
    dbIcon = [UIImage imageNamed:@"dbNOT.png"];
    batchIcon = [UIImage imageNamed:@"multiNOT.png"];
    versionNumber = [[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString *)kCFBundleVersionKey];
    oc = [OCRCache sharedInstance];

    //Test only, built-in OCR crap...
    [self loadBuiltinOCRToCache];

    return self;
}

//=============OCR MainVC=====================================================
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    int xi,yi,xs,ys;
    xs = viewWid;
    ys = 80;
    xi = 0;
    yi = viewHit - ys;
    nav = [[NavButtons alloc] initWithFrameAndCount: CGRectMake(xi, yi, xs, ys) : 4];
    nav.delegate = self;
    [self.view addSubview: nav];
    [self setupNavBar];

    _table.delegate = self;
    _table.dataSource = self;
    
    // if you're going to use local notifications, you must request permission
    
   //DO I NEED THIS? UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert categories:nil];
   //DO I NEED THIS? [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    

}



//=============OCR MainVC=====================================================
-(void) loadView
{
    [super loadView];
    CGSize csz   = [UIScreen mainScreen].bounds.size;
    viewWid = (int)csz.width;
    viewHit = (int)csz.height;
    viewW2  = viewWid/2;
    viewH2  = viewHit/2;
    
}

//=============OCR MainVC=====================================================
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [act readActivitiesFromParse:nil :nil];
}


//=============OCR MainVC=====================================================
- (void)viewDidAppear:(BOOL)animated {
    //NSLog(@"mainvc viewDidAppear...");
    [super viewDidAppear:animated];
    _versionLabel.text = [NSString stringWithFormat:@"version %@",versionNumber];
   // [self testit];

    //[self performSegueWithIdentifier:@"templateSegue" sender:@"mainVC"];

    //[self performSegueWithIdentifier:@"batchSegue" sender:@"mainVC"];
}


//=============OCR MainVC=====================================================
-(void) menu
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:
                                NSLocalizedString(@"Main Functions",nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Add Template",nil)
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              [self performSegueWithIdentifier:@"addTemplateSegue" sender:@"mainVC"];
                                                          }];
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Edit Template",nil)
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              [self performSegueWithIdentifier:@"templateSegue" sender:@"mainVC"];
                                                          }];
    UIAlertAction *thirdAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Clear OCR Cache",nil)
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               [self clearCacheMenu];
                                                           }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           }];
    //DHS 3/13: Add owner's ability to delete puzzle
    [alert addAction:firstAction];
    [alert addAction:secondAction];
    [alert addAction:thirdAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];

} //end menu

//=============OCR MainVC=====================================================
// if you click on a batch item, this gets invoked
// TRY CHANGING TITLE FONT SIZE AND COLOR
//   https://stackoverflow.com/questions/31662591/swift-how-to-change-uialertcontrollers-title-color
//   https://exceptionshub.com/uialertcontroller-change-font-color.html
//  This looks the best
//    https://stackoverflow.com/questions/26460706/uialertcontroller-custom-font-size-color
-(void) batchListChoiceMenu
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:
                                NSLocalizedString(@"Batch Retreival",nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *firstAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Get EXP records",nil)
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              self->stype = @"E";
                                                              [self performSegueWithIdentifier:@"dbSegue" sender:@"mainVC"];
                                                          }];
    UIAlertAction *secondAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Get Invoices",nil)
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               self->stype = @"I";
                                                               [self performSegueWithIdentifier:@"dbSegue" sender:@"mainVC"];
                                                           }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           }];
    //DHS 3/13: Add owner's ability to delete puzzle
    [alert addAction:firstAction];
    [alert addAction:secondAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
    
} //end menu


//=============OCR MainVC=====================================================
// Yes/No for cache clear...
-(void) clearCacheMenu
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:
                                NSLocalizedString(@"Clear Cache? (Cannot be undone!)",nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    UIAlertAction *yesAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"YES",nil)
                                                          style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                              [self->oc clearHardCore];
                                                          }];
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"NO",nil)
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           }];
    //DHS 3/13: Add owner's ability to delete puzzle
    [alert addAction:yesAction];
    [alert addAction:noAction];
    [self presentViewController:alert animated:YES completion:nil];
    
} //end menu




#define NAV_HOME_BUTTON 0
#define NAV_DB_BUTTON 1
#define NAV_SETTINGS_BUTTON 2
#define NAV_BATCH_BUTTON 3

//=============OCR MainVC=====================================================
-(void) setupNavBar
{
    // Menu Button...
    [nav setHotNot         : NAV_HOME_BUTTON : [UIImage imageNamed:@"HamburgerHOT"]  :
     [UIImage imageNamed:@"HamburgerNOT"] ];
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


//=============OCR MainVC=====================================================
// Handles last minute VC property setups prior to segues
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //NSLog(@" prepareForSegue: %@ sender %@",[segue identifier], sender);
    if([[segue identifier] isEqualToString:@"addTemplateSegue"])
    {
        AddTemplateViewController *vc = (AddTemplateViewController*)[segue destinationViewController];
        vc.step = 0;
        vc.needPicker = TRUE;	
    }
    else if([[segue identifier] isEqualToString:@"dbSegue"])
    {
        DBViewController *vc = (DBViewController*)[segue destinationViewController];
        vc.actData    = sdata; //Pass selected objectID's from activity, if any...
        vc.searchType = stype;
    }
}


#pragma mark - UITableViewDelegate

//=============OCR MainVC=====================================================
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    int row = (int)indexPath.row;
    activityCell *cell = (activityCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
    {
        cell = [[activityCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    NSString *atype = [act getType:row];
    NSString *adata = [act getData:row];

    UIImage *ii = emptyIcon;
    if ([atype.lowercaseString containsString:@"batch"]) ii = batchIcon;
    
    NSDate *adate = [act getDate:row];
    NSDateFormatter * formatter =  [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"MM/dd/yyyy  HH:mmv:SS"];
    NSString *sfd = [formatter stringFromDate:adate];

    cell.topLabel.text    = atype;
    cell.bottomLabel.text = adata;
    cell.icon.image       = ii;
    cell.dateLabel.text   = sfd;
    return cell;
} //end cellForRowAtIndexPath


//=============OCR MainVC=====================================================
- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [act getReadCount];
}

//=============OCR MainVC=====================================================
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
}

//==========FeedVC=========================================================================
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = (int)indexPath.row;
    sdata  = [act getData:row];
    [self batchListChoiceMenu];
}

#pragma mark - NavButtonsDelegate
//=============OCR MainVC=====================================================
-(void)  didSelectNavButton: (int) which
{
    //NSLog(@"   didselectNavButton %d",which);
    // [_sfx makeTicSoundWithPitch : 8 : 50 + which];
    
    if (which == 0) //THis is now a multi-function popup...
    {
        [self menu];
        //[self performSegueWithIdentifier:@"cloudSegue" sender:@"feedCell"];
    }
    else if (which == 1) //THis is now a multi-function popup...
    {
        sdata = @""; //No special objects to look up...
        [self performSegueWithIdentifier:@"dbSegue" sender:@"mainVC"];
    }
    else if (which == 2) //Templates / settings?
    {
        [self performSegueWithIdentifier:@"templateSegue" sender:@"mainVC"];
    }
    if (which == 3) //batch
    {
        [self performSegueWithIdentifier:@"batchSegue" sender:@"mainVC"];
        
    }

} //end didSelectNavButton

//=============OCR MainVC=====================================================
-(void) loadBuiltinOCRToCache
{
    NSString *fname = @"beef";
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:fname ofType:@"txt" inDirectory:@"txt"];
    NSURL *url = [NSURL fileURLWithPath:path];
    NSString *fileContentsAscii = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:&error];
    NSString *fullImageFname = @"hawaiiBeefInvoice.jpg";
    [oc addOCRTxtWithRect : fullImageFname : CGRectMake(0, 0, 1275, 1650) : fileContentsAscii];

    fname = @"hfm";
    path = [[NSBundle mainBundle] pathForResource:fname ofType:@"txt" inDirectory:@"txt"];
    url = [NSURL fileURLWithPath:path];
    fileContentsAscii = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:&error];
    fullImageFname = @"hfm90.jpg";
    [oc addOCRTxtWithRect : fullImageFname : CGRectMake(0, 0, 1777, 1181) : fileContentsAscii];
}

//=============OCR MainVC=====================================================
-(NSDictionary*) readTxtToJSON : (NSString *) fname
{
    NSError *error;
    NSArray *sItems;
    NSString *fileContentsAscii;
    NSString *path = [[NSBundle mainBundle] pathForResource:fname ofType:@"txt" inDirectory:@"txt"];
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *url = [NSURL fileURLWithPath:path];
    fileContentsAscii = [NSString stringWithContentsOfURL:url encoding:NSASCIIStringEncoding error:&error];
    if (fileContentsAscii == nil) return nil;
    sItems    = [fileContentsAscii componentsSeparatedByString:@"\n"];
    NSData *jsonData = [fileContentsAscii dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e;
    NSDictionary *jdict = [NSJSONSerialization JSONObjectWithData:jsonData options:nil error:&e];
    if (e != nil) NSLog(@" Error: %@",e.localizedDescription);
    return jdict;
}

//=============OCR MainVC=====================================================
-(void) testit
{
    NSDictionary *d    = [self readTxtToJSON:@"hfmpages"];
    OCRDocument *od = [[OCRDocument alloc] init];
    [od setupDocumentAndParseJDON : @"hfmpages" :d :FALSE];
    return;

   // NSDictionary *d    = [self readTxtToJSON:@"beef"];  //hfmpages"];
    NSArray *pr   = [d valueForKey:@"ParsedResults"];
    for (NSDictionary *dd in pr)
    {
        NSString *parsedText = [dd valueForKey:@"ParsedText"]; //Everything lumped together...
        NSDictionary *to     = [dd valueForKey:@"TextOverlay"];
        NSArray *lines       = [to valueForKey:@"Lines"]; //array of "Words"
        NSLog(@" duh");
        for (NSDictionary *ddd in lines)
        {
            //NSLog(@"duhh: %@",ddd);
            NSArray *words = [ddd valueForKey:@"Words"];
            for (NSDictionary *w in words) //loop over each word
            {
                OCRWord *ow = [[OCRWord alloc] init];
                [ow packFromDictionary:w];
                //NSLog(@" w %@",ow.wordtext);
                [ow dump];
               // [allWords addObject:ow];
            }
        }

    }

    
  //  NSString *gd = @"https://drive.google.com/open?id=1UF9Yh7kRNX8EuSzrLSSdCN00QO9TzVb4";
//    [self downloadPDF:gd];
    // Get the PDF Data from the url in a NSData Object
//    NSData *pdfData = [[NSData alloc] initWithContentsOfURL:[NSURL URLWithString:gd]];
//    NSLog(@" data is %@",pdfData);
   // UIImage *img = [ UIImage imageWithPDFURL:url atSize:CGSizeMake( 60, 60 ) atPage:1 ];

}







// https://developer.apple.com/library/archive/documentation/GraphicsImaging/Conceptual/drawingwithquartz2d/dq_pdf/dq_pdf.html


//=============OCR MainVC=====================================================
// This produces a file but it doesn't open up in acrobat
-(void) downloadPDF : (NSString *) urlString
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSLog(@" download PDF from [%@]",urlString);
    [[SessionManager sharedSession] startDownload:url];
    
}

#pragma mark - ActivityTableDelegate

//=============OCR MainVC=====================================================
- (void)didReadActivityTable
{
    //NSLog(@"  MainVC:got act table...");
    [_table reloadData];
}

//=============OCR MainVC=====================================================
- (void)errorReadingActivities : (NSString *)errmsg
{
    NSLog(@" act table err %@",errmsg);
}


@end
