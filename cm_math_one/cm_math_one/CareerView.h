//
//  CareerView.h
//  cm_math_one
//
//  Created by csjan on 6/17/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CareerView : UIViewController
@property (strong, nonatomic) IBOutlet UITableView *careerTable;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *addCareerButton;
- (IBAction)addCareerButtonTap:(UIBarButtonItem *)sender;


- (void)processData: (NSArray *) results;
@property UIRefreshControl *pullrefresh;

@end
