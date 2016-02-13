//
//  PFCTableViews.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-08.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCTableViews.h"

@implementation PFCTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

+ (unichar)firstCharPressedForEvent:(NSEvent *)theEvent {
    if ( ! [[theEvent characters] length] ) return -1;
    return [[theEvent characters] characterAtIndex:0];
}

+ (BOOL)eventIsDeleteKeyPressed:(NSEvent *)theEvent {
    switch ( [PFCTableView firstCharPressedForEvent:theEvent] ) {
        case NSDeleteFunctionKey:
        case NSDeleteCharFunctionKey:
        case NSDeleteCharacter:
            return YES;
        default:
            return NO;
    }
}

- (void)keyDown:(NSEvent *)theEvent {
    if ( [PFCTableView eventIsDeleteKeyPressed:theEvent] ) {
        if ( [[self delegate] respondsToSelector:@selector(deleteKeyPressedForTableView:)] ) {
            if ( [(id<PFCTableViewDelegate>)[self delegate] deleteKeyPressedForTableView:self] ) {
                return;
            }
        }
    }
    // The delegate wasn't able to handle it
    [super keyDown:theEvent];
}

@end
