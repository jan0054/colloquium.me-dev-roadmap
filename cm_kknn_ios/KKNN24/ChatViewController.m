//
//  ChatViewController.m
//  SQuInt2014
//
//  Created by csjan on 4/21/14.
//  Copyright (c) 2014 tapgo. All rights reserved.
//

#import "ChatViewController.h"
#import "UIColor+ProjectColors.h"
#import "ChatMeCellTableViewCell.h"
#import "ChatYouCellTableViewCell.h"
#import "ChatBroadcastCell.h"
#import "UIViewController+ParseQueries.h"

@interface ChatViewController ()

@end

PFUser *currentUser;

@implementation ChatViewController

@synthesize chat_table_array;
@synthesize pullrefresh;
@synthesize participants;
@synthesize conversation;

#pragma mark - Interface

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //init
    self.chat_input_box.delegate = self;
    self.chat_table_array = [[NSMutableArray alloc] init];
    currentUser = [PFUser currentUser];
    self.curtainView.hidden = YES;
    self.curtainView.userInteractionEnabled = NO;
    self.optionsContainer.hidden = YES;
    self.optionsContainer.userInteractionEnabled = NO;
    
    //styling
    self.view.backgroundColor = [UIColor dark_primary];
    self.chat_table.backgroundColor = [UIColor clearColor];
    [self.send_chat_button setTitleColor:[UIColor light_button_txt] forState:UIControlStateNormal];
    [self.send_chat_button setTitleColor:[UIColor light_button_txt] forState:UIControlStateHighlighted];
    self.chat_table.estimatedRowHeight = 69;
    self.chat_table.rowHeight = UITableViewAutomaticDimension;
    
    //Pull To Refresh Controls
    self.pullrefresh = [[UIRefreshControl alloc] init];
    [pullrefresh addTarget:self action:@selector(refreshctrl:) forControlEvents:UIControlEventValueChanged];
    [self.chat_table addSubview:pullrefresh];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pushreload:) name:@"gotchatinapp" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    [self get_chat_info];
}

- (void) viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"gotchatinapp" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)refreshctrl:(id)sender
{
    [self get_chat_info];
    [(UIRefreshControl *)sender endRefreshing];
}

//dismiss keyboard when touched outside
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [[event allTouches] anyObject];
    if ([self.chat_input_box isFirstResponder] && [touch view] != self.chat_input_box) {
        [self.chat_input_box resignFirstResponder];
    }
    [super touchesBegan:touches withEvent:event];
}

- (IBAction)send_chat_button_tap:(UIButton *)sender {
    NSString *content = self.chat_input_box.text;
    if (content.length >=1) {
        NSLog(@"sending chat...");
        [self sendChat:self withAuthor:currentUser withContent:content withConversation:self.conversation];
    }
}

- (IBAction)editButtonTap:(UIBarButtonItem *)sender {
    [self toggleOptionView];
}

#pragma mark - TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"chat table count: %ld",(unsigned long)[self.chat_table_array count]);
    return [self.chat_table_array count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatMeCellTableViewCell *chatmecell = [tableView dequeueReusableCellWithIdentifier:@"chatmecell"];
    ChatYouCellTableViewCell *chatyoucell = [tableView dequeueReusableCellWithIdentifier:@"chatyoucell"];
    ChatBroadcastCell *broadcastcell = [tableView dequeueReusableCellWithIdentifier:@"broadcastcell"];
    
    //styling
    chatmecell.selectionStyle = UITableViewCellSelectionStyleNone;
    chatyoucell.selectionStyle = UITableViewCellSelectionStyleNone;
    broadcastcell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    //data
    PFObject *chat = [self.chat_table_array objectAtIndex:indexPath.row];
    PFUser *author = chat[@"author"];
    NSDate *date = chat.createdAt;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat: @"MMM-d HH:mm"];
    NSString *dateString = [dateFormat stringFromDate:date];
    NSString *contentString = chat[@"content"];
    BOOL theySaid;
    
    if ([author.objectId isEqualToString:currentUser.objectId])
    {
        theySaid = NO;
    }
    else
    {
        theySaid = YES;
    }
    
    NSNumber *bc = chat[@"broadcast"];
    int bcInt = [bc intValue];
    if (bcInt == 1)
    {
        broadcastcell.broadcastContentLabel.text = contentString;
        return broadcastcell;
    }
    else if (theySaid)
    {
        //msg is them to me
        chatyoucell.chat_content_label.text = contentString;
        chatyoucell.chat_time_label.text = dateString;
        chatyoucell.chat_person_label.text = author.username;
        return chatyoucell;
    }
    else
    {
        //msg is me to them
        chatmecell.chat_content_label.text = contentString;
        chatmecell.chat_time_label.text = dateString;
        return chatmecell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //do nothing when tapping chat elements (yet)
    [self.chat_input_box resignFirstResponder];
}

#pragma mark - Data

//in-app push receiver
- (void) pushreload: (id) sender
{
    [self.conversation fetchIfNeededInBackground];
    [self get_chat_info];
}

- (void) get_chat_info {
    [self getChat:self withConversation:self.conversation];
}

- (void)processChatList: (NSArray *)results {
    NSLog(@"received chat list callback, refreshing table");
    [self.chat_table_array removeAllObjects];
    self.chat_table_array = [results mutableCopy];
    [self.chat_table reloadData];
    
    //scroll the table to bottom row (if not empty table)
    if ([self.chat_table_array count] >=1)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([self.chat_table_array count] - 1) inSection:0];
        [self.chat_table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)processChatUploadWithConversation:(PFObject *)conversation withContent:(NSString *)content
{
    NSLog(@"received chat upload callback, sending push");
    
    NSString *pushstr = [NSString stringWithFormat:@"%@: %@",currentUser.username,content];
    NSDictionary *data = [NSDictionary dictionaryWithObjectsAndKeys:
                          pushstr, @"alert",
                          @"Increment", @"badge",
                          @"default", @"sound",
                          nil];
    // Create our Installation query
    PFQuery *pushQuery = [PFInstallation query];
    [pushQuery whereKey:@"user" containedIn:participants];
    // Send push notification to query
    PFPush *push = [[PFPush alloc] init];
    [push setQuery:pushQuery]; // Set our Installation query
    [push setData:data];
    [push sendPushInBackground];
    
    //interface
    [self get_chat_info];
    self.chat_input_box.text = @"";
    self.chat_input_box.placeholder = @"Type message here..";
}



- (void)toggleOptionView
{
    if (self.optionsContainer.hidden)
    {
        self.optionsContainer.hidden = NO;
        self.curtainView.hidden = NO;
        self.optionsContainer.userInteractionEnabled = YES;
        self.curtainView.userInteractionEnabled = YES;
    }
    else
    {
        self.optionsContainer.hidden = YES;
        self.curtainView.hidden = YES;
        self.optionsContainer.userInteractionEnabled = NO;
        self.curtainView.userInteractionEnabled = NO;
    }
}

#pragma mark - Keyboard

- (void)keyboardWillShow:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSValue *kbFrame = [info objectForKey:UIKeyboardFrameEndUserInfoKey];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGRect keyboardFrame = [kbFrame CGRectValue];
    
    CGFloat height = keyboardFrame.size.height;
    
    NSLog(@"Updating constraints: keyboard up");
    
    self.textfieldbottom.constant = height+5;
    self.sendmessagebottom.constant = height+5;
    self.tablebottom.constant = height+50;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
    
    //scroll the table to bottom row (if not empty table)
    if ([self.chat_table_array count] >=1)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([self.chat_table_array count] - 1) inSection:0];
        [self.chat_table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *)notification {
    NSDictionary *info = [notification userInfo];
    NSTimeInterval animationDuration = [[info objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    NSLog(@"Updating constraints: keyboard down");
    
    self.textfieldbottom.constant = 5;
    self.sendmessagebottom.constant = 5;
    self.tablebottom.constant = 50;
    
    [UIView animateWithDuration:animationDuration animations:^{
        [self.view layoutIfNeeded];
    }];
    
    //scroll the table to bottom row (if not empty table)
    if ([self.chat_table_array count] >=1)
    {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:([self.chat_table_array count] - 1) inSection:0];
        [self.chat_table scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"chatoptionsegue"])
    {
        GroupChatOptions *controller = [segue destinationViewController];
        controller.data_delegate = self;
        controller.conversation = self.conversation;
        controller.participants = self.participants;
    }
}

- (void) gotParticipantsFromDelegate:(NSArray *)totalParticipants withNewPeople: (NSArray *)newPeople withConversation: (PFObject *)updatedConversation
{
    [self toggleOptionView];
    [self.participants removeAllObjects];
    self.participants = [totalParticipants mutableCopy];
    self.conversation = updatedConversation;
    [self.conversation fetchInBackground];
    NSString *names = @"";
    for (PFObject *person in newPeople)
    {
        names = [NSString stringWithFormat:@"%@, %@ %@", names, person[@"first_name"], person[@"last_name"]];
    }
    NSRange range = NSMakeRange(0, 2);
    names = [names stringByReplacingCharactersInRange:range withString:@""];

    NSString *broadcast = [NSString stringWithFormat:@"The following people: %@ have been added to the conversation.", names];
    [self sendBroadcast:self withAuthor:currentUser withContent:broadcast withConversation:self.conversation withParticipants:self.participants];
}

- (void) leaveConversationFromDelegate
{
    //tapped leave conversation in option view
    [conversation removeObject:currentUser forKey:@"participants"];
    [conversation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            NSLog(@"left conversation successfully");
            NSString *broadcast = [NSString stringWithFormat:@"%@ has left the conversation.", currentUser.username];
            [self sendBroadcast:self withAuthor:currentUser withContent:broadcast withConversation:self.conversation withParticipants:self.participants];
            UINavigationController *navCon = self.navigationController;
            [navCon popViewControllerAnimated:YES];
        }
        else
        {
            NSLog(@"leave conversation error:%@",error);
        }
    }];
}

@end
