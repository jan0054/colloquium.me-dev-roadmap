//
//  LaunchView.h
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import <ParseUI.h>
#import "UserPreferenceView.h"
#import "TutorialViewController.h"

@interface LaunchView : UIViewController<PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate, prefDelegateProtocol, tutorialDelegate>

@end
