//
//  PFCController.m
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

#import "PFCAppDelegate.h"
#import "PFCConstants.h"
#import "PFCLog.h"

#import "PFCMainWindow.h"
#import "PFCManifestLibrary.h"
#import "PFCPreferences.h"

@interface PFCAppDelegate ()

@property PFCMainWindow *mainWindowController;
@property PFCPreferences *preferencesController;

@end

@implementation PFCAppDelegate

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Delegate Methods NSApplicationDelegate
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)applicationWillFinishLaunching:(NSNotification *)notification {

    // --------------------------------------------------------------
    //  Register user defaults
    // --------------------------------------------------------------
    NSError *error;
    NSURL *defaultSettingsPath = [[NSBundle mainBundle] URLForResource:@"Defaults" withExtension:@"plist"];
    if ([defaultSettingsPath checkResourceIsReachableAndReturnError:&error]) {
        NSDictionary *defaultSettingsDict = [NSDictionary dictionaryWithContentsOfURL:defaultSettingsPath];
        if ([defaultSettingsDict count] != 0) {
            [[NSUserDefaults standardUserDefaults] registerDefaults:defaultSettingsDict];
        }
    } else {
        // Use NSLog as CocoaLumberjack isn't available yet
        NSLog(@"%@", [error localizedDescription]);
    }

    // --------------------------------------------------------------
    //  Initialize Logging
    // --------------------------------------------------------------
    [PFCLog configureLoggingForSession:kPFCSessionTypeGUI];

    // --------------------------------------------------------------
    //  Initialize Manifest Libraries
    // --------------------------------------------------------------
    [PFCManifestLibrary sharedLibrary];

    // --------------------------------------------------------------
    //  Initialize Controllers
    // --------------------------------------------------------------
    [self setMainWindowController:[[PFCMainWindow alloc] init]];

    // --------------------------------------------------------------
    //  Setup Menu Items
    // --------------------------------------------------------------
    [self setupMenuItems];

    // --------------------------------------------------------------
    //  Show Main Window
    // --------------------------------------------------------------
    [[_mainWindowController window] makeKeyAndOrderFront:self];

} // applicationWillFinishLaunching

- (void)menuItemPreferences {

    if (!_preferencesController) {
        _preferencesController = [[PFCPreferences alloc] init];
    }

    if (_preferencesController) {
        [[_preferencesController window] makeKeyAndOrderFront:self];
    }
}

- (void)setupMenuItems {

    // --------------------------------------------------------------
    //  Get Main Menu
    // --------------------------------------------------------------
    NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];

    // --------------------------------------------------------------
    //  Get Main Menu -> ProfileCreator
    // --------------------------------------------------------------
    NSMenu *menuProfileCreator = [[mainMenu itemWithTitle:@"ProfileCreator"] submenu];

    // --------------------------------------------------------------
    //  Update Menu Item -> ProfileCreator -> Preferences
    // --------------------------------------------------------------
    NSMenuItem *preferences = [menuProfileCreator itemWithTitle:@"Preferences…"];
    if (preferences) {
        [preferences setTarget:self];
        [preferences setAction:@selector(menuItemPreferences)];
    }

    // --------------------------------------------------------------
    //  Get Main Menu -> File
    // --------------------------------------------------------------
    NSMenu *menuFile = [[mainMenu itemWithTitle:@"File"] submenu];

    // --------------------------------------------------------------
    //  Update Menu Item -> File -> "New Profile"
    // --------------------------------------------------------------
    NSMenuItem *newProfile = [menuFile itemWithTitle:@"New Profile"];
    if (newProfile) {
        [newProfile setTarget:_mainWindowController];
        [newProfile setAction:@selector(menuItemNewProfile)];
    }

    // --------------------------------------------------------------
    //  Update Menu Item -> File -> "New Profile"
    // --------------------------------------------------------------
    NSMenuItem *newGroup = [menuFile itemWithTitle:@"New Group"];
    if (newGroup) {
        [newGroup setTarget:_mainWindowController];
        [newGroup setAction:@selector(menuItemNewGroup)];
    }
} // setupMenuItems

@end
