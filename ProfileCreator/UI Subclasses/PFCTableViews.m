//
//  PFCTableViews.m
//  ProfileCreator
//
//  Created by Erik Berglund.
//  Copyright (c) 2016 ProfileCreator. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

#import "PFCTableViews.h"

@implementation PFCTableView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

+ (unichar)firstCharPressedForEvent:(NSEvent *)theEvent {
    if (![[theEvent characters] length])
        return -1;
    return [[theEvent characters] characterAtIndex:0];
}

+ (BOOL)eventIsDeleteKeyPressed:(NSEvent *)theEvent {
    switch ([self.class firstCharPressedForEvent:theEvent]) {
    case NSDeleteFunctionKey:
    case NSDeleteCharFunctionKey:
    case NSDeleteCharacter:
        return YES;
    default:
        return NO;
    }
}

- (void)keyDown:(NSEvent *)theEvent {
    if ([self.class eventIsDeleteKeyPressed:theEvent]) {
        if ([self.delegate respondsToSelector:@selector(deleteKeyPressedForTableView:)]) {
            if ([(id<PFCTableViewDelegate>)self.delegate deleteKeyPressedForTableView:self]) {
                return;
            }
        }
    }
    // The delegate wasn't able to handle it
    [super keyDown:theEvent];
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent {

    // ------------------------------------------------------------------------------
    //  Get what row in the TableView the mouse is pointing at when the user clicked
    // ------------------------------------------------------------------------------
    NSPoint mousePoint = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    NSInteger row = [self rowAtPoint:mousePoint];

    // ----------------------------------------------------------------------------------------
    //  Get what table view responded when the user clicked
    // ----------------------------------------------------------------------------------------
    NSString *tableViewIdentifier = self.identifier;

    // ----------------------------------------------------------------------------------------
    //  Create an instance of the context menu bound to the TableView's menu outlet
    // ----------------------------------------------------------------------------------------
    NSMenu *menu = [self.menu copy];
    [menu setAutoenablesItems:YES];

    // -----------------------------------------------------------------------------------------------------------
    //  Send menu to delegate for validation to add, enable and disable menu items depending on TableView and row
    // -----------------------------------------------------------------------------------------------------------
    if ([self.delegate respondsToSelector:@selector(validateMenu:forTableViewWithIdentifier:row:)]) {
        [(id<PFCTableViewDelegate>)self.delegate validateMenu:menu forTableViewWithIdentifier:tableViewIdentifier row:row];
    }

    return menu;
} // menuForEvent

- (void)mouseDown:(NSEvent *)theEvent {

    NSPoint globalLocation = [theEvent locationInWindow];
    NSPoint localLocation = [self convertPoint:globalLocation fromView:nil];
    NSInteger clickedRow = [self rowAtPoint:localLocation];

    [super mouseDown:theEvent];

    if (clickedRow != -1) {
        if ([self.delegate respondsToSelector:@selector(didClickRow:)]) {
            [(id<PFCTableViewDelegate>)self.delegate didClickRow:clickedRow];
        }
    }
}

@end
