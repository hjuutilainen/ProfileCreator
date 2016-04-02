//
//  PFCPreferences.m
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

#import "PFCGeneralUtility.h"
#import "PFCPreferences.h"
#import "PFCPreferencesGeneral.h"
#import "PFCPreferencesLogging.h"
#import "PFCPreferencesMCX.h"

@interface PFCPreferences ()

@property (weak) IBOutlet NSView *viewPreferences;

@property PFCPreferencesGeneral *general;
- (IBAction)toolbarItemGeneral:(id)sender;

@property PFCPreferencesMCX *mcx;
- (IBAction)toolbarItemMCX:(id)sender;

@property PFCPreferencesLogging *logging;
- (IBAction)toolbarItemLogging:(id)sender;

@end

@implementation PFCPreferences

- (id)init {
    self = [super initWithWindowNibName:@"PFCPreferences"];
    if (self != nil) {
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];

    [self setGeneral:[[PFCPreferencesGeneral alloc] init]];
    [self setMcx:[[PFCPreferencesMCX alloc] init]];
    [self setLogging:[[PFCPreferencesLogging alloc] init]];
    [self toolbarItemGeneral:nil];
}

- (IBAction)toolbarItemGeneral:(id)__unused sender {
    [self.window setTitle:@"General"];
    [PFCGeneralUtility removeSubviewsFromView:_viewPreferences];
    [self updateWindowSizeForView:[_general view]];
    [PFCGeneralUtility insertSubview:[_general view] inSuperview:_viewPreferences hidden:NO];
}

- (IBAction)toolbarItemMCX:(id)__unused sender {
    [self.window setTitle:@"MCX"];
    [PFCGeneralUtility removeSubviewsFromView:_viewPreferences];
    [self updateWindowSizeForView:[_mcx view]];
    [PFCGeneralUtility insertSubview:[_mcx view] inSuperview:_viewPreferences hidden:NO];
}

- (IBAction)toolbarItemLogging:(id)sender {
    [self.window setTitle:@"Logging"];
    [PFCGeneralUtility removeSubviewsFromView:_viewPreferences];
    [self updateWindowSizeForView:[_logging view]];
    [PFCGeneralUtility insertSubview:[_logging view] inSuperview:_viewPreferences hidden:NO];
}

- (void)updateWindowSizeForView:(NSView *)view {

    NSRect frame = self.window.frame;
    NSRect oldView = self.window.contentView.frame;
    NSRect newView = view.frame;

    frame.origin.y = frame.origin.y + (oldView.size.height - newView.size.height);
    frame.size.height = ((frame.size.height - oldView.size.height) + newView.size.height);

    [self.window setFrame:frame display:YES animate:YES];
}

@end
