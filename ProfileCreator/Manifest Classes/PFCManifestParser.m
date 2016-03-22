//
//  PFCManifestParser.m
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

#import "PFCAvailability.h"
#import "PFCCellTypeCheckbox.h"
#import "PFCCellTypeDatePicker.h"
#import "PFCCellTypeFile.h"
#import "PFCCellTypePopUpButton.h"
#import "PFCCellTypeSegmentedControl.h"
#import "PFCCellTypeTableView.h"
#import "PFCCellTypeTextField.h"
#import "PFCCellTypeTextFieldDaysHours.h"
#import "PFCCellTypeTextFieldHostPort.h"
#import "PFCCellTypeTextFieldNumber.h"
#import "PFCCellTypeTextView.h"
#import "PFCConstants.h"
#import "PFCError.h"
#import "PFCLog.h"
#import "PFCManifestParser.h"
#import "PFCManifestUtility.h"

@implementation PFCManifestParser

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initialization
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

+ (id)sharedParser {
    // FIXME - Unsure if this has to be a singleton, figured it would be used alot and then not keep alloc/deallocing all the time
    static PFCManifestParser *sharedParser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
      sharedParser = [[self alloc] init];
    });
    return sharedParser;
} // sharedParser

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TableView Array Parsing
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)arrayFromManifestContent:(NSArray *)manifestContent settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal displayKeys:(NSDictionary *)displayKeys {
    NSMutableArray *array = [[NSMutableArray alloc] init];

    // -------------------------------------------------------------------------
    //  Create complete array from manifest content with current settings
    // -------------------------------------------------------------------------
    for (NSDictionary *manifestContentDict in manifestContent) {
        for (NSDictionary *resolvedManifestContentDict in [self arrayFromManifestContentDict:manifestContentDict settings:settings settingsLocal:settingsLocal parentKeys:nil]) {
            if ([[PFCManifestUtility sharedUtility] showManifestContentDict:resolvedManifestContentDict settings:settings displayKeys:displayKeys]) {
                [array addObject:resolvedManifestContentDict];
            }
        }
    }

    [[array copy] enumerateObjectsUsingBlock:^(NSDictionary *_Nonnull manifestContentDict, NSUInteger idx, BOOL *_Nonnull stop){

        // ---------------------------------------------------------------------------------
        //  Check if manifest content dict should be shown agains the current user settings
        // ---------------------------------------------------------------------------------

    }];

    return [array copy];
} // arrayFromManifestContent:settings:settingsLocal

- (NSArray *)arrayFromManifestContentDict:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal parentKeys:(NSMutableArray *)parentKeys {

    // ------------------------------------------------------------------------------------------------------
    //  Get current manifest content dict 'CellType' and call the correct method to add any possible subkeys
    // ------------------------------------------------------------------------------------------------------
    NSString *cellType = manifestContentDict[PFCManifestKeyCellType] ?: @"";

    // ---------------------------------------------------------------------
    //  Checkbox
    // ---------------------------------------------------------------------
    if ([cellType isEqualToString:PFCCellTypeCheckbox]) {
        return [self arrayFromCellTypeCheckbox:manifestContentDict settings:settings settingsLocal:settingsLocal parentKeys:parentKeys];

        // ---------------------------------------------------------------------
        //  CheckboxNoDescription
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeCheckboxNoDescription]) {
        return [self arrayFromCellTypeCheckbox:manifestContentDict settings:settings settingsLocal:settingsLocal parentKeys:parentKeys];

        // ---------------------------------------------------------------------
        //  DatePicker
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeDatePicker]) {
        return @[ manifestContentDict ];

        // ---------------------------------------------------------------------
        //  DatePickerNoTitle
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeDatePickerNoTitle]) {
        return @[ manifestContentDict ];

        // ---------------------------------------------------------------------
        //  File
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeFile]) {
        return @[ manifestContentDict ];

        // ---------------------------------------------------------------------
        //  Padding
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypePadding]) {
        return @[ manifestContentDict ];

        // ---------------------------------------------------------------------
        //  PopUpButton
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypePopUpButton]) {
        return [self arrayFromCellTypePopUpButton:manifestContentDict settings:settings settingsLocal:settingsLocal parentKeys:parentKeys];

        // ---------------------------------------------------------------------
        //  PopUpButtonLeft
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypePopUpButtonLeft]) {
        return [self arrayFromCellTypePopUpButton:manifestContentDict settings:settings settingsLocal:settingsLocal parentKeys:parentKeys];

        // ---------------------------------------------------------------------
        //  PopUpButtonNoTitle
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypePopUpButtonNoTitle]) {
        return [self arrayFromCellTypePopUpButton:manifestContentDict settings:settings settingsLocal:settingsLocal parentKeys:parentKeys];

        // ---------------------------------------------------------------------
        //  SegmentedControl
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeSegmentedControl]) {
        return [self arrayFromCellTypeSegmentedControl:manifestContentDict settings:settings settingsLocal:settingsLocal parentKeys:parentKeys];

        // ---------------------------------------------------------------------
        //  TableView
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTableView]) {
        return @[ manifestContentDict ];

        // ---------------------------------------------------------------------
        //  TextField
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextField]) {
        return @[ manifestContentDict ];

        // ---------------------------------------------------------------------
        //  TextFieldCheckbox
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldCheckbox]) {
        return [self arrayFromCellTypeTextFieldCheckbox:manifestContentDict settings:settings settingsLocal:settingsLocal parentKeys:parentKeys];

        // ---------------------------------------------------------------------
        //  TextFieldDaysHoursNoTitle
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldDaysHoursNoTitle]) {
        return @[ manifestContentDict ];

        // ---------------------------------------------------------------------
        //  TextFieldHostPort
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldHostPort]) {
        return @[ manifestContentDict ];

        // ---------------------------------------------------------------------
        //  TextFieldHostPortCheckbox
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldHostPortCheckbox]) {
        return [self arrayFromCellTypeTextFieldCheckbox:manifestContentDict settings:settings settingsLocal:settingsLocal parentKeys:parentKeys];

        // ---------------------------------------------------------------------
        //  TextFieldNoTitle
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldNoTitle]) {
        return @[ manifestContentDict ];

        // ---------------------------------------------------------------------
        //  TextFieldNumber
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldNumber]) {
        return @[ manifestContentDict ];

        // ---------------------------------------------------------------------
        //  TextFieldNumberLeft
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldNumberLeft]) {
        return @[ manifestContentDict ];

        // ---------------------------------------------------------------------
        //  TextView
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextView]) {
        return @[ manifestContentDict ];

    } else if ([cellType length] != 0) {
        DDLogError(@"Unknown CellType: %@ in %s", cellType, __PRETTY_FUNCTION__);
    }

    return @[];
} // arrayForManifestContentDict:settings:settingsLocal

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TableView Array Parsing ManifestContent Dict CellTypes
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)arrayFromCellTypeCheckbox:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal parentKeys:(NSMutableArray *)parentKeys {

    // -------------------------------------------------------------------------
    //  Verify this manifest content dict contains any 'ValueKeys'. Else stop.
    // -------------------------------------------------------------------------
    if ([manifestContentDict[PFCManifestKeyValueKeys] ?: @{} count] == 0) {
        return @[ manifestContentDict ];
    }

    // -------------------------------------------------------------------------
    //  Verify this manifest content dict contains an 'Identifier'. Else stop.
    // -------------------------------------------------------------------------
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    if ([identifier length] == 0) {
        return @[ manifestContentDict ];
    }

    // -------------------------------------------------------------------------
    //  Get current state of the checkbox
    // -------------------------------------------------------------------------
    BOOL checkboxState = NO;
    if (settings[identifier][PFCSettingsKeyValue] != nil) {
        checkboxState = [settings[identifier][PFCSettingsKeyValue] boolValue];
    } else if (manifestContentDict[PFCManifestKeyDefaultValue]) {
        checkboxState = [manifestContentDict[PFCManifestKeyDefaultValue] boolValue];
    } else if (settingsLocal[identifier][PFCSettingsKeyValue]) {
        checkboxState = [settingsLocal[identifier][PFCSettingsKeyValue] boolValue];
    }

    // -------------------------------------------------------------------------
    //  Add any subkeys the current manifest content dict contains
    // -------------------------------------------------------------------------
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:manifestContentDict, nil];
    [array addObjectsFromArray:[self arrayFromValueKeysForDict:manifestContentDict value:checkboxState ? @"True" : @"False" settings:settings settingsLocal:settingsLocal parentKeys:parentKeys]];
    return [array copy];
} // arrayFromCellTypeCheckbox:settings:settingsLocal:parentKeys

- (NSArray *)arrayFromCellTypePopUpButton:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal parentKeys:(NSMutableArray *)parentKeys {

    // ----------------------------------------------------------------------------------------------
    //  Verify this manifest content dict contains any 'ValueKeys' and 'AvailableValues'. Else stop.
    // ----------------------------------------------------------------------------------------------
    if ([manifestContentDict[PFCManifestKeyValueKeys] ?: @{} count] == 0 || [manifestContentDict[PFCManifestKeyAvailableValues] ?: @[] count] == 0) {
        return @[ manifestContentDict ];
    }

    // -------------------------------------------------------------------------
    //  Verify this manifest content dict contains an 'Identifier'. Else stop.
    // -------------------------------------------------------------------------
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    if ([identifier length] == 0) {
        return @[ manifestContentDict ];
    }

    // -------------------------------------------------------------------------
    //  Get current selection of the PopUpButton
    // -------------------------------------------------------------------------
    NSString *selectedItem;
    if ([settings[identifier][PFCSettingsKeyValue] length] != 0) {
        selectedItem = settings[identifier][PFCSettingsKeyValue];
    } else if ([manifestContentDict[PFCManifestKeyDefaultValue] length] != 0) {
        selectedItem = manifestContentDict[PFCManifestKeyDefaultValue];
    } else if ([settingsLocal[identifier][PFCSettingsKeyValue] length] != 0) {
        selectedItem = settingsLocal[identifier][PFCSettingsKeyValue];
    }

    // -------------------------------------------------------------------------
    //  Verify selection was made and that it exists in 'AvailableValues'
    //  If not, select first item in 'AvailableValues'
    // -------------------------------------------------------------------------
    NSArray *availableValues = manifestContentDict[PFCManifestKeyAvailableValues] ?: @[];
    if ([selectedItem length] == 0 || ![availableValues containsObject:selectedItem]) {
        DDLogWarn(@"PopUpButton selection is invalid, selecting first available item");
        selectedItem = [availableValues firstObject];
    }

    // -------------------------------------------------------------------------
    //  Add any subkeys the current manifest content dict contains
    // -------------------------------------------------------------------------
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:manifestContentDict, nil];
    [array addObjectsFromArray:[self arrayFromValueKeysForDict:manifestContentDict value:selectedItem settings:settings settingsLocal:settingsLocal parentKeys:parentKeys]];
    return [array copy];
} // arrayFromCellTypePopUpButton:settings:settingsLocal:parentKeys

- (NSArray *)arrayFromCellTypeSegmentedControl:(NSDictionary *)manifestContentDict
                                      settings:(NSDictionary *)settings
                                 settingsLocal:(NSDictionary *)settingsLocal
                                    parentKeys:(NSMutableArray *)parentKeys {

    // ----------------------------------------------------------------------------------------------
    //  Verify this manifest content dict contains any 'ValueKeys' and 'AvailableValues'. Else stop.
    // ----------------------------------------------------------------------------------------------
    if ([manifestContentDict[PFCManifestKeyValueKeys] ?: @{} count] == 0 || [manifestContentDict[PFCManifestKeyAvailableValues] ?: @[] count] == 0) {
        return @[ manifestContentDict ];
    }

    // -------------------------------------------------------------------------
    //  Verify this manifest content dict contains an 'Identifier'. Else stop.
    // -------------------------------------------------------------------------
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    if ([identifier length] == 0) {
        return @[ manifestContentDict ];
    }

    // -------------------------------------------------------------------------
    //  Get current selection of the SegmentedControl
    // -------------------------------------------------------------------------
    NSNumber *selectedSegment;
    if (manifestContentDict[PFCSettingsKeyValue] != nil) {
        selectedSegment = manifestContentDict[PFCSettingsKeyValue];
    }

    // -------------------------------------------------------------------------
    //  Verify selection was made and that it exists in 'AvailableValues'
    //  If not, select first item in 'AvailableValues'
    // -------------------------------------------------------------------------
    NSString *selectedSegmentString;
    NSArray *availableValues = manifestContentDict[PFCManifestKeyAvailableValues] ?: @[];
    if (selectedSegment == nil) {
        selectedSegmentString = [availableValues firstObject];
    } else if ([selectedSegment intValue] <= [availableValues count]) {
        selectedSegmentString = availableValues[[selectedSegment unsignedIntegerValue]];
    } else {
        return @[ manifestContentDict ];
    }

    // -------------------------------------------------------------------------
    //  Add any subkeys the current manifest content dict contains
    // -------------------------------------------------------------------------
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:manifestContentDict, nil];
    [array addObjectsFromArray:[self arrayFromValueKeysForDict:manifestContentDict value:selectedSegmentString settings:settings settingsLocal:settingsLocal parentKeys:parentKeys]];
    return [array copy];
} // arrayFromCellTypeSegmentedControl:settings:settingsLocal:parentKeys

- (NSArray *)arrayFromCellTypeTextFieldCheckbox:(NSDictionary *)manifestContentDict
                                       settings:(NSDictionary *)settings
                                  settingsLocal:(NSDictionary *)settingsLocal
                                     parentKeys:(NSMutableArray *)parentKeys {

    // -------------------------------------------------------------------------
    //  Verify this manifest content dict contains any 'ValueKeys'. Else stop.
    // -------------------------------------------------------------------------
    if ([manifestContentDict[PFCManifestKeyValueKeys] ?: @{} count] == 0) {
        return @[ manifestContentDict ];
    }

    // -------------------------------------------------------------------------
    //  Verify this manifest content dict contains an 'Identifier'. Else stop.
    // -------------------------------------------------------------------------
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    if ([identifier length] == 0) {
        return @[ manifestContentDict ];
    }

    // -------------------------------------------------------------------------
    //  Get current state of the checkbox
    // -------------------------------------------------------------------------
    BOOL checkboxState = NO;
    if (settings[identifier][@"ValueCheckbox"] != nil) {
        checkboxState = [settings[identifier][@"ValueCheckbox"] boolValue];
    } else if (manifestContentDict[PFCManifestKeyDefaultValueCheckbox]) {
        checkboxState = [manifestContentDict[PFCManifestKeyDefaultValueCheckbox] boolValue];
    } else if (settingsLocal[identifier][@"ValueCheckbox"]) {
        checkboxState = [settingsLocal[identifier][@"ValueCheckbox"] boolValue];
    }

    // -------------------------------------------------------------------------
    //  Add any subkeys the current manifest content dict contains
    // -------------------------------------------------------------------------
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:manifestContentDict, nil];
    [array addObjectsFromArray:[self arrayFromValueKeysForDict:manifestContentDict value:checkboxState ? @"True" : @"False" settings:settings settingsLocal:settingsLocal parentKeys:parentKeys]];
    return [array copy];
} // arrayFromCellTypeTextFieldCheckbox:settings:settingsLocal:parentKeys

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TableView Array Parsing ManifestContent Dict SubKeys (ValueKeys)
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)arrayFromValueKeysForDict:(NSDictionary *)manifestContentDict
                                 value:(NSString *)value
                              settings:(NSDictionary *)settings
                         settingsLocal:(NSDictionary *)settingsLocal
                            parentKeys:(NSMutableArray *)parentKeys {

    NSMutableArray *array = [[NSMutableArray alloc] init];

    NSDictionary *valueKeys = manifestContentDict[PFCManifestKeyValueKeys] ?: @{};
    if ([valueKeys count] != 0) {

        // ---------------------------------------------------------------------------
        //  If selected object (valueString) in dict valueKeys is not an array, stop.
        // ---------------------------------------------------------------------------
        if (![[valueKeys[value] class] isSubclassOfClass:[NSArray class]]) {
            /*
             DDLogDebug(@"Selected value is: %@", value);
             DDLogDebug(@"Selected value class is: %@", [valueKeys[value] class]);
             DDLogDebug(@"Available ValueKeys: %@", valueKeys);
             */
            return @[];
        }

        // ---------------------------------------------------------------------
        //  If manifestContentDict doesn't have an identifier, stop.
        //  The identifier is required to be able to remove the dicts when the user changes selection
        // ---------------------------------------------------------------------
        NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier] ?: @"";
        if ([identifier length] == 0) {
            return @[];
        }

        // ---------------------------------------------------------------------
        //  Check if any sub keys exist for selected value
        // ---------------------------------------------------------------------
        NSArray *valueKeyArray = [valueKeys[value] mutableCopy] ?: @[];
        for (NSDictionary *valueDict in valueKeyArray) {
            if ([valueDict count] == 0) {
                continue;
            }

            // --------------------------------------------------------------------------------------------
            //  If the key 'SharedKey' is present, the dict array to add is in the 'ValueKeysShared' array
            // --------------------------------------------------------------------------------------------
            NSMutableDictionary *mutableValueDict;
            if ([valueDict[PFCManifestKeySharedKey] length] != 0) {

                // ---------------------------------------------------------------
                //  Get the shared key dict from the manifest's 'ValueKeysShared'
                // ---------------------------------------------------------------
                NSString *sharedKey = valueDict[PFCManifestKeySharedKey];
                NSDictionary *valueKeysShared = manifestContentDict[PFCManifestKeyValueKeysShared];
                if ([valueKeysShared count] != 0) {
                    mutableValueDict = valueKeysShared[sharedKey];
                } else {
                    DDLogError(@"Shared Key is defined, but no ValueKeysShared dict was found!");
                    continue;
                }
            } else {
                mutableValueDict = [valueDict mutableCopy];
            }

            // ----------------------------------------------------------------------------------------
            //  Add the current manifest dict's identifier to the parentKeys array
            //  This is done so the correct dicts will be removed when the user selects another 'value'
            //  This allows for multiple nestings and just adding/removing the affected dicts instead of realoading the entire table view
            // ----------------------------------------------------------------------------------------
            if (parentKeys == nil) {
                parentKeys = [[NSMutableArray alloc] init];
            }

            if (![parentKeys containsObject:identifier]) {
                [parentKeys addObject:identifier];
            }

            mutableValueDict[PFCManifestKeyParentKey] = [parentKeys copy];

            // -----------------------------------------------------------------
            //  Add any subkeys the current manifest content dict contains
            // -----------------------------------------------------------------
            [array addObjectsFromArray:[self arrayFromManifestContentDict:mutableValueDict settings:settings settingsLocal:settingsLocal parentKeys:parentKeys]];
        }

        // -----------------------------------------------------------------------------------------------------------
        //  Remove the current manifest's identifer from the parentKeys array so subsequent dict's doesn't get tagged
        // -----------------------------------------------------------------------------------------------------------
        [parentKeys removeObject:identifier];
    }

    return [array copy];
} // arrayFromValueKeysForDict:value:settings:settingsLocal:parentKeys

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Create Manifest
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSDictionary *)manifestFromPlistAtURL:(NSURL *)fileURL settings:(NSMutableDictionary *)settings {

    NSDictionary *plistDict = [NSDictionary dictionaryWithContentsOfURL:fileURL] ?: @{};
    if ([plistDict count] == 0) {
        return plistDict;
    }

    NSMutableDictionary *manifestDict = [[NSMutableDictionary alloc] init];
    // ---------------------------------------------------------------------
    //  Create Manifest Root
    // ---------------------------------------------------------------------
    [manifestDict addEntriesFromDictionary:[self manifestRootFromPlistAtURL:fileURL]];

    // ---------------------------------------------------------------------
    //  Create Manifest Content
    // ---------------------------------------------------------------------
    manifestDict[PFCManifestKeyManifestContent] = [self manifestContentFromDict:plistDict settingsDict:settings];

    // ---------------------------------------------------------------------
    //  Add path to source plist
    // ---------------------------------------------------------------------
    manifestDict[PFCRuntimeKeyPath] = [fileURL path];
    return [manifestDict copy];
} // manifestForPlistAtURL

- (NSDictionary *)manifestFromMCXManifestAtURL:(NSURL *)fileURL {
    NSMutableDictionary *manifestDict = [[NSMutableDictionary alloc] init];

    NSError *error = nil;
    if ([fileURL checkResourceIsReachableAndReturnError:&error]) {
        NSDictionary *mcxManifest = [NSDictionary dictionaryWithContentsOfURL:fileURL];
        if ([mcxManifest count] != 0) {

            // ---------------------------------------------------------------------
            //  Create Manifest Root
            // ---------------------------------------------------------------------
            [manifestDict addEntriesFromDictionary:[self manifestRootFromMCXManifest:mcxManifest]];

            // ---------------------------------------------------------------------
            //  Create Manifest Content
            // ---------------------------------------------------------------------
            manifestDict[PFCManifestKeyManifestContent] = [self manifestContentFromMCXSubkeys:mcxManifest[PFCMCXManifestKeySubkeys]];

            // ---------------------------------------------------------------------
            //  Add path to source plist
            // ---------------------------------------------------------------------
            manifestDict[PFCRuntimeKeyPath] = [fileURL path];
            return [manifestDict copy];
        } else {
            DDLogError(@"MCX manifest at path: %@ was empty", [fileURL path]);
        }
    } else {
        DDLogError(@"%@", [error localizedDescription]);
    }

    return nil;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Create Manifest Root
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSDictionary *)manifestRootFromPlistAtURL:(NSURL *)fileURL {

    NSMutableDictionary *manifest = [[NSMutableDictionary alloc] init];

    // ---------------------------------------------------------------------
    //  Set the required CellType for the Menu
    // ---------------------------------------------------------------------
    manifest[PFCManifestKeyCellType] = PFCCellTypeMenu;

    // ---------------------------------------------------------------------
    //  Set allow multiple payloads to NO
    //  FIXME - This might be a setting, need to discuss.
    // ---------------------------------------------------------------------
    manifest[PFCManifestKeyAllowMultiplePayloads] = @NO;

    // ---------------------------------------------------------------------
    //  Add payload types
    // ---------------------------------------------------------------------
    manifest[PFCManifestKeyPayloadTypes] = @[ @"com.apple.ManagedClient.preferences" ];

    // ---------------------------------------------------------------------
    //  Set the domain to the plist name (without the file extension)
    // ---------------------------------------------------------------------
    NSString *domain = [[fileURL lastPathComponent] stringByDeletingPathExtension] ?: @"";
    if ([domain length] != 0) {

        // ---------------------------------------------------------------------
        //  Set both the "Domain" and "Title" to the domain
        // ---------------------------------------------------------------------
        manifest[PFCManifestKeyDomain] = domain;
        manifest[PFCManifestKeyTitle] = domain;

        // -----------------------------------------------------------------------------
        //  Check if any applications can be found using the domain as bundle identifier
        // -----------------------------------------------------------------------------
        NSURL *bundleURL = [(__bridge NSArray *)(LSCopyApplicationURLsForBundleIdentifier((__bridge CFStringRef _Nonnull)(domain), NULL))firstObject];
        if ([bundleURL checkResourceIsReachableAndReturnError:nil]) {
            NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
            if (bundle != nil) {

                // -----------------------------------------------------------------------------
                //  If the bundle name could be retrieved, set that as the manifest "Title" key
                // -----------------------------------------------------------------------------
                NSString *bundleName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
                if ([bundleName length] != 0) {
                    manifest[PFCManifestKeyTitle] = bundleName;
                }

                // ----------------------------------------------------------------------------------------
                //  If the bundle icon could be retrieved, set the bundle path as the "IconPathBundle" key
                // ----------------------------------------------------------------------------------------
                NSImage *bundleIcon = [[NSWorkspace sharedWorkspace] iconForFile:[bundleURL path]];
                if (bundleIcon) {
                    manifest[PFCManifestKeyIconPathBundle] = [bundleURL path];
                }
            }
        }
    }

    return [manifest copy];
}

- (NSDictionary *)manifestRootFromMCXManifest:(NSDictionary *)mcxManifest {

    NSMutableDictionary *manifest = [[NSMutableDictionary alloc] init];

    // ---------------------------------------------------------------------
    //  Set "CellType"
    // ---------------------------------------------------------------------
    manifest[PFCManifestKeyCellType] = PFCCellTypeMenu;

    // ---------------------------------------------------------------------
    //  Set allow multiple payloads to NO
    //  FIXME - This might be a setting, need to discuss.
    // ---------------------------------------------------------------------
    manifest[PFCManifestKeyAllowMultiplePayloads] = @NO;

    // ---------------------------------------------------------------------
    //  Set "Domain"
    // ---------------------------------------------------------------------
    manifest[PFCManifestKeyDomain] = mcxManifest[PFCMCXManifestKeyDomain] ?: @"";

    // ---------------------------------------------------------------------
    //  Set "Domain"
    // ---------------------------------------------------------------------
    manifest[PFCManifestKeyDomain] = mcxManifest[PFCMCXManifestKeyDomain] ?: @"";

    // ---------------------------------------------------------------------
    //  Set "Title"
    // ---------------------------------------------------------------------
    manifest[PFCManifestKeyTitle] = mcxManifest[PFCMCXManifestKeyTitle] ?: @"";

    // ---------------------------------------------------------------------
    //  Set "Description"
    // ---------------------------------------------------------------------
    manifest[PFCManifestKeyDescription] = mcxManifest[PFCMCXManifestKeyDescription] ?: @"";

    return [manifest copy];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Create Manifest Content
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)manifestContentFromDict:(NSDictionary *)dict settingsDict:(NSMutableDictionary *)settingsDict {
    NSMutableArray *manifestArray = [[NSMutableArray alloc] init];

    // -----------------------------------------------------------------------------------------
    //  Loop through all keys in the dict and create an array of "ManifestContent" dictionaries
    // -----------------------------------------------------------------------------------------
    NSArray *dictKeys = [dict allKeys];
    for (NSString *key in dictKeys) {

        NSMutableDictionary *manifestDict = [[NSMutableDictionary alloc] init];

        // -----------------------------------------------------------------------------------------
        //  Set 'Hidden' to yes for all keys in hidden list in preferences
        // -----------------------------------------------------------------------------------------
        if ([[PFCManifestUtility sharedUtility] hideKey:key]) {
            manifestDict[PFCManifestKeyHidden] = @YES;
        }

        // ---------------------------------------------------------------------------------
        //  Generate an identifier and add all static key/value pairs like "PayloadKey" etc.
        // ---------------------------------------------------------------------------------
        NSString *identifier = [[NSUUID UUID] UUIDString];
        manifestDict[PFCManifestKeyIdentifier] = identifier;
        manifestDict[PFCManifestKeyPayloadKey] = key;
        manifestDict[PFCManifestKeyTitle] = key;
        manifestDict[PFCManifestKeyPayloadType] = @"com.apple.ManagedClient.preferences";

        // ---------------------------------------------------------------------
        //  Cast the value to id and check what type the value is stored as
        // ---------------------------------------------------------------------
        id value = dict[key];
        NSString *typeString = [[PFCManifestUtility sharedUtility] typeStringFromValue:value];
        if ([typeString length] != 0) {

            // -----------------------------------------------------------------
            //  Add all static keys for the value type
            // -----------------------------------------------------------------
            manifestDict[PFCManifestKeyPayloadValueType] = typeString;
            manifestDict[PFCManifestKeyCellType] = [[PFCManifestUtility sharedUtility] cellTypeFromTypeString:typeString];
            manifestDict[PFCManifestKeyDescription] = @"No Description";

            // --------------------------------------------------------------------------
            //  Create a temporary dict for this key/value to store the current settings
            // --------------------------------------------------------------------------
            NSMutableDictionary *identifierSettingsDict = [[NSMutableDictionary alloc] init];

            // -----------------------------------------------------------------------
            //  Store current settings for the value types ( i.e. CellTypes) returned
            //
            //  Array - CellType: PFCCellTypeTableView
            // -----------------------------------------------------------------------
            if ([typeString isEqualToString:PFCValueTypeArray]) {
                manifestDict[PFCManifestKeyTableViewColumns] = [self tableViewColumnsFromArray:value settings:identifierSettingsDict];

                // -------------------------------------------------------------
                //  Dict - CellType: PFCCellTypeSegmentedControl
                // -------------------------------------------------------------
            } else if ([typeString isEqualToString:PFCValueTypeDict]) {
                manifestDict[PFCManifestKeyAvailableValues] = @[ key ];
                manifestDict[PFCManifestKeyValueKeys] = @{key : [self manifestContentFromDict:value settingsDict:identifierSettingsDict]};

                // -------------------------------------------------------------
                //  All other types just store their values in "Value"
                //
                //  Boolean - CellType: PFCCellTypeCheckbox
                //  String  - CellType: PFCCellTypeTextField
                //  Integer - CellType: PFCCellTypeTextFieldNumber
                //  Float   - CellType: PFCCellTypeTextFieldNumber
                //  Date    - CellType: PFCCellTypeDatePickerNoTitle
                //  Data    - CellType: PFCCellTypeFile
                // -------------------------------------------------------------
            } else {
                identifierSettingsDict[PFCSettingsKeyValue] = value;
            }

            // -----------------------------------------------------------------
            //  Store all settings in the passed settingsDict
            // -----------------------------------------------------------------
            settingsDict[identifier] = [identifierSettingsDict copy] ?: @{};
        } else {
            DDLogError(@"TypeString was empty!");
            continue;
        }
        [manifestArray addObject:[manifestDict copy]];
    }

    return [manifestArray copy];
} // manifestArrayFromDict:settingsDict

- (NSArray *)manifestContentFromMCXSubkeys:(NSArray *)mcxSubkeys {
    NSMutableArray *manifestArray = [[NSMutableArray alloc] init];

    // -----------------------------------------------------------------------------------------
    //  Loop through all subkeys and create an array of "ManifestContent" dictionaries
    // -----------------------------------------------------------------------------------------
    for (NSDictionary *mcxSubkey in mcxSubkeys) {

        NSMutableDictionary *manifestDict = [[NSMutableDictionary alloc] init];

        // ---------------------------------------------------------------------------------
        //  Generate an identifier and add all static key/value pairs like "PayloadKey" etc.
        // ---------------------------------------------------------------------------------
        NSString *identifier = [[NSUUID UUID] UUIDString];
        manifestDict[PFCManifestKeyIdentifier] = identifier;

        [manifestArray addObject:[manifestDict copy]];
    }

    return [manifestArray copy];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Create Manifest Utility Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)tableViewColumnsFromArray:(NSArray *)array settings:(NSMutableDictionary *)settings {
    NSMutableArray *tableViewColumns = [[NSMutableArray alloc] init];

    // -------------------------------------------------------------------------
    //  Check what type the array contains
    // -------------------------------------------------------------------------
    NSString *typeString = [[PFCManifestUtility sharedUtility] typeStringFromValue:[array firstObject]];

    // -------------------------------------------------------------------------
    //  Array content:  String
    //                  Integer
    //                  Float
    // -------------------------------------------------------------------------
    if ([typeString isEqualToString:PFCValueTypeString] || [typeString isEqualToString:PFCValueTypeInteger] || [typeString isEqualToString:PFCValueTypeFloat]) {

        // ---------------------------------------------------------------------
        //  Create a unique columen title
        // ---------------------------------------------------------------------
        NSString *columnTitle = [[NSUUID UUID] UUIDString];

        // ---------------------------------------------------------------------
        //  Add the manifest settings to describe the tableview column
        // ---------------------------------------------------------------------
        [tableViewColumns addObject:@{PFCManifestKeyTitle : columnTitle, PFCManifestKeyCellType : [[PFCManifestUtility sharedUtility] cellTypeFromTypeString:typeString]}];

        // ---------------------------------------------------------------------
        //  Add all current settings to the "TableViewContent" array
        // ---------------------------------------------------------------------
        NSMutableArray *tableViewContent = [[NSMutableArray alloc] init];
        for (NSString *string in array) {
            [tableViewContent addObject:@{ columnTitle : @{PFCSettingsKeyValue : string} }];
        }

        settings[PFCSettingsKeyTableViewContent] = [tableViewContent copy];

        // -------------------------------------------------------------------------
        //  Array content: Dict
        // -------------------------------------------------------------------------
    } else if ([typeString isEqualToString:PFCValueTypeDict]) {

        // -----------------------------------------------------------------------------
        //  FIXME - This assumes that all dicts in the array look the same. Should fix.
        //  Add the manifest settings to describe the tableview columns
        // -----------------------------------------------------------------------------
        NSDictionary *templateDict = [array firstObject];
        for (NSString *key in [templateDict allKeys]) {
            NSString *valueTypeString = [[PFCManifestUtility sharedUtility] typeStringFromValue:templateDict[key]];
            [tableViewColumns addObject:@{PFCManifestKeyTitle : key, PFCManifestKeyCellType : [[PFCManifestUtility sharedUtility] cellTypeFromTypeString:valueTypeString]}];
        }

        // -----------------------------------------------------------------------------
        //  Add all current settings to the "TableViewContent" array
        // -----------------------------------------------------------------------------
        NSMutableArray *tableViewContent = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in array) {
            NSMutableDictionary *contentDict = [[NSMutableDictionary alloc] init];
            for (NSString *key in [dict allKeys]) {
                NSString *valueTypeString = [[PFCManifestUtility sharedUtility] typeStringFromValue:dict[key]];
                if ([valueTypeString isEqualToString:PFCValueTypeString]) {
                    contentDict[key] = @{PFCSettingsKeyValue : dict[key]};
                } else if ([valueTypeString isEqualToString:PFCValueTypeBoolean]) {
                    contentDict[key] = @{PFCSettingsKeyValue : dict[key]};
                } else {
                    // DDLogDebug(@"TableViewContent, key=%@", dict[key]);
                }
            }

            [tableViewContent addObject:[contentDict copy]];
        }

        settings[PFCSettingsKeyTableViewContent] = [tableViewContent copy];
    }
    return [tableViewColumns copy];
} // tableViewColumnsFromArray

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Verify Manifests
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSDictionary *)settingsErrorForManifestContentDict:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings displayKeys:(NSDictionary *)displayKeys {

    // -------------------------------------------------------------------------------------------
    //  Get current manifest content dict 'CellType' and call the correct method for verification
    // -------------------------------------------------------------------------------------------
    NSString *cellType = manifestContentDict[PFCManifestKeyCellType] ?: @"";

    // ---------------------------------------------------------------------
    //  Checkbox
    // ---------------------------------------------------------------------
    if ([cellType isEqualToString:PFCCellTypeCheckbox]) {
        return [PFCCheckboxCellView verifyCellType:manifestContentDict settings:settings displayKeys:displayKeys];

        // ---------------------------------------------------------------------
        //  CheckboxNoDescription
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeCheckboxNoDescription]) {
        return [PFCCheckboxNoDescriptionCellView verifyCellType:manifestContentDict settings:settings displayKeys:displayKeys];

        // ---------------------------------------------------------------------
        //  DatePicker
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeDatePicker]) {
        return [PFCDatePickerCellView verifyCellType:manifestContentDict settings:settings displayKeys:displayKeys];

        // ---------------------------------------------------------------------
        //  DatePickerNoTitle
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeDatePickerNoTitle]) {
        return [PFCDatePickerNoTitleCellView verifyCellType:manifestContentDict settings:settings displayKeys:displayKeys];

        // ---------------------------------------------------------------------
        //  File
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeFile]) {
        return [PFCFileCellView verifyCellType:manifestContentDict settings:settings displayKeys:displayKeys];

        // ---------------------------------------------------------------------
        //  Padding
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypePadding]) {
        return @{}; // No need to verify

        // ---------------------------------------------------------------------
        //  PopUpButton
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypePopUpButton]) {
        return [PFCPopUpButtonCellView verifyCellType:manifestContentDict settings:settings displayKeys:displayKeys];

        // ---------------------------------------------------------------------
        //  PopUpButtonLeft
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypePopUpButtonLeft]) {
        return [PFCPopUpButtonLeftCellView verifyCellType:manifestContentDict settings:settings displayKeys:displayKeys];

        // ---------------------------------------------------------------------
        //  PopUpButtonNoTitle
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypePopUpButtonNoTitle]) {
        return [PFCPopUpButtonNoTitleCellView verifyCellType:manifestContentDict settings:settings displayKeys:displayKeys];

        // ---------------------------------------------------------------------
        //  SegmentedControl
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeSegmentedControl]) {
        return [PFCSegmentedControlCellView verifyCellType:manifestContentDict settings:settings displayKeys:displayKeys];

        // ---------------------------------------------------------------------
        //  TableView
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTableView]) {
        return [PFCTableViewCellView verifyCellType:manifestContentDict settings:settings displayKeys:displayKeys];

        // ---------------------------------------------------------------------
        //  TextField
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextField]) {
        return [PFCTextFieldCellView verifyCellType:manifestContentDict settings:settings displayKeys:displayKeys];

        // ---------------------------------------------------------------------
        //  TextFieldCheckbox
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldCheckbox]) {
        return [PFCTextFieldCheckboxCellView verifyCellType:manifestContentDict settings:settings displayKeys:displayKeys];

        // ---------------------------------------------------------------------
        //  TextFieldDaysHoursNoTitle
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldDaysHoursNoTitle]) {
        return [PFCTextFieldDaysHoursNoTitleCellView verifyCellType:manifestContentDict settings:settings displayKeys:displayKeys];

        // ---------------------------------------------------------------------
        //  TextFieldHostPort
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldHostPort]) {
        return [PFCTextFieldHostPortCellView verifyCellType:manifestContentDict settings:settings displayKeys:displayKeys];

        // ---------------------------------------------------------------------
        //  TextFieldHostPortCheckbox
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldHostPortCheckbox]) {
        return [PFCTextFieldHostPortCheckboxCellView verifyCellType:manifestContentDict settings:settings displayKeys:displayKeys];

        // ---------------------------------------------------------------------
        //  TextFieldNoTitle
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldNoTitle]) {
        return [PFCTextFieldNoTitleCellView verifyCellType:manifestContentDict settings:settings displayKeys:displayKeys];

        // ---------------------------------------------------------------------
        //  TextFieldNumber
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldNumber]) {
        return [PFCTextFieldNumberCellView verifyCellType:manifestContentDict settings:settings displayKeys:displayKeys];

        // ---------------------------------------------------------------------
        //  TextFieldNumberLeft
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldNumberLeft]) {
        return [PFCTextFieldNumberLeftCellView verifyCellType:manifestContentDict settings:settings displayKeys:displayKeys];

        // ---------------------------------------------------------------------
        //  TextView
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextView]) {
        return [PFCTextViewCellView verifyCellType:manifestContentDict settings:settings displayKeys:displayKeys];

    } else if ([cellType length] != 0) {
        DDLogError(@"Unknown CellType: %@ in %s", cellType, __PRETTY_FUNCTION__);
    }

    return @{};
}

- (NSDictionary *)settingsErrorForManifestContent:(NSArray *)manifestContent settings:(NSDictionary *)settings displayKeys:(NSDictionary *)displayKeys {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    NSMutableDictionary *report = [[NSMutableDictionary alloc] init];

    // ------------------------------------------------------------------------------
    //  Loop throgh all manifest content dicts in the current manifest content array
    // ------------------------------------------------------------------------------
    for (NSDictionary *manifestContentDict in manifestContent) {

        // -----------------------------------------------------------------------------------
        //  If manifest content dict contains key 'PayloadValue' or 'SharedKey'. Continue.
        //  These keys are only used in sub dicts to define a value or a link to a shared key.
        // -----------------------------------------------------------------------------------
        if (manifestContentDict[PFCManifestKeyPayloadValue] || manifestContentDict[PFCManifestKeySharedKey]) {
            continue;
        }

        // ----------------------------------------------------------------------------------------------
        //  Verify the current manifest dict, and add all errors and warnings to the verification report
        // ----------------------------------------------------------------------------------------------
        NSDictionary *settingsError = [self settingsErrorForManifestContentDict:manifestContentDict settings:settings displayKeys:displayKeys];
        if ([settingsError count] != 0) {
            [report addEntriesFromDictionary:settingsError];
        }
    }

    return [report copy];
} // verifyManifestContent:settings

@end
