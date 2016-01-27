//
//  PFCController.h
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

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "PFCProfileCreationWindowController.h"

typedef NS_ENUM(NSInteger, PFCFolders) {
    /** ProfileCreator in user application support **/
    kPFCFolderUserApplicationSupport = 0,
    /** Profile Save Folder **/
    kPFCFolderSavedProfiles
};

@interface PFCController : NSObject <NSApplicationDelegate, NSTableViewDelegate, NSTableViewDataSource>

@property (strong) IBOutlet NSWindow *sheetProfileName;
@property (weak) IBOutlet NSTextField *textFieldSheetProfileName;
- (IBAction)buttonCancelSheetProfileName:(id)sender;
@property (weak) IBOutlet NSButton *buttonSaveSheetProfileName;
- (IBAction)buttonSaveSheetProfileName:(id)sender;

@property (weak) IBOutlet NSWindow *window;

@property PFCProfileCreationWindowController *profileWindowController;

@property BOOL initialized; // Temporary
@property (weak) IBOutlet NSMenu *menuAdvancedOptions;

// Te be used when opening multiple profile windows
@property NSMutableDictionary *profileWindows;

@property (weak) IBOutlet NSView *viewTableViewProfilesSuperview;
@property (weak) IBOutlet NSView *viewNoProfiles;

@property (weak) IBOutlet NSTableView *tableViewProfiles;
@property NSMutableArray *tableViewProfilesItems;
@property NSMutableDictionary *savedProfiles;

@property (weak) IBOutlet NSSegmentedControl *segmentedControlAddRemove;
- (IBAction)segmentedControlAddRemove:(id)sender;

+ (NSString *)newProfilePath;
+ (NSURL *)profileCreatorFolder:(NSInteger)folder;
- (void)removeControllerForProfileDictWithName:(NSString *)name;
- (void)renameProfileWithName:(NSString *)name newName:(NSString *)newName;

@end
