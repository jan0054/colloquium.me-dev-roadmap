//
//  UIViewController+ParseQueries.h
//  cm_math_one
//
//  Created by csjan on 6/16/15.
//  Copyright (c) 2015 tapgo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface UIViewController (ParseQueries)

//venue
- (void)getVenue: (id)caller forEvent: (PFObject *)event;

//people
- (void)getPeople: (id)caller withSearch: (NSArray *)searchArray forEvent: (PFObject *)event;
- (void)getPeople: (id)caller forEvent: (PFObject *)event;

//timeline
- (void)getPosts: (id)caller forEvent: (PFObject *)event;
- (void)getComments: (id)caller forPost: (PFObject *)post;
- (void)sendComment: (id)caller forPost: (PFObject *)post withContent: (NSString *)content withAuthor: (PFUser *)author;
- (void)sentPost: (id)caller withAuthor: (PFUser *)author withContent: (NSString *)content withImage: (PFFile *)image withPreview: (PFFile *)preview forEvent: (PFObject *)event;

//chat
- (void)getConversations: (id)caller withUser: (PFUser *)user;
- (void)sendChat: (id)caller withAuthor: (PFUser *)user withContent: (NSString *)content withConversation: (PFObject *)conversation;
- (void)sendBroadcast:(id)caller withAuthor:(PFUser *)user withContent:(NSString *)content forConversation:(PFObject *)conversation;
- (void)getChat: (id)caller withConversation: (PFObject *)conversation;
- (void)getInviteeList: (id)caller withoutUsers: (NSArray *)participants;
- (void)getInviteeList: (id)caller withoutUsers: (NSArray *)participants withSearch: (NSArray *)searchArray;
- (void)inviteUser: (id)caller toConversation: (PFObject *)conversation withUser: (PFUser *)user atPath: (NSIndexPath *)path;
- (void)leaveConversation: (id)caller forConversation: (PFObject *)conversation forUser: (PFUser *)user;
- (void)createConcersation: (id)caller withParticipants: (NSMutableArray *)participants;

//program
- (void)getProgram: (id)caller ofType: (int)type withOrder: (int)order forEvent: (PFObject *)event;
- (void)getProgram: (id)caller ofType: (int)type withOrder: (int)order withSearch: (NSArray *)searchArray forEvent: (PFObject *)event;
- (void)getProgram: (id)caller forAuthor: (PFObject *)person forEvent: (PFObject *)event;
- (void)getSessions: (id)caller forEvent: (PFObject *)event;
- (void)getFilteredProgram: (id)caller ofType: (int)type withOrder: (int)order forEvent: (PFObject *)event forSession: (PFObject *)session;
- (void)getFilteredProgram: (id)caller ofType: (int)type withOrder: (int)order withSearch: (NSArray *)searchArray forEvent: (PFObject *)event forSession: (PFObject *)session;

//event
- (void)getEvents: (id)caller;
- (void)getCurrentEvents: (id)caller;
- (void)getPastEvents: (id)caller;
- (void)getChildrenEvents: (id)caller withParent: (PFObject *)parentEvent;
- (void)getEventsFromLocalList: (id)caller;
- (void)getEvent: (id)caller withId: (NSString *)eventId;
- (void)updateEventList: (id)caller forPerson: (PFObject *) person withList: (NSArray *) events;
- (void)getAnnouncements: (id)caller forEvent: (PFObject *)event;

//local
- (void)updateUserPreference: (id)caller forUser: (PFUser *)user;
- (void)removeLocalStorage;
- (void)writeUserPreferenceToLocal: (id)caller forUser: (PFUser *)user;

//forum
- (void)getForum: (id)caller forProgram: (PFObject *)program;
- (void)postForum: (id)caller forProgram: (PFObject *)program withContent: (NSString *)content withAuthor: (PFUser *)author;

//career
- (void)getCareer: (id)caller;

@end
