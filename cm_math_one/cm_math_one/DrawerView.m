//
//  DrawerView.m
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "DrawerView.h"
#import "UIViewController+MMDrawerController.h"
#import <Parse/Parse.h>
#import "DrawerCell.h"
#import "UIColor+ProjectColors.h"

@interface DrawerView ()

@end

NSIndexPath *currentIndex;

@implementation DrawerView

- (void)viewDidLoad {
    [super viewDidLoad];
    currentIndex = [NSIndexPath indexPathForRow:1 inSection:0];
    [self.tableView setContentInset:UIEdgeInsetsMake(35.0, 0.0, 0.0, 0.0)];
    self.tableView.tableFooterView = [[UIView alloc] init];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)viewDidLayoutSubviews {
    if ([self.tableView respondsToSelector:@selector(layoutMargins)]) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *eventNames = [defaults objectForKey:@"eventNames"];

    if (section == 0)
    {
        return 1+[eventNames count];
    }
    else
    {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    DrawerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"drawercell"];
    
    //styling
    cell.drawerBackground.backgroundColor = [UIColor clearColor];
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    [cell.drawerImage setTintColor:[UIColor dark_accent]];
    UIImage *img = [[UIImage alloc] init];
    
    //data
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *eventNames = [defaults objectForKey:@"eventNames"];
    NSString *name = @"";
    if (indexPath.section == 0 &&indexPath.row != 0)
    {
        name = [eventNames objectAtIndex:indexPath.row-1];
    }
    
    if (indexPath.section == 1)   //bottom 3 fixed rows
    {
        switch (indexPath.row) {
            case 0:
                cell.drawerTitle.text = @"Chat";
                img = [UIImage imageNamed:@"chat48"];
                img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.drawerImage.image = img;
                break;
            case 1:
                cell.drawerTitle.text = @"Career";
                img = [UIImage imageNamed:@"career48"];
                img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.drawerImage.image = img;
                break;
            case 2:
                cell.drawerTitle.text = @"Settings";
                img = [UIImage imageNamed:@"setting48"];
                img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.drawerImage.image = img;
                break;
            default:
                break;
        }
        return cell;
    }
    else     //dynamic event rows + first edit event row
    {
        switch (indexPath.row) {
            case 0:
                cell.drawerTitle.text = @"Edit Events";
                img = [UIImage imageNamed:@"addevent48"];
                img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.drawerImage.image = img;
                break;
            default:
                
                cell.drawerTitle.text = name;
                img = [UIImage imageNamed:@"event48"];
                img = [img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
                cell.drawerImage.image = img;
                break;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"DRAWER: selected indexpath %li - %li", (long)indexPath.section, (long)indexPath.row);
    
    if (currentIndex.row == indexPath.row && currentIndex.section == indexPath.section)
    {
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
        return;
    }
    
    UIViewController *centerViewController;
    
    if (indexPath.section == 1)   //bottom 3 fixed rows
    {
        switch (indexPath.row) {
            case 0:
                centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"conversation_nc"];
                break;
            case 1:
                centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"career_nc"];
                break;
            case 2:
                centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"settings_nc"];
                break;
            default:
                break;
        }
    }
    else     //dynamic event rows + first edit event row
    {
        switch (indexPath.row) {
            case 0:
                centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"eventchoose_nc"];
                break;
            default:
                centerViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"main_tc"];
                [self setCurrentEventIdForRow:indexPath.row-1];
                break;
        }
    }
    
    if (centerViewController) {
        currentIndex = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
        [self.mm_drawerController setCenterViewController:centerViewController withCloseAnimation:YES completion:nil];
    } else {
        [self.mm_drawerController closeDrawerAnimated:YES completion:nil];
    }
}

- (void) setCurrentEventIdForRow: (int)row
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *eventNames = [defaults objectForKey:@"eventNames"];
    NSString *name = [eventNames objectAtIndex:row];
    NSDictionary *eventDictionary = [defaults objectForKey:@"eventDictionary"];
    NSString *eid = [eventDictionary objectForKey:name];
    [defaults setObject:eid forKey:@"currentEventId"];
    [defaults synchronize];
}

- (void)updateEvents
{
    [self.tableView reloadData];
}

@end
