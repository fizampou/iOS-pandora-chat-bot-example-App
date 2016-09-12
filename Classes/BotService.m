//
//  BotService.m
//  TestTask
//
//  Created by Filippos Zampounis on 11/09/16.
//
//

#import "BotService.h"
#import "MockResponses.h"
#import "GPNSObjectAdditions.h"

#define BOTID_REGEX @"botid=(\\w+)"
#define BOTCUST_REGEX @"name=\"botcust2\" value=\"(\\w+)"
#define ALICE_REGEX @"<b>A.L.I.C.E.:<\\/b> *(.*?)<br\\/>"

@interface BotService ()
@property(nonatomic,strong) NSString *botId;
@property(nonatomic,strong) NSString *botcust2;
@end

@implementation BotService
@synthesize botId, botcust2, buddy, messageReceived;

- (void)initWithBuddy:(Buddy *) theBuddy {
    self.buddy = theBuddy;
}

- (void)responseReceived:(NSString*)response {
    [self setValue:response forKey:@"messageReceived"];
}

- (void)startTheBot {
    [self sendRequestFromURL: @"https://alice.pandorabots.com"
                  completion: ^(NSString *content, NSError *error) {
                      if (content) {
                          NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:BOTID_REGEX options:0 error:&error];
                          NSAssert1(error == nil, @"Regexp error %@", error);
                          NSArray *matches = [regex matchesInString:content options:0 range:NSMakeRange(0, [content length])];
                          self.botId = [content substringWithRange:[[matches objectAtIndex:0] rangeAtIndex:1]];
                          NSLog(@"Botid is now %@",self.botId);
                          [self getBotcust];
                      }
                  } postData: nil];
}

- (void)getBotcust {
    [self sendRequestFromURL: [NSString stringWithFormat:@"https://sheepridge.pandorabots.com/pandora/talk?botid=%@&skin=custom_input",self.botId]
                  completion: ^(NSString *content, NSError *error) {
                      if (content) {
                          NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:BOTCUST_REGEX options:0 error:&error];
                          NSAssert1(error == nil, @"Regexp error %@", error);
                          NSArray *matches = [regex matchesInString:content options:0 range:NSMakeRange(0, [content length])];
                          self.botcust2 = [content substringWithRange:[[matches objectAtIndex:0] rangeAtIndex:1]];
                          NSLog(@"botcust2 is now %@",self.botcust2);
                      }
                  } postData: nil];
}

- (void) sendRequestFromURL: (NSString *) url completion:(void (^)(NSString *, NSError *))completionBlock postData:(NSString *)postData {
    
    NSURL *myURL = [NSURL URLWithString: url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL: myURL];
    if(postData) {
        [request setHTTPMethod:@"POST"];
        [request setHTTPBody:[postData dataUsingEncoding:NSUTF8StringEncoding]];
    }
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest: request
                                            completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                                void (^runAfterCompletion)(void) = ^void (void) {
                                                    if (error) {
                                                        NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
                                                    } else {
                                                        NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[data length]);
                                                        NSString *dataText = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
                                                        completionBlock(dataText, error);
                                                    }
                                                };
                                                
                                                //Dispatch the queue
                                                dispatch_async(dispatch_get_main_queue(), runAfterCompletion);
                                            }];
    [task resume];
    
}

- (void)requestBotResponse {
    if(self.botId != nil && self.botcust2 != nil) {
        // bot connection is ready / available
        NSString *lastMessage = [[self.buddy.messages lastObject] text];
        NSString *postString = [NSString stringWithFormat:@"input=%@&botcust2=%@",[lastMessage stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],self.botcust2];

        [self sendRequestFromURL: [NSString stringWithFormat:@"https://sheepridge.pandorabots.com/pandora/talk?botid=%@&skin=custom_input",self.botId]
                      completion: ^(NSString *content, NSError *error) {
                          if (content) {
                              NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:ALICE_REGEX options:0 error:&error];
                              NSAssert1(error == nil, @"Regexp error %@", error);
                              NSArray *matches = [regex matchesInString:content options:0 range:NSMakeRange(0, [content length])];
                              NSString *reply = [content substringWithRange:[[matches objectAtIndex:0] rangeAtIndex:1]];
                              NSLog(@"Reply: %@",reply);
                              dispatch_async(
                                             dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                                             ^{
                                                 sleep(5);
                                                 [self responseReceived:reply];
                                             }
                                             );
                          }
                      } postData: postString];
    } else {
        // bot connection is not ready / available use the mocks
        [self performSelector:@selector(responseReceived:) withObject:MockResponses.RandomPhrase afterDelay:rand() % 15 + 2];
    }
}

- (void)cancelBotResponseRequest {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}


@end
