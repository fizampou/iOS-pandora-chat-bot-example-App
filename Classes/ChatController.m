#import "ChatController.h"
#import "GPNSObjectAdditions.h"
#import "Message.h"
#import "TextViewCell.h"
#import "NSString+SKAdditions.h"
#import "CustomTableView.h"

@interface ChatController ()
- (void)addMessage:(NSString*)text fromMe:(BOOL)fromMe;
@property (strong, nonatomic) CustomTableView *tableView;
@end

@implementation ChatController
@synthesize buddy, repository, botService;

- (id)init {
	self = [super initWithStyle:UITableViewStyleGrouped];
	return self;
}

#pragma mark -
#pragma mark View lifecycle

- (void)loadView {
    [super loadView];
	self.title = self.buddy.name;
    
    self.tableView = [[CustomTableView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    self.tableView.backgroundColor = [UIColor whiteColor];
    [self.tableView becomeFirstResponder];
    
    // Pass the current controller as the keyboardDelegate
    ((CustomTableView *)self.tableView).keyboardDelegate = self;
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(didTouchView)];
    [self.view addGestureRecognizer:recognizer];
    
    [self.botService startTheBot];
}

// Dissmiss the keyboard on tableView touches by making the view first responder
- (void)didTouchView {
    [self.tableView becomeFirstResponder];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if([keyPath isEqualToString:@"messageReceived"])
    {
        NSString* message = [change objectForKey:NSKeyValueChangeNewKey];
        [self addMessage:message fromMe:NO];
    }
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
	NSInteger section = [self.buddy.messages count];
    if(section > 0){
		[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section-1] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.botService addObserver:self forKeyPath:@"messageReceived" options:NSKeyValueObservingOptionNew context:nil];
	[self.botService requestBotResponse];
}

- (void)viewWillDisappear:(BOOL)animated {
	[self.botService cancelBotResponseRequest];
    [self.botService removeObserver:self forKeyPath:@"messageReceived"];
    [super viewWillDisappear:YES];
}

#pragma mark -
#pragma mark KeyboardDelegate

- (void)keyboard:(Keyboard *)keyboard sendText:(NSString *)text {
    [self addMessage:text fromMe:YES];
}

#pragma mark -
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.buddy.messages count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableVi cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	Message *message = [self.buddy.messages objectAtIndex:indexPath.section];
	TextViewCell *cell = [TextViewCell cellForTableView:tableVi];
	cell.textView.text = [message text];
	cell.backgroundColor = message.fromMe ? [UIColor whiteColor] : [UIColor colorWithRed:.95 green:.95 blue:1 alpha:1];
										
	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
	return NO;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	UILabel *label = [[UILabel alloc] init];
	label.frame = CGRectMake(18, 0, 290, 20);
	label.font = [UIFont boldSystemFontOfSize:[UIFont smallSystemFontSize]];
	label.backgroundColor = [UIColor clearColor];
	label.textColor = [UIColor darkGrayColor];
	
	// inset effect
	label.shadowColor  = [UIColor colorWithRed:1 green:1 blue:1 alpha:.55];
	label.shadowOffset = CGSizeMake(0.0, 1.0);

	label.text = [[self.buddy.messages objectAtIndex:section] header];

	UIView *view = [[UIView alloc] init];
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
#pragma mark Private methods

- (void)addMessage:(NSString*)text fromMe:(BOOL)fromMe {
	NSAssert(self.repository != nil, @"Not initialized");
	Message *msg = [self.repository messageForBuddy:self.buddy];
	msg.text = text;
	msg.fromMe = fromMe;
    if(fromMe) {
        [self.botService requestBotResponse];
    }
	[self.repository asyncSave];
	[self.tableView reloadData];
	[self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:[self.buddy.messages count] - 1] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
}

@end

