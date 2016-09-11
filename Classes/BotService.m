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


@interface BotService ()
@property(nonatomic,strong) NSMutableData *receivedData;
@property(nonatomic,strong) NSMutableData *startData;
@property(nonatomic,strong) NSMutableData *start2Data;
@property(nonatomic,strong) NSURLConnection *receivedConnection;
@property(nonatomic,strong) NSURLConnection *startConnection;
@property(nonatomic,strong) NSURLConnection *start2Connection;
@property(nonatomic,strong) NSString *botId;
@property(nonatomic,strong) NSString *botcust2;
@end

@implementation BotService
@synthesize receivedData, startData, start2Data, receivedConnection, startConnection, start2Connection, botId, botcust2, buddy, messageReceived;

- (void)initWithBuddy:(Buddy *) theBuddy {
    self.buddy = theBuddy;
}

- (void)responseReceived:(NSString*)response {
    [self setValue:response forKey:@"messageReceived"];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    if(connection == receivedConnection)
        [receivedData setLength:0];
    else if(connection == startConnection)
        [startData setLength:0];
    else
        [start2Data setLength:0];
    
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    if(connection == receivedConnection) {
        [receivedData appendData:data];
    } else if(connection == startConnection) {
        [startData appendData:data];
    } else {
        [start2Data appendData:data];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[receivedData length]);
    if(connection == receivedConnection) {
        NSLog(@"Received %@",[[NSString alloc] initWithBytes:[receivedData bytes] length:[receivedData length] encoding:NSUTF8StringEncoding]);
        NSString *content = [[NSString alloc] initWithBytes:[receivedData bytes] length:[receivedData length] encoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"<b>A.L.I.C.E.:<\\/b> *(.*?)<br\\/>" options:0 error:&error];
        NSAssert1(error == nil, @"Regexp error %@", error);
        NSArray *matches = [regex matchesInString:content options:0 range:NSMakeRange(0, [content length])];
        NSString *reply = [content substringWithRange:[[matches objectAtIndex:0] rangeAtIndex:1]];
        NSLog(@"Reply: %@",reply);
        [NSThread sleepForTimeInterval:5]; // don't answer immediately
        [self responseReceived:reply];
    } else if(connection == startConnection) {
        NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[startData length]);
        NSString *content = [[NSString alloc] initWithBytes:[startData bytes] length:[startData length] encoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"botid=(\\w+)" options:0 error:&error];
        NSAssert1(error == nil, @"Regexp error %@", error);
        NSArray *matches = [regex matchesInString:content options:0 range:NSMakeRange(0, [content length])];
        self.botId = [content substringWithRange:[[matches objectAtIndex:0] rangeAtIndex:1]];
        NSLog(@"Botid is now %@",self.botId);
        [self startStep2Bot];
    } else {
        NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[start2Data length]);
        NSString *content = [[NSString alloc] initWithBytes:[start2Data bytes] length:[start2Data length] encoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"name=\"botcust2\" value=\"(\\w+)" options:0 error:&error];
        NSAssert1(error == nil, @"Regexp error %@", error);
        NSArray *matches = [regex matchesInString:content options:0 range:NSMakeRange(0, [content length])];
        self.botcust2 = [content substringWithRange:[[matches objectAtIndex:0] rangeAtIndex:1]];
        NSLog(@"botcust2 is now %@",self.botcust2);
    }
}

- (void)startTheBot {
    NSString *url = @"https://alice.pandorabots.com";
    NSLog(@"Getting url %@",url);
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    startConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    startData = [NSMutableData data];
    
}

- (void)startStep2Bot {
    NSString *url = [NSString stringWithFormat:@"https://sheepridge.pandorabots.com/pandora/talk?botid=%@&skin=custom_input",self.botId];
    NSLog(@"Getting url %@",url);
    NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
    
    start2Connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    start2Data = [NSMutableData data];
}

- (void)requestBotResponse {
    if(self.botId != nil && self.botcust2 != nil) {
        
        NSString *lastMessage = [[self.buddy.messages lastObject] text];
        NSString *postString = [NSString stringWithFormat:@"input=%@&botcust2=%@",[lastMessage stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],self.botcust2];
        
        NSString *url = [NSString stringWithFormat:@"https://sheepridge.pandorabots.com/pandora/talk?botid=%@&skin=custom_input",self.botId];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
        request.HTTPMethod = @"POST";
        NSLog(@"Posting url %@\n%@",url,postString);
        [request setHTTPBody:[postString dataUsingEncoding:NSUTF8StringEncoding]];
        
        receivedConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
        receivedData = [NSMutableData data];
    } else {
        [self performSelector:@selector(responseReceived:) withObject:MockResponses.RandomPhrase afterDelay:rand() % 15 + 2];
    }
}

- (void)cancelBotResponseRequest {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}


@end
