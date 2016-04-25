//
//  PFCProfileExport.m
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

#import "PFCCellTypeCheckbox.h"
#import "PFCCellTypeDatePicker.h"
#import "PFCCellTypePopUpButton.h"
#import "PFCCellTypeSegmentedControl.h"
#import "PFCCellTypeTableView.h"
#import "PFCCellTypeTextField.h"
#import "PFCCellTypeTextFieldHostPort.h"
#import "PFCCellTypeTextFieldNumber.h"
#import "PFCCellTypeTextView.h"
#import "PFCConstants.h"
#import "PFCLog.h"
#import "PFCManifestLibrary.h"
#import "PFCProfileExport.h"
#import "PFCTableViewCellTypeCheckbox.h"
#import "PFCTableViewCellTypeTextField.h"

@interface PFCProfileExport ()

@property PFCMainWindow *mainWindow;
@property NSDictionary *settingsProfile;

@property NSString *rootIdentifier;
@property NSString *rootOrganization;

@end

@implementation PFCProfileExport

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id)initWithProfileSettings:(NSDictionary *)settings mainWindow:(PFCMainWindow *)mainWindow {
    self = [super init];
    if (self != nil) {
        _settingsProfile = settings;
        _mainWindow = mainWindow;
    }
    return self;
} // initWithProfileSettings:mainWindow

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Export Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)exportProfileToURL:(NSURL *)url manifests:(NSArray *)manifests settings:(NSDictionary *)settings {
    // -------------------------------------------------------------------------
    //  Create profile root from profile settings
    // -------------------------------------------------------------------------
    NSMutableDictionary *profile = [[NSMutableDictionary alloc] init];
    [profile addEntriesFromDictionary:[self profileRootKeysFromSettings:_settingsProfile] ?: @{}];

    // -------------------------------------------------------------------------
    //  Extract Root Organization from General settings
    // -------------------------------------------------------------------------
    // FIXME - Possibly dangerous to do this deep extraction like this, could possible get this some other way.
    [self setRootOrganization:[settings[@"com.apple.general"][@"Settings"] firstObject][@"E2E64509-BDE4-4743-8AE9-D46B76E0CDA8"][@"Value"] ?: @""];
    DDLogDebug(@"Root Organization: %@", _rootOrganization);

    // -------------------------------------------------------------------------
    //  Create and add all payloads
    // -------------------------------------------------------------------------
    NSMutableArray *payloadArray = [[NSMutableArray alloc] init];
    for (NSDictionary *manifest in manifests) {
        NSDictionary *manifestSettings = settings[manifest[PFCManifestKeyDomain]];
        for (NSDictionary *manifestTabSettings in manifestSettings[@"Settings"]) {
            [self createPayloadFromManifestContent:manifest[PFCManifestKeyManifestContent] settings:manifestTabSettings payloads:&payloadArray];
        }
    }

    if (payloadArray.count == 0) {
        DDLogError(@"No payload array returned");
        // FIXME - Add user error message
        return;
    }

    // -------------------------------------------------------------------------
    //  Add to profile root from "General" settings
    //  Get index of general settings and remove it from manifest array
    // -------------------------------------------------------------------------
    NSUInteger index = [payloadArray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
      return [item[PFCManifestKeyPayloadType] isEqualToString:@"com.apple.profile"];
    }];

    DDLogDebug(@"Profile settings index in payload array: %lu", (unsigned long)index);
    NSMutableDictionary *profileRootKeys = [[NSMutableDictionary alloc] init];
    if (index == NSNotFound) {
        DDLogError(@"No general settings found in manifest array");
        // FIXME - Add user warning message, as these aren't strictly required!?
        // return;
    } else {
        profileRootKeys = [payloadArray[index] mutableCopy];
        [payloadArray removeObjectAtIndex:index];
    }
    [profile addEntriesFromDictionary:[self profileRootKeysFromGeneralPayload:profileRootKeys]];
    profile[@"PayloadContent"] = [payloadArray copy] ?: @[];

    DDLogVerbose(@"Finished profile: %@", profile);

    // -------------------------------------------------------------------------
    //  Write profile to disk
    // -------------------------------------------------------------------------
    NSError *error = nil;
    if (![profile writeToURL:url atomically:NO]) {
        DDLogError(@"Could not write profile to disk");
        // FIXME - Add user error message
    } else {
        if ([url checkResourceIsReachableAndReturnError:&error]) {
            // FIXME - Here either do callback or update working version and last eport date in profile settings.

            // -------------------------------------------------------------------------
            //  Show profile in Finder
            // -------------------------------------------------------------------------
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[ url ]];
        } else {
            DDLogError(@"%@", error.localizedDescription);
            // FIXME - Add user error message
        }
    }
} // exportProfileToURL:manifests:settings

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Profile Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSDictionary *)profileRootKeysFromSettings:(NSDictionary *)settings {
    NSMutableDictionary *profileRoot = [[NSMutableDictionary alloc] init];

    // -------------------------------------------------------------------------
    //  Add constant values
    // -------------------------------------------------------------------------
    profileRoot[PFCManifestKeyPayloadType] = @"Configuration";
    profileRoot[PFCManifestKeyPayloadVersion] = @1;

    // -------------------------------------------------------------------------
    //  Add user values
    // -------------------------------------------------------------------------
    [self setRootIdentifier:settings[@"Config"][PFCProfileTemplateKeyIdentifier] ?: @""];
    DDLogDebug(@"Profile root identifier: %@", _rootIdentifier);

    profileRoot[PFCManifestKeyPayloadUUID] = settings[@"Config"][PFCProfileTemplateKeyUUID];
    profileRoot[PFCManifestKeyPayloadIdentifier] = _rootIdentifier;
    profileRoot[PFCManifestKeyPayloadScope] = settings[@"Config"][PFCManifestKeyPayloadScope] ?: @"User";

    DDLogVerbose(@"Profile root: %@", profileRoot);
    return [profileRoot copy];
} // profileRootKeysFromSettings

- (NSDictionary *)profileRootKeysFromGeneralPayload:(NSMutableDictionary *)profileRootKeys {
    [profileRootKeys removeObjectForKey:@"PayloadType"];
    [profileRootKeys removeObjectForKey:@"PayloadIdentifier"];
    [profileRootKeys removeObjectForKey:@"PayloadUUID"];
    [profileRootKeys removeObjectForKey:@"PayloadVersion"];
    return [profileRootKeys copy];
} // profileRootKeysFromGeneralPayload

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Payload Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSMutableDictionary *)payloadRootFromManifest:(NSDictionary *)manifest settings:(NSDictionary *)settings payloadType:(NSString *)payloadType payloadUUID:(NSString *)payloadUUID {

    if (payloadType == nil || payloadType.length == 0) {
        payloadType = manifest[PFCManifestKeyPayloadType];
    }

    if (payloadUUID == nil || payloadUUID.length == 0) {
        if ([settings[payloadType][@"UUID"] length] != 0) {
            payloadUUID = settings[payloadType][@"UUID"];
        } else {
            DDLogWarn(@"No UUID found for payload type: %@", payloadType);
            payloadUUID = NSUUID.UUID.UUIDString;
        }
    }

    return [NSMutableDictionary dictionaryWithDictionary:@{
        PFCManifestKeyPayloadType : payloadType,
        PFCManifestKeyPayloadVersion : @1, // Could be different!?
        PFCManifestKeyPayloadIdentifier : [NSString stringWithFormat:@"%@.%@.%@", _rootIdentifier, payloadType, payloadUUID],
        PFCManifestKeyPayloadUUID : payloadUUID,
        PFCManifestKeyPayloadDisplayName : @"FIXME",
        PFCManifestKeyPayloadDescription : @"FIXME",                                                         // Optional for payloads
        PFCManifestKeyPayloadOrganization : [NSString stringWithFormat:@"%@", _rootOrganization ?: @"FIXME"] // Optional for payloads
    }];
} // payloadRootFromManifest:settings:payloadType:payloadUUID

- (void)createPayloadFromManifestContent:(NSArray *)manifestContent settings:(NSDictionary *)settings payloads:(NSMutableArray **)payloads {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    for (NSDictionary *manifestContentDict in manifestContent) {
        [self createPayloadFromManifestContentDict:manifestContentDict settings:settings payloads:payloads];
    }
} // createPayloadFromManifestContent:settings:payloads

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ManifestContentDict Error Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)payloadErrorForManifestKey:(NSString *)key manifestContentDict:(NSDictionary *)manifestContentDict {
    DDLogError(@"Manifest is missing required key: %@", key);
    DDLogError(@"Manifest: %@", manifestContentDict);
}

- (void)payloadErrorForValueClass:(NSString *)valueClass payloadKey:(NSString *)payloadKey exptectedClasses:(NSArray *)expectedClasses {
    DDLogError(@"Value for payload key: %@ is not of the correct class", payloadKey);
    DDLogError(@"Expected classes: %@", expectedClasses);
    DDLogError(@"Value class: %@", valueClass);
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ManifestContentDict Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (BOOL)verifyRequiredManifestContentDictKeys:(NSArray *)manifestContentDictKeys manifestContentDict:(NSDictionary *)manifestContentDict {
    __block BOOL verified = YES;
    [manifestContentDictKeys enumerateObjectsUsingBlock:^(NSString *_Nonnull key, NSUInteger idx, BOOL *_Nonnull stop) {
      if (manifestContentDict[key] != nil) {
          DDLogDebug(@"%@: %@", key, manifestContentDict[key]);
      } else {
          [self payloadErrorForManifestKey:key manifestContentDict:manifestContentDict];
          verified = NO;
          *stop = YES;
      }
    }];
    return verified;
} // verifyRequiredManifestContentDictKeys:manifestContentDict

- (void)createPayloadFromValueKey:(NSString *)selectedValue
                  availableValues:(NSArray *)availableValues
              manifestContentDict:(NSDictionary *)manifestContentDict
                         settings:(NSDictionary *)settings
                       payloadKey:(NSString *)payloadKey
                      payloadType:(NSString *)payloadType
                      payloadUUID:(NSString *)payloadUUID
                         payloads:(NSMutableArray **)payloads {

    // -------------------------------------------------------------------------
    //  Check that selected value exist among available values
    // -------------------------------------------------------------------------
    if (availableValues == nil) {
        return;
    } else if (availableValues.count == 0) {
        return;
    } else if (![availableValues containsObject:selectedValue]) {
        DDLogWarn(@"Selection does not exist in available values");
        DDLogWarn(@"Selected value: %@", selectedValue);
        DDLogWarn(@"Available values: %@", availableValues);
        return;
    }

    // -------------------------------------------------------------------------
    //  Check that selected value exist among value keys
    // -------------------------------------------------------------------------
    NSDictionary *valueKeys = manifestContentDict[PFCManifestKeyValueKeys] ?: @{};
    if (valueKeys.count == 0) {
        DDLogError(@"ValueKeys is empty, please update the manifest to handle all selections");
        return;
    } else if (!valueKeys[selectedValue]) {
        DDLogWarn(@"Selection does not exist in manifest ValueKeys");
        DDLogWarn(@"Selected value: %@", selectedValue);
        DDLogWarn(@"ValueKeys: %@", valueKeys);
        return;
    }

    // -------------------------------------------------------------------------
    //  Check that selected value exist among value keys
    // -------------------------------------------------------------------------
    NSMutableArray *selectedValueArray = [valueKeys[selectedValue] mutableCopy]; // Same as manifestContent

    // -------------------------------------------------------------------------------------------------
    //  Check if the selectedValueArray contains the actual "Value" for the selecting item's PayloadKey
    //  Return a valid idxPayloadValue if that is found
    // -------------------------------------------------------------------------------------------------
    NSUInteger idxPayloadValue = [selectedValueArray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
      return (item[PFCManifestKeyPayloadValue]) ? YES : NO;
    }];

    // -------------------------------------------------------------------------
    //  If a PayloadValue was found in the array, update the payload
    // -------------------------------------------------------------------------
    if (idxPayloadValue != NSNotFound) {
        NSDictionary *payloadValueDict = selectedValueArray[idxPayloadValue]; // Same as manifestContentDict

        // ---------------------------------------------------------------------
        //  Remove the PayloadValue from the array
        // ---------------------------------------------------------------------
        [selectedValueArray removeObjectAtIndex:idxPayloadValue];

        // ---------------------------------------------------------------------
        //  Get value for selection
        // ---------------------------------------------------------------------
        id value = payloadValueDict[PFCManifestKeyPayloadValue];
        if (value == nil) {
            DDLogError(@"PayloadValue was empty");
            return;
        }

        // FIXME - Possibly add valuetype-key or other method to verify value type, or require it in the dict

        // -------------------------------------------------------------------------
        //  Check if custom PayloadType was passed, else use standard "PayloadType"
        // -------------------------------------------------------------------------
        if (payloadType == nil || payloadType.length == 0) {
            payloadType = manifestContentDict[PFCManifestKeyPayloadType];
        }

        // -------------------------------------------------------------------------
        //  Check if custom PayloadUUID was passed, else use standard "PayloadUUID"
        // -------------------------------------------------------------------------
        if (payloadUUID == nil || payloadUUID.length == 0) {
            if ([settings[payloadType][@"UUID"] length] != 0) {
                payloadUUID = settings[payloadType][@"UUID"];
            } else {
                DDLogWarn(@"No UUID found for payload type: %@", payloadType);
                payloadUUID = NSUUID.UUID.UUIDString;
            }
        }

        // -----------------------------------------------------------------------
        //  Check if custom PayloadKey was passed, else use standard "PayloadKey"
        // -----------------------------------------------------------------------
        if (payloadKey == nil || payloadKey.length == 0) {
            payloadKey = manifestContentDict[PFCManifestKeyPayloadKey];
        }

        // ---------------------------------------------------------------------
        //  Resolve any nested payload keys
        //  FIXME - Need to implement this for nested keys
        // ---------------------------------------------------------------------
        // NSString *payloadParentKey = payloadDict[PFCManifestParentKey];

        // ---------------------------------------------------------------------
        //  Get index of current payload in payload array
        // ---------------------------------------------------------------------
        NSUInteger index = [*payloads indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
          return [item[PFCManifestKeyPayloadUUID] isEqualToString:payloadUUID];
        }];

        // ----------------------------------------------------------------------------------
        //  Create mutable version of current payload, or create new payload if none existed
        // ----------------------------------------------------------------------------------
        NSMutableDictionary *payloadDictDict;
        if (index != NSNotFound) {
            payloadDictDict = [[*payloads objectAtIndex:index] mutableCopy];
        } else {
            payloadDictDict = [self payloadRootFromManifest:manifestContentDict settings:settings payloadType:payloadType payloadUUID:payloadUUID];
        }

        // ---------------------------------------------------------------------
        //  Add current key and value to payload
        // ---------------------------------------------------------------------
        payloadDictDict[payloadKey] = value;

        // ---------------------------------------------------------------------
        //  Save payload to payload array
        // ---------------------------------------------------------------------
        if (index != NSNotFound) {
            [*payloads replaceObjectAtIndex:index withObject:[payloadDictDict copy]];
        } else {
            [*payloads addObject:[payloadDictDict copy]];
        }
    }

    // -------------------------------------------------------------------------
    //  Check if the selectedValueArray contains any SharedKeys
    //  Return a valid idxPayloadValue if that is found
    // -------------------------------------------------------------------------
    NSUInteger idxSharedKey = [selectedValueArray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
      return (item[PFCManifestKeySharedKey]) ? YES : NO;
    }];

    // FIXME - How does this handle multiple shared keys!?

    // -------------------------------------------------------------------------
    //  If a SharedKey was found in the array, update the payload
    // -------------------------------------------------------------------------
    if (idxSharedKey != NSNotFound) {
        NSDictionary *sharedKeyDict = selectedValueArray[idxSharedKey];

        // ---------------------------------------------------------------------
        //  Remove the SharedKey from the array
        // ---------------------------------------------------------------------
        [selectedValueArray removeObjectAtIndex:idxSharedKey];

        // ---------------------------------------------------------------------
        //  Get the SharedKey name
        // ---------------------------------------------------------------------
        id value = sharedKeyDict[PFCManifestKeySharedKey];
        if (value == nil) {
            DDLogError(@"SharedKey was empty");
            return;
        } else if (![[value class] isSubclassOfClass:NSString.class]) {
            return [self payloadErrorForValueClass:NSStringFromClass([value class]) payloadKey:manifestContentDict[PFCManifestKeyPayloadType] exptectedClasses:@[ NSStringFromClass(NSString.class) ]];
        } else {

            // -----------------------------------------------------------------
            //  Get the ValueKeysShared array
            // -----------------------------------------------------------------
            NSDictionary *valueKeysShared = manifestContentDict[PFCManifestKeyValueKeysShared] ?: @{};
            if (valueKeysShared.count == 0) {
                DDLogError(@"ValueKeysShared was empty");
                return;
            } else if (!valueKeysShared[value]) {
                DDLogWarn(@"Selection does not exist in manifest ValueKeysShared");
                DDLogWarn(@"Selected value: %@", value);
                DDLogWarn(@"ValueKeys: %@", valueKeys);
                return;
            }

            // ---------------------------------------------------------------------------
            //  Pass valueKeysShared dict as a manifestContentDict to be added to payload
            // ---------------------------------------------------------------------------
            [self createPayloadFromManifestContentDict:valueKeysShared[value] settings:settings payloads:payloads];
        }
    }

    // -----------------------------------------------------------------------------------------
    //  If any more dicts are in the array, pass them as manifestContent to be added to payload
    // -----------------------------------------------------------------------------------------
    if (selectedValueArray.count != 0) {
        [self createPayloadFromManifestContent:selectedValueArray settings:settings payloads:payloads];
    }
} // createPayloadFromValueKey:availableValues:manifestContentDict:settings:payloadKey:payloadType:payloadUUID:payloads

- (void)createPayloadFromManifestContentDict:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings payloads:(NSMutableArray **)payloads {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    NSString *cellType = manifestContentDict[PFCManifestKeyCellType];
    DDLogDebug(@"CellType: %@", cellType);

    // -------------------------------------------------------------------------
    //  Checkbox
    // -------------------------------------------------------------------------
    if ([cellType isEqualToString:PFCCellTypeCheckbox]) {
        [PFCCheckboxCellView createPayloadForCellType:manifestContentDict settings:settings payloads:payloads sender:self];

        // ---------------------------------------------------------------------
        //  CheckboxNoDescription
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeCheckboxNoDescription]) {
        [PFCCheckboxNoDescriptionCellView createPayloadForCellType:manifestContentDict settings:settings payloads:payloads sender:self];

        // ---------------------------------------------------------------------
        //  DatePicker
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeDatePicker]) {
        [PFCDatePickerCellView createPayloadForCellType:manifestContentDict settings:settings payloads:payloads sender:self];

        // ---------------------------------------------------------------------
        //  DatePickerNoTitle
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeDatePickerNoTitle]) {
        [PFCDatePickerNoTitleCellView createPayloadForCellType:manifestContentDict settings:settings payloads:payloads sender:self];

        // ---------------------------------------------------------------------
        //  File
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeFile]) {

        // ---------------------------------------------------------------------
        //  PopUpButton
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypePopUpButton]) {
        [PFCPopUpButtonCellView createPayloadForCellType:manifestContentDict settings:settings payloads:payloads sender:self];

        // ---------------------------------------------------------------------
        //  PopUpButtonLeft
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypePopUpButtonLeft]) {
        [PFCPopUpButtonLeftCellView createPayloadForCellType:manifestContentDict settings:settings payloads:payloads sender:self];

        // ---------------------------------------------------------------------
        //  PopUpButtonNoTitle
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypePopUpButtonNoTitle]) {
        [PFCPopUpButtonNoTitleCellView createPayloadForCellType:manifestContentDict settings:settings payloads:payloads sender:self];

        // ---------------------------------------------------------------------
        //  SegmentedControl
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeSegmentedControl]) {
        [PFCSegmentedControlCellView createPayloadForCellType:manifestContentDict settings:settings payloads:payloads sender:self];

        // ---------------------------------------------------------------------
        //  TableView
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTableView]) {
        [PFCTableViewCellView createPayloadForCellType:manifestContentDict settings:settings payloads:payloads sender:self];

        // ---------------------------------------------------------------------
        //  TextField
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextField]) {
        [PFCTextFieldCellView createPayloadForCellType:manifestContentDict settings:settings payloads:payloads sender:self];

        // ---------------------------------------------------------------------
        //  TextFieldCheckbox
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldCheckbox]) {
        [PFCTextFieldCheckboxCellView createPayloadForCellType:manifestContentDict settings:settings payloads:payloads sender:self];

        // ---------------------------------------------------------------------
        //  TextFieldDaysHoursNoTitle
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldDaysHoursNoTitle]) {

        // ---------------------------------------------------------------------
        //  TextFieldHostPort
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldHostPort]) {
        [PFCTextFieldHostPortCellView createPayloadForCellType:manifestContentDict settings:settings payloads:payloads sender:self];

        // ---------------------------------------------------------------------
        //  TextFieldHostPortCheckbox
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldHostPortCheckbox]) {
        [PFCTextFieldHostPortCheckboxCellView createPayloadForCellType:manifestContentDict settings:settings payloads:payloads sender:self];

        // ---------------------------------------------------------------------
        //  TextFieldNoTitle
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldNoTitle]) {
        [PFCTextFieldNoTitleCellView createPayloadForCellType:manifestContentDict settings:settings payloads:payloads sender:self];

        // ---------------------------------------------------------------------
        //  TextFieldNumber
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldNumber]) {
        [PFCTextFieldNumberCellView createPayloadForCellType:manifestContentDict settings:settings payloads:payloads sender:self];

        // ---------------------------------------------------------------------
        //  TextFieldNumberLeft
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldNumberLeft]) {
        [PFCTextFieldNumberLeftCellView createPayloadForCellType:manifestContentDict settings:settings payloads:payloads sender:self];

        // ---------------------------------------------------------------------
        //  TextView
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextView]) {
        [PFCTextViewCellView createPayloadForCellType:manifestContentDict settings:settings payloads:payloads sender:self];

    } else {
        DDLogError(@"Unknown CellType: %@ in %s", cellType, __PRETTY_FUNCTION__);
    }
} // createPayloadFromManifestContentDict:settings:payloads

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TableView Column Dict Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)createPayloadFromTableViewColumns:(NSArray *)tableViewColumns settings:(NSDictionary *)settings payloads:(NSMutableArray **)payloads {
    NSMutableDictionary *payloadDict = [[NSMutableDictionary alloc] init];
    for (NSDictionary *tableViewColumnDict in tableViewColumns) {
        [self createPayloadFromTableViewColumnDict:tableViewColumnDict settings:settings payloadDict:&payloadDict];
    }
    [*payloads addObject:[payloadDict copy]];
} // createPayloadFromTableViewColumns:settings:payloads

- (void)createPayloadFromTableViewColumnDict:(NSDictionary *)tableViewColumnDict settings:(NSDictionary *)settings payloadDict:(NSMutableDictionary **)payloadDict {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    NSString *cellType = tableViewColumnDict[PFCManifestKeyCellType];
    DDLogDebug(@"CellType: %@", cellType);

    // -------------------------------------------------------------------------
    //  TableView Checkbox
    // -------------------------------------------------------------------------
    if ([cellType isEqualToString:PFCTableViewCellTypeCheckbox]) {
        [PFCTableViewCheckboxCellView createPayloadForCellType:tableViewColumnDict settings:settings payloadDict:payloadDict sender:self];

        // -------------------------------------------------------------------------
        //  TableView PopUp Button
        // -------------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCTableViewCellTypePopUpButton]) {

        // -------------------------------------------------------------------------
        //  TableView TextField
        // -------------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCTableViewCellTypeTextField]) {
        [PFCTableViewTextFieldCellView createPayloadForCellType:tableViewColumnDict settings:settings payloadDict:payloadDict sender:self];

        // -------------------------------------------------------------------------
        //  TableView TextFieldNumber
        // -------------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCTableViewCellTypeTextFieldNumber]) {

    } else {
        DDLogError(@"Unknown CellType: %@ in %s", cellType, __PRETTY_FUNCTION__);
    }
}

@end
