#import "Repository.h"
#import "GPNSObjectAdditions.h"

@implementation Repository

- (NSArray*)findBuddies {
	return [SharedAppDelegate findAllOfEntity:@"Buddy"];
}

- (NSArray*)findMessages {
	return [SharedAppDelegate findAllOfEntity:@"Message"];
}

- (Buddy*)buddyWithName:(NSString*)name {
	Buddy *result = [SharedAppDelegate entityForName:@"Buddy"];
	result.name = name;
	return result;
}

- (Message*)messageForBuddy:(Buddy*)buddy {
	Message *msg = [SharedAppDelegate entityForName:@"Message"];
	msg.source = buddy;
	[SharedAppDelegate.context refreshObject:buddy mergeChanges:YES];
	return msg;
}

- (void)asyncSave {
	[SharedAppDelegate performSelector:@selector(save) withObject:nil afterDelay:0];
}


@end
