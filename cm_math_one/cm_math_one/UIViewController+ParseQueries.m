//
//  UIViewController+ParseQueries.m
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import "UIViewController+ParseQueries.h"

@implementation UIViewController (ParseQueries)

- (void) getVenue:(id)caller forEvent:(PFObject *)event
{
    PFQuery *query = [PFQuery queryWithClassName:@"Venue"];
    [query whereKey:@"event" equalTo:event];
    [query orderByDescending:@"order"];
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 86400;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"venue query success: %lu", (unsigned long)[objects count]);
        //[caller processData:objects];
    }];
}

- (void)getPeople: (id)caller withSearch: (NSMutableArray *)searchArray
{
    PFQuery *personquery = [PFQuery queryWithClassName:@"Person"];
    [personquery orderByAscending:@"last_name"];
    [personquery setLimit:500];
    personquery.cachePolicy = kPFCachePolicyCacheThenNetwork;
    personquery.maxCacheAge = 86400;
    if (searchArray.count >=1)
    {
        [personquery whereKey:@"words" containsAllObjectsInArray:searchArray];
        NSLog(@"person query did do search");
    }
    [personquery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"person query success: %lu", (unsigned long)[objects count]);
        //[caller processData:objects];
    }];
}

- (void)getPosts: (id)caller
{
    
}

- (void)getConversations:(id)caller withUser:(PFUser *)user
{
    PFQuery *query = [PFQuery queryWithClassName:@"Conversation"];
    [query whereKey:@"participants" equalTo:user];
    [query includeKey:@"participants"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"conversation query error");
        } else {
            //[caller processData:objects];
        }
    }];
}



- (void)getAttachments: (id)caller forAuthor: (PFObject *)person
{
    PFQuery *query = [PFQuery queryWithClassName:@"Attachment"];
    [query whereKey:@"author" equalTo:person];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Successfully retrieved %lu talks for the person.", (unsigned long)objects.count);
        //[caller processAttachmentData:objects];
    }];
}

- (void)sendChat:(id)caller withAuthor:(PFUser *)user withContent:(NSString *)content withConversation:(PFObject *)conversation
{
    PFObject *chat = [PFObject objectWithClassName:@"Chat"];
    chat[@"content"] = content;
    chat[@"author"] = user;
    chat[@"conversation"] = conversation;
    [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            NSLog(@"new chat uploaded successfully");
            conversation[@"last_time"] = [NSDate date];
            conversation[@"last_msg"] = content;
            [conversation saveInBackground];
            //[caller processChatUploadWithConversation:conversation withContent:content];
        }
        else
        {
            NSLog(@"chat upload error:%@",error);
        }
    }];
}

- (void)sendBroadcast:(id)caller withAuthor:(PFUser *)user withContent:(NSString *)content withConversation:(PFObject *)conversation withParticipants:(NSArray *)participants
{
    PFObject *chat = [PFObject objectWithClassName:@"Chat"];
    chat[@"content"] = content;
    chat[@"author"] = user;
    chat[@"broadcast"] = @1;
    chat[@"conversation"] = conversation;
    [chat saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)
        {
            NSLog(@"new broadcast uploaded successfully, sending push");
            NSString *pushstr = content;
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
        }
        else
        {
            NSLog(@"broadcast upload error:%@",error);
        }
    }];
}

- (void)getChat:(id)caller withConversation:(PFObject *)conversation
{
    PFQuery *query = [PFQuery queryWithClassName:@"Chat"];
    [query whereKey:@"conversation" equalTo:conversation];
    [query orderByAscending:@"createdAt"];
    [query includeKey:@"read"];
    [query includeKey:@"author"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"chat query success with # of chats: %ld", (unsigned long)[objects count]);
        //[caller processChatList:objects];
    }];
}

- (void)getPrivateChat: (id)caller withUser: (PFUser *)user alongWithSelf: (PFUser *) currentUser
{
    PFQuery *query = [PFQuery queryWithClassName:@"Conversation"];
    [query whereKey:@"is_group" notEqualTo:@1];
    [query includeKey:@"participants"];
    [query whereKey:@"participants" containsAllObjectsInArray:@[user, currentUser]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Successfully retrieved %lu conversations for these users.", (unsigned long)objects.count);
        //[caller processConversationData:objects];
    }];
}

- (void)getInviteeList: (id)caller withoutUsers:(NSArray *)users
{
    PFQuery *query = [PFQuery queryWithClassName:@"Person"];
    [query whereKey:@"chat_status" equalTo:@1];
    [query whereKey:@"debug_status" notEqualTo:@1];
    [query includeKey:@"user"];
    [query whereKey:@"user" notContainedIn:users];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Successfully retrieved %lu invitees.(persons)", (unsigned long)objects.count);
        //[caller processInviteeData:objects];
    }];
}

//type = 99 for all types, 0 = talk, 1 = poster (no start/end time), so don't use order = 0 with type = 1. Leave author = nil to not filter by specific person
- (void)getProgram: (id)caller ofType: (int)type forAuthor: (PFObject *)person withOrdering: (int)order forEvent:(PFObject *)event
{
    PFQuery *query = [PFQuery queryWithClassName:@"Talk"];
    [query whereKey:@"event" equalTo:event];
    if (person != nil)
    {
        [query whereKey:@"author" equalTo:person];
    }
    if (type != 99)
    {
        [query whereKey:@"type" equalTo:[NSNumber numberWithInt:type]];
    }
    //order = 0 start_time, order = 1 name, can add others in future if needed
    if (order ==0)
    {
        [query orderByDescending:@"start_time"];
    }
    else if (order ==1)
    {
        [query orderByDescending:@"name"];
    }
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 86400;
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"Successfully retrieved %lu programs for the person.", (unsigned long)objects.count);
        //[caller processTalkData:objects];
    }];
}





@end
