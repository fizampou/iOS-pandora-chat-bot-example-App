//
//  CustomTableView.h
//  TestTask
//
//  Created by Filippos Zampounis on 13/09/16.
//
//

#import <UIKit/UIKit.h>
#import "Keyboard.h"

@interface CustomTableView : UITableView
@property (weak, nonatomic) id<KeyboardDelegate> keyboardDelegate;
@end
