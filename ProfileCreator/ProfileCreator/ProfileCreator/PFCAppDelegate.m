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
#import "PFCManifestParser.h"
#import "PFCTableViewCellsProfiles.h"
#import "PFCProfileExportWindowController.h"
#import "PFCManifestLibrary.h"
#import "PFCLog.h"
#import "PFCGeneralUtility.h"

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
    if ( [defaultSettingsPath checkResourceIsReachableAndReturnError:&error] ) {
        NSDictionary *defaultSettingsDict = [NSDictionary dictionaryWithContentsOfURL:defaultSettingsPath];
        if ( [defaultSettingsDict count] != 0 ) {
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
    //  Initialize Main Window Controller
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

- (void) setupMenuItems {
    NSMenu *mainMenu = [[NSApplication sharedApplication] mainMenu];
    NSMenu *menuFile = [[mainMenu itemWithTitle:@"File"] submenu];
    NSMenuItem *newProfile = [menuFile itemWithTitle:@"New Profile"];
    [newProfile setTarget:_mainWindowController];
    [newProfile setAction:@selector(menuItemNewProfile)];
}

@end
