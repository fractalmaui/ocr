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
#import "ActivityTable.h"
#import "activityCell.h"
#import "AddTemplateViewController.h"
#import "DBViewController.h"
#import "NavButtons.h"
#import "SessionManager.h"
#import "OCRCache.h"
#import "OCRDocument.h"
NS_ASSUME_NONNULL_BEGIN

@interface MainVC : UIViewController <NavButtonsDelegate,ActivityTableDelegate,
                    UITableViewDelegate,UITableViewDataSource>
{
    NavButtons *nav;
    int viewWid,viewHit,viewW2,viewH2;
    ActivityTable *act;
    NSString *versionNumber;
    UIImage *emptyIcon;
    UIImage *dbIcon;
    UIImage *batchIcon;
    int selectedRow;
    NSString* stype;
    NSString* sdata;

    OCRCache *oc;
}
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (weak, nonatomic) IBOutlet UITableView *table;

@property (weak, nonatomic) IBOutlet UILabel *versionLabel;

@end

NS_ASSUME_NONNULL_END
