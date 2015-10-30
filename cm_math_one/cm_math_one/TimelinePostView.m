//
//  TimelinePostView.m
//  cm_math_one
//
//  Created by csjan on 6/29/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "TimelinePostView.h"
#import <Parse/Parse.h>
#import "UIColor+ProjectColors.h"
#import "UIViewController+ParseQueries.h"
#import "GKImagePicker.h"

@interface TimelinePostView ()<GKImagePickerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (nonatomic, strong) GKImagePicker *imagePicker;

@end

BOOL photoSet;

@implementation TimelinePostView

#pragma mark - Interface

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //styling
    UIImage *cam_img = [UIImage imageNamed:@"camera48.png"];
    cam_img = [cam_img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.addPhotoButton setTintColor:[UIColor dark_accent]];
    [self.addPhotoButton setImage:cam_img forState:UIControlStateNormal];
    UIImage *key_img = [UIImage imageNamed:@"key_down48.png"];
    key_img = [key_img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.keyboardButton setTintColor:[UIColor dark_accent]];
    [self.keyboardButton setImage:key_img forState:UIControlStateNormal];
    UIImage *cancel_img = [UIImage imageNamed:@"cross64.png"];
    cancel_img = [cancel_img imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [self.cancelPhotoButton setTintColor:[UIColor whiteColor]];
    [self.cancelPhotoButton setImage:cancel_img forState:UIControlStateNormal];
    
    self.horizontalBarBackground.backgroundColor = [UIColor whiteColor];
    self.cancelPhotoButton.backgroundColor = [UIColor dark_accent];
    self.inputTextView.backgroundColor = [UIColor clearColor];
    [self.addPhotoButton setTitleColor:[UIColor dark_primary] forState:UIControlStateNormal];
    self.cancelPhotoButton.layer.cornerRadius = 16.0;
    self.postImageView.backgroundColor = [UIColor clearColor];
    
    //init
    self.cancelPhotoButton.hidden = YES;
    self.cancelPhotoButton.userInteractionEnabled = NO;
    self.inputTextViewToBottom.active = NO;
    self.imageRatio.active = NO;
    self.keyboardButton.hidden = YES;
    photoSet = NO;
    

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self.inputTextView becomeFirstResponder];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (IBAction)addPhotoButtonTap:(UIButton *)sender {
    if (photoSet)
    {
        self.postImageView.image = nil;
        photoSet = NO;
        self.imageRatio.active = NO;
        [self.addPhotoButton setTitle:NSLocalizedString(@"post_add_photo", nil) forState:UIControlStateNormal];
        [self.inputTextView resignFirstResponder];
        [self.view setNeedsLayout];
        [self.view setNeedsUpdateConstraints];
        [self.view setNeedsDisplay];
    }
    else
    {
        self.imagePicker = [[GKImagePicker alloc] init];
        self.imagePicker.cropSize = CGSizeMake(640, 640);
        self.imagePicker.delegate = self;
        self.imagePicker.useFrontCameraAsDefault = NO;
        
        [self.imagePicker showActionSheetOnViewController:self onPopoverFromView:sender];
    }
}

- (IBAction)keyboardButtonTap:(UIButton *)sender {
    [self.inputTextView resignFirstResponder];
}

- (IBAction)cancelPhotoButtonTap:(UIButton *)sender {
    /*
    self.postImageView.image = nil;
    photoSet = NO;
    self.imageRatio.active = NO;
    self.cancelPhotoButton.hidden = YES;
    self.cancelPhotoButton.userInteractionEnabled = NO;
    [self.inputTextView resignFirstResponder];
    [self.view setNeedsLayout];
    [self.view setNeedsUpdateConstraints];
    [self.view setNeedsDisplay];
     */
}

- (IBAction)sendPostButtonTap:(UIBarButtonItem *)sender {
    if ([PFUser currentUser] && self.inputTextView.text.length>0)
    {
        [self doProcessPost];
        UINavigationController *navCon = self.navigationController;
        [navCon popViewControllerAnimated:YES];
    }
}

#pragma mark - Data

- (void)doProcessPost
{
    CGSize img_param = CGSizeMake(1080.0, 1080.0);
    UIImage *smallpic = [self shrinkImage:self.postImageView.image withSize:img_param];
    NSData *imageData = UIImagePNGRepresentation(smallpic);
    PFFile *imageFile = [PFFile fileWithName:[self generate_filename] data:imageData];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *eventid = [defaults objectForKey:@"currentEventId"];
    PFObject *event = [PFObject objectWithoutDataWithClassName:@"Event" objectId:eventid];
    [self sentPost:self withAuthor:[PFUser currentUser] withContent:self.inputTextView.text withImage:imageFile forEvent:event];
}

- (NSString *) generate_filename {
    PFUser *user = [PFUser currentUser];
    NSString *uname = user.username;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat: @"yyyyMMddHHmm"];
    NSString *dateString = [dateFormat stringFromDate:[NSDate date]];
    NSString *filename = [NSString stringWithFormat:@"%@%@.png",uname,dateString];
    return filename;
}

#pragma mark - Imaging

- (void)imagePicker:(GKImagePicker *)imagePicker pickedImage:(UIImage *)image{
    self.postImageView.image = image;
    photoSet = YES;
    [self.addPhotoButton setTitle:NSLocalizedString(@"post_remove_photo", nil) forState:UIControlStateNormal];
    self.imageRatio.active = YES;
}

- (UIImage *)shrinkImage:(UIImage *)image withSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *destImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return destImage;
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    NSLog(@"keyboard will show");
    self.keyboardButton.hidden = NO;
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    CGFloat height = keyboardFrame.size.height;
    if (photoSet)
    {
        self.inputTextViewToBottom.active = YES;
        //30 is up to how much of the top of the photo you want to show, 45 is the bottom bar height
        self.inputTextViewToBottom.constant = height+45+30;
        //self.textview_keyboard_spacing.constant = height+self.bottom_bar_height.constant+30;
        self.imageToBottomBar.active = NO;
        self.horizontalBarBottom.constant = height - 49;
    }
    else
    {
        self.horizontalBarBottom.constant = height - 49;
    }
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSLog(@"keyboard will hide");
    self.keyboardButton.hidden = YES;
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    CGFloat height = keyboardFrame.size.height;
    if (photoSet)
    {
        self.inputTextViewToBottom.active = NO;
        self.imageToBottomBar.active = YES;
        self.horizontalBarBottom.constant = 0;
    }
    else
    {
        self.inputTextViewToBottom.active = NO;
        self.imageToBottomBar.active = YES;
        self.horizontalBarBottom.constant = 0;
    }
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
    
}

@end