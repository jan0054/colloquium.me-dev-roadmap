//
//  OverviewView.m
//  cm_math_one
//
//  Created by csjan on 7/22/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "OverviewView.h"
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"

@interface OverviewView ()

@end

PFUser *admin;
PFUser *eventSelf;
PFObject *currentEvent;
NSMutableArray *newsArray;

@implementation OverviewView
@synthesize pullrefresh;

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLeftMenuButton];
    newsArray = [[NSMutableArray alloc] init];
    self.noNewsLabel.hidden = YES;
    self.newsTable.tableFooterView = [[UIView alloc] init];
    if ([PFUser currentUser])
    {
        eventSelf = [PFUser currentUser];
    }
    
    //styling
    [self.organizerButton setTitleColor:[UIColor dark_button_txt] forState:UIControlStateNormal];
    self.timeLabel.textColor = [UIColor dark_primary];
    self.backgroundView.backgroundColor = [UIColor clearColor];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.timeLabel.backgroundColor = [UIColor clearColor];
    self.timeAndOrganizerBackground.backgroundColor = [UIColor clearColor];
    self.contentLabel.backgroundColor = [UIColor clearColor];
    self.attendanceBackground.backgroundColor = [UIColor clearColor];
    self.attendanceLabel.backgroundColor = [UIColor clearColor];
    self.organizerButton.backgroundColor = [UIColor clearColor];
    
    self.pullrefresh = [[UIRefreshControl alloc] init];
    [pullrefresh addTarget:self action:@selector(refreshctrl:) forControlEvents:UIControlEventValueChanged];
    [self.newsTable addSubview:pullrefresh];
}

- (void)refreshctrl:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *eventid = [defaults objectForKey:@"currentEventId"];
    [self getEvent:self withId:eventid];
    [(UIRefreshControl *)sender endRefreshing];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *eventid = [defaults objectForKey:@"currentEventId"];
    [self getEvent:self withId:eventid];
}

- (void)setupLeftMenuButton {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}

- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

- (IBAction)organizerButtonTap:(UIButton *)sender {
    NSString *mailstr = [NSString stringWithFormat:@"mailto://%@", admin[@"email"]];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:mailstr]];
}

- (IBAction)attendanceSwitchChanged:(UISwitch *)sender {
    if (!eventSelf)
    {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"alert_need_account", nil)
                                    message:NSLocalizedString(@"alert_sign_in", nil)
                                   delegate:nil
                          cancelButtonTitle:NSLocalizedString(@"alert_done", nil)
                          otherButtonTitles:nil] show];
        self.attendanceSwitch.on = NO;
    }
    else
    {
        NSLog(@"SWITCH:setting attendance to %@", self.attendanceSwitch.on ? @"YES" : @"NO");
        if (self.attendanceSwitch.on)
        {
            [self attendEvent];
        }
        else
        {
            [self cancelEvent];
        }
    }
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [newsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"newscell"];
    
    //data
    PFObject *announcement = [newsArray objectAtIndex:indexPath.row];
    PFUser *author = announcement[@"author"];
    cell.textLabel.text = announcement[@"content"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@", author[@"first_name"], author[@"last_name"]];
    
    return cell;
}

#pragma mark - Data

- (void)processEvent: (PFObject *) object  //callback for the event query
{
    //data source
    NSString *name = object[@"name"];
    NSString *content = object[@"content"];
    NSString *organizer = object[@"organizer"];
    admin = object[@"admin"];
    currentEvent = object;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateStyle:NSDateFormatterMediumStyle];
    [dateFormat setTimeZone:[NSTimeZone systemTimeZone]];
    [dateFormat setDateFormat: @"MMM-d"];
    NSDate *sdate = object[@"start_time"];
    NSDate *edate = object[@"end_time"];
    NSString *sstr = [dateFormat stringFromDate:sdate];
    NSString *estr = [dateFormat stringFromDate:edate];
    
    //interface
    self.timeLabel.text = [NSString stringWithFormat:@"%@ ~ %@", sstr, estr];
    self.nameLabel.text = name;
    self.contentLabel.text = content;
    [self.organizerButton setTitle:organizer forState:UIControlStateNormal];
    self.attendanceLabel.text = NSLocalizedString(@"overview_attend", nil);
    
    //followup stuff now that we have the event
    [self setupAttendance];
    [self getAnnouncements:self forEvent:currentEvent];
}

- (void)processData: (NSArray *) results  //callback for the news/announcement query
{
    [newsArray removeAllObjects];
    newsArray = [results mutableCopy];
    [self.newsTable reloadData];
    
    if (newsArray.count >0)
    {
        self.noNewsLabel.hidden = YES;
    }
    else
    {
        self.noNewsLabel.hidden = NO;
    }
}

- (void)setupAttendance  //determine initial position for the attendance switch
{
    if (!eventSelf)  //set to no if not logged in
    {
        self.attendanceSwitch.on = NO;
    }
    else  //search the attendance array if logged in
    {
        NSArray *attendance = eventSelf[@"attendance"];
        int match = 0;
        for (PFObject *event in attendance)
        {

            if ([currentEvent.objectId isEqualToString:event.objectId])
            {
                match = 1;
                NSLog(@"attendance match found:%@", event.objectId);
            }
        }
        if (match == 1)
        {
            //already set to attend
            NSLog(@"Setting switch to ON");
            self.attendanceSwitch.on = YES;
        }
        else
        {
            //wasn't attending
            NSLog(@"Nothing found, switch set to OFF");
            self.attendanceSwitch.on = NO;
        }
    }
}

- (void)attendEvent
{
    NSLog(@"Attending Event in progress...");
    [eventSelf addObject:currentEvent forKey:@"attendance"];
    [eventSelf saveEventually:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            NSLog(@"DONE: Successfully saved user attendance add, doing the event add now:");
            [currentEvent addObject:eventSelf forKey:@"attendees"];
            [currentEvent saveEventually:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded)
                {
                    NSLog(@"Successfully saved event attendance add");
                }
                else
                {
                    NSLog(@"Error saving event attendance add: %@", error);
                }
            }];
        }
        else
        {
            NSLog(@"DONE: Error saving user attendance add: %@", error);
        }
    }];
}

- (void)cancelEvent
{
    NSLog(@"Cancelling Event in progress...");
    [eventSelf removeObject:currentEvent forKey:@"attendance"];
    [eventSelf saveEventually:^(BOOL succeeded, NSError * _Nullable error) {
        if (succeeded)
        {
            NSLog(@"DONE: Successfully saved user attendance remove, doing the event remove now:");
            [currentEvent removeObject:eventSelf forKey:@"attendees"];
            [currentEvent saveEventually:^(BOOL succeeded, NSError * _Nullable error) {
                if (succeeded)
                {
                    NSLog(@"Successfully saved event attendance remove");
                }
                else
                {
                    NSLog(@"Error saving event attendance remove: %@", error);
                }
            }];
        }
        else
        {
            NSLog(@"DONE: Error saving user attendance remove: %@", error);
        }
    }];
}

@end