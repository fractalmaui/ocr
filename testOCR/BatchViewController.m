//
//   ____        _       _  __     ______
//  | __ )  __ _| |_ ___| |_\ \   / / ___|
//  |  _ \ / _` | __/ __| '_ \ \ / / |
//  | |_) | (_| | || (__| | | \ V /| |___
//  |____/ \__,_|\__\___|_| |_|\_/  \____|
//
//  BatchViewController.m
//  testOCR
//
//  Created by Dave Scruton on 12/21/18.
//  Copyright © 2018 Beyond Green Partners. All rights reserved.
//

#import "BatchViewController.h"



@implementation BatchViewController

#define NOCAN_RUN_ALL_BATCHES

//=============DB VC=====================================================
-(id)initWithCoder:(NSCoder *)aDecoder {
    if ( !(self = [super initWithCoder:aDecoder]) ) return nil;

    bbb = [BatchObject sharedInstance];
    bbb.delegate = self;
    [bbb setParent:self];
    vv  = [Vendors sharedInstance];
    authorized = FALSE;
    return self;
}



//=============Batch VC=====================================================
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _activityIndicator.hidden = FALSE;
    [_activityIndicator startAnimating];
    _titleLabel.text = @"Getting Batch Info...";
    _batchTableLabel.text = @"...";
    [bbb getBatchCounts];
}

//=============Batch VC=====================================================
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //Check for authorization...
    if ([DBClientsManager authorizedClient] || [DBClientsManager authorizedTeamClient])
    {
        //NSLog(@" dropbox authorized...");
        authorized = TRUE;
        bbb.authorized = TRUE;
        
        
    } //end auth OK
    else
    {
        //NSLog(@" need to be authorized...");
        [DBClientsManager authorizeFromController:[UIApplication sharedApplication]
                                       controller:self
                                          openURL:^(NSURL *url) {
                                              [[UIApplication sharedApplication] openURL:url];
                                          }];
    } //End need auth

} //end viewDidAppear

//=============Batch VC=====================================================
-(void) dismiss
{
    //[_sfx makeTicSoundWithPitch : 8 : 52];
    [self dismissViewControllerAnimated : YES completion:nil];
    
}

//=============AddTemplate VC=====================================================
-(void) updateUI
{
   // NSLog(@" updateui step %d showr %d",step,showRotatedImage);
    NSString *s = @"Staged Files by Vendor:\n\n";
    for (NSString *vn in vv.vFolderNames)
    {
        int vc = [bbb getVendorFileCount:vn];
        //NSLog(@" v[%@]: %d",vn,vc);
        s = [s stringByAppendingString:[NSString stringWithFormat:@"%@ :%d\n",vn,vc]];
        
    }
    _batchTableLabel.text = s;
    
} //end updateUI

//=============Batch VC=====================================================
- (IBAction)cancelSelect:(id)sender
{
    [self dismiss];
}

//=============Batch VC=====================================================
- (IBAction)runSelect:(id)sender {
    if (!authorized) return ; //can't get at dropbox w/o login! 
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:
                                NSLocalizedString(@"Run one or more Batches...",nil)
                                                                   message:nil
                                                            preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *actions[MAX_POSSIBLE_VENDORS]; //Up to 16 vendors...

    int i = 0;
    int vindex = 0;
    for (NSString *s in vv.vNames)
    {
        int vc = [bbb getVendorFileCount:vv.vFolderNames[vindex]];
        if (vc > 0) //Don't add a batch run option for empty batch folders!
        {
            actions[i] = [UIAlertAction actionWithTitle:s
                                                  style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                      self->vendorName = s;
                                                      self->_activityIndicator.hidden = FALSE;
                                                      [self->_activityIndicator startAnimating];
                                                      [self->bbb runOneOrMoreBatches : s : i];
                                                  }];
            i++;
            if (i >= MAX_POSSIBLE_VENDORS) break;
        }
        vindex++; //Update vendor index (for checking vendor filecounts)
    }
#ifdef CAN_RUN_ALL_BATCHES
    UIAlertAction *allAction    = [UIAlertAction actionWithTitle:NSLocalizedString(@"Run All",nil)
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                               self->_activityIndicator.hidden = FALSE;
                                                               [self->_activityIndicator startAnimating];
                                                               [self->bbb runOneOrMoreBatches:@"":-1];
                                                           }];
#endif
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel",nil)
                                                           style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                                           }];
    //DHS 3/13: Add owner's ability to delete puzzle
    for (int ii = 0;ii<i;ii++) [alert addAction:actions[ii]];
#ifdef CAN_RUN_ALL_BATCHES
    [alert addAction:allAction];
#endif
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

#pragma mark - batchObjectDelegate

//=============Batch VC=====================================================
-(void) didGetBatchCounts
{
    [self updateUI];
    _activityIndicator.hidden = TRUE;
    [_activityIndicator stopAnimating];
    _titleLabel.text = @"Batch Processor Ready";


}

//=============Batch VC=====================================================
- (void)didCompleteBatch
{
    _activityIndicator.hidden = TRUE;
    [_activityIndicator stopAnimating];
    _titleLabel.text = @"Batch Completed!";
}

//=============Batch VC=====================================================
- (void)didFailBatch
{
    NSLog(@" batch FAILURE!");
    _activityIndicator.hidden = TRUE;
    [_activityIndicator stopAnimating];
}

//=============Batch VC=====================================================
- (void)batchUpdate : (NSString *) s
{
    _titleLabel.text = s;
}


@end
