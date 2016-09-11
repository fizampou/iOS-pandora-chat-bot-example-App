#import "ChatController.h"
#import "GPNSObjectAdditions.h"
#import "Message.h"
#import "TextViewCell.h"
#import "NSString+SKAdditions.h"
#import "MockResponses.h"


@interface ChatController ()
@property(nonatomic,strong) NSMutableData *receivedData;
@property(nonatomic,strong) NSMutableData *startData;
@property(nonatomic,strong) NSMutableData *start2Data;
@property(nonatomic,strong) NSURLConnection *receivedConnection;
@property(nonatomic,strong) NSURLConnection *startConnection;
@property(nonatomic,strong) NSURLConnection *start2Connection;
@property(nonatomic,strong) NSString *botId;
@property(nonatomic,strong) NSString *botcust2;
- (void)requestBotResponse;
- (void)cancelBotResponseRequest;
- (void)addMessage:(NSString*)text fromMe:(BOOL)fromMe;
@end

@implementation ChatController
@synthesize buddy, repository, responses, receivedData, startData, receivedConnection, startConnection, botId, start2Data, start2Connection, botcust2;

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)loadView {
    [super loadView];
    NSAssert(self.repository != nil,@"Not initialized");
    
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
	self.title = self.buddy.name;
    
    if(self.useTheBot) [self startTheBot];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	NSInteger section = [self.buddy.messages count];
	if(section > 0)
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section-1] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
	[self requestBotResponse];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self cancelBotResponseRequest];
    [super viewWillDisappear:YES];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.buddy.messages count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	Message *message = [self.buddy.messages objectAtIndex:indexPath.section];
	TextViewCell *cell = [TextViewCell cellForTableView:tableView];
	cell.textView.text = [message text];
	cell.backgroundColor = message.fromMe ? [UIColor whiteColor] : [UIColor colorWithRed:.95 green:.95 blue:1 alpha:1];
										
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UILabel *label = [UILabel xnew];
	label.frame = CGRectMake(18, 0, 290, 20);
	label.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor darkGrayColor];
	
	// inset effect
	label.shadowColor  = [UIColor colorWithRed:1 green:1 blue:1 alpha:.55];
	label.shadowOffset = CGSizeMake(0.0, 1.0);

	label.text = [[self.buddy.messages objectAtIndex:section] header];

	UIView *view = [UIView xnew];
	[view addSubview:label];
	
	return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	return 20;
}

#pragma mark -
#pragma mark UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	static int minSize = 32;
	static TextViewCell *dummy = nil;
	if(dummy == nil)
		dummy = [TextViewCell cellForTableView:nil];
	dummy.textView.text = [[self.buddy.messages objectAtIndex:indexPath.section] text];
    CGSize size = [dummy.textView sizeThatFits:CGSizeMake(320.0, INFINITY)];
    size.height += 12.0;
	return size.height > minSize ? size.height : minSize;
}


#pragma mark -
#pragma mark SendControllerDelegate

- (void)didSendMessage:(NSString*)text {
	[self addMessage:text fromMe:YES];
}

#pragma mark -
#pragma mark Private methods

- (void)responseReceived:(NSString*)response {
	[self addMessage:response fromMe:NO];
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
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    
    if(connection == receivedConnection)
        [receivedData appendData:data];
    else if(connection == startConnection)
        [startData appendData:data];
    else
        [start2Data appendData:data];
            
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@", [error localizedDescription], [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[receivedData length]);
    if(connection == receivedConnection) {
        //NSLog(@"Received %@",[[NSString alloc] initWithBytes:[receivedData bytes] length:[receivedData length] encoding:NSUTF8StringEncoding]);         
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

- (void)addMessage:(NSString*)text fromMe:(BOOL)fromMe {
	NSAssert(self.repository != nil, @"Not initialized");
	Message *msg = [self.repository messageForBuddy:self.buddy];
	msg.text = text;
	msg.fromMe = fromMe;
    if(fromMe) {
        [self requestBotResponse];
    }
	[self.repository asyncSave];
	[self.tableView reloadData];
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.buddy.messages count] - 1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

- (void)add:(id)sender {
	SendController *ctrl = [SendController xnew];
	ctrl.delegate = self;
	[self presentModalViewController:[[UINavigationController alloc] initWithRootViewController:ctrl] animated:YES];
}

@end

