//
//  Keyboard.h
//
//  Created by Filippos Zampounis on 13/09/16.
//
//

#import <UIKit/UIKit.h>

@class Keyboard;

@protocol KeyboardDelegate <NSObject>
- (void)keyboard:(Keyboard *)keyboard sendText:(NSString *)text;
@end

@interface Keyboard : UIView
- (id)initWithDelegate:(id<KeyboardDelegate>)delegate;
@property (strong, nonatomic) UITextView *textView;
@property (strong, nonatomic) UIButton *sendButton;
@property (weak, nonatomic) id<KeyboardDelegate> delegate;
@end
