//
//  activityCell.h
//  testOCR
//
//  Created by Dave Scruton on 12/27/18.
//  Copyright © 2018 huedoku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface activityCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;
@property (weak, nonatomic) IBOutlet UILabel *bottomLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end
