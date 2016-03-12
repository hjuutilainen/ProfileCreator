//
//  PFCProfileEditor.m
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
#import "PFCError.h"
#import "PFCGeneralUtility.h"
#import "PFCLog.h"
#import "PFCMainWindow.h"
#import "PFCManifestLibrary.h"
#import "PFCManifestUtility.h"
#import "PFCProfileEditor.h"
#import "PFCProfileEditorInfo.h"
#import "PFCProfileEditorLibraryMenu.h"
#import "PFCProfileUtility.h"
#import "PFCSplitViews.h"
#import "PFCStatusView.h"

@interface PFCProfileEditor ()

@property (nonatomic, weak) PFCMainWindow *mainWindow;

// -------------------------------------------------------------------------
//  Toolbar
// -------------------------------------------------------------------------
@property (weak) IBOutlet NSView *viewWindow;

// -------------------------------------------------------------------------
//  Settings
// -------------------------------------------------------------------------
@property PFCStatusView *viewStatusSettings;
@property (weak) IBOutlet NSButton *buttonSettings;
- (IBAction)buttonSettings:(id)sender;
@property (weak) IBOutlet NSViewController *viewControllerDisplaySettings;

// -------------------------------------------------------------------------
//  Library
// -------------------------------------------------------------------------
@property (weak) IBOutlet NSView *viewLibrarySplitView;
@property (weak) IBOutlet NSView *viewLibraryProfileSplitView;
@property (weak) IBOutlet NSView *viewLibraryFooterSuperview;
@property (readwrite) BOOL librarySplitViewCollapsed;

// -------------------------------------------------------------------------
//  ManifestFooter
// -------------------------------------------------------------------------
@property (weak) IBOutlet NSPopover *popOverSettings;
@property (weak) IBOutlet NSButton *buttonCancel;
@property (weak) IBOutlet NSButton *buttonSave;
@property (weak) IBOutlet NSButton *buttonToggleInfo;

- (IBAction)buttonPopOverSettings:(id)sender;
- (IBAction)buttonCancel:(id)sender;
- (IBAction)buttonSave:(id)sender;
- (IBAction)buttonToggleInfo:(id)sender;

// -------------------------------------------------------------------------
//  Info
// -------------------------------------------------------------------------
@property PFCStatusView *viewStatusInfo;
@property (weak) IBOutlet NSView *viewInfoFooterSplitView; // FIXME - Not done yet
@property (weak) IBOutlet NSView *viewInfoSplitView;
@property (weak) IBOutlet NSView *viewInfoHeaderSplitView;
@property (readwrite) BOOL infoSplitViewCollapsed;

// -------------------------------------------------------------------------
//  Booleans
// -------------------------------------------------------------------------
@property (readwrite) BOOL windowShouldClose;

// -------------------------------------------------------------------------
//  Sheet ProfileName
// -------------------------------------------------------------------------
@property (strong) IBOutlet NSWindow *sheetProfileName;
@property (weak) IBOutlet NSTextField *textFieldSheetProfileNameTitle;
@property (weak) IBOutlet NSTextField *textFieldSheetProfileNameMessage;
@property (weak) IBOutlet NSTextField *textFieldSheetProfileName;
@property (weak) IBOutlet NSButton *buttonSaveSheetProfileName;

- (IBAction)buttonCancelSheetProfileName:(id)sender;
- (IBAction)buttonSaveSheetProfileName:(id)sender;

@end

@implementation PFCProfileEditor

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id)initWithProfileDict:(NSDictionary *)profileDict mainWindow:(PFCMainWindow *)mainWindow {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    self = [super initWithWindowNibName:@"PFCProfileEditor"];
    if (self != nil) {

        // ---------------------------------------------------------------------
        //  Initialize Passed Objects
        // ---------------------------------------------------------------------
        _mainWindow = mainWindow;
        _profileDict = profileDict ?: @{};

        // ---------------------------------------------------------------------
        //  Initialize Settings
        // ---------------------------------------------------------------------
        _profileSettings = [profileDict[@"Config"][PFCProfileTemplateKeySettings] mutableCopy] ?: [[NSMutableDictionary alloc] init];

        // ---------------------------------------------------------------------
        //  Initialize Views
        // ---------------------------------------------------------------------
        _settings = [[PFCProfileEditorSettings alloc] initWithProfile:profileDict profileEditor:self];
        _library = [[PFCProfileEditorLibrary alloc] initWithProfileEditor:self];
        _manifest = [[PFCProfileEditorManifest alloc] initWithProfileEditor:self];

        _viewStatusSettings = [[PFCStatusView alloc] init];
        _viewStatusInfo = [[PFCStatusView alloc] initWithStatusType:kPFCStatusNoSelection];

        // FIXME - Not done yet
        _info = [[PFCProfileEditorInfo alloc] initWithDelegate:self];

        // ---------------------------------------------------------------------
        //  Initialize BOOLs (for clarity)
        // ---------------------------------------------------------------------
        _windowShouldClose = NO;
        _deallocKVO = NO;
    }
    return self;
} // init

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ViewSetup
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)windowDidLoad {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    [super windowDidLoad];

    // -------------------------------------------------------------------------
    //  Set window delegate to self to respond to -(void)windowShouldClose
    //  Also set window background color to white
    // -------------------------------------------------------------------------
    [[self window] setDelegate:self];
    [[self window] setBackgroundColor:[NSColor whiteColor]];
    [[self window] setTitleVisibility:NSWindowTitleHidden];

    // -------------------------------------------------------------------------
    //  Library
    // -------------------------------------------------------------------------
    [PFCGeneralUtility insertSubview:[_library viewProfile] inSuperview:_viewLibraryProfileSplitView hidden:NO];
    [PFCGeneralUtility insertSubview:[_library viewLibrary] inSuperview:_viewLibrarySplitView hidden:NO];
    [PFCGeneralUtility insertSubview:[_library viewLibrarySearch] inSuperview:_viewLibraryFooterSuperview hidden:NO];

    // -------------------------------------------------------------------------
    //  Manifest
    // -------------------------------------------------------------------------
    [PFCGeneralUtility insertSubview:[_manifest view] inSuperview:_viewManifestSplitView hidden:NO];
    [PFCGeneralUtility insertSubview:[_viewStatusSettings view] inSuperview:_viewManifestSplitView hidden:YES];
    [PFCGeneralUtility insertSubview:[_settings view] inSuperview:_viewManifestSplitView hidden:YES];
    [_viewControllerDisplaySettings setView:[_manifest viewPopUpDisplaySettings]];

    // -------------------------------------------------------------------------
    //  Info
    // -------------------------------------------------------------------------
    [PFCGeneralUtility insertSubview:[_info view] inSuperview:_viewInfoSplitView hidden:YES];
    [PFCGeneralUtility insertSubview:[[_info infoMenu] view] inSuperview:_viewInfoHeaderSplitView hidden:NO];
    [PFCGeneralUtility insertSubview:[_viewStatusInfo view] inSuperview:_viewInfoSplitView hidden:NO];

    // -------------------------------------------------------------------------
    //  Perform Initial Setup
    // -------------------------------------------------------------------------
    [self windowSetup];
} // windowDidLoad

- (void)windowSetup {

    // -------------------------------------------------------------------------
    //  Setup Main SplitView
    // -------------------------------------------------------------------------
    [self collapseSplitViewInfo];

    // -------------------------------------------------------------------------
    //  Set first responder depending on profile state
    // -------------------------------------------------------------------------
    [self setFirstResponder];

} // windowSetup

- (void)setFirstResponder {

    // -------------------------------------------------------------------------
    //  If this is a new profile (profile name is the Default name)
    //  Select profile settings and set profile name setting as first responder
    // -------------------------------------------------------------------------
    if ([[_settings profileName] isEqualToString:PFCDefaultProfileName]) {
        [self buttonSettings:self];
        [[self window] setInitialFirstResponder:[_settings textFieldProfileName]];
    } else {

        // ---------------------------------------------------------------------------
        //  If this is an already saved profile (profile name is NOT the Default name)
        //  Select manifest General in payload profile
        // ---------------------------------------------------------------------------
        [[_library tableViewProfile] selectRowIndexes:[NSIndexSet indexSetWithIndex:0] byExtendingSelection:NO];
        [_library selectManifest:[_library tableViewProfile]];
        [[self window] setInitialFirstResponder:[_library tableViewProfile]];
    }
} // setFirstResponder

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSWindow Delegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (BOOL)windowShouldClose:(id)sender {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    // ------------------------------------------------------------------------------------
    //  Check if property (BOOL)windowShouldClose is true
    //  If true the user has seen this warning and acted upon it, and the window can close
    // ------------------------------------------------------------------------------------
    if (_windowShouldClose) {
        [self setDeallocKVO:YES];
        [self setWindowShouldClose:NO];
        [_mainWindow closeProfileEditorForProfileWithUUID:_profileDict[@"Config"][PFCProfileTemplateKeyUUID]];
        return YES;
    }

    if ([self settingsSaved]) {
        [self setDeallocKVO:YES];
        [self setWindowShouldClose:NO];
        [_mainWindow closeProfileEditorForProfileWithUUID:_profileDict[@"Config"][PFCProfileTemplateKeyUUID]];
        return YES;
    } else {

        // ---------------------------------------------------------------------
        //  Show modal alert if there are any unsaved settings
        // ---------------------------------------------------------------------
        NSAlert *alert = [[NSAlert alloc] init];
        [alert addButtonWithTitle:@"Save & Close"];
        [alert addButtonWithTitle:@"Close"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setMessageText:@"Unsaved Settings"];
        [alert setInformativeText:@"If you close this window, all unsaved settings will be lost. Are you sure you want to close the window?"];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert beginSheetModalForWindow:[self window]
                      completionHandler:^(NSInteger returnCode) {

                        // Save & Close
                        if (returnCode == NSAlertFirstButtonReturn) {
                            [self setWindowShouldClose:YES];
                            [self buttonSave:self];

                            // Close
                        } else if (returnCode == NSAlertSecondButtonReturn) {
                            [self setWindowShouldClose:YES];
                            [self performSelectorOnMainThread:@selector(closeWindow) withObject:self waitUntilDone:NO];

                            // Cancel
                        } else if (returnCode == NSAlertThirdButtonReturn) {
                            [self setWindowShouldClose:NO];
                        }
                      }];
        return NO;
    }
} // windowShouldClose

- (void)closeWindow {
    [[self window] performClose:self];
} // closeWindow

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSSPlitView Delegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (BOOL)splitView:(NSSplitView *)splitView shouldAdjustSizeOfSubview:(NSView *)view {
    if (splitView == _splitViewWindow) {
        if (view == [_splitViewWindow subviews][1]) {
            return YES;
        }
        return NO;
    }
    return YES;
} // splitView:shouldAdjustSizeOfSubview

- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if (splitView == _librarySplitView && dividerIndex == 0) {
        return proposedMaximumPosition - 96;
    } else if (splitView == _splitViewWindow) {
        if (dividerIndex == 0) {
            return proposedMaximumPosition - 510;
        } else if (dividerIndex == 1) {
            return proposedMaximumPosition - 220;
        }
    }

    return proposedMaximumPosition;
} // splitView:constrainMaxCoordinate:ofSubviewAt

- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex {
    if (splitView == _librarySplitView && dividerIndex == 0) {
        return proposedMinimumPosition + 88;
    } else if (splitView == _splitViewWindow) {
        if (dividerIndex == 0) {
            return proposedMinimumPosition + 220;
        } else if (dividerIndex == 1) {
            return proposedMinimumPosition + 510;
        }
    }
    return proposedMinimumPosition;
} // splitView:constrainMinCoordinate:ofSubviewAt

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview {
    if ((splitView == _librarySplitView && subview == _viewLibrarySplitView) || (splitView == _splitViewWindow && subview == [[_splitViewWindow subviews] lastObject])) {
        return YES;
    }
    return NO;
} // splitView:canCollapseSubview

- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex {
    if (splitView == _splitViewWindow && dividerIndex == 1) {
        return [_splitViewWindow isSubviewCollapsed:[_splitViewWindow subviews][2]];
    }
    return NO;
} // splitView:shouldHideDividerAtIndex

- (NSRect)splitView:(NSSplitView *)splitView additionalEffectiveRectOfDividerAtIndex:(NSInteger)dividerIndex {
    // FIXME - This only catches half the divider, I don't know how to split up the divider rects in 3 (and also keep the 1 pixel across the top)
    if (splitView == _librarySplitView) {
        NSRect viewBounds = [[[_library libraryMenu] view] bounds];
        NSRect viewButtonBounds = [[[_library libraryMenu] viewButtons] bounds];
        CGFloat dividerSpace = ((viewBounds.size.width - viewButtonBounds.size.width) / 2);
        // NSRect leftRect = NSMakeRect(0, 0, dividerSpace, viewBounds.size.height);
        NSRect rightRect = NSMakeRect((viewBounds.size.width - dividerSpace), 0, dividerSpace, viewBounds.size.height);
        return [[[_library libraryMenu] view] convertRect:rightRect fromView:splitView];
        // return [[_viewPayloadLibraryMenu view] convertRect:[[_viewPayloadLibraryMenu view] bounds] fromView:splitView]; // <-- Entire divider
    }
    return NSZeroRect;
}

- (void)splitViewDidResizeSubviews:(NSNotification *)notification {
    if ([notification object] == _librarySplitView) {
        if ([_librarySplitView isSubviewCollapsed:[_librarySplitView subviews][1]]) {
            [self hideLibrarySearch];
        } else if (_librarySplitViewCollapsed) {
            [self showLibrarySearch];
        }
    }
} // splitViewDidResizeSubviews

- (void)controlTextDidChange:(NSNotification *)sender {
    NSDictionary *userInfo = [sender userInfo];
    NSString *inputText = [[userInfo valueForKey:@"NSFieldEditor"] string];

    if ([[sender object] isEqualTo:_textFieldSheetProfileName]) {
        if ([inputText hasPrefix:@"Untitled Profile"] || [[[PFCProfileUtility sharedUtility] allProfileNamesExceptProfileWithUUID:nil] containsObject:inputText] || [inputText length] == 0) {
            [_buttonSaveSheetProfileName setEnabled:NO];
        } else {
            [_buttonSaveSheetProfileName setEnabled:YES];
        }
        return;
    }
} // controlTextDidChangex

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark SplitView Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)collapseLibrary {
    // FIXME - Write this for when opening an imported profile or locally installed profile
} // collapsePayloadLibrary

- (void)uncollapseLibrary {

    // -------------------------------------------------------------------------
    //  Get the instances, frames and sizes of the subviews
    // -------------------------------------------------------------------------
    NSView *profilePayloads = [_librarySplitView subviews][0];
    NSRect profilePayloadsFrame = [profilePayloads frame];

    NSView *payloadLibrary = [_librarySplitView subviews][1];
    NSRect payloadLibraryFrame = [payloadLibrary frame];

    CGFloat dividerThickness = [_librarySplitView dividerThickness];

    // -------------------------------------------------------------------------
    //  Calculate new sizes for the subviews
    // -------------------------------------------------------------------------
    profilePayloadsFrame.size.height = (profilePayloadsFrame.size.height - payloadLibraryFrame.size.height - dividerThickness);
    payloadLibraryFrame.origin.x = profilePayloadsFrame.size.height + dividerThickness;

    // -------------------------------------------------------------------------
    //  Set new sizes
    // -------------------------------------------------------------------------
    [profilePayloads setFrameSize:profilePayloadsFrame.size];
    [payloadLibrary setFrame:payloadLibraryFrame];

    // -------------------------------------------------------------------------
    //  Update the UI
    // -------------------------------------------------------------------------
    [payloadLibrary setHidden:NO];
    [_librarySplitView display];

    // -------------------------------------------------------------------------
    //  Update the property
    // -------------------------------------------------------------------------
    [self setLibrarySplitViewCollapsed:NO];
} // uncollapsePayloadLibrary

- (void)collapseSplitViewInfo {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    // -------------------------------------------------------------------------
    //  Get the instances, frames and sizes of the subviews
    // -------------------------------------------------------------------------
    NSView *viewInfo = [_splitViewWindow subviews][2];
    NSView *viewCenter = [_splitViewWindow subviews][1];
    NSRect viewCenterFrame = [viewCenter frame];

    NSRect splitViewWindowFrame = [_splitViewWindow frame];

    // -------------------------------------------------------------------------
    //  Set new sizes
    // -------------------------------------------------------------------------
    [viewCenter setFrameSize:NSMakeSize(splitViewWindowFrame.size.width, viewCenterFrame.size.height)];

    // -------------------------------------------------------------------------
    //  Update the UI
    // -------------------------------------------------------------------------
    [viewInfo setHidden:YES];
    [_splitViewWindow display];

    // -------------------------------------------------------------------------
    //  Update the property
    // -------------------------------------------------------------------------
    [self setInfoSplitViewCollapsed:YES];
} // collapseSplitViewInfo

- (void)uncollapseSplitViewInfo {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    // -------------------------------------------------------------------------
    //  Get the instances, frames and sizes of the subviews
    // -------------------------------------------------------------------------
    NSView *viewCenter = [_splitViewWindow subviews][1];
    NSRect viewCenterFrame = [viewCenter frame];

    NSView *viewInfo = [_splitViewWindow subviews][2];
    NSRect viewInfoFrame = [viewInfo frame];

    CGFloat dividerThickness = [_librarySplitView dividerThickness];

    // -------------------------------------------------------------------------
    //  Calculate new sizes for the subviews
    // -------------------------------------------------------------------------
    viewCenterFrame.size.height = (viewCenterFrame.size.height - viewInfoFrame.size.height - dividerThickness);
    viewInfoFrame.origin.x = viewCenterFrame.size.height + dividerThickness;

    // -------------------------------------------------------------------------
    //  Set new sizes
    // -------------------------------------------------------------------------
    [viewCenter setFrameSize:viewCenterFrame.size];
    [viewInfo setFrame:viewInfoFrame];

    // -------------------------------------------------------------------------
    //  Update the UI
    // -------------------------------------------------------------------------
    [viewInfo setHidden:NO];
    [_splitViewWindow display];

    // -------------------------------------------------------------------------
    //  Update the property
    // -------------------------------------------------------------------------
    [self setInfoSplitViewCollapsed:NO];
} // uncollapseSplitViewInfo

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Saving
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (BOOL)settingsSaved {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    // -------------------------------------------------------------------------
    //  Check if there's a path saved for the profile
    // -------------------------------------------------------------------------
    NSString *profilePath = _profileDict[PFCRuntimeKeyPath];
    if ([profilePath length] == 0) {
        return NO;
    }

    // -------------------------------------------------------------------------
    //  Check if the path saved exists
    // -------------------------------------------------------------------------
    NSURL *profileURL = [NSURL fileURLWithPath:profilePath];
    if (![profileURL checkResourceIsReachableAndReturnError:nil]) {
        return NO;
    }

    // ---------------------------------------------------------------------------
    //  Check that all settings in the template on disk math the current settings
    // ---------------------------------------------------------------------------
    NSDictionary *profileDict = [NSDictionary dictionaryWithContentsOfURL:profileURL];
    if ([profileDict count] == 0) {
        return NO;
    } else {
        [_manifest saveSelectedManifest];

        // FIXME - Maybe check all before returning for logging purposes?

        DDLogDebug(@"Saved 'Name': %@", profileDict[PFCProfileTemplateKeyName]);
        DDLogDebug(@"Current 'Name': %@", [_settings profileName]);

        if (![profileDict[PFCProfileTemplateKeyName] isEqualToString:[_settings profileName]]) {
            return NO;
        }

        DDLogDebug(@"Saved 'UUID': %@", profileDict[PFCProfileTemplateKeyUUID]);
        DDLogDebug(@"Current 'UUID': %@", [_settings profileUUID]);

        if (![profileDict[PFCProfileTemplateKeyUUID] isEqualToString:[_settings profileUUID]]) {
            return NO;
        }

        // FIXME - Should this be a single dict, or is this ok? Should I be rewrite how settings are handled.

        DDLogDebug(@"Saved 'DisplaySettings': %@", profileDict[PFCProfileTemplateKeyDisplaySettings]);
        DDLogDebug(@"Current 'DisplaySettings': %@", [self currentDisplaySettings]);

        if (![profileDict[PFCProfileTemplateKeyDisplaySettings] isEqualToDictionary:[self currentDisplaySettings] ?: @{}]) {
            return NO;
        }

        DDLogDebug(@"Saved 'Settings': %@", profileDict[PFCProfileTemplateKeySettings]);
        DDLogDebug(@"Current 'Settings' : %@", _profileSettings);

        if (![profileDict[PFCProfileTemplateKeySettings] isEqualToDictionary:_profileSettings]) {
            return NO;
        }
    }

    return YES;
} // settingsSaved

- (BOOL)saveProfile:(NSError **)error {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    // -------------------------------------------------------------------------
    //  Save the selected manifest settings before saving the profile template
    // -------------------------------------------------------------------------
    [_manifest saveSelectedManifest];

    // -------------------------------------------------------------------------
    //  Create the profile template save folder if it does not exist
    // -------------------------------------------------------------------------
    NSURL *savedProfilesFolderURL = [PFCGeneralUtility profileCreatorFolder:kPFCFolderSavedProfiles];
    DDLogDebug(@"Profiles save folder: %@", [savedProfilesFolderURL path]);
    if (![savedProfilesFolderURL checkResourceIsReachableAndReturnError:nil]) {
        if (![[NSFileManager defaultManager] createDirectoryAtURL:savedProfilesFolderURL withIntermediateDirectories:YES attributes:nil error:error]) {
            return NO;
        }
    }

    // ----------------------------------------------------------------------------
    //  Get the path to this profile template, or if never saved create a new path
    // ----------------------------------------------------------------------------
    NSString *profilePath = _profileDict[PFCRuntimeKeyPath];
    if ([profilePath length] == 0) {
        profilePath = [PFCGeneralUtility newProfilePath];
    }
    NSURL *profileURL = [NSURL fileURLWithPath:profilePath];
    DDLogDebug(@"Profile save path: %@", [profileURL path]);

    NSMutableDictionary *profileDict = [_profileDict mutableCopy] ?: [[NSMutableDictionary alloc] init];
    NSMutableDictionary *configurationDict = [_profileDict[@"Config"] mutableCopy] ?: [[NSMutableDictionary alloc] init];

    // ---------------------------------------------------------------------------------
    //  Verify all domains have a saved UUID to reuse if updating the profie
    //  This way the updated profile gets updated (overwritten) instead of added as new
    // ---------------------------------------------------------------------------------
    NSMutableDictionary *settingsProfile = [_profileSettings mutableCopy];
    for (NSString *domain in [settingsProfile allKeys] ?: @[]) {
        NSMutableArray *manifestSettings = [[NSMutableArray alloc] init];
        NSMutableDictionary *domainSettings = [settingsProfile[domain] mutableCopy] ?: [[NSMutableDictionary alloc] init];
        for (NSDictionary *settings in settingsProfile[domain][@"Settings"] ?: @[]) {
            NSMutableDictionary *settingsMutable = [settings mutableCopy];
            NSDictionary *manifest = [[[PFCManifestLibrary sharedLibrary] manifestsWithDomains:@[ domain ]] firstObject] ?: @{};
            if ([manifest[PFCManifestKeyPayloadTypes] count] == 0) {
                DDLogError(@"Manifest with domain: %@ is missing the required %@ array. Please add that to enable manifest for export.", manifest[PFCManifestKeyDomain], PFCManifestKeyPayloadTypes);
            } else {
                for (NSString *payloadType in manifest[PFCManifestKeyPayloadTypes] ?: @[]) {
                    if ([settingsMutable[payloadType] count] == 0) {
                        settingsMutable[payloadType] = @{ PFCManifestKeyPayloadVersion : @1, @"UUID" : [[NSUUID UUID] UUIDString] };
                    }
                }
            }
            [manifestSettings addObject:[settingsMutable copy]];
        }
        domainSettings[@"Settings"] = [manifestSettings copy];
        settingsProfile[domain] = [domainSettings copy];
    }

    [self setProfileSettings:[settingsProfile mutableCopy]];
    configurationDict[PFCProfileTemplateKeyName] = [_settings profileName] ?: @"";
    configurationDict[PFCProfileTemplateKeyIdentifier] = [_settings profileIdentifier] ?: @"";
    configurationDict[PFCProfileTemplateKeySign] = @([_settings signProfile]);
    configurationDict[PFCProfileTemplateKeyEncrypt] = @([_settings encryptProfile]);
    configurationDict[PFCProfileTemplateKeyIdentifierFormat] = [_settings profileIdentifierFormat] ?: PFCDefaultProfileIdentifierFormat;
    configurationDict[PFCProfileTemplateKeySettings] = [settingsProfile copy];
    configurationDict[PFCProfileTemplateKeyDisplaySettings] = [self currentDisplaySettings] ?: @{};

    // -------------------------------------------------------------------------
    //  Write the profile template to disk and update
    // -------------------------------------------------------------------------
    if ([configurationDict writeToURL:profileURL atomically:YES]) {
        profileDict[@"Config"] = [configurationDict copy];
        [self setProfileDict:[profileDict copy]];

        // ---------------------------------------------------------------------
        //  Update main window with new settings for the saved profile
        // ---------------------------------------------------------------------
        [_mainWindow updateProfileWithUUID:_profileDict[@"Config"][PFCProfileTemplateKeyUUID] ?: @""];
        return YES;
    } else {
        // FIXME - Should notify the user that the save failed!
        DDLogError(@"Saving profile template failed!");
        return NO;
    }
} // saveProfile

- (NSDictionary *)currentDisplaySettings {
    NSMutableDictionary *displaySettings = [[NSMutableDictionary alloc] init];

    displaySettings[PFCProfileDisplaySettingsKeyAdvancedSettings] = @([_settings showAdvancedSettings]);
    displaySettings[PFCProfileDisplaySettingsKeySupervised] = @([_settings showKeysSupervised]);
    displaySettings[PFCProfileDisplaySettingsKeyPlatform] = @{
        PFCProfileDisplaySettingsKeyPlatformOSX : @([_settings includePlatformOSX]),
        PFCProfileDisplaySettingsKeyPlatformOSXMaxVersion : [_settings osxMaxVersion] ?: @"",
        PFCProfileDisplaySettingsKeyPlatformOSXMinVersion : [_settings osxMinVersion] ?: @"",
        PFCProfileDisplaySettingsKeyPlatformiOS : @([_settings includePlatformiOS]),
        PFCProfileDisplaySettingsKeyPlatformiOSMaxVersion : [_settings iosMaxVersion] ?: @"",
        PFCProfileDisplaySettingsKeyPlatformiOSMinVersion : [_settings iosMinVersion] ?: @""
    };
    return [displaySettings copy];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UI Updates
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)showLibrarySearch {
    [self setLibrarySplitViewCollapsed:NO];
    [[_library viewLibrarySearch] setHidden:NO];
    [PFCGeneralUtility insertSubview:[[_library libraryMenu] view] inSuperview:[_library viewLibraryMenu] hidden:NO];
} // showLibrarySearch

- (void)hideLibrarySearch {
    [self setLibrarySplitViewCollapsed:YES];
    [[_library viewLibrarySearch] setHidden:YES];
    [PFCGeneralUtility insertSubview:[[_library libraryMenu] view] inSuperview:_viewLibraryFooterSuperview hidden:NO];
} // hideLibrarySearch

- (void)showSettings {
    [[_settings view] setHidden:NO];
    [[_manifest view] setHidden:YES];
    [[_viewStatusSettings view] setHidden:YES];
} // showSettings

- (void)showManifest {
    [[_manifest view] setHidden:NO];
    if (![[_settings view] isHidden]) {
        [[_settings view] setHidden:YES];
    }
    [[_viewStatusSettings view] setHidden:YES];
} // showManifest

- (void)showManifestLoading {
    [_viewStatusSettings showStatus:kPFCStatusLoadingSettings];
    [[_settings view] setHidden:YES];
    [[_manifest view] setHidden:YES];
    [[_viewStatusSettings view] setHidden:NO];
} // showManifestLoading

- (void)showManifestError {
    [_viewStatusSettings showStatus:kPFCStatusErrorReadingSettings];
    [[_settings view] setHidden:YES];
    [[_manifest view] setHidden:YES];
    [[_viewStatusSettings view] setHidden:NO];
} // showManifestError

- (void)showManifestNoSettings {
    [_viewStatusSettings showStatus:kPFCStatusNoSettings];
    [[_settings view] setHidden:YES];
    [[_manifest view] setHidden:YES];
} // showManifestNoSettings

- (void)hideManifestStatus {
    [[_viewStatusSettings view] setHidden:YES];
    [[_settings view] setHidden:YES];
    [[_manifest view] setHidden:NO];
} // hideManifestStatus

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark IBActions
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (IBAction)buttonCancel:(id)sender {
    [[self window] performClose:self];
} // buttonCancel

- (IBAction)buttonCancelSheetProfileName:(id)sender {
    [[NSApp mainWindow] endSheet:_sheetProfileName returnCode:NSModalResponseCancel];
    [_sheetProfileName orderOut:self];
} // buttonCancelSheetProfileName

- (IBAction)buttonPopOverSettings:(id)sender {
    [_popOverSettings showRelativeToRect:[sender bounds] ofView:sender preferredEdge:NSMinYEdge];
} // buttonPopOverSettings

- (IBAction)buttonSave:(id)sender {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    if ([[_settings profileName] hasPrefix:@"Untitled Profile"]) {

        [_buttonSaveSheetProfileName setEnabled:NO];
        [_textFieldSheetProfileNameTitle setStringValue:@"Invalid Name"];
        [_textFieldSheetProfileNameMessage setStringValue:@"You have to choose a name for your profile."];
        [_textFieldSheetProfileName setStringValue:[_settings profileName] ?: PFCDefaultProfileName];

        [[NSApp mainWindow] beginSheet:_sheetProfileName
                     completionHandler:^(NSModalResponse returnCode) {
                       if (returnCode == NSModalResponseOK && _windowShouldClose) {
                           [self performSelectorOnMainThread:@selector(closeWindow) withObject:self waitUntilDone:NO];
                       } else if (_windowShouldClose) {
                           [self setWindowShouldClose:NO];
                       }
                     }];
    } else if ([[[PFCProfileUtility sharedUtility] allProfileNamesExceptProfileWithUUID:[_settings profileUUID]] containsObject:[_settings profileName]]) {

        [_buttonSaveSheetProfileName setEnabled:NO];
        [_textFieldSheetProfileNameTitle setStringValue:@"Invalid Name"];
        [_textFieldSheetProfileNameMessage
            setStringValue:[NSString stringWithFormat:@"There already exist a profile with name: \"%@\". Please choose a unique name for your profile.", [_settings profileName]]];
        [_textFieldSheetProfileName setStringValue:[_settings profileName] ?: PFCDefaultProfileName];

        [[NSApp mainWindow] beginSheet:_sheetProfileName
                     completionHandler:^(NSModalResponse returnCode) {
                       if (returnCode == NSModalResponseOK && _windowShouldClose) {
                           [self performSelectorOnMainThread:@selector(closeWindow) withObject:self waitUntilDone:NO];
                       } else if (_windowShouldClose) {
                           [self setWindowShouldClose:NO];
                       }
                     }];
    } else {
        NSError *error = nil;
        if ([self saveProfile:&error]) {
            if (_windowShouldClose) {
                [self performSelectorOnMainThread:@selector(closeWindow) withObject:self waitUntilDone:NO];
            }
        } else {
            DDLogError(@"Save Error: %@", [error localizedDescription]);
            if (_windowShouldClose) {
                [self setWindowShouldClose:NO];
            }
        }
    }
} // buttonSave

- (IBAction)buttonSaveSheetProfileName:(id)sender {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    // -------------------------------------------------------------------------
    //  Get new name from text filed in sheet
    // -------------------------------------------------------------------------
    NSString *newName = [_textFieldSheetProfileName stringValue] ?: @"";

    // -----------------------------------------------------------------------------
    //  Update the profile dict stored in this window controller with the same name
    // -----------------------------------------------------------------------------
    NSMutableDictionary *profileDict = [_profileDict mutableCopy];
    NSMutableDictionary *configDict = [_profileDict[@"Config"] mutableCopy];
    configDict[PFCProfileTemplateKeyName] = newName;
    profileDict[@"Config"] = [configDict copy];
    [self setProfileDict:[profileDict copy]];

    // -----------------------------------------------------------------------------------------
    //  Update the profile name property (Profile Name TextField in the Profile Editor Window)
    // -----------------------------------------------------------------------------------------
    [_settings setProfileName:newName];

    // -------------------------------------------------------------------------
    //  Save profile settings to disk
    // -------------------------------------------------------------------------
    NSError *error = nil;
    if ([self saveProfile:&error]) {
        [[NSApp mainWindow] endSheet:_sheetProfileName returnCode:NSModalResponseOK];
    } else {
        DDLogError(@"Save Error: %@", [error localizedDescription]);
        [[NSApp mainWindow] endSheet:_sheetProfileName returnCode:NSModalResponseCancel];
    }
    [_sheetProfileName orderOut:self];
} // buttonSaveSheetProfileName

- (IBAction)buttonToggleInfo:(id)sender {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    /*
     BOOL isCollapsed = [_splitViewWindow isSubviewCollapsed:[_splitViewWindow subviews][2]];
     DDLogDebug(@"View info is collapsed: %@", isCollapsed ? @"YES" : @"NO");

     NSView *viewInfo = [_splitViewWindow subviews][2];

     // -------------------------------------------------------------------------
     //  Set the holding priorities for window resizing
     // -------------------------------------------------------------------------
     NSLayoutPriority viewCenterPruiority = [_splitViewWindow holdingPriorityForSubviewAtIndex:1];
     NSLayoutPriority viewInfoPriority = [_splitViewWindow holdingPriorityForSubviewAtIndex:2];
     [_splitViewWindow setHoldingPriority:NSLayoutPriorityDefaultHigh forSubviewAtIndex:1];
     [_splitViewWindow setHoldingPriority:1 forSubviewAtIndex:2];

     // -------------------------------------------------------------------------
     //  Update window size
     // -------------------------------------------------------------------------
     NSRect windowFrame = [[self window] frame];
     CGFloat minimumSize = 1.0f;
     if ( isCollapsed ) {

     // -------------------------------------------------------------------------
     //  Uncollapse
     // -------------------------------------------------------------------------
     [_splitViewWindow setPosition:minimumSize ofDividerAtIndex:1];
     windowFrame.size.width += minimumSize;
     windowFrame.origin.x -= minimumSize;
     [[self window] setFrame:windowFrame display:YES animate:NO];

     CGFloat expandedWidth = 220;
     windowFrame.size.width += expandedWidth;
     windowFrame.origin.x -= expandedWidth;
     [[self window] setFrame:windowFrame display:YES animate:YES];
     } else {

     // -------------------------------------------------------------------------
     //  Animate the window smaller
     // -------------------------------------------------------------------------
     windowFrame.size.width -= NSWidth(viewInfo.frame) - minimumSize;
     //windowFrame.origin.x += NSWidth(viewInfo.frame) - minimumSize;
     [[self window] setFrame:windowFrame display:YES animate:YES];

     // -------------------------------------------------------------------------
     //  Collapse it
     // -------------------------------------------------------------------------
     [_splitViewWindow setPosition:0 ofDividerAtIndex:1];
     windowFrame.size.width -= minimumSize;
     //windowFrame.origin.x += minimumSize;
     [[self window] setFrame:windowFrame display:YES animate:NO];
     }

     [_splitViewWindow setHoldingPriority:viewInfoPriority forSubviewAtIndex:2];
     [_splitViewWindow setHoldingPriority:viewCenterPruiority forSubviewAtIndex:1];
     */

    if ([_splitViewWindow isSubviewCollapsed:[_splitViewWindow subviews][2]]) {
        [self uncollapseSplitViewInfo];
    } else {
        [self collapseSplitViewInfo];
    }
} // buttonToggleInfo

- (void)updateTableViewSelection:(NSString *)tableViewIdentifier {
    if ([tableViewIdentifier isEqualToString:@"Profile"]) {
        [[_library tableViewLibrary] deselectAll:self];
    } else if ([tableViewIdentifier isEqualToString:@"Library"]) {
        [[_library tableViewProfile] deselectAll:self];
    }
}

- (IBAction)buttonSettings:(id)sender {
    [_manifest updateToolbarWithTitle:@"Profile Settings" icon:[[NSWorkspace sharedWorkspace] iconForFileType:@"com.apple.mobileconfig"]];
    [_manifest saveSelectedManifest];
    [self showSettings];
    [[_library tableViewLibrary] deselectAll:self];
    [[_library tableViewProfile] deselectAll:self];
}
@end
