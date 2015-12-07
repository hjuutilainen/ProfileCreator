//
//  PFCProfileCreationWindowController.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2015-12-07.
//  Copyright © 2015 Erik Berglund. All rights reserved.
//

#import "PFCProfileCreationWindowController.h"

@interface PFCProfileCreationWindowController ()

@end

@implementation PFCProfileCreationWindowController

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initialization
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id)init {
    self = [super initWithWindowNibName:@"PFCProfileCreationWindowController"];
    if (self != nil) {
        _tableViewMenuItemsEnabled = [[NSMutableArray alloc] init];
        _tableViewMenuItemsDisabled = [[NSMutableArray alloc] init];
        _tableViewSettingsItemsEnabled = [[NSMutableArray alloc] init];
        _tableViewSettingsItemsDisabled = [[NSMutableArray alloc] init];
    }
    return self;
} // init

- (void)windowDidLoad {
    [super windowDidLoad];
} // windowDidLoad

@end
