//
//  SettingPushCellTableViewCell.m
//  SQuInt2014
//
//  Created by csjan on 9/9/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import "SettingPushCellTableViewCell.h"

@implementation SettingPushCellTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)push_status_switch_tap:(UISwitch *)sender {
}
@end