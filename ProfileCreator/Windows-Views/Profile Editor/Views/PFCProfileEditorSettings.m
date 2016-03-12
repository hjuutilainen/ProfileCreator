//
//  PFCProfileEditorSettings.m
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
#import "PFCGeneralUtility.h"
#import "PFCLog.h"
#import "PFCProfileEditor.h"
#import "PFCProfileEditorSettings.h"

@interface PFCProfileEditorSettings ()

@property NSDictionary *profile;

@property (nonatomic, weak) PFCProfileEditor *profileEditor;

// Advanced Settings
@property BOOL showAdvancedSettings;

// Target Platform
@property NSArray *osxVersions;
@property (weak) IBOutlet NSButton *checkboxPlatformOSX;
@property (weak) IBOutlet NSPopUpButton *popUpButtonPlatformOSXMinVersion;
@property (weak) IBOutlet NSPopUpButton *popUpButtonPlatformOSXMaxVersion;

@property NSArray *iosVersions;
@property (weak) IBOutlet NSButton *checkboxPlatformiOS;
@property (weak) IBOutlet NSPopUpButton *popUpButtonPlatformiOSMinVersion;
@property (weak) IBOutlet NSPopUpButton *popUpButtonPlatformiOSMaxVersion;

// Security
@property (weak) IBOutlet NSPopUpButton *popUpButtonCertificateSigning;
@property (weak) IBOutlet NSPopUpButton *popUpButtonCertificateEncryption;

@property (weak) IBOutlet NSTextField *textFieldProfileIdentifier;
@property (weak) IBOutlet NSTextField *textFieldProfileIdentifierFormat;

@end

@implementation PFCProfileEditorSettings

- (id)initWithProfile:(NSDictionary *)profile profileEditor:(PFCProfileEditor *)profileEditor {
    self = [super initWithNibName:@"PFCProfileEditorSettings" bundle:nil];
    if (self != nil) {
        _profile = profile;
        _profileEditor = profileEditor;

        _showKeysSupervised = NO;
        [self view];
    }
    return self;
} // init

- (void)dealloc {
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(osxMinVersion))];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(osxMaxVersion))];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(iosMinVersion))];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(iosMaxVersion))];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(osxMinVersion)) options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(osxMaxVersion)) options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(iosMinVersion)) options:NSKeyValueObservingOptionNew context:nil];
    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(iosMaxVersion)) options:NSKeyValueObservingOptionNew context:nil];
    [self setupSettings];
    [self setupPopUpButtonOsVersion];
    [self setupDisplaySettings];
}

- (void)setupSettings {
    [self setProfileName:_profile[@"Config"][PFCProfileTemplateKeyName] ?: PFCDefaultProfileName];
    [self setProfileUUID:_profile[@"Config"][PFCProfileTemplateKeyUUID] ?: [[NSUUID UUID] UUIDString]];
    [self setProfileIdentifierFormat:_profile[@"Config"][PFCProfileTemplateKeyIdentifierFormat] ?: PFCDefaultProfileIdentifierFormat];
    [self setProfileIdentifier:[self expandVariablesInString:_profileIdentifierFormat overrideValues:nil]];
} // setupProfileSettings

- (void)selectOSVersion:(NSMenuItem *)menuItem {
    NSMenu *menu = [menuItem menu];
    if (menu == [_popUpButtonPlatformOSXMinVersion menu]) {
        [self setOsxMinVersion:[menuItem title]];
    } else if (menu == [_popUpButtonPlatformOSXMaxVersion menu]) {
        [self setOsxMaxVersion:[menuItem title]];
    } else if (menu == [_popUpButtonPlatformiOSMinVersion menu]) {
        [self setIosMinVersion:[menuItem title]];
    } else if (menu == [_popUpButtonPlatformiOSMaxVersion menu]) {
        [self setIosMaxVersion:[menuItem title]];
    }
} // selectOSVersion

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Validating Menu Items
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (BOOL)validateMenuItem:(NSMenuItem *)menuItem {
    NSMenu *menu = [menuItem menu];
    if (menu == [_popUpButtonPlatformOSXMinVersion menu]) {
        return [PFCGeneralUtility version:[menuItem title] isLowerThanVersion:_osxMaxVersion];
    } else if (menu == [_popUpButtonPlatformOSXMaxVersion menu]) {
        return [PFCGeneralUtility version:_osxMinVersion isLowerThanVersion:[menuItem title]];
    } else if (menu == [_popUpButtonPlatformiOSMinVersion menu]) {
        return [PFCGeneralUtility version:[menuItem title] isLowerThanVersion:_iosMaxVersion];
    } else if (menu == [_popUpButtonPlatformiOSMaxVersion menu]) {
        return [PFCGeneralUtility version:_iosMinVersion isLowerThanVersion:[menuItem title]];
    }
    return YES;
} // validateMenuItem

- (NSDictionary *)displayKeys {
    return @{
        PFCProfileDisplaySettingsKeyPlatformOSX : @(_includePlatformOSX),
        PFCProfileDisplaySettingsKeyPlatformOSXMaxVersion : _osxMaxVersion ?: @"",
        PFCProfileDisplaySettingsKeyPlatformOSXMinVersion : _osxMinVersion ?: @"",
        PFCProfileDisplaySettingsKeyPlatformiOS : @(_includePlatformiOS),
        PFCProfileDisplaySettingsKeyPlatformiOSMaxVersion : _iosMaxVersion ?: @"",
        PFCProfileDisplaySettingsKeyPlatformiOSMinVersion : _iosMinVersion ?: @"",
        PFCManifestKeyDisabled : @([[_profileEditor manifest] showKeysDisabled]),
        PFCManifestKeyHidden : @([[_profileEditor manifest] showKeysHidden]),
        PFCManifestKeySupervisedOnly : @(_showKeysSupervised)
    };
} // displayKeys

- (void)setupPopUpButtonOsVersion {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    // -------------------------------------------------------------------------
    //  Create base menu
    // -------------------------------------------------------------------------
    NSMenu *menu = [[NSMenu alloc] init];
    [menu setAutoenablesItems:YES];

    // -------------------------------------------------------------------------
    //  MenuItem: Latest
    // -------------------------------------------------------------------------
    NSMenuItem *menuItemLatest = [[NSMenuItem alloc] init];
    [menuItemLatest setTarget:self];
    [menuItemLatest setAction:@selector(selectOSVersion:)];
    [menuItemLatest setTitle:@"Latest"];
    [menu addItem:menuItemLatest];

    // -------------------------------------------------------------------------
    //  MenuItem: Separator
    // -------------------------------------------------------------------------
    [menu addItem:[NSMenuItem separatorItem]];

    // -------------------------------------------------------------------------
    //  Read OSVersions plist from bundle contents
    // -------------------------------------------------------------------------
    // FIXME - This should be a downloadable setting, read from appsupport first
    NSError *error = nil;
    NSURL *osVersionsPlistURL = [[NSBundle mainBundle] URLForResource:@"OSVersions" withExtension:@"plist"];
    if (![osVersionsPlistURL checkResourceIsReachableAndReturnError:&error]) {
        DDLogError(@"%@", [error localizedDescription]);
        return;
    }

    NSDictionary *osVersions = [NSDictionary dictionaryWithContentsOfURL:osVersionsPlistURL];
    if ([osVersions count] == 0) {
        DDLogError(@"OS Versions dict was empty!");
        return;
    }

    // -------------------------------------------------------------------------
    //  Create OS X versions menu and add to popUpButtons for OS X
    // -------------------------------------------------------------------------
    NSArray *osVersionsOSX = osVersions[@"OS X"] ?: @[];
    if ([osVersionsOSX count] == 0) {
        DDLogError(@"OS Versions array for OS X is empty!");
    } else {

        NSMenu *menuOSX = [menu copy];
        NSArray *osxVersionArray;
        int lastMajorVersion = 0;
        NSMenuItem *menuItemOSXVersion = [[NSMenuItem alloc] init];
        [menuItemOSXVersion setTarget:self];
        [menuItemOSXVersion setAction:@selector(selectOSVersion:)];
        for (NSString *osxVersion in osVersionsOSX) {

            // -----------------------------------------------------------------
            //  Add separator if major version of OS changed
            // -----------------------------------------------------------------
            osxVersionArray = [osxVersion componentsSeparatedByString:@"."];
            if (2 <= [osxVersionArray count]) {
                int majorVersion = [(NSString *)osxVersionArray[1] intValue];
                if (lastMajorVersion != majorVersion) {
                    [menuOSX addItem:[NSMenuItem separatorItem]];
                    lastMajorVersion = majorVersion;
                }
            }
            [menuItemOSXVersion setTitle:osxVersion];
            [menuOSX addItem:[menuItemOSXVersion copy]];
        }

        [_popUpButtonPlatformOSXMinVersion setMenu:[menuOSX copy]];
        [_popUpButtonPlatformOSXMaxVersion setMenu:[menuOSX copy]];
    }

    // -------------------------------------------------------------------------
    //  Create iOS versions menu and add to popUpButtons for iOS
    // -------------------------------------------------------------------------
    NSArray *osVersionsiOS = osVersions[@"iOS"] ?: @[];
    if ([osVersionsiOS count] == 0) {
        DDLogError(@"OS Versions array for iOS is empty!");
    } else {

        NSMenu *menuiOS = [menu copy];
        NSArray *iosVersionArray;
        int lastMajorVersion = 0;
        NSMenuItem *menuItemiOSVersion = [[NSMenuItem alloc] init];
        [menuItemiOSVersion setTarget:self];
        [menuItemiOSVersion setAction:@selector(selectOSVersion:)];
        for (NSString *iosVersion in osVersionsiOS) {

            // -----------------------------------------------------------------
            //  Add separator if major version of OS changed
            // -----------------------------------------------------------------
            iosVersionArray = [iosVersion componentsSeparatedByString:@"."];
            if (1 <= [iosVersionArray count]) {
                int majorVersion = [(NSString *)iosVersionArray[0] intValue];
                if (lastMajorVersion != majorVersion) {
                    [menuiOS addItem:[NSMenuItem separatorItem]];
                    lastMajorVersion = majorVersion;
                }
            }
            [menuItemiOSVersion setTitle:iosVersion];
            [menuiOS addItem:[menuItemiOSVersion copy]];
        }

        [_popUpButtonPlatformiOSMinVersion setMenu:[menuiOS copy]];
        [_popUpButtonPlatformiOSMaxVersion setMenu:[menuiOS copy]];
    }
} // setupPopUpButtonOsVersion

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)__unused object change:(NSDictionary *)change context:(void *)__unused context {
    if ([@[ @"osxMinVersion", @"osxMaxVersion", @"iosMinVersion", @"iosMaxVersion" ] containsObject:keyPath]) {
        [[_profileEditor library] updateManifests];
    }
}

- (void)controlTextDidChange:(NSNotification *)sender {

    NSDictionary *userInfo = [sender userInfo];
    NSString *inputText = [[userInfo valueForKey:@"NSFieldEditor"] string];

    if ([[sender object] isEqualTo:_textFieldProfileName]) {
        [self setProfileIdentifier:[self expandVariablesInString:_profileIdentifierFormat overrideValues:@{ @"%NAME%" : inputText }]];
        return;
    }
}

- (void)setupDisplaySettings {
    DDLogDebug(@"%s", __PRETTY_FUNCTION__);
    NSDictionary *displaySettings = _profile[@"Config"][PFCProfileTemplateKeyDisplaySettings] ?: @{};

    // -------------------------------------------------------------------------
    //  Set "Advanced Settings" and "Supervised"
    // -------------------------------------------------------------------------
    // FIXME - What is this trying to do?
    //[self setShowAdvancedSettings:[displaySettings[PFCProfileDisplaySettingsKeyAdvancedSettings] boolValue]];
    [self setShowKeysSupervised:[displaySettings[PFCProfileDisplaySettingsKeySupervised] boolValue]];

    NSDictionary *platform = displaySettings[PFCProfileDisplaySettingsKeyPlatform] ?: @{};
    // -------------------------------------------------------------------------
    //  Platform: OS X
    // -------------------------------------------------------------------------
    [self setIncludePlatformOSX:[platform[PFCProfileDisplaySettingsKeyPlatformOSX] boolValue]];
    NSString *osxMaxVersion = platform[PFCProfileDisplaySettingsKeyPlatformOSXMaxVersion] ?: @"";
    if ([osxMaxVersion length] != 0 && [[_popUpButtonPlatformOSXMaxVersion itemTitles] containsObject:osxMaxVersion]) {
        [self setOsxMaxVersion:osxMaxVersion];
    } else {
        [self setOsxMaxVersion:@"Latest"];
    }
    [_popUpButtonPlatformOSXMaxVersion selectItemWithTitle:_osxMaxVersion];

    NSString *osxMinVersion = platform[PFCProfileDisplaySettingsKeyPlatformOSXMinVersion] ?: @"";
    if ([osxMinVersion length] != 0 && [[_popUpButtonPlatformOSXMinVersion itemTitles] containsObject:osxMinVersion]) {
        [self setOsxMinVersion:osxMinVersion];
    } else {
        [self setOsxMinVersion:@"10.7"];
    }
    [_popUpButtonPlatformOSXMinVersion selectItemWithTitle:_osxMinVersion];

    // -------------------------------------------------------------------------
    //  Platform: iOS
    // -------------------------------------------------------------------------
    [self setIncludePlatformiOS:[platform[PFCProfileDisplaySettingsKeyPlatformiOS] boolValue]];
    NSString *iosMaxVersion = platform[PFCProfileDisplaySettingsKeyPlatformiOSMaxVersion] ?: @"";
    if ([iosMaxVersion length] != 0 && [[_popUpButtonPlatformiOSMaxVersion itemTitles] containsObject:iosMaxVersion]) {
        [self setIosMaxVersion:iosMaxVersion];
    } else {
        [self setIosMaxVersion:@"Latest"];
    }
    [_popUpButtonPlatformiOSMaxVersion selectItemWithTitle:_iosMaxVersion];

    NSString *iosMinVersion = platform[PFCProfileDisplaySettingsKeyPlatformiOSMinVersion] ?: @"";
    if ([iosMinVersion length] != 0 && [[_popUpButtonPlatformiOSMinVersion itemTitles] containsObject:iosMinVersion]) {
        [self setIosMinVersion:iosMinVersion];
    } else {
        [self setIosMinVersion:@"7.0"];
    }
    [_popUpButtonPlatformiOSMinVersion selectItemWithTitle:_iosMinVersion];
} // setupDisplaySettings

- (NSString *)expandVariablesInString:(NSString *)string overrideValues:(NSDictionary *)overrideValues {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    if (overrideValues[@"%NAME%"] != nil) {
        string = [string stringByReplacingOccurrencesOfString:@"%NAME%" withString:overrideValues[@"%NAME%"]];
    } else {
        string = [string stringByReplacingOccurrencesOfString:@"%NAME%" withString:_profileName];
    }

    if (overrideValues[@"%PROFILEUUID%"] != nil) {
        string = [string stringByReplacingOccurrencesOfString:@"%PROFILEUUID%" withString:overrideValues[@"%PROFILEUUID%"]];
    } else {
        string = [string stringByReplacingOccurrencesOfString:@"%PROFILEUUID%" withString:_profileUUID];
    }

    string = [string stringByReplacingOccurrencesOfString:@" " withString:@"-"];

    DDLogDebug(@"Returning string: %@", string);
    return string;
} // expandVariables:overrideValues

@end
