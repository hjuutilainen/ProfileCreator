//
//  PFCProfileExport.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-21.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCProfileExport.h"
#import "PFCConstants.h"
#import "PFCLog.h"
#import "PFCManifestLibrary.h"

@interface PFCProfileExport()

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
    if ( self != nil ) {
        _settingsProfile = settings;
        _mainWindow = mainWindow;
    }
    return self;
} // initWithProfileSettings:mainWindow

- (void)dealloc {
    
} // dealloc

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Export Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)exportProfileToURL:(NSURL *)url manifests:(NSArray *)manifests settings:(NSDictionary *)settings {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    // -------------------------------------------------------------------------
    //  Create profile root from profile settings
    // -------------------------------------------------------------------------
    NSMutableDictionary *profile = [NSMutableDictionary dictionary];
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
    for ( NSDictionary *manifest in manifests ) {
        NSDictionary *manifestSettings = settings[manifest[PFCManifestKeyDomain]];
        for ( NSDictionary *manifestTabSettings in manifestSettings[@"Settings"] ) {
            [self createPayloadFromManifestContent:manifest[PFCManifestKeyManifestContent] settings:manifestTabSettings payloads:&payloadArray];
        }
    }
    
    if ( [payloadArray count] == 0 ) {
        DDLogError(@"No payload array returned");
        // FIXME - Add user error message
        return;
    }
    
    // -------------------------------------------------------------------------
    //  Add to profile root from "General" settings
    //  Get index of general settings and remove it from manifest array
    // -------------------------------------------------------------------------
    NSUInteger idx = [payloadArray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return [[item objectForKey:PFCManifestKeyPayloadType] isEqualToString:@"com.apple.profile"];
    }];
    
    DDLogDebug(@"Profile settings index in payload array: %lu", (unsigned long)idx);
    if ( idx == NSNotFound ) {
        DDLogError(@"No general settings found in manifest array");
        // FIXME - Add user error message
        return;
    }
    
    NSMutableDictionary *profileRootKeys = [[payloadArray objectAtIndex:idx] mutableCopy];
    [payloadArray removeObjectAtIndex:idx];
    [profile addEntriesFromDictionary:[self profileRootKeysFromGeneralPayload:profileRootKeys]];
    
    profile[@"PayloadContent"] = [payloadArray copy] ?: @[];
    
    DDLogVerbose(@"Finished profile: %@", profile);
    
    // -------------------------------------------------------------------------
    //  Write profile to disk
    // -------------------------------------------------------------------------
    NSError *error = nil;
    if ( ! [profile writeToURL:url atomically:NO] ) {
        DDLogError(@"Could not write profile to disk");
        // FIXME - Add user error message
    } else {
        if ( [url checkResourceIsReachableAndReturnError:&error] ) {
            
            // -------------------------------------------------------------------------
            //  Show profile in Finder
            // -------------------------------------------------------------------------
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[ url ]];
        } else {
            DDLogError(@"%@", [error localizedDescription]);
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
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    DDLogVerbose(@"%@", settings);
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
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
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
    
    if ( payloadType == nil || [payloadType length] == 0 ) {
        payloadType = manifest[PFCManifestKeyPayloadType];
    }
    
    if ( payloadUUID == nil || [payloadUUID length] == 0 ) {
        if ( [settings[payloadType][@"UUID"] length] != 0 ) {
            payloadUUID = settings[payloadType][@"UUID"];
        } else {
            DDLogWarn(@"No UUID found for payload type: %@", payloadType);
            payloadUUID = [[NSUUID UUID] UUIDString];
        }
    }
    
    return [NSMutableDictionary dictionaryWithDictionary:@{ PFCManifestKeyPayloadType : payloadType,
                                                            PFCManifestKeyPayloadVersion : @1, // Could be different!?
                                                            PFCManifestKeyPayloadIdentifier : [NSString stringWithFormat:@"%@.%@.%@", _rootIdentifier, payloadType, payloadUUID],
                                                            PFCManifestKeyPayloadUUID : payloadUUID,
                                                            PFCManifestKeyPayloadDisplayName : @"FIXME",
                                                            PFCManifestKeyPayloadDescription : @"FIXME",
                                                            PFCManifestKeyPayloadOrganization : [NSString stringWithFormat:@"%@", _rootOrganization ?: @"FIXME"]
                                                            }];
} // payloadRootFromManifest:settings:payloadType:payloadUUID

- (void)createPayloadFromManifestContent:(NSArray *)manifestContent settings:(NSDictionary *)settings payloads:(NSMutableArray **)payloads {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    for ( NSDictionary *manifestContentDict in manifestContent ) {
        [self createPayloadFromManifestContentDict:manifestContentDict settings:settings payloads:payloads];
    }
} // createPayloadFromManifestContent:settings:payloads

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark ManifestContentDict Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

void (^payloadManifestKeyError)(NSString *key, NSDictionary *manifestContentDict) = ^(NSString *key, NSDictionary *manifestContentDict) {
    DDLogError(@"Manifest is missing required key: %@", key);
    DDLogError(@"Manifest: %@", manifestContentDict);
}; // payloadManifestKeyError

void (^payloadValueClassError)(NSString *payloadKey, NSString *valueClass, NSArray *expectedClasses) = ^(NSString *payloadKey, NSString *valueClass, NSArray *expectedClasses) {
    DDLogError(@"Value for payload key: %@ is not of the correct class", payloadKey);
    DDLogError(@"Expected classes: %@", expectedClasses);
    DDLogError(@"Value class: %@", valueClass);
}; // payloadValueClassError

- (BOOL)verifyRequiredManifestContentDictKeys:(NSArray *)manifestContentDictKeys manifestContentDict:(NSDictionary *)manifestContentDict {
    __block BOOL verified = YES;
    [manifestContentDictKeys enumerateObjectsUsingBlock:^(NSString * _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( manifestContentDict[key] != nil ) {
            DDLogDebug(@"%@: %@", key, manifestContentDict[key]);
        } else {
            payloadManifestKeyError(key, manifestContentDict);
            verified = NO;
            *stop = YES;
        }
    }];
    return verified;
} // verifyRequiredManifestContentDictKeys:manifestContentDict

- (void)createPayloadFromValueKey:(NSString *)selectedValue availableValues:(NSArray *)availableValues manifestContentDict:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings payloadKey:(NSString *)payloadKey payloadType:(NSString *)payloadType payloadUUID:(NSString *)payloadUUID payloads:(NSMutableArray **)payloads {
    
    // -------------------------------------------------------------------------
    //  Check that selected value exist among available values
    // -------------------------------------------------------------------------
    if ( availableValues == nil ) {
        return;
    } else if ( [availableValues count] == 0 ) {
        return;
    } else if ( ! [availableValues containsObject:selectedValue] ) {
        DDLogWarn(@"Selection does not exist in available values");
        DDLogWarn(@"Selected value: %@", selectedValue);
        DDLogWarn(@"Available values: %@", availableValues);
        return;
    }
    
    // -------------------------------------------------------------------------
    //  Check that selected value exist among value keys
    // -------------------------------------------------------------------------
    NSDictionary *valueKeys = manifestContentDict[PFCManifestKeyValueKeys] ?: @{};
    if ( [valueKeys count] == 0 ) {
        DDLogError(@"ValueKeys is empty, please update the manifest to handle all selections");
        return;
    } else if ( ! valueKeys[selectedValue] ) {
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
        return ( item[PFCManifestKeyPayloadValue] ) ? YES : NO;
    }];
    
    // -------------------------------------------------------------------------
    //  If a PayloadValue was found in the array, update the payload
    // -------------------------------------------------------------------------
    if ( idxPayloadValue != NSNotFound ) {
        NSDictionary *payloadValueDict = [selectedValueArray objectAtIndex:idxPayloadValue]; // Same as manifestContentDict
        
        // ---------------------------------------------------------------------
        //  Remove the PayloadValue from the array
        // ---------------------------------------------------------------------
        [selectedValueArray removeObjectAtIndex:idxPayloadValue];
        
        // ---------------------------------------------------------------------
        //  Get value for selection
        // ---------------------------------------------------------------------
        id value = payloadValueDict[PFCManifestKeyPayloadValue];
        if ( value == nil ) {
            DDLogError(@"PayloadValue was empty");
            return;
        }
        
        // FIXME - Possibly add valuetype-key or other method to verify value type, or require it in the dict
        
        // -------------------------------------------------------------------------
        //  Check if custom PayloadType was passed, else use standard "PayloadType"
        // -------------------------------------------------------------------------
        if ( payloadType == nil || [payloadType length] == 0 ) {
            payloadType = manifestContentDict[PFCManifestKeyPayloadType];
        }
        
        // -------------------------------------------------------------------------
        //  Check if custom PayloadUUID was passed, else use standard "PayloadUUID"
        // -------------------------------------------------------------------------
        if ( payloadUUID == nil || [payloadUUID length] == 0 ) {
            if ( [settings[payloadType][@"UUID"] length] != 0 ) {
                payloadUUID = settings[payloadType][@"UUID"];
            } else {
                DDLogWarn(@"No UUID found for payload type: %@", payloadType);
                payloadUUID = [[NSUUID UUID] UUIDString];
            }
        }
        
        // -----------------------------------------------------------------------
        //  Check if custom PayloadKey was passed, else use standard "PayloadKey"
        // -----------------------------------------------------------------------
        if ( payloadKey == nil || [payloadKey length] == 0 ) {
            payloadKey = manifestContentDict[PFCManifestKeyPayloadKey];
        }
        
        // ---------------------------------------------------------------------
        //  Resolve any nested payload keys
        //  FIXME - Need to implement this for nested keys
        // ---------------------------------------------------------------------
        //NSString *payloadParentKey = payloadDict[PFCManifestParentKey];
        
        // ---------------------------------------------------------------------
        //  Get index of current payload in payload array
        // ---------------------------------------------------------------------
        NSUInteger idx = [*payloads indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
            return [[item objectForKey:PFCManifestKeyPayloadUUID] isEqualToString:payloadUUID];
        }];
        
        // ----------------------------------------------------------------------------------
        //  Create mutable version of current payload, or create new payload if none existed
        // ----------------------------------------------------------------------------------
        NSMutableDictionary *payloadDictDict;
        if ( idx != NSNotFound ) {
            payloadDictDict = [[*payloads objectAtIndex:idx] mutableCopy];
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
        if ( idx != NSNotFound ) {
            [*payloads replaceObjectAtIndex:idx withObject:[payloadDictDict copy]];
        } else {
            [*payloads addObject:[payloadDictDict copy]];
        }
    }
    
    // -------------------------------------------------------------------------
    //  Check if the selectedValueArray contains any SharedKeys
    //  Return a valid idxPayloadValue if that is found
    // -------------------------------------------------------------------------
    NSUInteger idxSharedKey = [selectedValueArray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return ( item[PFCManifestKeySharedKey] ) ? YES : NO;
    }];
    
    // FIXME - How does this handle multiple shared keys!?
    
    // -------------------------------------------------------------------------
    //  If a SharedKey was found in the array, update the payload
    // -------------------------------------------------------------------------
    if ( idxSharedKey != NSNotFound ) {
        NSDictionary *sharedKeyDict = [selectedValueArray objectAtIndex:idxSharedKey];
        
        // ---------------------------------------------------------------------
        //  Remove the SharedKey from the array
        // ---------------------------------------------------------------------
        [selectedValueArray removeObjectAtIndex:idxSharedKey];
        
        // ---------------------------------------------------------------------
        //  Get the SharedKey name
        // ---------------------------------------------------------------------
        id value = sharedKeyDict[PFCManifestKeySharedKey];
        if ( value == nil ) {
            DDLogError(@"SharedKey was empty");
            return;
        } else if ( ! [[value class] isSubclassOfClass:[NSString class]] ) {
            payloadValueClassError(manifestContentDict[PFCManifestKeyPayloadType], NSStringFromClass([value class]), @[ NSStringFromClass([NSString class]) ]);
        } else {
            
            // -----------------------------------------------------------------
            //  Get the ValueKeysShared array
            // -----------------------------------------------------------------
            NSDictionary *valueKeysShared = manifestContentDict[PFCManifestKeyValueKeysShared] ?: @{};
            if ( [valueKeysShared count] == 0 ) {
                DDLogError(@"ValueKeysShared was empty");
                return;
            } else if ( ! valueKeysShared[value] ) {
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
    if ( [selectedValueArray count] != 0 ) {
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
    if ( [cellType isEqualToString:PFCCellTypeCheckbox] ) {
        [self createPayloadFromCellTypeCheckbox:manifestContentDict settings:settings payloads:payloads];
        
        // ---------------------------------------------------------------------
        //  CheckboxNoDescription
        // ---------------------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeCheckboxNoDescription] ) {
        [self createPayloadFromCellTypeCheckbox:manifestContentDict settings:settings payloads:payloads];
        
        // ---------------------------------------------------------------------
        //  DatePicker
        // ---------------------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeDatePicker] ) {
        
        // ---------------------------------------------------------------------
        //  DatePickerNoTitle
        // ---------------------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeDatePickerNoTitle] ) {
        
        // ---------------------------------------------------------------------
        //  File
        // ---------------------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeFile] ) {
        
        // ---------------------------------------------------------------------
        //  PopUpButton
        // ---------------------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypePopUpButton] ) {
        [self createPayloadFromCellTypePopUpButton:manifestContentDict settings:settings payloads:payloads];
        
        // ---------------------------------------------------------------------
        //  PopUpButtonLeft
        // ---------------------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypePopUpButtonLeft] ) {
        [self createPayloadFromCellTypePopUpButton:manifestContentDict settings:settings payloads:payloads];
        
        // ---------------------------------------------------------------------
        //  PopUpButtonNoTitle
        // ---------------------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypePopUpButtonNoTitle] ) {
        [self createPayloadFromCellTypePopUpButton:manifestContentDict settings:settings payloads:payloads];
        
        // ---------------------------------------------------------------------
        //  SegmentedControl
        // ---------------------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeSegmentedControl] ) {
        [self createPayloadFromCellTypeSegmentedControl:manifestContentDict settings:settings payloads:payloads];
        
        // ---------------------------------------------------------------------
        //  TableView
        // ---------------------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeTableView] ) {
        
        // ---------------------------------------------------------------------
        //  TextField
        // ---------------------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeTextField] ) {
        [self createPayloadFromCellTypeTextField:manifestContentDict settings:settings payloads:payloads];
        
        // ---------------------------------------------------------------------
        //  TextFieldCheckbox
        // ---------------------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeTextFieldCheckbox] ) {
        [self createPayloadFromCellTypeTextFieldCheckbox:manifestContentDict settings:settings payloads:payloads];
        
        // ---------------------------------------------------------------------
        //  TextFieldDaysHoursNoTitle
        // ---------------------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeTextFieldDaysHoursNoTitle] ) {
        
        // ---------------------------------------------------------------------
        //  TextFieldHostPort
        // ---------------------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeTextFieldHostPort] ) {
        [self createPayloadFromCellTypeTextFieldHostPort:manifestContentDict settings:settings payloads:payloads];
        
        // ---------------------------------------------------------------------
        //  TextFieldHostPortCheckbox
        // ---------------------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeTextFieldHostPortCheckbox] ) {
        [self createPayloadFromCellTypeTextFieldHostPortCheckbox:manifestContentDict settings:settings payloads:payloads];
        
        // ---------------------------------------------------------------------
        //  TextFieldNoTitle
        // ---------------------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeTextFieldNoTitle] ) {
        [self createPayloadFromCellTypeTextField:manifestContentDict settings:settings payloads:payloads];
        
        // ---------------------------------------------------------------------
        //  TextFieldNumber
        // ---------------------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeTextFieldNumber] ) {
        [self createPayloadFromCellTypeTextFieldNumber:manifestContentDict settings:settings payloads:payloads];
        
        // ---------------------------------------------------------------------
        //  TextFieldNumberLeft
        // ---------------------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeTextFieldNumberLeft] ) {
        [self createPayloadFromCellTypeTextFieldNumber:manifestContentDict settings:settings payloads:payloads];
        
    } else {
        DDLogDebug(@"Unknown cell type: %@", cellType);
    }
} // createPayloadFromManifestContentDict:settings:payloads

- (void)createPayloadFromCellTypeCheckbox:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings payloads:(NSMutableArray **)payloads {
    
    // -------------------------------------------------------------------------
    //  Verify required keys for CellType: 'Checkbox'
    // -------------------------------------------------------------------------
    if ( ! [self verifyRequiredManifestContentDictKeys:@[ PFCManifestKeyIdentifier,
                                                          PFCManifestKeyPayloadType,
                                                          PFCManifestKeyPayloadKey ]
                                   manifestContentDict:manifestContentDict] ) {
        return;
    }
    
    // -------------------------------------------------------------------------
    //  Get value for Checkbox
    // -------------------------------------------------------------------------
    NSDictionary *contentDictSettings = settings[manifestContentDict[PFCManifestKeyIdentifier]] ?: @{};
    id value = contentDictSettings[PFCSettingsKeyValue];
    if ( value == nil ) {
        value = manifestContentDict[PFCManifestKeyDefaultValue];
    }
    
    // -------------------------------------------------------------------------
    //  Verify CheckboxValue is of the expected class type(s)
    // -------------------------------------------------------------------------
    BOOL checkboxState = NO;
    if ( value == nil ) {
        DDLogWarn(@"CheckboxValue is empty");
        
        if ( [manifestContentDict[PFCManifestKeyOptional] boolValue] ) {
            DDLogDebug(@"PayloadKey: %@ is optional, skipping", manifestContentDict[PFCManifestKeyPayloadKey]);
            return;
        }
    } else if ( ! [[value class] isEqualTo:[@(YES) class]] && ! [[value class] isEqualTo:[@(0) class]] ) {
        return payloadValueClassError(manifestContentDict[PFCManifestKeyPayloadType], NSStringFromClass([value class]), @[ NSStringFromClass([@(YES) class]), NSStringFromClass([@(0) class]) ]);
    } else {
        checkboxState = [(NSNumber *)value boolValue];
        DDLogDebug(@"CheckboxValue: %@", (checkboxState) ? @"YES" : @"NO");
    }
    
    // ---------------------------------------------------------------------
    //  Resolve any nested payload keys
    //  FIXME - Need to implement this for nested keys
    // ---------------------------------------------------------------------
    //NSString *payloadParentKey = payloadDict[PFCManifestParentKey];
    
    // -------------------------------------------------------------------------
    //  Get index of current payload in payload array
    // -------------------------------------------------------------------------
    NSUInteger idx = [*payloads indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return [[item objectForKey:PFCManifestKeyPayloadUUID] isEqualToString:settings[manifestContentDict[PFCManifestKeyPayloadType]][PFCProfileTemplateKeyUUID] ?: @""];
    }];
    
    // ----------------------------------------------------------------------------------
    //  Create mutable version of current payload, or create new payload if none existed
    // ----------------------------------------------------------------------------------
    NSMutableDictionary *payloadDictDict;
    if ( idx != NSNotFound ) {
        payloadDictDict = [[*payloads objectAtIndex:idx] mutableCopy];
    } else {
        payloadDictDict = [self payloadRootFromManifest:manifestContentDict settings:settings payloadType:nil payloadUUID:nil];
    }
    
    // -------------------------------------------------------------------------
    //  Add current key and value to payload
    // -------------------------------------------------------------------------
    payloadDictDict[manifestContentDict[PFCManifestKeyPayloadKey]] = @(checkboxState);
    
    // -------------------------------------------------------------------------
    //  Save payload to payload array
    // -------------------------------------------------------------------------
    if ( idx != NSNotFound ) {
        [*payloads replaceObjectAtIndex:idx withObject:[payloadDictDict copy]];
    } else {
        [*payloads addObject:[payloadDictDict copy]];
    }
    
    // -------------------------------------------------------------------------
    //
    // -------------------------------------------------------------------------
    [self createPayloadFromValueKey:( checkboxState ) ? @"True" : @"False" availableValues:manifestContentDict[PFCManifestKeyAvailableValues] manifestContentDict:manifestContentDict settings:settings payloadKey:nil payloadType:nil payloadUUID:nil payloads:payloads];
} // createPayloadFromCellTypeCheckbox:settings:payloads

- (void)createPayloadFromCellTypePopUpButton:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings payloads:(NSMutableArray **)payloads {
    
    // -------------------------------------------------------------------------
    //  Verify required keys for CellType: 'PopUpButton'
    // -------------------------------------------------------------------------
    if ( ! [self verifyRequiredManifestContentDictKeys:@[ PFCManifestKeyIdentifier,
                                                          PFCManifestKeyAvailableValues ]
                                   manifestContentDict:manifestContentDict] ) {
        return;
    }
    
    // -------------------------------------------------------------------------
    //  Get selected title
    // -------------------------------------------------------------------------
    NSDictionary *contentDictSettings = settings[manifestContentDict[PFCManifestKeyIdentifier]] ?: @{};
    id value = contentDictSettings[PFCSettingsKeyValue];
    if ( value == nil ) {
        value = manifestContentDict[PFCManifestKeyDefaultValue];
    }
    
    // -------------------------------------------------------------------------
    //  Verify value is of the expected class type(s)
    // -------------------------------------------------------------------------
    if ( value == nil ) {
        DDLogError(@"Value is empty");
        return;
    } else if ( ! [[value class] isSubclassOfClass:[NSString class]] ) {
        return payloadValueClassError(manifestContentDict[PFCManifestKeyPayloadType], NSStringFromClass([value class]), @[ NSStringFromClass([NSString class]) ]);
    } else {
        DDLogDebug(@"Selected title: %@", value);
    }
    
    // -------------------------------------------------------------------------
    //
    // -------------------------------------------------------------------------
    [self createPayloadFromValueKey:value availableValues:manifestContentDict[PFCManifestKeyAvailableValues] manifestContentDict:manifestContentDict settings:settings payloadKey:nil payloadType:nil payloadUUID:nil payloads:payloads];
} // createPayloadFromCellTypePopUpButton:settings:payloads

- (void)createPayloadFromCellTypeSegmentedControl:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings payloads:(NSMutableArray **)payloads {
    
    // -------------------------------------------------------------------------
    //  Verify required keys for CellType: 'SegmentedControl'
    // -------------------------------------------------------------------------
    if ( ! [self verifyRequiredManifestContentDictKeys:@[ PFCManifestKeyAvailableValues,
                                                          PFCManifestKeyValueKeys ]
                                   manifestContentDict:manifestContentDict] ) {
        return;
    }
    
    // -------------------------------------------------------------------------
    //  Verify AvailableValues isn't empty
    // -------------------------------------------------------------------------
    NSArray *availableValues = manifestContentDict[PFCManifestKeyAvailableValues] ?: @[];
    if ( [availableValues count] == 0 ) {
        DDLogError(@"AvailableValues is empty");
        return;
    }
    
    // -------------------------------------------------------------------------
    //  Verify ValueKeys isn't empty
    // -------------------------------------------------------------------------
    NSDictionary *valueKeys = manifestContentDict[PFCManifestKeyValueKeys] ?: @{};
    if ( [valueKeys count] == 0 ) {
        DDLogError(@"ValueKeys is empty");
        return;
    }
    
    // -------------------------------------------------------------------------
    //  Loop through all values in "AvailableValues" and add to payloads
    // -------------------------------------------------------------------------
    for ( NSString *selection in availableValues ) {
        [self createPayloadFromManifestContent:valueKeys[selection] settings:settings payloads:payloads];
    }
} // createPayloadFromCellTypeSegmentedControl:settings:payloads

- (void)createPayloadFromCellTypeTextField:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings payloads:(NSMutableArray **)payloads {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    // -------------------------------------------------------------------------
    //  Verify required keys for CellType: 'TextField'
    // -------------------------------------------------------------------------
    if ( ! [self verifyRequiredManifestContentDictKeys:@[ PFCManifestKeyIdentifier,
                                                          PFCManifestKeyPayloadType,
                                                          PFCManifestKeyPayloadKey ]
                                   manifestContentDict:manifestContentDict] ) {
        return;
    }
    
    // -------------------------------------------------------------------------
    //  Get value for current PayloadKey
    // -------------------------------------------------------------------------
    NSDictionary *contentDictSettings = settings[manifestContentDict[PFCManifestKeyIdentifier]] ?: @{};
    id value = contentDictSettings[PFCSettingsKeyValue];
    if ( value == nil ) {
        value = manifestContentDict[PFCManifestKeyDefaultValue];
    }
    
    // -------------------------------------------------------------------------
    //  Verify value is of the expected class type(s)
    // -------------------------------------------------------------------------
    if ( value == nil || ( [[value class] isSubclassOfClass:[NSString class]] && [value length] == 0 ) ) {
        DDLogDebug(@"PayloadValue is empty");
        
        if ( [manifestContentDict[PFCManifestKeyOptional] boolValue] ) {
            DDLogDebug(@"PayloadKey: %@ is optional, skipping", manifestContentDict[PFCManifestKeyPayloadKey]);
            return;
        }
        
        value = @"";
    } else if ( ! [[value class] isSubclassOfClass:[NSString class]] ) {
        return payloadValueClassError(manifestContentDict[PFCManifestKeyPayloadType], NSStringFromClass([value class]), @[ NSStringFromClass([NSString class]) ]);
    } else {
        DDLogDebug(@"PayloadValue: %@", value);
    }
    
    // -------------------------------------------------------------------------
    //  Resolve any nested payload keys
    //  FIXME - Need to implement this for nested keys
    // -------------------------------------------------------------------------
    //NSString *payloadParentKey = payloadDict[PFCManifestParentKey];
    
    // -------------------------------------------------------------------------
    //  Get index of current payload in payload array
    // -------------------------------------------------------------------------
    NSUInteger idx = [*payloads indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return [[item objectForKey:PFCManifestKeyPayloadUUID] isEqualToString:settings[manifestContentDict[PFCManifestKeyPayloadType]][PFCProfileTemplateKeyUUID] ?: @""];
    }];
    
    // ----------------------------------------------------------------------------------
    //  Create mutable version of current payload, or create new payload if none existed
    // ----------------------------------------------------------------------------------
    NSMutableDictionary *payloadDictDict;
    if ( idx != NSNotFound ) {
        payloadDictDict = [[*payloads objectAtIndex:idx] mutableCopy];
    } else {
        payloadDictDict = [self payloadRootFromManifest:manifestContentDict settings:settings payloadType:nil payloadUUID:nil];
    }
    
    // -------------------------------------------------------------------------
    //  Add current key and value to payload
    // -------------------------------------------------------------------------
    payloadDictDict[manifestContentDict[PFCManifestKeyPayloadKey]] = value;
    
    // -------------------------------------------------------------------------
    //  Save payload to payload array
    // -------------------------------------------------------------------------
    if ( idx != NSNotFound ) {
        [*payloads replaceObjectAtIndex:idx withObject:[payloadDictDict copy]];
    } else {
        [*payloads addObject:[payloadDictDict copy]];
    }
} // createPayloadFromCellTypeTextField:settings:payloads

- (void)createPayloadFromCellTypeTextFieldCheckbox:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings payloads:(NSMutableArray **)payloads {
    
    // -------------------------------------------------------------------------
    //  Verify required keys for CellType: 'TextFieldCheckbox'
    // -------------------------------------------------------------------------
    if ( ! [self verifyRequiredManifestContentDictKeys:@[ PFCManifestKeyIdentifier,
                                                          PFCManifestKeyPayloadType,
                                                          PFCManifestKeyPayloadKey ]
                                   manifestContentDict:manifestContentDict] ) {
        return;
    }
    
    // -------------------------------------------------------------------------
    //  Get value for Checkbox
    // -------------------------------------------------------------------------
    NSDictionary *contentDictSettings = settings[manifestContentDict[PFCManifestKeyIdentifier]] ?: @{};
    id valueCheckbox = contentDictSettings[PFCSettingsKeyValueCheckbox];
    if ( valueCheckbox == nil ) {
        valueCheckbox = manifestContentDict[PFCManifestKeyDefaultValueCheckbox];
    }
    
    // -------------------------------------------------------------------------
    //  Verify CheckboxValue is of the expected class type(s)
    // -------------------------------------------------------------------------
    BOOL checkboxState = NO;
    if ( valueCheckbox == nil ) {
        DDLogWarn(@"CheckboxValue is empty");
        
        if ( [manifestContentDict[PFCManifestKeyOptional] boolValue] ) {
            // FIXME - Log this different, if checkbox payload key is empty for example, or log both payload keys?
            DDLogDebug(@"PayloadKey: %@ is optional, skipping", manifestContentDict[PFCManifestKeyPayloadKeyCheckbox]);
            return;
        }
    } else if ( ! [[valueCheckbox class] isEqualTo:[@(YES) class]] && ! [[valueCheckbox class] isEqualTo:[@(0) class]] ) {
        return payloadValueClassError(manifestContentDict[PFCManifestKeyPayloadType], NSStringFromClass([valueCheckbox class]), @[ NSStringFromClass([@(YES) class]), NSStringFromClass([@(0) class]) ]);
    } else {
        checkboxState = [(NSNumber *)valueCheckbox boolValue];
        DDLogDebug(@"CheckboxValue: %@", (checkboxState) ? @"YES" : @"NO");
    }
    
    // -------------------------------------------------------------------------
    //  If Checkbox is enabled, verify required keys for TextField
    // -------------------------------------------------------------------------
    if ( checkboxState && [self verifyRequiredManifestContentDictKeys:@[ PFCManifestKeyPayloadKeyTextField ]
                                                  manifestContentDict:manifestContentDict] ) {
        
        // ---------------------------------------------------------------------
        //  Get value for TextField
        // ---------------------------------------------------------------------
        id valueTextField = contentDictSettings[PFCSettingsKeyValue];
        if ( valueTextField == nil ) {
            valueTextField = manifestContentDict[PFCManifestKeyDefaultValue];
        }
        
        // ---------------------------------------------------------------------
        //  Verify value is of the expected class type(s)
        // ---------------------------------------------------------------------
        if ( valueTextField == nil || ( [[valueTextField class] isSubclassOfClass:[NSString class]] && [valueTextField length] == 0 ) ) {
            DDLogDebug(@"PayloadValue is empty");
            
            if ( [manifestContentDict[PFCManifestKeyOptional] boolValue] ) {
                DDLogDebug(@"PayloadKey: %@ is optional, skipping", manifestContentDict[PFCManifestKeyPayloadKey]);
                return;
            }
            
            valueTextField = @"";
        } else if ( ! [[valueTextField class] isSubclassOfClass:[NSString class]] ) {
            return payloadValueClassError(manifestContentDict[PFCManifestKeyPayloadType], NSStringFromClass([valueTextField class]), @[ NSStringFromClass([NSString class]) ]);
        } else {
            DDLogDebug(@"PayloadValue: %@", valueTextField);
        }
        
        // ---------------------------------------------------------------------
        //  Resolve any nested payload keys
        //  FIXME - Need to implement this for nested keys
        // ---------------------------------------------------------------------
        //NSString *payloadParentKey = payloadDict[PFCManifestParentKey];
        
        //  FIXME - Add UUID for PayloadTypeTextField/Checkbox
        //  FIXME - Rename PFCProfileTemplateKeyUUID to PayloadUUID and use a SettingsKey
        NSString *payloadTypeTextField;
        NSString *payloadUUIDTextField;
        if ( manifestContentDict[PFCManifestKeyPayloadTypeCheckbox] != nil ) {
            payloadTypeTextField = manifestContentDict[PFCManifestKeyPayloadTypeTextField];
            payloadUUIDTextField = settings[@"PayloadUUIDTextField"] ?: settings[manifestContentDict[PFCManifestKeyPayloadType]][PFCProfileTemplateKeyUUID];
        } else {
            payloadTypeTextField = manifestContentDict[PFCManifestKeyPayloadType];
            payloadUUIDTextField = settings[manifestContentDict[PFCManifestKeyPayloadType]][PFCProfileTemplateKeyUUID];
        }
        
        // ---------------------------------------------------------------------
        //  Get index of current payload in payload array
        // ---------------------------------------------------------------------
        NSUInteger idx = [*payloads indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
            return [[item objectForKey:PFCManifestKeyPayloadUUID] isEqualToString:payloadUUIDTextField ?: @""];
        }];
        
        // ----------------------------------------------------------------------------------
        //  Create mutable version of current payload, or create new payload if none existed
        // ----------------------------------------------------------------------------------
        NSMutableDictionary *payloadDictDict;
        if ( idx != NSNotFound ) {
            payloadDictDict = [[*payloads objectAtIndex:idx] mutableCopy];
        } else {
            payloadDictDict = [self payloadRootFromManifest:manifestContentDict settings:settings payloadType:payloadTypeTextField payloadUUID:payloadUUIDTextField];
        }
        
        // ---------------------------------------------------------------------
        //  Add current key and value to payload
        // ---------------------------------------------------------------------
        payloadDictDict[manifestContentDict[PFCManifestKeyPayloadKeyTextField]] = valueTextField;
        
        // ---------------------------------------------------------------------
        //  Save payload to payload array
        // ---------------------------------------------------------------------
        if ( idx != NSNotFound ) {
            [*payloads replaceObjectAtIndex:idx withObject:[payloadDictDict copy]];
        } else {
            [*payloads addObject:[payloadDictDict copy]];
        }
    }
    
    if ( ! [self verifyRequiredManifestContentDictKeys:@[ PFCManifestKeyPayloadKeyCheckbox ]
                                   manifestContentDict:manifestContentDict] ) {
        return;
    }
    
    // -------------------------------------------------------------------------
    //  Resolve any nested payload keys
    //  FIXME - Need to implement this for nested keys
    // -------------------------------------------------------------------------
    //NSString *payloadParentKey = payloadDict[PFCManifestParentKey];
    
    //  FIXME - Add UUID for PayloadTypeTextField/Checkbox
    //  FIXME - Rename PFCProfileTemplateKeyUUID to PayloadUUID and use a SettingsKey
    NSString *payloadTypeCheckbox;
    NSString *payloadUUIDCheckbox;
    if ( manifestContentDict[PFCManifestKeyPayloadTypeCheckbox] != nil ) {
        payloadTypeCheckbox = manifestContentDict[PFCManifestKeyPayloadTypeCheckbox];
        payloadUUIDCheckbox = settings[@"PayloadUUIDCheckbox"] ?: settings[manifestContentDict[PFCManifestKeyPayloadType]][PFCProfileTemplateKeyUUID];
    } else {
        payloadTypeCheckbox = manifestContentDict[PFCManifestKeyPayloadType];
        payloadUUIDCheckbox = settings[manifestContentDict[PFCManifestKeyPayloadType]][PFCProfileTemplateKeyUUID];
    }
    
    // -------------------------------------------------------------------------
    //  Get index of current payload in payload array
    // -------------------------------------------------------------------------
    NSUInteger idx = [*payloads indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return [[item objectForKey:PFCManifestKeyPayloadUUID] isEqualToString:payloadUUIDCheckbox ?: @""];
    }];
    
    // ----------------------------------------------------------------------------------
    //  Create mutable version of current payload, or create new payload if none existed
    // ----------------------------------------------------------------------------------
    NSMutableDictionary *payloadDictDict;
    if ( idx != NSNotFound ) {
        payloadDictDict = [[*payloads objectAtIndex:idx] mutableCopy];
    } else {
        payloadDictDict = [self payloadRootFromManifest:manifestContentDict settings:settings payloadType:payloadTypeCheckbox payloadUUID:payloadUUIDCheckbox];
    }
    
    // -------------------------------------------------------------------------
    //  Add current key and value to payload
    // -------------------------------------------------------------------------
    payloadDictDict[manifestContentDict[PFCManifestKeyPayloadKeyCheckbox]] = @(checkboxState);
    
    // -------------------------------------------------------------------------
    //  Save payload to payload array
    // -------------------------------------------------------------------------
    if ( idx != NSNotFound ) {
        [*payloads replaceObjectAtIndex:idx withObject:[payloadDictDict copy]];
    } else {
        [*payloads addObject:[payloadDictDict copy]];
    }
    
    // -------------------------------------------------------------------------
    //
    // -------------------------------------------------------------------------
    [self createPayloadFromValueKey:( checkboxState ) ? @"True" : @"False" availableValues:manifestContentDict[PFCManifestKeyAvailableValues] manifestContentDict:manifestContentDict settings:settings payloadKey:manifestContentDict[PFCManifestKeyPayloadKeyCheckbox] payloadType:payloadTypeCheckbox payloadUUID:payloadUUIDCheckbox payloads:payloads];
} // createPayloadFromCellTypeTextFieldCheckbox:settings:payloads

- (void)createPayloadFromCellTypeTextFieldHostPort:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings payloads:(NSMutableArray **)payloads {
    
    // -------------------------------------------------------------------------
    //  Verify required keys for CellType: 'TextFieldHostPort'
    // -------------------------------------------------------------------------
    if ( ! [self verifyRequiredManifestContentDictKeys:@[ PFCManifestKeyIdentifier,
                                                          PFCManifestKeyPayloadType ]
                                   manifestContentDict:manifestContentDict] ) {
        return;
    }
    
    // -------------------------------------------------------------------------
    //  Get value for Host
    // -------------------------------------------------------------------------
    NSDictionary *contentDictSettings = settings[manifestContentDict[PFCManifestKeyIdentifier]] ?: @{};
    id valueHost = contentDictSettings[PFCSettingsKeyValueHost];
    if ( valueHost == nil ) {
        valueHost = manifestContentDict[PFCManifestKeyDefaultValueHost];
    }
    
    // -------------------------------------------------------------------------
    //  Verify value is of the expected class type(s)
    // -------------------------------------------------------------------------
    if ( valueHost == nil || ( [[valueHost class] isSubclassOfClass:[NSString class]] && [valueHost length] == 0 ) ) {
        DDLogDebug(@"PayloadValueHost is empty");
        valueHost = @"";
    } else if ( ! [[valueHost class] isSubclassOfClass:[NSString class]] ) {
        return payloadValueClassError(manifestContentDict[PFCManifestKeyPayloadType], NSStringFromClass([valueHost class]), @[ NSStringFromClass([NSString class]) ]);
    } else {
        DDLogDebug(@"PayloadValueHost: %@", valueHost);
    }
    
    // -------------------------------------------------------------------------
    //  Get value for Port
    // -------------------------------------------------------------------------
    id valuePort = contentDictSettings[PFCSettingsKeyValuePort];
    if ( valuePort == nil ) {
        valuePort = manifestContentDict[PFCManifestKeyDefaultValuePort];
    }
    
    // -------------------------------------------------------------------------
    //  Verify value is of the expected class type(s)
    // -------------------------------------------------------------------------
    if ( valuePort == nil ) {
        DDLogDebug(@"PayloadValuePort is empty");
    } else if ( [[valuePort class] isSubclassOfClass:[NSString class]]) {
        
        // ---------------------------------------------------------------------
        //  Convert string to integer
        // ---------------------------------------------------------------------
        valuePort = @([(NSString *)valuePort integerValue]);
    } else if ( ! [[valuePort class] isEqualTo:[@(0) class] ] ) {
        return payloadValueClassError(manifestContentDict[PFCManifestKeyPayloadType], NSStringFromClass([valuePort class]), @[ NSStringFromClass([NSString class]), NSStringFromClass([@(0) class]) ]);
    } else {
        DDLogDebug(@"PayloadValuePort: %@", valuePort);
    }
    
    NSString *payloadKey;
    NSString *payloadKeyHost = manifestContentDict[PFCManifestKeyPayloadKeyHost];
    NSString *payloadKeyPort;
    if ( [payloadKeyHost length] != 0 && [manifestContentDict[PFCManifestKeyPayloadKeyPort] length] == 0 ) {
        DDLogError(@"PayloadKeyHost is: %@ but PayloadKeyPort is undefined", payloadKeyHost);
        return;
    } else if ( [payloadKeyHost length] != 0 ) {
        payloadKeyPort = manifestContentDict[PFCManifestKeyPayloadKeyPort];
    } else if ( [manifestContentDict[PFCManifestKeyPayloadKey] length] != 0 ) {
        payloadKey = manifestContentDict[PFCManifestKeyPayloadKey];
    } else {
        DDLogError(@"No PayloadKey was defined!");
        return;
    }
    
    if ( [valueHost length] == 0 && [manifestContentDict[PFCManifestKeyOptional] boolValue] ) {
        DDLogDebug(@"PayloadKey: %@ is optional, skipping", payloadKeyHost ?: payloadKey );
        return;
    }
    
    // -------------------------------------------------------------------------
    //  Resolve any nested payload keys
    //  FIXME - Need to implement this for nested keys
    // -------------------------------------------------------------------------
    //NSString *payloadParentKey = payloadDict[PFCManifestParentKey];
    
    // -------------------------------------------------------------------------
    //  Get index of current payload in payload array
    // -------------------------------------------------------------------------
    NSUInteger idx = [*payloads indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return [[item objectForKey:PFCManifestKeyPayloadUUID] isEqualToString:settings[manifestContentDict[PFCManifestKeyPayloadType]][PFCProfileTemplateKeyUUID] ?: @""];
    }];
    
    // ----------------------------------------------------------------------------------
    //  Create mutable version of current payload, or create new payload if none existed
    // ----------------------------------------------------------------------------------
    NSMutableDictionary *payloadDictDict;
    if ( idx != NSNotFound ) {
        payloadDictDict = [[*payloads objectAtIndex:idx] mutableCopy];
    } else {
        payloadDictDict = [self payloadRootFromManifest:manifestContentDict settings:settings payloadType:nil payloadUUID:nil];
    }
    
    // -------------------------------------------------------------------------
    //  Add current key and value to payload
    // -------------------------------------------------------------------------
    if ( [payloadKey length] != 0 ) {
        payloadDictDict[payloadKey] = [NSString stringWithFormat:@"%@:%@", valueHost, [valuePort stringValue]];
    } else {
        payloadDictDict[payloadKeyHost] = valueHost;
        payloadDictDict[payloadKeyPort] = valuePort;
    }
    
    // -------------------------------------------------------------------------
    //  Save payload to payload array
    // -------------------------------------------------------------------------
    if ( idx != NSNotFound ) {
        [*payloads replaceObjectAtIndex:idx withObject:[payloadDictDict copy]];
    } else {
        [*payloads addObject:[payloadDictDict copy]];
    }
} // createPayloadFromCellTypeTextFieldHostPort:settings:payloads

- (void)createPayloadFromCellTypeTextFieldHostPortCheckbox:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings payloads:(NSMutableArray **)payloads {
    
    // -------------------------------------------------------------------------
    //  Verify required keys for CellType: 'TextFieldHostPortCheckbox'
    // -------------------------------------------------------------------------
    if ( ! [self verifyRequiredManifestContentDictKeys:@[ PFCManifestKeyIdentifier,
                                                          PFCManifestKeyPayloadType ]
                                   manifestContentDict:manifestContentDict] ) {
        return;
    }
    
    // -------------------------------------------------------------------------
    //  Get value for Checkbox
    // -------------------------------------------------------------------------
    NSDictionary *contentDictSettings = settings[manifestContentDict[PFCManifestKeyIdentifier]] ?: @{};
    id valueCheckbox = contentDictSettings[PFCSettingsKeyValueCheckbox];
    if ( valueCheckbox == nil ) {
        valueCheckbox = manifestContentDict[PFCManifestKeyDefaultValueCheckbox];
    }
    
    // -------------------------------------------------------------------------
    //  Verify CheckboxValue is of the expected class type(s)
    // -------------------------------------------------------------------------
    BOOL checkboxState = NO;
    if ( valueCheckbox == nil ) {
        DDLogWarn(@"CheckboxValue is empty");
        
        if ( [manifestContentDict[PFCManifestKeyOptional] boolValue] ) {
            // FIXME - Log this different, if checkbox payload key is empty for example, or log both payload keys?
            DDLogDebug(@"PayloadKey: %@ is optional, skipping", manifestContentDict[PFCManifestKeyPayloadKeyCheckbox]);
            return;
        }
    } else if ( ! [[valueCheckbox class] isEqualTo:[@(YES) class]] && ! [[valueCheckbox class] isEqualTo:[@(0) class]] ) {
        return payloadValueClassError(manifestContentDict[PFCManifestKeyPayloadType], NSStringFromClass([valueCheckbox class]), @[ NSStringFromClass([@(YES) class]), NSStringFromClass([@(0) class]) ]);
    } else {
        checkboxState = [(NSNumber *)valueCheckbox boolValue];
        DDLogDebug(@"CheckboxValue: %@", (checkboxState) ? @"YES" : @"NO");
    }
    
    // -------------------------------------------------------------------------
    //  If Checkbox is enabled
    // -------------------------------------------------------------------------
    // FIXME - Here i could check if there are any payloadKeys for host/port, but they should be required
    if ( checkboxState ) {
        
        // ------------------------------------------------------------------------
        //  All keys are equal to TextFieldHostPort, so use that to add to payload
        // ------------------------------------------------------------------------
        [self createPayloadFromCellTypeTextFieldHostPort:manifestContentDict settings:settings payloads:payloads];
    }
    
    if ( ! [self verifyRequiredManifestContentDictKeys:@[ PFCManifestKeyPayloadKeyCheckbox ]
                                   manifestContentDict:manifestContentDict] ) {
        return;
    }
    
    // -------------------------------------------------------------------------
    //  Resolve any nested payload keys
    //  FIXME - Need to implement this for nested keys
    // -------------------------------------------------------------------------
    //NSString *payloadParentKey = payloadDict[PFCManifestParentKey];
    
    //  FIXME - Add UUID for PayloadTypeTextField/Checkbox
    //  FIXME - Rename PFCProfileTemplateKeyUUID to PayloadUUID and use a SettingsKey
    NSString *payloadTypeCheckbox;
    NSString *payloadUUIDCheckbox;
    if ( manifestContentDict[PFCManifestKeyPayloadTypeCheckbox] != nil ) {
        payloadTypeCheckbox = manifestContentDict[PFCManifestKeyPayloadTypeCheckbox];
        payloadUUIDCheckbox = settings[@"PayloadUUIDCheckbox"] ?: settings[manifestContentDict[PFCManifestKeyPayloadType]][PFCProfileTemplateKeyUUID];
    } else {
        payloadTypeCheckbox = manifestContentDict[PFCManifestKeyPayloadType];
        payloadUUIDCheckbox = settings[manifestContentDict[PFCManifestKeyPayloadType]][PFCProfileTemplateKeyUUID];
    }
    
    // -------------------------------------------------------------------------
    //  Get index of current payload in payload array
    // -------------------------------------------------------------------------
    NSUInteger idx = [*payloads indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return [[item objectForKey:PFCManifestKeyPayloadUUID] isEqualToString:payloadUUIDCheckbox ?: @""];
    }];
    
    // ----------------------------------------------------------------------------------
    //  Create mutable version of current payload, or create new payload if none existed
    // ----------------------------------------------------------------------------------
    NSMutableDictionary *payloadDictDict;
    if ( idx != NSNotFound ) {
        payloadDictDict = [[*payloads objectAtIndex:idx] mutableCopy];
    } else {
        payloadDictDict = [self payloadRootFromManifest:manifestContentDict settings:settings payloadType:payloadTypeCheckbox payloadUUID:payloadUUIDCheckbox];
    }
    
    // -------------------------------------------------------------------------
    //  Add current key and value to payload
    // -------------------------------------------------------------------------
    payloadDictDict[manifestContentDict[PFCManifestKeyPayloadKeyCheckbox]] = @(checkboxState);
    
    // -------------------------------------------------------------------------
    //  Save payload to payload array
    // -------------------------------------------------------------------------
    if ( idx != NSNotFound ) {
        [*payloads replaceObjectAtIndex:idx withObject:[payloadDictDict copy]];
    } else {
        [*payloads addObject:[payloadDictDict copy]];
    }
    
    // -------------------------------------------------------------------------
    //
    // -------------------------------------------------------------------------
    [self createPayloadFromValueKey:( checkboxState ) ? @"True" : @"False" availableValues:manifestContentDict[PFCManifestKeyAvailableValues] manifestContentDict:manifestContentDict settings:settings payloadKey:manifestContentDict[PFCManifestKeyPayloadKeyCheckbox] payloadType:payloadTypeCheckbox payloadUUID:payloadUUIDCheckbox payloads:payloads];
    
} // createPayloadFromCellTypeTextFieldHostPortCheckbox:settings:payloads

- (void)createPayloadFromCellTypeTextFieldNumber:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings payloads:(NSMutableArray **)payloads {
    
    // -------------------------------------------------------------------------
    //  Verify required keys for CellType: 'TextFieldNumber'
    // -------------------------------------------------------------------------
    if ( ! [self verifyRequiredManifestContentDictKeys:@[ PFCManifestKeyIdentifier,
                                                          PFCManifestKeyPayloadType,
                                                          PFCManifestKeyPayloadKey,
                                                          PFCManifestKeyPayloadValueType ]
                                   manifestContentDict:manifestContentDict] ) {
        return;
    }
    
    NSString *payloadKey = manifestContentDict[PFCManifestKeyPayloadKey];
    
    // -------------------------------------------------------------------------
    //  Verify PayloadValueType is set and valid
    // -------------------------------------------------------------------------
    NSString *payloadValueType = manifestContentDict[PFCManifestKeyPayloadValueType];
    if ( ! [payloadValueType isEqualToString:@"Integer"] && ! [payloadValueType isEqualToString:@"Float"] ) {
        DDLogError(@"Unknown PayloadValueType: %@ for CellType: %@", payloadValueType, PFCCellTypeTextFieldNumber );
        return;
    }
    
    // -------------------------------------------------------------------------
    //  Get value
    // -------------------------------------------------------------------------
    NSDictionary *contentDictSettings = settings[manifestContentDict[PFCManifestKeyIdentifier]] ?: @{};
    id value = contentDictSettings[PFCSettingsKeyValue];
    if ( value == nil ) {
        value = manifestContentDict[PFCManifestKeyDefaultValue];
    }
    
    if ( value == nil ) {
        // FIXME - Value for a number cannot be empty, how to handle this?
        DDLogError(@"Value is empty");
        return;
    } else if ( ! [[value class] isSubclassOfClass:[@(0) class]] ) {
        return payloadValueClassError(manifestContentDict[PFCManifestKeyPayloadType], NSStringFromClass([value class]), @[ NSStringFromClass([@(0) class]) ]);
    }
    
    // -------------------------------------------------------------------------
    //  Resolve any nested payload keys
    //  FIXME - Need to implement this for nested keys
    // -------------------------------------------------------------------------
    //NSString *payloadParentKey = payloadDict[PFCManifestParentKey];
    
    // -------------------------------------------------------------------------
    //  Get index of current payload in payload array
    // -------------------------------------------------------------------------
    NSUInteger idx = [*payloads indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return [[item objectForKey:PFCManifestKeyPayloadUUID] isEqualToString:settings[manifestContentDict[PFCManifestKeyPayloadType]][PFCProfileTemplateKeyUUID] ?: @""];
    }];
    
    // ----------------------------------------------------------------------------------
    //  Create mutable version of current payload, or create new payload if none existed
    // ----------------------------------------------------------------------------------
    NSMutableDictionary *payloadDictDict;
    if ( idx != NSNotFound ) {
        payloadDictDict = [[*payloads objectAtIndex:idx] mutableCopy];
    } else {
        payloadDictDict = [self payloadRootFromManifest:manifestContentDict settings:settings payloadType:nil payloadUUID:nil];
    }
    
    // -------------------------------------------------------------------------
    //  Add current key and value to payload
    // -------------------------------------------------------------------------
    if ( [payloadValueType isEqualToString:@"Integer"] ) {
        payloadDictDict[payloadKey] = @([(NSNumber *)value integerValue]);
    } else if ( [payloadValueType isEqualToString:@"Float"] ) {
        payloadDictDict[payloadKey] = @([(NSNumber *)value floatValue]);
    }
    
    // -------------------------------------------------------------------------
    //  Save payload to payload array
    // -------------------------------------------------------------------------
    if ( idx != NSNotFound ) {
        [*payloads replaceObjectAtIndex:idx withObject:[payloadDictDict copy]];
    } else {
        [*payloads addObject:[payloadDictDict copy]];
    }
} // createPayloadFromCellTypeTextFieldNumber:settings:payloads

@end
