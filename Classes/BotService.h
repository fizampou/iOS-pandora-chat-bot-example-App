//
//  BotService.h
//  TestTask
//
//  Created by Filippos Zampounis on 11/09/16.
//
//

#import <Foundation/Foundation.h>
#import "Buddy.h"


@interface BotService : NSObject {
}

@property(nonatomic,strong) Buddy *buddy;
@property(nonatomic,strong) NSString *messageReceived;

- (void)initWithBuddy:(Buddy *) theBuddy;
- (void)requestBotResponse;
- (void)cancelBotResponseRequest;

@end
