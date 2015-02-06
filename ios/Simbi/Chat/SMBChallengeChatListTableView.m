//
//  SMBChallengeChatListTableView.m
//  Simbi
//
//  Created by flynn on 5/30/14.
//  Copyright (c) 2014 SimbiSocial. All rights reserved.
//

#import "SMBChallengeChatListTableView.h"

#import "SMBChatCircleTimerView.h"
#import "SMBChatManager.h"
#import "SMBChallengeCell.h"


@implementation SMBChallengeChatListTableView

static NSString *CellIdentifier = @"Cell";

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame style:UITableViewStyleGrouped manager:[SMBChatManager sharedManager]];
    
    if (self)
    {
        [self setBackgroundColor:[UIColor simbiWhiteColor]];
        [self setSeparatorColor:[UIColor clearColor]];
        
        [self setNoResultsMessage:@"No Active Games"];
        [self setErrorMessage:@"Error Loading Games"];
        
        [self registerClass:[SMBChallengeCell class] forCellReuseIdentifier:CellIdentifier];
    }
    
    return self;
}


#pragma mark - Public Methods

- (void)sortChats
{
    NSMutableArray *sortedChats = [NSMutableArray new];
    
    for (SMBChat *chat in self.objects)
    {
        if (chat.currentChallenge) // Only pick chats with challenges
        {
            int i = 0;
            
            for (i = 0; i < sortedChats.count; i++)
            {
                SMBChat *sortedChat = [sortedChats objectAtIndex:i];
                
                if (!sortedChat.dateStarted && [sortedChat.createdAt compare:chat.createdAt] == NSOrderedDescending)
                    break;
                else if (chat.dateStarted && [sortedChat.dateStarted compare:chat.dateStarted] == NSOrderedDescending)
                    break;
            }
            
            if (i == sortedChats.count)
                [sortedChats addObject:chat];
            else
                [sortedChats insertObject:chat atIndex:i];
        }
    }
    
    [self setObjects:[NSArray arrayWithArray:sortedChats]];
    
    [self showNoResultsLabel:(self.objects.count == 0)];
    
    [self reloadData];
}


#pragma mark - SMBManagerDelegate

- (void)manager:(SMBManager *)manager didUpdateObjects:(NSArray *)objects
{
    [super manager:manager didUpdateObjects:objects];
    
    [self sortChats];
}


#pragma mark - UITableViewDataSource/Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 2.f;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [SMBChatCell cellHeight];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SMBChat *chat = [self.objects objectAtIndex:indexPath.row];
    SMBChallengeCell *cell = [[SMBChallengeCell alloc] initWithChat:chat];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    if (!chat.currentChallenge.winner.objectId && ![cell.timerView hasExpired])
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}


@end
