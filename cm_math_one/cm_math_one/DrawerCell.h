//
//  DrawerCell.h
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface DrawerCell : UITableViewCell
@property (strong, nonatomic) IBOutlet UILabel *drawerTitle;
@property (strong, nonatomic) IBOutlet UIImageView *drawerImage;
@property (strong, nonatomic) IBOutlet UIView *drawerBackground;
@property (weak, nonatomic) IBOutlet UIView *lowerSeparator;
@property (weak, nonatomic) IBOutlet UIView *upperSeparator;

@property NSString *eventName;
@property NSString *eventId;
@property PFObject *eventObject;

@end
