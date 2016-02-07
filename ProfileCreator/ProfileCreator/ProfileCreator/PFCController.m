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

#import "PFCController.h"
#import "PFCConstants.h"
#import "PFCManifestParser.h"
#import "PFCTableViewCellsProfiles.h"
#import "PFCProfileExportWindowController.h"
#import "PFCManifestLibrary.h"
#import "PFCLog.h"
#import "PFCGeneralUtility.h"

@implementation PFCController

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id)init {
    self = [super init];
    if (self != nil) {
        _profileWindows = [[NSMutableDictionary alloc] init];
        _savedProfiles = [[NSMutableDictionary alloc] init];
        _initialized = NO;
    }
    return self;
} // init

- (void)dealloc {
    
}

- (void)controlTextDidChange:(NSNotification *)sender {
    if ( [[sender object] isEqualTo:_textFieldSheetProfileName] ) {
        NSDictionary *userInfo = [sender userInfo];
        NSString *inputText = [[userInfo valueForKey:@"NSFieldEditor"] string];
        
        NSInteger selectedRow = [_tableViewProfiles selectedRow];
        if ( selectedRow < 0 ) {
            NSLog(@"[ERROR] No row is selected!");
            return;
        }
        
        NSMutableDictionary *profileDict = [[_tableViewProfilesItems objectAtIndex:selectedRow] mutableCopy];
        if ( [ profileDict count] == 0 ) {
            NSLog(@"[ERROR] profile at index: %ld is empty!", (long)selectedRow);
            return;
        }
        
        NSString *profilePath = profileDict[@"Path"];
        if ( [profilePath length] == 0 ) {
            NSLog(@"[ERROR] No path to profile!");
            return;
        }
        
        NSString *profileCurrentName = profileDict[@"Config"][@"Name"];
        
        if (
            [inputText isEqualToString:PFCDefaultProfileName] ||
            [inputText isEqualToString:profileCurrentName] ||
            [inputText length] == 0 ) {
            [_buttonSaveSheetProfileName setEnabled:NO];
        } else {
            [_buttonSaveSheetProfileName setEnabled:YES];
        }
        return;
    }
}

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
    [self setMainWindowController:[[PFCMainWindowController alloc] init]];
    
    // --------------------------------------------------------------
    //  Show Main Window
    // --------------------------------------------------------------
    [[_mainWindowController window] makeKeyAndOrderFront:self];
    
} // applicationWillFinishLaunching

- (void)removeControllerForProfileDictWithName:(NSString *)name {
    NSUInteger idx = [_tableViewProfilesItems indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return [item[@"Config"][PFCProfileTemplateKeyName] isEqualToString:name];
    }];
    
    if ( idx != NSNotFound ) {
        NSMutableDictionary *profileDict = [[_tableViewProfilesItems objectAtIndex:idx] mutableCopy];
        [profileDict removeObjectForKey:@"Controller"];
        [_tableViewProfilesItems replaceObjectAtIndex:idx withObject:[profileDict copy]];
    } else {
        NSLog(@"Found no profile named: %@", name);
    }
}

- (void)renameProfileWithName:(NSString *)name newName:(NSString *)newName {
    NSUInteger idx = [_tableViewProfilesItems indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return [item[@"Config"][@"Name"] isEqualToString:name];
    }];
    
    if ( idx != NSNotFound ) {
        NSMutableDictionary *profileDict = [[_tableViewProfilesItems objectAtIndex:idx] mutableCopy];
        NSMutableDictionary *configDict = [profileDict[@"Config"] mutableCopy];
        configDict[@"Name"] = newName ?: @"";
        profileDict[@"Config"] = [configDict copy];
        [_tableViewProfilesItems replaceObjectAtIndex:idx withObject:[profileDict copy]];
        [_tableViewProfiles reloadData];
    } else {
        NSLog(@"Found no profile named: %@", name);
    }
}

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    
    NSString *menuItemTitle = [menuItem title];
    
    // Verify one (1) profile is selected
    if (
        [menuItemTitle isEqualToString:@"Rename"] ||
        [menuItemTitle isEqualToString:@"Export"]
        ) {
        return ( [[_tableViewProfiles selectedRowIndexes] count] == 1 ) ? YES : NO;
    }
    
    return YES;
}

- (void)setupAdvancedOptions {
    NSMenuItem *menuItemRename = [[NSMenuItem alloc] initWithTitle:@"Rename" action:@selector(renameProfile) keyEquivalent:@""];
    [menuItemRename setTarget:self];
    [_menuAdvancedOptions addItem:menuItemRename];
    
    [_menuAdvancedOptions addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *menuItemExport = [[NSMenuItem alloc] initWithTitle:@"Export" action:@selector(exportProfile) keyEquivalent:@""];
    [menuItemExport setTarget:self];
    [_menuAdvancedOptions addItem:menuItemExport];
}

- (void)renameProfile {
    NSInteger selectedRow = [_tableViewProfiles selectedRow];
    if ( selectedRow < 0 ) {
        NSLog(@"[ERROR] No row is selected!");
        return;
    }
    
    NSDictionary *profileDict = [_tableViewProfilesItems objectAtIndex:selectedRow];
    if ( [ profileDict count] == 0 ) {
        NSLog(@"[ERROR] profile at index: %ld is empty!", (long)selectedRow);
        return;
    }
    
    NSString *profileCurrentName = profileDict[@"Config"][@"Name"];
    [_buttonSaveSheetProfileName setEnabled:NO];
    [_textFieldSheetProfileName setStringValue:profileCurrentName];
    [[NSApp mainWindow] beginSheet:_sheetProfileName completionHandler:^(NSModalResponse __unused returnCode) {
        
    }];
}

- (void)exportProfile {
    NSInteger idx = [_tableViewProfiles selectedRow];
    
    if ( 0 <= idx && idx <= [_tableViewProfilesItems count] ) {
        NSMutableDictionary *profileDict = [[_tableViewProfilesItems objectAtIndex:idx] mutableCopy];
        PFCProfileExportWindowController *exporter = [[PFCProfileExportWindowController alloc] initWithProfileDict:[profileDict copy] sender:self];
        if ( exporter ) {
            profileDict[@"Controller"] = exporter;
            [_tableViewProfilesItems replaceObjectAtIndex:idx withObject:[profileDict copy]];
            [[exporter window] makeKeyAndOrderFront:self];
        } else {
            NSLog(@"[ERROR] Problem creating export controller!");
        }
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark IBActions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)openProfileCreationWindow:(id)sender {
    NSInteger row = [sender clickedRow];
    if ( 0 <= row && row <= [_tableViewProfilesItems count] ) {
        NSMutableDictionary *profileDict = [_tableViewProfilesItems[row] mutableCopy];
        PFCProfileCreationWindowController *controller;
        if ( profileDict[@"Controller"] != nil ) {
            controller = profileDict[@"Controller"];
        } else {
            controller = [[PFCProfileCreationWindowController alloc] initWithProfileDict:[profileDict copy] sender:self];
            if ( controller ) {
                profileDict[@"Controller"] = controller;
                [_tableViewProfilesItems replaceObjectAtIndex:row withObject:[profileDict copy]];
            } else {
                NSLog(@"[ERROR] No Controller!");
            }
        }
        [[controller window] makeKeyAndOrderFront:self];
    }
}

- (void)showStatusNoProfiles {
    //[_viewTableViewProfilesSuperview setHidden:YES];
    [_viewNoProfiles setHidden:NO];
}

- (void)hideStatusNoProfiles {
    [_viewNoProfiles setHidden:YES];
    //[_viewTableViewProfilesSuperview setHidden:YES];
}

- (void)removeProfile {
    
    NSInteger index = [_tableViewProfiles selectedRow];
    
    if ( index < 0 ) {
        NSLog(@"No profile selected");
        return;
    }
    
    NSDictionary *profileDict = [_tableViewProfilesItems objectAtIndex:index];
    NSString *profileName = profileDict[@"Config"][@"Name"] ?: @"";
    
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:@"Cancel"];
    [alert addButtonWithTitle:@"Delete"];
    [alert setMessageText:@"Delete profile"];
    [alert setInformativeText:[NSString stringWithFormat:@"Are you sure you want to delete profile: %@?", profileName ]];
    [alert setAlertStyle:NSInformationalAlertStyle];
    [alert beginSheetModalForWindow:[self window] completionHandler:^(NSInteger returnCode) {
        if ( returnCode == NSAlertSecondButtonReturn ) { // Delete
            
            NSString *profilePath = profileDict[@"Path"];
            if ( [profilePath length] == 0 ) {
                NSLog(@"[ERROR] No path to profile!");
                return;
            }
            
            NSError *error = nil;
            NSURL *profileURL = [NSURL fileURLWithPath:profilePath];
            if ( ! [profileURL checkResourceIsReachableAndReturnError:&error] ) {
                NSLog(@"[ERROR] %@", [error localizedDescription]);
                return;
            } else {
                if ( [[NSFileManager defaultManager] removeItemAtURL:profileURL error:&error] ) {
                    [_tableViewProfilesItems removeObjectAtIndex:index];
                    [_tableViewProfiles removeRowsAtIndexes:[NSIndexSet indexSetWithIndex:index] withAnimation:NSTableViewAnimationEffectNone];
                    if ( [_tableViewProfilesItems count] == 0 ) {
                        [self showStatusNoProfiles];
                    }
                } else {
                    NSLog(@"[ERROR] %@", [error localizedDescription]);
                }
            }
        }
    }];
}

- (IBAction)buttonCancelSheetProfileName:(id)sender {
    [[NSApp mainWindow] endSheet:_sheetProfileName returnCode:NSModalResponseCancel];
    [_sheetProfileName orderOut:self];
}

- (IBAction)buttonSaveSheetProfileName:(id)sender {
    
    NSInteger selectedRow = [_tableViewProfiles selectedRow];
    if ( selectedRow < 0 ) {
        NSLog(@"[ERROR] No row is selected!");
        return;
    }
    
    NSMutableDictionary *profileDict = [[_tableViewProfilesItems objectAtIndex:selectedRow] mutableCopy];
    if ( [ profileDict count] == 0 ) {
        NSLog(@"[ERROR] profile at index: %ld is empty!", (long)selectedRow);
        return;
    }
    
    NSString *profilePath = profileDict[@"Path"];
    if ( [profilePath length] == 0 ) {
        NSLog(@"[ERROR] No path to profile!");
        return;
    }
    
    NSURL *profileURL = [NSURL fileURLWithPath:profilePath];
    
    NSString *profileCurrentName = profileDict[@"Config"][@"Name"];
    NSString *newName = [_textFieldSheetProfileName stringValue];
    [self renameProfileWithName:profileCurrentName newName:newName];
    
    NSMutableDictionary *configDict = [profileDict[@"Config"] mutableCopy];
    configDict[@"Name"] = newName;
    
    [configDict writeToURL:profileURL atomically:NO];
    [[NSApp mainWindow] endSheet:_sheetProfileName returnCode:NSModalResponseCancel];
    [_sheetProfileName orderOut:self];
}

@end
