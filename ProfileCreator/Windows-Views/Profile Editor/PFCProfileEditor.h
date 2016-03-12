//
//  PFCProfileEditor.h
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

#import "PFCProfileEditorInfo.h"
#import "PFCProfileEditorLibrary.h"
#import "PFCProfileEditorManifest.h"
#import "PFCProfileEditorSettings.h"
#import "PFCSplitViews.h"
#import "PFCViews.h"
#import <Cocoa/Cocoa.h>
@class PFCMainWindow;

@interface PFCProfileEditor : NSWindowController <NSSplitViewDelegate, NSWindowDelegate, PFCProfileEditorInfoDelegate>

// -------------------------------------------------------------------------
//  Init
// -------------------------------------------------------------------------
- (id)initWithProfileDict:(NSDictionary *)profileDict mainWindow:(PFCMainWindow *)mainWindow;

// Set to yes when window is closing so all KVO observers of other classes than self will be removed
@property (readwrite) BOOL deallocKVO;

// -------------------------------------------------------------------------
//  Toolbar
// -------------------------------------------------------------------------
@property (weak) IBOutlet NSImageView *imageViewToolbar;
@property (weak) IBOutlet NSTextField *textFieldToolbar;

// -------------------------------------------------------------------------
//  Settings
// -------------------------------------------------------------------------
@property (strong) PFCProfileEditorSettings *settings;

// -------------------------------------------------------------------------
//  Library
// -------------------------------------------------------------------------
@property (strong) PFCProfileEditorLibrary *library;
@property (weak) IBOutlet PFCSplitViewPayloadLibrary *librarySplitView;

// -------------------------------------------------------------------------
//  Manifest
// -------------------------------------------------------------------------
@property (weak) IBOutlet NSView *viewManifestSplitView;
@property (strong) PFCProfileEditorManifest *manifest;
- (void)showManifest;
- (void)showManifestNoSettings;
- (void)hideManifestStatus;

// -------------------------------------------------------------------------
//  Info
// -------------------------------------------------------------------------
@property (strong) PFCProfileEditorInfo *info;

// -------------------------------------------------------------------------
//  SplitView
// -------------------------------------------------------------------------
@property (weak) IBOutlet NSSplitView *splitViewWindow;
- (void)uncollapseLibrary;

// -------------------------------------------------------------------------
//  Properties
// -------------------------------------------------------------------------
@property (readwrite) NSDictionary *profileDict;
@property (readwrite) NSMutableDictionary *profileSettings;
@property (readonly) BOOL librarySplitViewCollapsed;
@property (readonly) BOOL infoSplitViewCollapsed;
- (void)updateTableViewSelection:(NSString *)tableViewIdentifier;

@end
