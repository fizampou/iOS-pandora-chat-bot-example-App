#import <UIKit/UIKit.h>
#import "Repository.h"
#import "BotService.h"

@interface BuddiesController : UITableViewController {
	NSArray *buddies;
	Repository *repository;
    BotService *botService;
    
}
@property(nonatomic, strong) Repository *repository;
@property(nonatomic, strong) BotService *botService;

@end
