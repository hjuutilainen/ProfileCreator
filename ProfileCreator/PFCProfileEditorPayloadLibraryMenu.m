//
//  PFCProfileEditorPayloadLibraryMenu.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-25.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCGeneralUtility.h"
#import "PFCProfileEditorPayloadLibraryMenu.h"

@interface PFCProfileEditorPayloadLibraryMenu ()

@property (nonatomic, weak) PFCProfileEditor *profileEditor;

@property (weak) IBOutlet NSButton *buttonLibraryApple;
- (IBAction)buttonLibraryApple:(id)sender;

@property (weak) IBOutlet NSButton *buttonLibraryLocal;
- (IBAction)buttonLibraryLocal:(id)sender;

@property (weak) IBOutlet NSButton *buttonLibraryMCX;
- (IBAction)buttonLibraryMCX:(id)sender;

@property (weak) IBOutlet NSButton *buttonLibraryCustom;
- (IBAction)buttonLibraryCustom:(id)sender;

@end

@implementation PFCProfileEditorPayloadLibraryMenu

- (id)initWithProfileEditor:(PFCProfileEditor *)profileEditor {
    self = [super initWithNibName:@"PFCProfileEditorPayloadLibraryMenu" bundle:nil];
    if (self != nil) {
        _profileEditor = profileEditor;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [_buttonLibraryApple setState:NSOnState];
}

- (IBAction)buttonLibraryApple:(id)sender {
    [_buttonLibraryMCX setState:NSOffState];
    [_buttonLibraryCustom setState:NSOffState];
    [_buttonLibraryLocal setState:NSOffState];
    [_profileEditor selectPayloadLibrary:kPFCPayloadLibraryApple];
}

- (IBAction)buttonLibraryCustom:(id)sender {
    [_buttonLibraryMCX setState:NSOffState];
    [_buttonLibraryApple setState:NSOffState];
    [_buttonLibraryLocal setState:NSOffState];
    [_profileEditor selectPayloadLibrary:kPFCPayloadLibraryCustom];
}

- (IBAction)buttonLibraryLocal:(id)sender {
    [_buttonLibraryMCX setState:NSOffState];
    [_buttonLibraryApple setState:NSOffState];
    [_buttonLibraryCustom setState:NSOffState];
    [_profileEditor selectPayloadLibrary:kPFCPayloadLibraryUserPreferences];
}

- (IBAction)buttonLibraryMCX:(id)sender {
    [_buttonLibraryApple setState:NSOffState];
    [_buttonLibraryLocal setState:NSOffState];
    [_buttonLibraryCustom setState:NSOffState];
    [_profileEditor selectPayloadLibrary:kPFCPayloadLibraryMCX];
}

@end
