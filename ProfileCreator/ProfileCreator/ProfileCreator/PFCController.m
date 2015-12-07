//
//  PFCController.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2015-12-07.
//  Copyright © 2015 Erik Berglund. All rights reserved.
//

#import "PFCController.h"

@implementation PFCController

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initialization
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id)init {
    self = [super init];
    if (self != nil) {
        _profileWindows = [[NSMutableArray alloc] init];
    }
    return self;
} // init

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Delegate Methods NSApplicationDelegate
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)applicationWillFinishLaunching:(NSNotification *) __unused notification {

    
} // applicationWillFinishLaunching

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark IBActions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (IBAction)buttonCreateProfile:(id)sender {
    if ( ! _profileWindowController ) {
        _profileWindowController = [[PFCProfileCreationWindowController alloc] init];
    }
    [[_profileWindowController window] makeKeyAndOrderFront:self];
} // buttonCreateProfile

@end
