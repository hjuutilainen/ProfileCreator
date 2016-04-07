//
//  PFCMainWindowGroupTitle.m
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

#import "PFCMainWindow.h"
#import "PFCMainWindowGroupTitle.h"

@interface PFCMainWindowGroupTitle ()

@property (nonatomic, weak) id sender;
@property PFCProfileGroups group;

@end

@implementation PFCMainWindowGroupTitle

- (id)initWithGroup:(PFCProfileGroups)group sender:(id)sender {
    self = [super initWithNibName:@"PFCMainWindowGroupTitle" bundle:nil];
    if (self != nil) {
        _group = group;
        _sender = sender;
        [self view];
    }
    return self;
} // init

+ (NSImage *)iconForGroup:(PFCProfileGroups)group {
    switch (group) {
    case kPFCProfileGroupAll:
        return nil;
        break;

    case kPFCProfileGroups:
        return [NSImage imageNamed:@"SidebarFolder"];
        break;

    case kPFCProfileSmartGroups:
        return [NSImage imageNamed:@"SidebarSmartFolder"];
        break;
    }
}

- (NSString *)nameForGroup:(PFCProfileGroups)group {
    switch (group) {
    case kPFCProfileGroupAll:
        return @"";
        break;

    case kPFCProfileGroups:
        return @"Groups";
        break;

    case kPFCProfileSmartGroups:
        return @"Smart Groups";
        break;
    }
} // nameForGroup

- (void)viewDidLoad {
    [super viewDidLoad];
    [[(PFCMainWindowGroupTitleView *)self.view textFieldTitle] setStringValue:[self nameForGroup:_group]];
    [(PFCMainWindowGroupTitleView *)self.view setDelegate:_sender];
    [(PFCMainWindowGroupTitleView *)self.view setGroup:_group];
    //[(PFCMainWindowGroupTitleView *)[self view] setTranslatesAutoresizingMaskIntoConstraints:NO];
} // viewDidLoad

@end

@implementation PFCMainWindowGroupTitleView

- (IBAction)buttonAddGroup:(id)sender {
    if (_delegate) {
        [_delegate createNewGroupOfType:_group];
    }
} // buttonAddGroup

- (void)showButtonAddGroup {
    // FIXME - Animate this with a fade in
    [_buttonAddGroup setHidden:NO];
}

- (void)hideButtonAddGroup {
    // FIXME - Animate this with a fade out
    [_buttonAddGroup setHidden:YES];
}

- (void)mouseEntered:(NSEvent *)theEvent {
    [self showButtonAddGroup];
} // mouseEntered

- (void)mouseExited:(NSEvent *)theEvent {
    [self hideButtonAddGroup];
} // mouseExited

- (void)updateTrackingAreas {
    if (_trackingArea != nil) {
        [self removeTrackingArea:_trackingArea];
    }

    NSUInteger opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    [self setTrackingArea:[[NSTrackingArea alloc] initWithRect:self.bounds options:opts owner:self userInfo:nil]];
    [self addTrackingArea:_trackingArea];
} // updateTrackingAreas

@end
