#import <UIKit/UIKit.h>
#import "Repository.h"
#import "BotService.h"
#import "Keyboard.h"

@interface ChatController : UITableViewController <KeyboardDelegate> {
	Buddy *buddy;
	Repository *repository;
    BotService *botService;
}

@property(nonatomic,strong) Buddy *buddy;
@property(nonatomic,strong) Repository *repository;
@property(nonatomic,strong) BotService *botService;

@end
