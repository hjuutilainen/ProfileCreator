//
//  PFCProfileEditorManifestTab.h
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

#import <Cocoa/Cocoa.h>
@class PFCProfileEditorManifestTabView;

////////////////////////////////////////////////////////////////////////////////
#pragma mark PFCProfileEditorManifestTabDelegate
////////////////////////////////////////////////////////////////////////////////
@protocol PFCProfileEditorManifestTabDelegate
- (void)selectTab:(NSUInteger)tabIndex saveSettings:(BOOL)saveSettings sender:(id)sender;
- (BOOL)shouldCloseTab:(NSUInteger)tabIndex sender:(id)sender;
- (void)closeTab:(NSUInteger)tabIndex sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark PFCProfileEditorManifestTab
////////////////////////////////////////////////////////////////////////////////
@interface PFCProfileEditorManifestTab : NSViewController
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark PFCProfileEditorManifestTabView
////////////////////////////////////////////////////////////////////////////////
@interface PFCProfileEditorManifestTabView : NSView

// ------------------------------------------------------
//  Delegate
// ------------------------------------------------------
@property (nonatomic, weak) id delegate;

@property (weak) IBOutlet NSBox *borderBottom;
@property (weak) IBOutlet NSTextField *textFieldTitle;
@property (weak) IBOutlet NSTextField *textFieldErrorCount;
@property (weak) IBOutlet NSButton *buttonClose;
@property BOOL isSelected;
@property NSTrackingArea *trackingArea;

@property NSColor *colorSelected;
@property NSColor *colorDeSelected;
@property NSColor *colorDeSelectedMouseOver;
@property NSColor *color;

- (NSUInteger)tabIndex;
- (void)updateTitle:(NSString *)title;
- (void)updateErrorCount:(NSNumber *)errorCount;
- (IBAction)buttonClose:(id)sender;

@end
