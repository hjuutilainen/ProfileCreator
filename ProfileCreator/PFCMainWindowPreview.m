//
//  PFCMainWindowPayloadPreview.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-27.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCMainWindowPreview.h"
#import "PFCConstants.h"
#import "PFCLog.h"
#import "PFCManifestLibrary.h"
#import "PFCManifestUtility.h"
#import "PFCMainWindowPreviewPayload.h"

@interface PFCMainWindowPreview ()

@property (weak) IBOutlet NSScrollView *scrollViewProfilePreview;
@property (weak) IBOutlet NSTextField *textFieldProfileName;
@property (weak) IBOutlet NSTextField *textFieldPayloadCount;
@property (weak) IBOutlet NSTextField *textFieldPreviewSelectionUnavailable;
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

@property NSString *profileUUID;

- (IBAction) buttonProfileEdit:(id)sender;
- (IBAction) buttonProfileExport:(id)sender;

@end

@implementation PFCMainWindowPreview

- (id)initWithMainWindow:(PFCMainWindow *)mainWindow {
    self = [super initWithNibName:@"PFCMainWindowPreview" bundle:nil];
    if ( self != nil ) {
        [self view];
        _mainWindow = mainWindow;
        _arrayStackViewPreview = [[NSMutableArray alloc] init];
        _profilePreviewHidden = YES;
        _profilePreviewSelectionUnavailableHidden = YES;
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
}

- (void)showProfilePreview {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    [_viewPreviewSuperview setHidden:NO];
    [self setProfilePreviewHidden:NO];
    
    [_viewPreviewSelectionUnavailable setHidden:YES];
    [_textFieldPreviewSelectionUnavailable setStringValue:@""];
    [self setProfilePreviewSelectionUnavailableHidden:YES];
} // showProfilePreview

- (void)showProfilePreviewError {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    [_textFieldPreviewSelectionUnavailable setStringValue:@"Error Reading Selected Profile"];
    [_viewPreviewSelectionUnavailable setHidden:NO];
    [self setProfilePreviewSelectionUnavailableHidden:NO];
    
    [_viewPreviewSuperview setHidden:YES];
    [self setProfilePreviewHidden:YES];
    [self setProfileUUID:nil];
} // showProfilePreviewError

- (void)showProfilePreviewNoSelection {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    [_textFieldPreviewSelectionUnavailable setStringValue:@"No Profile Selected"];
    [_viewPreviewSelectionUnavailable setHidden:NO];
    [self setProfilePreviewSelectionUnavailableHidden:NO];
    
    [_viewPreviewSuperview setHidden:YES];
    [self setProfilePreviewHidden:YES];
    [self setProfileUUID:nil];
} // showProfilePreviewNoSelection

- (void)showProfilePreviewMultipleSelections:(NSNumber *)count {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    [_textFieldPreviewSelectionUnavailable setStringValue:[NSString stringWithFormat:@"%@ %@ Selected", [count stringValue], ([count intValue] == 1) ? @"Profile" : @"Profiles"]];
    [_viewPreviewSelectionUnavailable setHidden:NO];
    [self setProfilePreviewSelectionUnavailableHidden:NO];
    
    [_viewPreviewSuperview setHidden:YES];
    [self setProfilePreviewHidden:YES];
    [self setProfileUUID:nil];
} // showProfilePreviewNoSelection

- (IBAction)buttonProfileExport:(id)sender {
    if ( _mainWindow ) {
        [_mainWindow exportProfileWithUUID:_profileUUID];
    }
}

- (IBAction)buttonProfileEdit:(id)sender {
    if ( _mainWindow ) {
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
    for ( NSView *view in [_stackViewPreview views] ) {
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
    if ( [profileDisplaySettingsPlatform[PFCProfileDisplaySettingsKeyPlatformOSX] boolValue] ) {
        [platform appendString:@"OS X"];
        if (
            ! [profileDisplaySettingsPlatform[PFCProfileDisplaySettingsKeyPlatformOSXMinVersion] isEqualToString:@"10.7"] ||
            ! [profileDisplaySettingsPlatform[PFCProfileDisplaySettingsKeyPlatformOSXMaxVersion] isEqualToString:@"Latest"] ) {
            [platform appendString:[NSString stringWithFormat:@" (%@-%@)", profileDisplaySettingsPlatform[PFCProfileDisplaySettingsKeyPlatformOSXMinVersion] ?: @"10.7", profileDisplaySettingsPlatform[PFCProfileDisplaySettingsKeyPlatformOSXMaxVersion] ?: @"Latest"]];
        }
    }
    
    if ( [profileDisplaySettingsPlatform[PFCProfileDisplaySettingsKeyPlatformiOS] boolValue] ) {
        [platform appendString:[NSString stringWithFormat:@"%@iOS", ([platform length] == 0) ? @"" : @", "]];
        if (
            ! [profileDisplaySettingsPlatform[PFCProfileDisplaySettingsKeyPlatformiOSMinVersion] isEqualToString:@"7.0"] ||
            ! [profileDisplaySettingsPlatform[PFCProfileDisplaySettingsKeyPlatformiOSMaxVersion] isEqualToString:@"Latest"] ) {
            [platform appendString:[NSString stringWithFormat:@" (%@-%@)", profileDisplaySettingsPlatform[PFCProfileDisplaySettingsKeyPlatformiOSMinVersion] ?: @"7.0", profileDisplaySettingsPlatform[PFCProfileDisplaySettingsKeyPlatformiOSMaxVersion] ?: @"Latest"]];
        }
    }
    
    [_textFieldPlatform setStringValue:platform];
    DDLogDebug(@"Profile Platform: %@", platform);
    
    // -------------------------------------------------------------------------
    //  Supervised
    // -------------------------------------------------------------------------
    [_textFieldSupervised setStringValue:[NSString stringWithFormat:@"%@", ([profileDisplaySettings[PFCProfileDisplaySettingsKeySupervised] boolValue]) ? @"Yes" : @"No"]];
    DDLogDebug(@"Profile Supervised: %@", _textFieldSupervised);
    
    // -------------------------------------------------------------------------
    //  Sign
    // -------------------------------------------------------------------------
    [_textFieldSign setStringValue:[NSString stringWithFormat:@"%@", ([profileDisplaySettings[PFCProfileTemplateKeySign] boolValue]) ? @"Yes" : @"No"]];
    
    // -------------------------------------------------------------------------
    //  Encrypt
    // -------------------------------------------------------------------------
    [_textFieldEncrypt setStringValue:[NSString stringWithFormat:@"%@", ([profileDisplaySettings[PFCProfileTemplateKeyEncrypt] boolValue]) ? @"Yes" : @"No"]];
    
    NSMutableArray *selectedDomains = [[NSMutableArray alloc] init];
    for ( NSString *domain in [profileSettings[@"Settings"] allKeys] ?: @[] ) {
        DDLogDebug(@"Payload domain: %@", domain);
        
        NSDictionary *domainSettings = profileSettings[@"Settings"][domain];
        if ( ! [domain isEqualToString:@"com.apple.general"] && ! [domainSettings[PFCSettingsKeySelected] boolValue] ) {
            continue;
        }
        
        if ( [domain isEqualToString:@"com.apple.general"] || ( [domainSettings[PFCSettingsKeySelected] boolValue] && domainSettings[@"PayloadLibrary"] != nil ) ) {
            [selectedDomains addObject:domain];
            NSInteger payloadLibrary = [domainSettings[@"PayloadLibrary"] integerValue] ?: 0;
            DDLogDebug(@"Payload library: %ld", (long)payloadLibrary);
            
            NSDictionary *manifest = [[PFCManifestLibrary sharedLibrary] manifestFromLibrary:payloadLibrary withDomain:domain];
            if ( [manifest count] != 0 ) {
                PFCMainWindowPreviewPayload *preview = [self previewForMainfest:manifest domain:domain settings:domainSettings];
                [_arrayStackViewPreview addObject:preview];
                [_stackViewPreview addView:[preview view] inGravity:NSStackViewGravityTop];
            } else {
                DDLogError(@"No manifest returned from payload library: %ld with domain: %@", (long)payloadLibrary, domain);
            }
        } else {
            DDLogError(@"Payload is selected but doesn't contain a \"PayloadLibrary\"");
        }
    }
    
    // -------------------------------------------------------------------------
    //  Payload Count
    // -------------------------------------------------------------------------
    // FIXME - This is incorrect when multiple payloads are selected from the same manifest
    [_textFieldPayloadCount setStringValue:[NSString stringWithFormat:@"%lu %@", (unsigned long)[selectedDomains count], ([selectedDomains count] == 1) ? @"Payload" : @"Payloads" ]];
    
    if ( [selectedDomains count] <= 1 ) {
        [_textFieldExportError setStringValue:@"No Payload Selected"];
        [_buttonProfileExport setEnabled:NO];
        return;
    }
    
    if ( 0 < [_payloadErrorCount integerValue] ) {
        [_textFieldExportError setStringValue:[NSString stringWithFormat:@"%ld Payload %@ Need To Be Resolved", (long)[_payloadErrorCount integerValue], ([_payloadErrorCount integerValue] == 1) ? @"Error" : @"Errors" ]];
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
    if ( [settingsError count] != 0 ) {
        
        
        [settingsError enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
            errorCount += [[dict allKeys] count] ?: 0;
        }];
    }
    
    [self setPayloadErrorCount:@( [_payloadErrorCount integerValue] + errorCount )];
    
    DDLogDebug(@"Setting Payload Error Count: %@", [@(errorCount) stringValue]);
    [preview setPayloadErrorCount:[@(errorCount) stringValue]];
    
    
    NSImage *icon = [[PFCManifestUtility sharedUtility] iconForManifest:manifest];
    if ( icon ) {
        [preview setPayloadIcon:icon];
    }
    
    return preview;
} // previewForMainfest:domain

@end
