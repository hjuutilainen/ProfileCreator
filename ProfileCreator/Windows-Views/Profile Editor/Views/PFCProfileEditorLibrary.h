//
//  PFCProfileEditorLibrary.h
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

#import "PFCProfileEditorLibraryMenu.h"
#import "PFCTableViews.h"
#import <Cocoa/Cocoa.h>
@class PFCProfileEditor;
@class RFOverlayScrollView;

@interface PFCProfileEditorLibrary : NSViewController <NSTableViewDelegate, NSTableViewDataSource>

@property PFCProfileEditorLibraryMenu *libraryMenu;

@property (weak) IBOutlet RFOverlayScrollView *scrollViewLibrary;
@property (weak) IBOutlet PFCTableView *tableViewProfile;
@property (weak) IBOutlet PFCTableView *tableViewLibrary;

@property (weak) IBOutlet NSView *viewProfile;
@property (weak) IBOutlet NSView *viewLibrary;
@property (weak) IBOutlet NSView *viewLibrarySearch;
@property (weak) IBOutlet NSView *viewLibraryMenu;

// Init
- (id)initWithProfileEditor:(PFCProfileEditor *)profileEditor;

// Library
- (void)selectLibrary:(PFCPayloadLibrary)library;
- (void)setArray:(NSArray *)array forLibrary:(PFCPayloadLibrary)library;

- (void)checkboxMenuEnabled:(NSButton *)checkbox;

// Manifest
- (void)reloadManifest:(NSDictionary *)manifest;
- (void)updateManifests;
- (IBAction)selectManifest:(id)sender;

@end
