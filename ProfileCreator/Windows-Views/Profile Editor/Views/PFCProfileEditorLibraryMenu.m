//
//  PFCProfileEditorLibraryMenu.m
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
#import "PFCManifestLibrary.h"
#import "PFCProfileEditorLibrary.h"
#import "PFCProfileEditorLibraryMenu.h"

@interface PFCProfileEditorLibraryMenu ()

@property (nonatomic, weak) PFCProfileEditorLibrary *library;

@property (weak) IBOutlet NSButton *buttonLibraryApple;
- (IBAction)buttonLibraryApple:(id)sender;

@property (weak) IBOutlet NSButton *buttonLibraryLocal;
- (IBAction)buttonLibraryLocal:(id)sender;

@property (weak) IBOutlet NSButton *buttonLibraryMCX;
- (IBAction)buttonLibraryMCX:(id)sender;

@property (weak) IBOutlet NSButton *buttonLibraryCustom;
- (IBAction)buttonLibraryCustom:(id)sender;

@end

@implementation PFCProfileEditorLibraryMenu

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark init/dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id)initWithProfileEditorLibrary:(PFCProfileEditorLibrary *)profileEditorLibrary {
    self = [super initWithNibName:@"PFCProfileEditorLibraryMenu" bundle:nil];
    if (self != nil) {
        _library = profileEditorLibrary;
    }
    return self;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark View Setup
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)viewDidLoad {
    [super viewDidLoad];
    [_buttonLibraryApple setState:NSOnState];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark IBActions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (IBAction)buttonLibraryApple:(id)sender {
    [_buttonLibraryApple setState:NSOnState]; // On
    [_buttonLibraryLocal setState:NSOffState];
    [_buttonLibraryMCX setState:NSOffState];
    [_buttonLibraryCustom setState:NSOffState];
    [_library selectLibrary:kPFCPayloadLibraryApple];
}

- (IBAction)buttonLibraryCustom:(id)sender {
    [_buttonLibraryApple setState:NSOffState];
    [_buttonLibraryLocal setState:NSOffState];
    [_buttonLibraryMCX setState:NSOffState];
    [_buttonLibraryCustom setState:NSOnState]; // On
    [_library selectLibrary:kPFCPayloadLibraryCustom];
}

- (IBAction)buttonLibraryLocal:(id)sender {
    [_buttonLibraryApple setState:NSOffState];
    [_buttonLibraryLocal setState:NSOnState]; // On
    [_buttonLibraryMCX setState:NSOffState];
    [_buttonLibraryCustom setState:NSOffState];
    [_library selectLibrary:kPFCPayloadLibraryUserPreferences];
}

- (IBAction)buttonLibraryMCX:(id)sender {
    [_buttonLibraryApple setState:NSOffState];
    [_buttonLibraryLocal setState:NSOffState];
    [_buttonLibraryMCX setState:NSOnState]; // On
    [_buttonLibraryCustom setState:NSOffState];
    [_library selectLibrary:kPFCPayloadLibraryMCX];
}

@end
