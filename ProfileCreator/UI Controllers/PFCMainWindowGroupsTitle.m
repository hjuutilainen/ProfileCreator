//
//  PFCProfileGroupTitle.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-06.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCMainWindowGroupsTitle.h"

@interface PFCMainWindowGroupsTitle ()

@end

@implementation PFCMainWindowGroupsTitle

- (id)init {
    self = [super initWithNibName:@"PFCMainWindowGroupsTitle" bundle:nil];
    if (self != nil) {
    }
    return self;
} // init

- (void)viewDidLoad {
    [super viewDidLoad];
} // viewDidLoad

@end

@implementation PFCMainWindowGroupsTitleView

- (IBAction)buttonAddGroup:(id)sender {
    if (_delegate) {
        [_delegate createNewGroupOfType:_profileGroup];
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

    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    [self setTrackingArea:[[NSTrackingArea alloc] initWithRect:[self bounds] options:opts owner:self userInfo:nil]];
    [self addTrackingArea:_trackingArea];
} // updateTrackingAreas

@end