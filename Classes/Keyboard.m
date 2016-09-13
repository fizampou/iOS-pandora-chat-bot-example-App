//
//  Keyboard.m
//  TestTask
//
//  Created by Filippos Zampounis on 13/09/16.
//
//

#import "Keyboard.h"

@implementation Keyboard

- (id)initWithDelegate:(id<KeyboardDelegate>)delegate {
    self = [self init];
    self.delegate = delegate;
    return self;
}

- (id)init {
    CGRect screen = [[UIScreen mainScreen] bounds];
    CGRect frame = CGRectMake(0,0, CGRectGetWidth(screen), 40);
    self = [self initWithFrame:frame];
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.textView = [[UITextView alloc]initWithFrame:CGRectMake(5, 5, frame.size.width - 70, frame.size.height - 10)];
        [self addSubview:self.textView];
        
        self.sendButton = [[UIButton alloc]initWithFrame:CGRectMake(frame.size.width - 60, 5, 55, frame.size.height - 10)];
        [self.sendButton setTitle:@"Send" forState:UIControlStateNormal];
        [self.sendButton addTarget:self action:@selector(didTouchAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.sendButton];
        
        [self setBackgroundColor:[UIColor blackColor]];
    }
    return self;
}

- (void)didTouchAction {
    [self.delegate keyboard:self sendText:self.textView.text];
}

@end
