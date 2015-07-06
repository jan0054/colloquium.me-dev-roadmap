//
//  SettingsView.m
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "SettingsView.h"
#import <Parse/Parse.h>
#import "MMDrawerBarButtonItem.h"
#import "UIViewController+MMDrawerController.h"
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"
#import "SettingUserCell.h"
#import "SettingGenericCell.h"
#import "LoginView.h"
#import "SignUpView.h"
#import "UserPreferenceView.h"

@implementation SettingsView

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLeftMenuButton];
}

- (void)setupLeftMenuButton {
    MMDrawerBarButtonItem * leftDrawerButton = [[MMDrawerBarButtonItem alloc] initWithTarget:self action:@selector(leftDrawerButtonPress:)];
    [self.navigationItem setLeftBarButtonItem:leftDrawerButton];
}

- (void)leftDrawerButtonPress:(id)leftDrawerButtonPress {
    [self.mm_drawerController toggleDrawerSide:MMDrawerSideLeft animated:YES completion:nil];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (![PFUser currentUser])
    {
        return 5;
    }
    else
    {
        //add a user settings row
        return 6;
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingUserCell *userCell = [tableView dequeueReusableCellWithIdentifier:@"settingusercell"];
    SettingGenericCell *genericCell = [tableView dequeueReusableCellWithIdentifier:@"settinggenericcell"];
    
    NSString *userStatus = @"";
    NSString *secondaryStatus = @"";
    NSString *statusButton = @"";
    if ([PFUser currentUser])
    {
        PFUser *user = [PFUser currentUser];
        userStatus = [NSString stringWithFormat:@"Logged in as %@ %@", user[@"first_name"], user[@"last_name"]];
        secondaryStatus = @"Logout to switch users";
        statusButton = @"Log Out";
    }
    else
    {
        userStatus = @"Not logged in yet";
        secondaryStatus = @"Log in to access social features";
        statusButton = @"Log In";
    }
    
    switch (indexPath.row) {
        case 0:
            userCell.primaryLabel.text = userStatus;
            userCell.secondaryLabel.text = secondaryStatus;
            [userCell.userButton setTitle:statusButton forState:UIControlStateNormal | UIControlStateHighlighted];
            return userCell;
            break;
        case 1:
            return genericCell;
            break;
            
        default:
            return genericCell;
            break;
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}

- (IBAction)userButtonTap:(UIButton *)sender {
    if ([PFUser currentUser])
    {
        PFUser *user = [PFUser currentUser];

    }
    else
    {
        if (![PFUser currentUser])
        {
            [self log_in];
        }
        else
        {
            [self log_out];
            [self.settingTable reloadData];
        }
    }

}

-(void) log_out
{
    [PFUser logOut];
    // DIS-Associate the device with logged out user
    PFInstallation *installation = [PFInstallation currentInstallation];
    [installation removeObjectForKey:@"user"];
    [installation saveInBackground];
    NSLog(@"USER INSTALLATION DIS-ASSOCIATED: %@", installation.objectId);
    
}

-(void) log_in
{
    if (![PFUser currentUser])
    {
        // Customize the Log In View Controller
        LoginView *logInViewController = [[LoginView alloc] init];
        [logInViewController setDelegate:self];
        [logInViewController setFields: PFLogInFieldsDismissButton | PFLogInFieldsLogInButton | PFLogInFieldsSignUpButton | PFLogInFieldsUsernameAndPassword ];
        
        // Create the sign up view controller
        SignUpView *signUpViewController = [[SignUpView alloc] init];
        [signUpViewController setDelegate:self]; // Set ourselves as the delegate
        
        // Assign our sign up controller to be displayed from the login controller
        [logInViewController setSignUpController:signUpViewController];
        
        // Present the log in view controller
        [self presentViewController:logInViewController animated:YES completion:NULL];
    }
}

#pragma mark - User Management

// Sent to the delegate to determine whether the log in request should be submitted to the server.
- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
    // Check if both fields are completed
    if (username && password && username.length != 0 && password.length != 0) {
        return YES; // Begin login process
    }
    
    [[[UIAlertView alloc] initWithTitle:@"Error"
                                message:@"Please fill in all fields."
                               delegate:nil
                      cancelButtonTitle:@"Done"
                      otherButtonTitles:nil] show];
    return NO; // Interrupt login process
}

// Sent to the delegate when a PFUser is logged in.
- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
    
    [self completeOnboarding];
}

// Sent to the delegate when the log in attempt fails.
- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
    NSLog(@"Failed to log in...");
}

// Sent to the delegate when the log in screen is dismissed.
- (void)logInViewControllerDidCancelLogIn:(PFLogInViewController *)logInController {
    [self.navigationController popViewControllerAnimated:YES];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                    message:@"You can log in later from the Settings screen"
                                                   delegate:self
                                          cancelButtonTitle:@"Done"
                                          otherButtonTitles:nil];
    [alert show];
    
}

// Sent to the delegate to determine whether the sign up request should be submitted to the server.
- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
    BOOL informationComplete = YES;
    
    // loop through all of the submitted data
    for (id key in info) {
        NSString *field = [info objectForKey:key];
        if (!field || field.length == 0) { // check completion
            informationComplete = NO;
            break;
        }
    }
    
    // Display an alert if a field wasn't completed
    if (!informationComplete) {
        [[[UIAlertView alloc] initWithTitle:@"Error"
                                    message:@"Please fill in all fields."
                                   delegate:nil
                          cancelButtonTitle:@"Done"
                          otherButtonTitles:nil] show];
    }
    
    return informationComplete;
}

// Sent to the delegate when a PFUser is signed up.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
    [self completeOnboarding];
}

// Sent to the delegate when the sign up attempt fails.
- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
    NSLog(@"Failed to sign up with error: %@", error);
}

// Sent to the delegate when the sign up screen is dismissed.
- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
    NSLog(@"User dismissed the signUpViewController");
}

- (void) completeOnboarding
{
    // Associate the device with a user
    PFInstallation *installation = [PFInstallation currentInstallation];
    installation[@"user"] = [PFUser currentUser];
    [installation saveInBackground];
    NSLog(@"User associcated with Installation: %@ to %@",[PFUser currentUser].objectId, installation.objectId);
    
    // Dismiss the PFSignUpViewController
    [self dismissViewControllerAnimated:YES completion:^{
        NSLog(@"sign up / login controller dismissed");
        //pop up the user preference controller to setup stuff
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UserPreferenceView *controller = (UserPreferenceView *)[storyboard instantiateViewControllerWithIdentifier:@"userpreferenceview"];
        [self presentViewController:controller animated:YES completion:nil];
    }];
}

@end
