//
//  PFCProfileGroupTitle.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-06.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCMainWindowGroupTitle.h"
#import "PFCMainWindow.h"

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
            return [NSImage imageNamed:@"SidebarFolder"];
            break;
        case kPFCProfileGroups:
            return [NSImage imageNamed:@"SidebarFolder"];
            break;
            
        case kPFCProfileSmartGroups:
            return [NSImage imageNamed:@"SidebarFolder"];
            break;
            
        default:
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
        default:
            return @"";
            break;
    }
} // nameForGroup

- (void)viewDidLoad {
    [super viewDidLoad];
    [[(PFCMainWindowGroupTitleView *)[self view] textFieldTitle] setStringValue:[self nameForGroup:_group]];
    [(PFCMainWindowGroupTitleView *)[self view] setDelegate:_sender];
    [(PFCMainWindowGroupTitleView *)[self view] setGroup:_group];
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

    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    [self setTrackingArea:[[NSTrackingArea alloc] initWithRect:[self bounds] options:opts owner:self userInfo:nil]];
    [self addTrackingArea:_trackingArea];
} // updateTrackingAreas

@end