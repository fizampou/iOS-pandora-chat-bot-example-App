#import <UIKit/UIKit.h>
#import "Repository.h"
#import "SendController.h"
#import "BotService.h"

@interface ChatController : UITableViewController <UITextViewDelegate,SendControllerDelegate> {
	Buddy *buddy;
	Repository *repository;
    BotService *botService;
}

@property(nonatomic,strong) Buddy *buddy;
@property(nonatomic,strong) Repository *repository;
@property(nonatomic,strong) BotService *botService;

@end
