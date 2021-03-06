//
//  PFCMainWindowPreview.m
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

#import "PFCConstants.h"
#import "PFCLog.h"
#import "PFCMainWindowPreview.h"
#import "PFCMainWindowPreviewPayload.h"
#import "PFCManifestLibrary.h"
#import "PFCManifestUtility.h"

@interface PFCMainWindowPreview ()

@property (weak) IBOutlet NSScrollView *scrollViewProfilePreview;
@property (weak) IBOutlet NSTextField *textFieldProfileName;
@property (weak) IBOutlet NSTextField *textFieldPayloadCount;
@property (weak) IBOutlet NSTextField *textFieldExportError;
@property (weak) IBOutlet NSTextField *textFieldPlatform;
@property (weak) IBOutlet NSTextField *textFieldSupervised;
@property (weak) IBOutlet NSTextField *textFieldSign;
@property (weak) IBOutlet NSTextField *textFieldEncrypt;
@property (weak) IBOutlet NSStackView *stackViewPreview;
@property NSNumber *payloadErrorCount;
@property (strong) NSArray *stackViewPreviewConstraints;
@property NSMutableArray *arrayStackViewPreview;
@property PFCMainWindow *mainWindow;
@property (weak) IBOutlet NSButton *buttonProfileEdit;
@property (weak) IBOutlet NSButton *buttonProfileExport;
@property (weak) IBOutlet NSImageView *imageViewProfileIcon;
@property NSString *profileUUID;

- (IBAction)buttonProfileEdit:(id)sender;
- (IBAction)buttonProfileExport:(id)sender;

@end

@implementation PFCMainWindowPreview

- (id)initWithMainWindow:(PFCMainWindow *)mainWindow {
    self = [super initWithNibName:@"PFCMainWindowPreview" bundle:nil];
    if (self != nil) {
        [self view];
        _mainWindow = mainWindow;

        _viewStatus = [[PFCStatusView alloc] initWithStatusType:kPFCStatusNoProfileSelected];

        _arrayStackViewPreview = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupProfilePreview];
}

- (void)setupProfilePreview {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    [_scrollViewProfilePreview setDocumentView:_stackViewPreview];

    NSDictionary *viewsDict = NSDictionaryOfVariableBindings(_stackViewPreview);
    _stackViewPreviewConstraints = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_stackViewPreview]-0-|" options:0 metrics:nil views:viewsDict];
    [_scrollViewProfilePreview addConstraints:_stackViewPreviewConstraints];

    [self showProfilePreviewNoSelection];

    NSImage *profileIcon = [[NSWorkspace sharedWorkspace] iconForFileType:@"com.apple.mobileconfig"];
    if (profileIcon) {
        [_imageViewProfileIcon setImage:profileIcon];
    }
}

- (void)showProfilePreview {
    [_viewPreviewSuperview setHidden:NO];
    [[_viewStatus view] setHidden:YES];
} // showProfilePreview

- (void)showProfilePreviewError {
    [_viewStatus showStatus:kPFCStatusErrorReadingSettings];
    [_viewPreviewSuperview setHidden:YES];
    [self setProfileUUID:nil];
} // showProfilePreviewError

- (void)showProfilePreviewNoSelection {
    [_viewStatus showStatus:kPFCStatusNoProfileSelected];
    [_viewPreviewSuperview setHidden:YES];
    [self setProfileUUID:nil];
} // showProfilePreviewNoSelection

- (void)showProfilePreviewMultipleSelections:(NSNumber *)count {
    [_viewStatus setCounter:count];
    [_viewStatus showStatus:kPFCStatusMultipleProfilesSelected];
    [_viewPreviewSuperview setHidden:YES];
    [self setProfileUUID:nil];
} // showProfilePreviewNoSelection

- (IBAction)buttonProfileExport:(id)sender {
    if (_mainWindow) {
        [_mainWindow exportProfileWithUUID:_profileUUID];
    }
}

- (IBAction)buttonProfileEdit:(id)sender {
    if (_mainWindow) {
        [_mainWindow openProfileEditorForProfileWithUUID:_profileUUID];
    }
}

- (void)updatePreviewWithProfileDict:(NSDictionary *)profileDict {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    // -------------------------------------------------------------------------
    //  Clean up previous preview content
    // -------------------------------------------------------------------------
    [self setPayloadErrorCount:@0];
    [_arrayStackViewPreview removeAllObjects];
    for (NSView *view in [_stackViewPreview views]) {
        [view removeFromSuperview];
    }

    NSDictionary *profileSettings = profileDict[@"Config"];
    NSDictionary *profileDisplaySettings = profileSettings[PFCProfileTemplateKeyDisplaySettings];

    // -------------------------------------------------------------------------
    //  UUID
    // -------------------------------------------------------------------------
    [self setProfileUUID:profileSettings[PFCProfileTemplateKeyUUID]];

    // -------------------------------------------------------------------------
    //  Name
    // -------------------------------------------------------------------------
    NSString *profileName = profileSettings[PFCProfileTemplateKeyName];
    [_textFieldProfileName setStringValue:profileName ?: @""];
    DDLogDebug(@"Profile Name: %@", profileName);

    // -------------------------------------------------------------------------
    //  Platform
    // -------------------------------------------------------------------------
    NSDictionary *profileDisplaySettingsPlatform = profileDisplaySettings[PFCProfileDisplaySettingsKeyPlatform];
    NSMutableString *platform = [[NSMutableString alloc] init];
    if ([profileDisplaySettingsPlatform[PFCProfileDisplaySettingsKeyPlatformOSX] boolValue]) {
        [platform appendString:@"OS X"];
        if (![profileDisplaySettingsPlatform[PFCProfileDisplaySettingsKeyPlatformOSXMinVersion] isEqualToString:@"10.7"] ||
            ![profileDisplaySettingsPlatform[PFCProfileDisplaySettingsKeyPlatformOSXMaxVersion] isEqualToString:@"Latest"]) {
            [platform appendString:[NSString stringWithFormat:@" (%@-%@)", profileDisplaySettingsPlatform[PFCProfileDisplaySettingsKeyPlatformOSXMinVersion] ?: @"10.7",
                                                              profileDisplaySettingsPlatform[PFCProfileDisplaySettingsKeyPlatformOSXMaxVersion] ?: @"Latest"]];
        }
    }

    if ([profileDisplaySettingsPlatform[PFCProfileDisplaySettingsKeyPlatformiOS] boolValue]) {
        [platform appendString:[NSString stringWithFormat:@"%@iOS", ([platform length] == 0) ? @"" : @", "]];
        if (![profileDisplaySettingsPlatform[PFCProfileDisplaySettingsKeyPlatformiOSMinVersion] isEqualToString:@"7.0"] ||
            ![profileDisplaySettingsPlatform[PFCProfileDisplaySettingsKeyPlatformiOSMaxVersion] isEqualToString:@"Latest"]) {
            [platform appendString:[NSString stringWithFormat:@" (%@-%@)", profileDisplaySettingsPlatform[PFCProfileDisplaySettingsKeyPlatformiOSMinVersion] ?: @"7.0",
                                                              profileDisplaySettingsPlatform[PFCProfileDisplaySettingsKeyPlatformiOSMaxVersion] ?: @"Latest"]];
        }
    }

    [_textFieldPlatform setStringValue:platform];
    DDLogDebug(@"Profile Platform: %@", platform);

    // -------------------------------------------------------------------------
    //  Supervised
    // -------------------------------------------------------------------------
    [_textFieldSupervised setStringValue:[NSString stringWithFormat:@"%@", ([profileDisplaySettings[PFCProfileDisplaySettingsKeySupervised] boolValue]) ? @"Yes" : @"No"]];
    DDLogDebug(@"Profile Supervised: %@", [_textFieldSupervised stringValue]);

    // -------------------------------------------------------------------------
    //  Sign
    // -------------------------------------------------------------------------
    [_textFieldSign setStringValue:[NSString stringWithFormat:@"%@", ([profileDisplaySettings[PFCProfileTemplateKeySign] boolValue]) ? @"Yes" : @"No"]];

    // -------------------------------------------------------------------------
    //  Encrypt
    // -------------------------------------------------------------------------
    [_textFieldEncrypt setStringValue:[NSString stringWithFormat:@"%@", ([profileDisplaySettings[PFCProfileTemplateKeyEncrypt] boolValue]) ? @"Yes" : @"No"]];

    NSMutableArray *selectedDomains = [[NSMutableArray alloc] init];
    for (NSString *domain in [profileSettings[@"Settings"] allKeys] ?: @[]) {
        DDLogDebug(@"Payload domain: %@", domain);

        NSDictionary *domainSettings = profileSettings[@"Settings"][domain];
        if (![domain isEqualToString:PFCManifestDomainGeneral] && ![domainSettings[PFCSettingsKeySelected] boolValue]) {
            continue;
        }

        if ([domain isEqualToString:PFCManifestDomainGeneral] || [domainSettings[PFCSettingsKeySelected] boolValue]) {
            [selectedDomains addObject:domain];

            // FIXME - This is inelegant and error prone. Shouldn't rely on the moanifest domain as it MAY be duplicated from the generated manifests. Possibly use UUID instead.
            NSDictionary *manifest = [[PFCManifestLibrary sharedLibrary] manifestFromLibrary:kPFCPayloadLibraryAll withDomain:domain];
            if (manifest.count != 0) {
                PFCMainWindowPreviewPayload *preview = [self previewForMainfest:manifest domain:domain settings:domainSettings];
                [_arrayStackViewPreview addObject:preview];
                [_stackViewPreview addView:preview.view inGravity:NSStackViewGravityTop];
            } else {
                DDLogError(@"No manifest returned for domain: %@", domain);
            }
        } else {
            DDLogError(@"Payload is selected but doesn't contain a \"PayloadLibrary\"");
        }
    }

    // -------------------------------------------------------------------------
    //  Payload Count
    // -------------------------------------------------------------------------
    // FIXME - This is incorrect when multiple payloads are selected from the same manifest
    [_textFieldPayloadCount setStringValue:[NSString stringWithFormat:@"%lu %@", (unsigned long)selectedDomains.count, (selectedDomains.count == 1) ? @"Payload" : @"Payloads"]];

    if (selectedDomains.count <= 1) {
        [_textFieldExportError setStringValue:@"No Payload Selected"];
        [_buttonProfileExport setEnabled:NO];
        return;
    }

    if (0 < _payloadErrorCount.integerValue) {
        [_textFieldExportError
            setStringValue:[NSString stringWithFormat:@"%ld Payload %@ Need To Be Resolved", (long)_payloadErrorCount.integerValue, (_payloadErrorCount.integerValue == 1) ? @"Error" : @"Errors"]];
        [_buttonProfileExport setEnabled:NO];
        return;
    }

    [_textFieldExportError setStringValue:@""];
    [_buttonProfileExport setEnabled:YES];
}

- (PFCMainWindowPreviewPayload *)previewForMainfest:(NSDictionary *)manifest domain:(NSString *)domain settings:(NSDictionary *)settings {

    PFCMainWindowPreviewPayload *preview = [[PFCMainWindowPreviewPayload alloc] init];

    [preview setPayloadName:manifest[PFCManifestKeyTitle] ?: domain];
    [preview setPayloadDescription:manifest[PFCManifestKeyDescription] ?: @""];

    // -------------------------------------------------------------------------
    //  Error Count
    // -------------------------------------------------------------------------
    NSArray *settingsError = settings[@"SettingsError"] ?: @[];
    __block NSInteger errorCount = 0;
    if (settingsError.count != 0) {

        [settingsError enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull dict, NSUInteger idx, BOOL *_Nonnull stop) {
          errorCount += dict.allKeys.count ?: 0;
        }];
    }

    [self setPayloadErrorCount:@([_payloadErrorCount integerValue] + errorCount)];

    DDLogDebug(@"Setting Payload Error Count: %@", [@(errorCount) stringValue]);
    [preview setPayloadErrorCount:[@(errorCount) stringValue]];

    NSImage *icon = [[PFCManifestUtility sharedUtility] iconForManifest:manifest];
    if (icon) {
        [preview setPayloadIcon:icon];
    }

    return preview;
} // previewForMainfest:domain

@end
