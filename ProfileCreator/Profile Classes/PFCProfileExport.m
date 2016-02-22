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
} // initWithProfileSettings:sender

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
    //  Create and add all payloads
    // -------------------------------------------------------------------------
    NSMutableArray *payloadArray = [[NSMutableArray alloc] init];
    for ( NSDictionary *manifest in manifests ) {
        [self createPayloadFromManifestContent:manifest[PFCManifestKeyManifestContent] settings:settings[manifest[PFCManifestKeyDomain] ?: @""] payloads:&payloadArray];
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
    /*
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
     */
}

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
}

- (NSDictionary *)profileRootKeysFromGeneralPayload:(NSMutableDictionary *)profileRootKeys {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    DDLogVerbose(@"profileRootKeys=%@", profileRootKeys);
    NSMutableDictionary *profileRoot = [[NSMutableDictionary alloc] init];
    
    [profileRootKeys removeObjectForKey:@"PayloadType"];
    [profileRootKeys removeObjectForKey:@"PayloadIdentifier"];
    [profileRootKeys removeObjectForKey:@"PayloadUUID"];
    [profileRootKeys removeObjectForKey:@"PayloadVersion"];
    
    return [profileRoot copy];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Payload Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSMutableDictionary *)newPayloadDictForType:(NSString *)payloadType settingsDict:(NSDictionary *)settingsDict {
    
    NSString *payloadUUID = settingsDict[@"UUID"];
    if ( [payloadUUID length] == 0 ) {
        NSLog(@"[WARNING] No saved UUID found!");
        payloadUUID = [[NSUUID UUID] UUIDString];
    }
    
    return [NSMutableDictionary dictionaryWithDictionary:@{ @"PayloadType" : payloadType,
                                                            @"PayloadVersion" : @1, // Could be different!?
                                                            @"PayloadIdentifier" : @"Identifier", //Need fix
                                                            @"PayloadUUID" : payloadUUID,
                                                            @"PayloadDisplayName" : @"DisplayName", //Need fix
                                                            @"PayloadDescription" : @"Description", //Need fix
                                                            @"PayloadOrganization" : @"Organization" //Need fix
                                                            }];
}

- (NSMutableDictionary *)payloadRootFromManifest:(NSDictionary *)manifest settings:(NSDictionary *)settings {
    
    NSString *payloadUUID = settings[@"UUID"];
    if ( [payloadUUID length] == 0 ) {
        //DDLogWarn(@"No UUID found for payload type: %@", payloadType);
        payloadUUID = [[NSUUID UUID] UUIDString];
    }
    
    return [NSMutableDictionary dictionaryWithDictionary:@{ PFCManifestKeyPayloadType : @"",
                                                            PFCManifestKeyPayloadVersion : @1, // Could be different!?
                                                            PFCManifestKeyPayloadIdentifier : @"Identifier", //Need fix
                                                            PFCManifestKeyPayloadUUID : payloadUUID,
                                                            @"PayloadDisplayName" : @"DisplayName", //Need fix
                                                            @"PayloadDescription" : @"Description", //Need fix
                                                            @"PayloadOrganization" : @"Organization" //Need fix
                                                            }];
}

- (void)createPayloadFromManifestContent:(NSArray *)manifestContent settings:(NSDictionary *)settings payloads:(NSMutableArray **)payloads {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    for ( NSDictionary *manifestContentDict in manifestContent ) {
        [self createPayloadFromManifestContentDict:manifestContentDict settings:settings payloads:payloads];
    }
} // createPayloadFromManifestArray:settings:payloads

- (void)createPayloadFromManifestContentDict:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings payloads:(NSMutableArray **)payloads {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    NSString *cellType = manifestContentDict[PFCManifestKeyCellType];
    
    // -------------------------------------------------------------
    //  Checkbox
    // -------------------------------------------------------------
    if ( [cellType isEqualToString:PFCCellTypeCheckbox] ) {
        [self createPayloadFromCellTypeCheckbox:manifestContentDict settingsDict:settings payloadArray:payloads];
        
        // ---------------------------------------------------------
        //  CheckboxNoDescription
        // ---------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeCheckboxNoDescription] ) {
        [self createPayloadFromCellTypeCheckbox:manifestContentDict settingsDict:settings payloadArray:payloads];
        
        // ---------------------------------------------------------
        //  DatePicker
        // ---------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeDatePicker] ) {
        
        // ---------------------------------------------------------
        //  DatePickerNoTitle
        // ---------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeDatePickerNoTitle] ) {
        
        // ---------------------------------------------------------
        //  File
        // ---------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeFile] ) {
        
        // ---------------------------------------------------------
        //  PopUpButton
        // ---------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypePopUpButton] ) {
        [self createPayloadFromCellTypePopUpButton:manifestContentDict settingsDict:settings payloadArray:payloads];
        
        // ---------------------------------------------------------
        //  PopUpButtonLeft
        // ---------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypePopUpButtonLeft] ) {
        [self createPayloadFromCellTypePopUpButton:manifestContentDict settingsDict:settings payloadArray:payloads];
        
        // ---------------------------------------------------------
        //  PopUpButtonNoTitle
        // ---------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypePopUpButtonNoTitle] ) {
        [self createPayloadFromCellTypePopUpButton:manifestContentDict settingsDict:settings payloadArray:payloads];
        
        // ---------------------------------------------------------
        //  SegmentedControl
        // ---------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeSegmentedControl] ) {
        [self createPayloadFromCellTypeSegmentedControl:manifestContentDict settingsDict:settings payloadArray:payloads];
        
        // ---------------------------------------------------------
        //  TableView
        // ---------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeTableView] ) {
        
        // ---------------------------------------------------------
        //  TextField
        // ---------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeTextField] ) {
        [self createPayloadFromCellTypeTextField:manifestContentDict settings:settings payloads:payloads];
        
        // ---------------------------------------------------------
        //  TextFieldCheckbox
        // ---------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeTextFieldCheckbox] ) {
        [self createPayloadFromCellTypeTextFieldCheckbox:manifestContentDict settingsDict:settings payloadArray:payloads];
        
        // ---------------------------------------------------------
        //  TextFieldDaysHoursNoTitle
        // ---------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeTextFieldDaysHoursNoTitle] ) {
        
        // ---------------------------------------------------------
        //  TextFieldHostPort
        // ---------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeTextFieldHostPort] ) {
        [self createPayloadFromCellTypeTextFieldHostPort:manifestContentDict settingsDict:settings payloadArray:payloads];
        
        // ---------------------------------------------------------
        //  TextFieldHostPortCheckbox
        // ---------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeTextFieldHostPortCheckbox] ) {
        
        // ---------------------------------------------------------
        //  TextFieldNoTitle
        // ---------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeTextFieldNoTitle] ) {
        [self createPayloadFromCellTypeTextField:manifestContentDict settings:settings payloads:payloads];
        
        // ---------------------------------------------------------
        //  TextFieldNumber
        // ---------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeTextFieldNumber] ) {
        [self createPayloadFromCellTypeTextFieldNumber:manifestContentDict settingsDict:settings payloadArray:payloads];
        
        // ---------------------------------------------------------
        //  TextFieldNumberLeft
        // ---------------------------------------------------------
    } else if ( [cellType isEqualToString:PFCCellTypeTextFieldNumberLeft] ) {
        [self createPayloadFromCellTypeTextFieldNumber:manifestContentDict settingsDict:settings payloadArray:payloads];
        
        
    } else {
        DDLogDebug(@"Unknown cell type: %@", cellType);
    }
} // createPayloadFromManifestContentDict:settings:payloads

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellType Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)createPayloadFromCellTypeTextField:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings payloads:(NSMutableArray **)payloads {
    
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    if ( [identifier length] == 0 ) {
        DDLogError(@"");
        return;
    }
    
    NSString *payloadType = manifestContentDict[PFCManifestKeyPayloadType];
    if ( [payloadType length] == 0 ) {
        NSLog(@"[ERROR] No payload type!");
        return;
    }
    
    NSString *payloadKey = manifestContentDict[PFCManifestKeyPayloadKey];
    if ( [payloadKey length] == 0 ) {
        NSLog(@"[ERROR] No payloadKey");
        return;
    }
    
    NSDictionary *contentDictSettings = settings[identifier] ?: @{};
    id value = contentDictSettings[PFCSettingsKeyValue];
    if ( value == nil ) {
        value = manifestContentDict[@"DefaultValue"];
    }
    
    if ( value == nil || [value length] == 0 ) {
        if ( [manifestContentDict[@"Optional"] boolValue] ) {
            return;
        }
        value = @"";
    } else if ( ! [[value class] isSubclassOfClass:[NSString class]] ) {
        NSLog(@"[ERROR] value is not of the correct class!");
        NSLog(@"[ERROR] value class: %@", [value class]);
        NSLog(@"[ERROR] expected class: %@", [NSString class]);
        return;
    }
    
    // Next step is to solve nested keys
    //NSString *payloadParentKey = payloadDict[PFCManifestParentKey];
    
    NSUInteger idx = [*payloads indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return [[item objectForKey:@"PayloadType"] isEqualToString:payloadType];
    }];
    
    NSMutableDictionary *payloadDictDict;
    if ( idx != NSNotFound ) {
        payloadDictDict = [[*payloads objectAtIndex:idx] mutableCopy];
    } else {
        payloadDictDict = [self newPayloadDictForType:payloadType settingsDict:settings];
    }
    
    payloadDictDict[payloadKey] = value;
    
    if ( idx != NSNotFound ) {
        [*payloads replaceObjectAtIndex:idx withObject:[payloadDictDict copy]];
    } else {
        [*payloads addObject:[payloadDictDict copy]];
    }
}

- (void)createPayloadFromCellTypeTextFieldCheckbox:(NSDictionary *)payloadDict settingsDict:(NSDictionary *)settingsDict payloadArray:(NSMutableArray **)payloadArray {
    
    NSString *identifier = payloadDict[@"Identifier"];
    if ( [identifier length] == 0 ) {
        NSLog(@"[ERROR] No identifier!");
        return;
    }
    
    NSDictionary *settings = settingsDict[identifier] ?: @{};
    
    id value = settings[PFCSettingsKeyValue];
    if ( value == nil ) {
        value = payloadDict[@"DefaultValue"];
    }
    
    BOOL checkboxState = NO;
    
    if ( value == nil ) {
        NSLog(@"[WARNING] Bool not set, defaults to NO");
    } else if ( [[value class] isEqualTo:[@(YES) class]] || [[value class] isEqualTo:[@(0) class]] ) {
        checkboxState = [(NSNumber *)value boolValue];
    } else {
        NSLog(@"[ERROR] value is not of the correct class!");
        NSLog(@"[ERROR] value class: %@", [value class]);
        NSLog(@"[ERROR] expected class: %@", [@(YES) class]);
        return;
    }
    
    if ( checkboxState ) {
        NSString *payloadTypeTextField = payloadDict[@"PayloadTypeTextField"];
        if ( [payloadTypeTextField length] == 0 ) {
            NSLog(@"[ERROR] No payload type!");
            return;
        }
        
        NSString *payloadKeyTextField = payloadDict[@"PayloadKeyTextField"];
        if ( [payloadKeyTextField length] == 0 ) {
            NSLog(@"[ERROR] No payloadKey");
            return;
        }
        
        id valueTextField = settings[@"ValueTextField"];
        if ( valueTextField == nil ) {
            valueTextField = payloadDict[@"DefaultValueTextField"];
        }
        
        if ( valueTextField == nil ) {
            valueTextField = @"";
        } else if ( ! [[valueTextField class] isSubclassOfClass:[NSString class]] ) {
            NSLog(@"[ERROR] value is not of the correct class!");
            NSLog(@"[ERROR] value class: %@", [valueTextField class]);
            NSLog(@"[ERROR] expected class: %@", [NSString class]);
            return;
        }
        
        // Next step is to solve nested keys
        //NSString *payloadParentKey = payloadDict[@"PayloadParentKeyTextField"];
        
        NSUInteger idx = [*payloadArray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
            return [[item objectForKey:@"PayloadType"] isEqualToString:payloadTypeTextField];
        }];
        
        NSMutableDictionary *payloadDictDict;
        if ( idx != NSNotFound ) {
            payloadDictDict = [[*payloadArray objectAtIndex:idx] mutableCopy];
        } else {
            payloadDictDict = [self newPayloadDictForType:payloadTypeTextField settingsDict:settingsDict];
        }
        
        payloadDictDict[payloadKeyTextField] = valueTextField;
        
        if ( idx != NSNotFound ) {
            [*payloadArray replaceObjectAtIndex:idx withObject:[payloadDictDict copy]];
        } else {
            [*payloadArray addObject:[payloadDictDict copy]];
        }
    }
    
    // Check if checkbox also has payload etc.
    
    NSString *payloadTypeCheckbox = payloadDict[@"PayloadTypeCheckbox"];
    if ( [payloadTypeCheckbox length] == 0 ) {
        NSLog(@"[ERROR] No payload type!");
        return;
    }
    
    NSString *payloadKeyCheckbox = payloadDict[@"PayloadKeyCheckbox"];
    if ( [payloadKeyCheckbox length] == 0 ) {
        NSLog(@"[ERROR] No payloadKey");
        return;
    }
    
    // Next step is to solve nested keys
    //NSString *payloadParentKeyCheckbox = payloadDict[@"PayloadParentKeyCheckbox"];
    
    NSUInteger idx = [*payloadArray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return [[item objectForKey:@"PayloadType"] isEqualToString:payloadTypeCheckbox];
    }];
    
    NSMutableDictionary *payloadDictDict;
    if ( idx != NSNotFound ) {
        payloadDictDict = [[*payloadArray objectAtIndex:idx] mutableCopy];
    } else {
        payloadDictDict = [self newPayloadDictForType:payloadTypeCheckbox settingsDict:settingsDict];
    }
    
    payloadDictDict[payloadKeyCheckbox] = @(checkboxState);
    
    if ( idx != NSNotFound ) {
        [*payloadArray replaceObjectAtIndex:idx withObject:[payloadDictDict copy]];
    } else {
        [*payloadArray addObject:[payloadDictDict copy]];
    }
    
    NSString *checkboxStateString = ( checkboxState ) ? @"True" : @"False";
    
    NSArray *availableValues = payloadDict[@"AvailableValues"] ?: @[];
    if ( [availableValues count] == 0 ) {
        return;
    } else if ( ! [availableValues containsObject:checkboxStateString] ) {
        NSLog(@"[ERROR] Selection is not valid!");
        NSLog(@"[ERROR] Selected item: %@", value);
        NSLog(@"[ERROR] Available values: %@", availableValues);
        return;
    }
    
    NSDictionary *valueKeys = payloadDict[@"ValueKeys"] ?: @{};
    if ( [valueKeys count] == 0 ) {
        NSLog(@"[ERROR] value keys cannot be empty!");
        return;
    } else if ( ! valueKeys[checkboxStateString] ) {
        NSLog(@"[ERROR] selected value doesn't exist in value keys!");
        NSLog(@"[ERROR] selected value: %@", checkboxStateString);
        NSLog(@"[ERROR] value keys: %@", valueKeys);
        return;
    }
    
    NSMutableArray *selectedValueArray = [valueKeys[checkboxStateString] mutableCopy];
    
    NSUInteger idxPayloadValue = [selectedValueArray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return ( item[PFCManifestKeyPayloadValue] ) ? YES : NO;
    }];
    
    if ( idxPayloadValue != NSNotFound ) {
        NSDictionary *payloadValueDict = [selectedValueArray objectAtIndex:idxPayloadValue];
        [selectedValueArray removeObjectAtIndex:idxPayloadValue];
        
        id value = payloadValueDict[PFCManifestKeyPayloadValue];
        if ( value == nil ) {
            NSLog(@"[ERROR] payload value cannot be nil!");
            return;
        }
        
        NSString *payloadType = payloadDict[@"PayloadType"];
        if ( [payloadType length] == 0 ) {
            NSLog(@"[ERROR] No payload type!");
            return;
        }
        
        NSString *payloadKey = payloadDict[@"PayloadKey"];
        if ( [payloadKey length] == 0 ) {
            NSLog(@"[ERROR] No payloadKey");
            return;
        }
        
        // Next step is to solve nested keys
        //NSString *payloadParentKey = payloadDict[PFCManifestParentKey];
        
        NSUInteger idx = [*payloadArray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
            return [[item objectForKey:@"PayloadType"] isEqualToString:payloadType];
        }];
        
        NSMutableDictionary *payloadDictDict;
        if ( idx != NSNotFound ) {
            payloadDictDict = [[*payloadArray objectAtIndex:idx] mutableCopy];
        } else {
            payloadDictDict = [self newPayloadDictForType:payloadType settingsDict:settingsDict];
        }
        
        payloadDictDict[payloadKey] = value;
        
        if ( idx != NSNotFound ) {
            [*payloadArray replaceObjectAtIndex:idx withObject:[payloadDictDict copy]];
        } else {
            [*payloadArray addObject:[payloadDictDict copy]];
        }
    }
    
    NSUInteger idxSharedKey = [selectedValueArray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return ( item[PFCManifestKeySharedKey] ) ? YES : NO;
    }];
    
    if ( idxSharedKey != NSNotFound ) {
        NSDictionary *sharedKeyDict = [selectedValueArray objectAtIndex:idxSharedKey];
        [selectedValueArray removeObjectAtIndex:idxSharedKey];
        
        id value = sharedKeyDict[PFCManifestKeySharedKey];
        if ( value == nil ) {
            NSLog(@"[ERROR] payload value cannot be nil!");
            return;
        } else if ( ! [[value class] isSubclassOfClass:[NSString class]] ) {
            NSLog(@"[ERROR] value is not of the correct class!");
            NSLog(@"[ERROR] value class: %@", [value class]);
            NSLog(@"[ERROR] expected class: %@", [NSString class]);
            return;
        }
        
        NSDictionary *valueKeysShared = payloadDict[@"ValueKeysShared"] ?: @{};
        if ( [valueKeysShared count] == 0 ) {
            NSLog(@"[ERROR] value keys shared cannot be empty!");
            return;
        } else if ( ! valueKeysShared[value] ) {
            NSLog(@"[ERROR] selected value doesn't exist in value keys!");
            NSLog(@"[ERROR] selected value: %@", value);
            NSLog(@"[ERROR] value keys: %@", valueKeysShared);
            return;
        }
        
        [self createPayloadFromManifestContentDict:valueKeysShared[value] settings:settingsDict payloads:payloadArray];
    }
    
    
    if ( [selectedValueArray count] != 0 ) {
        [self createPayloadFromManifestContent:selectedValueArray settings:settingsDict payloads:payloadArray];
    }
}

- (void)createPayloadFromCellTypeTextFieldHostPort:(NSDictionary *)payloadDict settingsDict:(NSDictionary *)settingsDict payloadArray:(NSMutableArray **)payloadArray {
    
    NSString *identifier = payloadDict[@"Identifier"];
    if ( [identifier length] == 0 ) {
        NSLog(@"[ERROR] No identifier!");
        return;
    }
    
    NSString *payloadType = payloadDict[@"PayloadType"];
    if ( [payloadType length] == 0 ) {
        NSLog(@"[ERROR] No payload type!");
        return;
    }
    
    
    // HOST
    NSString *payloadKeyHost = payloadDict[@"PayloadKeyHost"];
    if ( [payloadKeyHost length] == 0 ) {
        NSLog(@"[ERROR] No payloadKeyHost");
        return;
    }
    
    NSDictionary *settings = settingsDict[identifier] ?: @{};
    id valueHost = settings[@"ValueHost"];
    if ( valueHost == nil ) {
        valueHost = payloadDict[@"DefaultValueHost"];
    }
    
    if ( valueHost == nil ) {
        valueHost = @"";
    } else if ( ! [[valueHost class] isSubclassOfClass:[NSString class]] ) {
        NSLog(@"[ERROR] valueHost is not of the correct class!");
        NSLog(@"[ERROR] valueHost class: %@", [valueHost class]);
        NSLog(@"[ERROR] expected class: %@", [NSString class]);
        return;
    }
    
    
    // PORT
    
    NSString *payloadKeyPort = payloadDict[@"PayloadKeyPort"];
    if ( [payloadKeyPort length] == 0 ) {
        NSLog(@"[ERROR] No payloadKeyPort");
        return;
    }
    
    id valuePort = settings[@"ValuePort"];
    if ( valuePort == nil ) {
        valuePort = payloadDict[@"DefaultValuePort"];
    }
    
    if ( valuePort == nil ) {
        valuePort = @0; // What should be the default if it's empty!? probably nothing, but is that possible?
    } else if ( [[valuePort class] isSubclassOfClass:[NSString class]]) {
        valuePort = @([(NSString *)valuePort integerValue]); // Convert string to int here
    } else if ( ! [[valuePort class] isEqualTo:[@(0) class] ] ) {
        NSLog(@"[ERROR] valuePort is not of the correct class!");
        NSLog(@"[ERROR] valuePort class: %@", [valuePort class]);
        NSLog(@"[ERROR] expected class: %@", [@(0) class]);
        return;
    }
    
    // Next step is to solve nested keys
    //NSString *payloadParentKeyHost = payloadDict[@"ParentKeyHost"];
    //NSString *payloadParentKeyPort = payloadDict[@"ParentKeyPort"];
    
    NSUInteger idx = [*payloadArray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return [[item objectForKey:@"PayloadType"] isEqualToString:payloadType];
    }];
    
    NSMutableDictionary *payloadDictDict;
    if ( idx != NSNotFound ) {
        payloadDictDict = [[*payloadArray objectAtIndex:idx] mutableCopy];
    } else {
        payloadDictDict = [self newPayloadDictForType:payloadType settingsDict:settingsDict];
    }
    
    payloadDictDict[payloadKeyHost] = valueHost;
    payloadDictDict[payloadKeyPort] = valuePort;
    
    if ( idx != NSNotFound ) {
        [*payloadArray replaceObjectAtIndex:idx withObject:[payloadDictDict copy]];
    } else {
        [*payloadArray addObject:[payloadDictDict copy]];
    }
}

- (void)createPayloadFromCellTypeTextFieldNumber:(NSDictionary *)payloadDict settingsDict:(NSDictionary *)settingsDict payloadArray:(NSMutableArray **)payloadArray {
    
    NSString *identifier = payloadDict[@"Identifier"];
    if ( [identifier length] == 0 ) {
        NSLog(@"[ERROR] No identifier!");
        return;
    }
    
    NSString *payloadType = payloadDict[@"PayloadType"];
    if ( [payloadType length] == 0 ) {
        NSLog(@"[ERROR] No payload type!");
        return;
    }
    
    NSString *payloadKey = payloadDict[@"PayloadKey"];
    if ( [payloadKey length] == 0 ) {
        NSLog(@"[ERROR] No payloadKey");
        return;
    }
    
    NSString *payloadValueKey = payloadDict[@"PayloadValueType"];
    if ( [payloadValueKey length] == 0 ) {
        NSLog(@"[ERROR] No payloadValueKey!");
        return;
    } else if ( ! [payloadValueKey isEqualToString:@"Integer"] && ! [payloadValueKey isEqualToString:@"Float"] ) {
        NSLog(@"[ERROR] Unknown payload value key: %@", payloadValueKey);
        return;
    }
    
    NSDictionary *settings = settingsDict[identifier] ?: @{};
    id value = settings[PFCSettingsKeyValue];
    if ( value == nil ) {
        value = payloadDict[@"DefaultValue"];
    }
    
    if ( value == nil ) {
        value = @0; // What should this be?
    } else if ( ! [[value class] isSubclassOfClass:[@(0) class]] ) {
        NSLog(@"[ERROR] value is not of the correct class!");
        NSLog(@"[ERROR] value class: %@", [value class]);
        NSLog(@"[ERROR] expected class: %@", [NSString class]);
        return;
    }
    
    // Next step is to solve nested keys
    //NSString *payloadParentKey = payloadDict[PFCManifestParentKey];
    
    NSUInteger idx = [*payloadArray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return [[item objectForKey:@"PayloadType"] isEqualToString:payloadType];
    }];
    
    NSMutableDictionary *payloadDictDict;
    if ( idx != NSNotFound ) {
        payloadDictDict = [[*payloadArray objectAtIndex:idx] mutableCopy];
    } else {
        payloadDictDict = [self newPayloadDictForType:payloadType settingsDict:settingsDict];
    }
    
    if ( [payloadValueKey isEqualToString:@"Integer"] ) {
        payloadDictDict[payloadKey] = @([(NSNumber *)value integerValue]);
    } else if ( [payloadValueKey isEqualToString:@"Float"] ) {
        payloadDictDict[payloadKey] = @([(NSNumber *)value floatValue]);
    }
    
    if ( idx != NSNotFound ) {
        [*payloadArray replaceObjectAtIndex:idx withObject:[payloadDictDict copy]];
    } else {
        [*payloadArray addObject:[payloadDictDict copy]];
    }
    
}


- (void)createPayloadFromCellTypeCheckbox:(NSDictionary *)payloadDict settingsDict:(NSDictionary *)settingsDict payloadArray:(NSMutableArray **)payloadArray {
    
    NSString *identifier = payloadDict[@"Identifier"];
    if ( [identifier length] == 0 ) {
        NSLog(@"[ERROR] No identifier!");
        return;
    }
    
    NSString *payloadType = payloadDict[@"PayloadType"];
    if ( [payloadType length] == 0 ) {
        NSLog(@"[ERROR] No payload type!");
        return;
    }
    
    NSString *payloadKey = payloadDict[@"PayloadKey"];
    if ( [payloadKey length] == 0 ) {
        NSLog(@"[ERROR] No payloadKey");
        return;
    }
    
    NSDictionary *settings = settingsDict[identifier] ?: @{};
    id value = settings[PFCSettingsKeyValue];
    if ( value == nil ) {
        value = payloadDict[@"DefaultValue"];
    }
    
    BOOL checkboxState = NO;
    
    if ( value == nil ) {
        NSLog(@"[WARNING] Bool not set, defaults to NO");
    } else if ( [[value class] isEqualTo:[@(YES) class]] || [[value class] isEqualTo:[@(0) class]] ) {
        checkboxState = [(NSNumber *)value boolValue];
    } else {
        NSLog(@"[ERROR] value is not of the correct class!");
        NSLog(@"[ERROR] value class: %@", [value class]);
        NSLog(@"[ERROR] expected class: %@", [@(YES) class]);
        return;
    }
    
    // Next step is to solve nested keys
    //NSString *payloadParentKey = payloadDict[PFCManifestParentKey];
    
    NSUInteger idx = [*payloadArray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return [[item objectForKey:@"PayloadType"] isEqualToString:payloadType];
    }];
    
    NSMutableDictionary *payloadDictDict;
    if ( idx != NSNotFound ) {
        payloadDictDict = [[*payloadArray objectAtIndex:idx] mutableCopy];
    } else {
        payloadDictDict = [self newPayloadDictForType:payloadType settingsDict:settingsDict];
    }
    
    payloadDictDict[payloadKey] = @(checkboxState);
    
    if ( idx != NSNotFound ) {
        [*payloadArray replaceObjectAtIndex:idx withObject:[payloadDictDict copy]];
    } else {
        [*payloadArray addObject:[payloadDictDict copy]];
    }
    
    NSString *checkboxStateString = ( checkboxState ) ? @"True" : @"False";
    
    NSArray *availableValues = payloadDict[@"AvailableValues"] ?: @[];
    if ( [availableValues count] == 0 ) {
        return;
    } else if ( ! [availableValues containsObject:checkboxStateString] ) {
        NSLog(@"[ERROR] Selection is not valid!");
        NSLog(@"[ERROR] Selected item: %@", value);
        NSLog(@"[ERROR] Available values: %@", availableValues);
        return;
    }
    
    NSDictionary *valueKeys = payloadDict[@"ValueKeys"] ?: @{};
    if ( [valueKeys count] == 0 ) {
        NSLog(@"[ERROR] value keys cannot be empty!");
        return;
    } else if ( ! valueKeys[checkboxStateString] ) {
        NSLog(@"[ERROR] selected value doesn't exist in value keys!");
        NSLog(@"[ERROR] selected value: %@", checkboxStateString);
        NSLog(@"[ERROR] value keys: %@", valueKeys);
        return;
    }
    
    NSMutableArray *selectedValueArray = [valueKeys[checkboxStateString] mutableCopy];
    
    NSUInteger idxPayloadValue = [selectedValueArray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return ( item[PFCManifestKeyPayloadValue] ) ? YES : NO;
    }];
    
    if ( idxPayloadValue != NSNotFound ) {
        NSDictionary *payloadValueDict = [selectedValueArray objectAtIndex:idxPayloadValue];
        [selectedValueArray removeObjectAtIndex:idxPayloadValue];
        
        id value = payloadValueDict[PFCManifestKeyPayloadValue];
        if ( value == nil ) {
            NSLog(@"[ERROR] payload value cannot be nil!");
            return;
        }
        
        NSString *payloadType = payloadDict[@"PayloadType"];
        if ( [payloadType length] == 0 ) {
            NSLog(@"[ERROR] No payload type!");
            return;
        }
        
        NSString *payloadKey = payloadDict[@"PayloadKey"];
        if ( [payloadKey length] == 0 ) {
            NSLog(@"[ERROR] No payloadKey");
            return;
        }
        
        // Next step is to solve nested keys
        //NSString *payloadParentKey = payloadDict[PFCManifestParentKey];
        
        NSUInteger idx = [*payloadArray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
            return [[item objectForKey:@"PayloadType"] isEqualToString:payloadType];
        }];
        
        NSMutableDictionary *payloadDictDict;
        if ( idx != NSNotFound ) {
            payloadDictDict = [[*payloadArray objectAtIndex:idx] mutableCopy];
        } else {
            payloadDictDict = [self newPayloadDictForType:payloadType settingsDict:settingsDict];
        }
        
        payloadDictDict[payloadKey] = value;
        
        if ( idx != NSNotFound ) {
            [*payloadArray replaceObjectAtIndex:idx withObject:[payloadDictDict copy]];
        } else {
            [*payloadArray addObject:[payloadDictDict copy]];
        }
    }
    
    NSUInteger idxSharedKey = [selectedValueArray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return ( item[PFCManifestKeySharedKey] ) ? YES : NO;
    }];
    
    if ( idxSharedKey != NSNotFound ) {
        NSDictionary *sharedKeyDict = [selectedValueArray objectAtIndex:idxSharedKey];
        [selectedValueArray removeObjectAtIndex:idxSharedKey];
        
        id value = sharedKeyDict[PFCManifestKeySharedKey];
        if ( value == nil ) {
            NSLog(@"[ERROR] payload value cannot be nil!");
            return;
        } else if ( ! [[value class] isSubclassOfClass:[NSString class]] ) {
            NSLog(@"[ERROR] value is not of the correct class!");
            NSLog(@"[ERROR] value class: %@", [value class]);
            NSLog(@"[ERROR] expected class: %@", [NSString class]);
            return;
        }
        
        NSDictionary *valueKeysShared = payloadDict[@"ValueKeysShared"] ?: @{};
        if ( [valueKeysShared count] == 0 ) {
            NSLog(@"[ERROR] value keys shared cannot be empty!");
            return;
        } else if ( ! valueKeysShared[value] ) {
            NSLog(@"[ERROR] selected value doesn't exist in value keys!");
            NSLog(@"[ERROR] selected value: %@", value);
            NSLog(@"[ERROR] value keys: %@", valueKeysShared);
            return;
        }
        
        [self createPayloadFromManifestContentDict:valueKeysShared[value] settings:settingsDict payloads:payloadArray];
    }
    
    
    if ( [selectedValueArray count] != 0 ) {
        [self createPayloadFromManifestContent:selectedValueArray settings:settingsDict payloads:payloadArray];
    }
}

- (void)createPayloadFromCellTypePopUpButton:(NSDictionary *)payloadDict settingsDict:(NSDictionary *)settingsDict payloadArray:(NSMutableArray **)payloadArray {
    
    NSString *identifier = payloadDict[@"Identifier"];
    if ( [identifier length] == 0 ) {
        NSLog(@"[ERROR] No identifier!");
        return;
    }
    
    NSDictionary *settings = settingsDict[identifier] ?: @{};
    id value = settings[PFCSettingsKeyValue];
    if ( value == nil ) {
        value = payloadDict[@"DefaultValue"];
    }
    
    if ( value == nil ) {
        NSLog(@"[ERROR] value cannot be empty!");
        return;
    } else if ( ! [[value class] isSubclassOfClass:[NSString class]] ) {
        NSLog(@"[ERROR] value is not of the correct class!");
        NSLog(@"[ERROR] value class: %@", [value class]);
        NSLog(@"[ERROR] expected class: %@", [NSString class]);
        return;
    }
    
    NSArray *availableValues = payloadDict[@"AvailableValues"] ?: @[];
    if ( [availableValues count] == 0 ) {
        NSLog(@"[ERROR] Available values can't be 0");
        return;
    } else if ( ! [availableValues containsObject:value] ) {
        NSLog(@"[ERROR] Selection is not valid!");
        NSLog(@"[ERROR] Selected item: %@", value);
        NSLog(@"[ERROR] Available values: %@", availableValues);
        return;
    }
    
    NSDictionary *valueKeys = payloadDict[@"ValueKeys"] ?: @{};
    if ( [valueKeys count] == 0 ) {
        NSLog(@"[ERROR] value keys cannot be empty!");
        return;
    } else if ( ! valueKeys[value] ) {
        NSLog(@"[ERROR] selected value doesn't exist in value keys!");
        NSLog(@"[ERROR] selected value: %@", value);
        NSLog(@"[ERROR] value keys: %@", valueKeys);
        return;
    }
    
    NSMutableArray *selectedValueArray = [valueKeys[value] mutableCopy];
    
    NSUInteger idxPayloadValue = [selectedValueArray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return ( item[PFCManifestKeyPayloadValue] ) ? YES : NO;
    }];
    
    if ( idxPayloadValue != NSNotFound ) {
        NSDictionary *payloadValueDict = [selectedValueArray objectAtIndex:idxPayloadValue];
        [selectedValueArray removeObjectAtIndex:idxPayloadValue];
        
        id value = payloadValueDict[PFCManifestKeyPayloadValue];
        if ( value == nil ) {
            NSLog(@"[ERROR] payload value cannot be nil!");
            return;
        }
        
        NSString *payloadType = payloadDict[@"PayloadType"];
        if ( [payloadType length] == 0 ) {
            NSLog(@"[ERROR] No payload type!");
            return;
        }
        
        NSString *payloadKey = payloadDict[@"PayloadKey"];
        if ( [payloadKey length] == 0 ) {
            NSLog(@"[ERROR] No payloadKey");
            return;
        }
        
        // Next step is to solve nested keys
        //NSString *payloadParentKey = payloadDict[PFCManifestParentKey];
        
        NSUInteger idx = [*payloadArray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
            return [[item objectForKey:@"PayloadType"] isEqualToString:payloadType];
        }];
        
        NSMutableDictionary *payloadDictDict;
        if ( idx != NSNotFound ) {
            payloadDictDict = [[*payloadArray objectAtIndex:idx] mutableCopy];
        } else {
            payloadDictDict = [self newPayloadDictForType:payloadType settingsDict:settingsDict];
        }
        
        payloadDictDict[payloadKey] = value;
        
        if ( idx != NSNotFound ) {
            [*payloadArray replaceObjectAtIndex:idx withObject:[payloadDictDict copy]];
        } else {
            [*payloadArray addObject:[payloadDictDict copy]];
        }
    }
    
    NSUInteger idxSharedKey = [selectedValueArray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return ( item[PFCManifestKeySharedKey] ) ? YES : NO;
    }];
    
    if ( idxSharedKey != NSNotFound ) {
        NSDictionary *sharedKeyDict = [selectedValueArray objectAtIndex:idxSharedKey];
        [selectedValueArray removeObjectAtIndex:idxSharedKey];
        
        id value = sharedKeyDict[PFCManifestKeySharedKey];
        if ( value == nil ) {
            NSLog(@"[ERROR] payload value cannot be nil!");
            return;
        } else if ( ! [[value class] isSubclassOfClass:[NSString class]] ) {
            NSLog(@"[ERROR] value is not of the correct class!");
            NSLog(@"[ERROR] value class: %@", [value class]);
            NSLog(@"[ERROR] expected class: %@", [NSString class]);
            return;
        }
        
        NSDictionary *valueKeysShared = payloadDict[@"ValueKeysShared"] ?: @{};
        if ( [valueKeysShared count] == 0 ) {
            NSLog(@"[ERROR] value keys shared cannot be empty!");
            return;
        } else if ( ! valueKeysShared[value] ) {
            NSLog(@"[ERROR] selected value doesn't exist in value keys!");
            NSLog(@"[ERROR] selected value: %@", value);
            NSLog(@"[ERROR] value keys: %@", valueKeysShared);
            return;
        }
        
        [self createPayloadFromManifestContentDict:valueKeysShared[value] settings:settingsDict payloads:payloadArray];
    }
    
    
    if ( [selectedValueArray count] != 0 ) {
        [self createPayloadFromManifestContent:selectedValueArray settings:settingsDict payloads:payloadArray];
    }
}

- (void)createPayloadFromCellTypeSegmentedControl:(NSDictionary *)payloadDict settingsDict:(NSDictionary *)settingsDict payloadArray:(NSMutableArray **)payloadArray {
    
    NSArray *availableValues = payloadDict[@"AvailableValues"] ?: @[];
    if ( [availableValues count] == 0 ) {
        NSLog(@"[ERROR] Available values can't be 0");
        return;
    }
    
    NSDictionary *valueKeys = payloadDict[@"ValueKeys"] ?: @{};
    if ( [valueKeys count] == 0 ) {
        NSLog(@"[ERROR] value keys cannot be empty!");
        return;
    }
    
    for ( NSString *selection in availableValues ) {
        [self createPayloadFromManifestContent:valueKeys[selection] settings:settingsDict payloads:payloadArray];
    }
}

@end
