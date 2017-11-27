//
//  CustomTableView.m
//
//  Created by Filippos Zampounis on 13/09/16.
//
//

#import "CustomTableView.h"

@interface CustomTableView()
@property (nonatomic, readwrite, retain) UIView *input;
@end

@implementation CustomTableView
@synthesize input;

- (bool) canBecomeFirstResponder {
    return true;
}

- (UIView *)inputAccessoryView {
    if(!self.input) {
        self.input = [[Keyboard alloc] initWithDelegate:self.keyboardDelegate];
    }
    return self.input;
}

@end
