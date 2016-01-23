//
//  PFCProfileExportWindowController.m
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

#import "PFCProfileExportWindowController.h"
#import "PFCManifestParser.h"
#import "PFCController.h"

@interface PFCProfileExportWindowController ()

@end

@implementation PFCProfileExportWindowController


- (id)initWithProfileDict:(NSDictionary *)profileDict sender:(id)sender {
    self = [super initWithWindowNibName:@"PFCProfileExportWindowController"];
    if (self != nil) {
        _profileDict = profileDict;
        _parentObject = sender;
    }
    return self;
}

- (void)awakeFromNib {
    [_stackView setOrientation:NSUserInterfaceLayoutOrientationVertical];
    [_stackView setAlignment:NSLayoutAttributeCenterX];
    [_stackView setSpacing:0];
    [_stackView setHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationHorizontal];
    [_stackView setHuggingPriority:NSLayoutPriorityDefaultHigh forOrientation:NSLayoutConstraintOrientationVertical];
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [[self window] setBackgroundColor:[NSColor whiteColor]];
    [[self window] setTitle:[NSString stringWithFormat:@"Export %@", _profileDict[@"Config"][@"Name"]] ?: @"Export"];
    [self updateProfileInfo];
    [self verifyProfile];
}

- (void)updateProfileInfo {
    if ( [_profileDict count] == 0 ) {
        NSLog(@"[ERROR] No profile!");
        return;
    }
    
    NSString *profileName = _profileDict[@"Config"][@"Name"];
    [_textFieldName setStringValue:profileName];
}

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

- (BOOL)windowShouldClose:(id)sender {
        if ( [_parentObject respondsToSelector:@selector(removeControllerForProfileDictWithName:)] ) {
            [_parentObject removeControllerForProfileDictWithName:_profileDict[@"Config"][@"Name"]];
        }
        return YES;
}

- (IBAction)buttonExport:(id)sender {
    
    NSSavePanel *panel = [NSSavePanel savePanel];
    NSString *profileName = _profileDict[@"Config"][@"Name"] ?: @"";
        
        //[panel setAllowedFileTypes:@[ @"com.github.NBICreator.template" ]];
        [panel setCanCreateDirectories:YES];
        [panel setTitle:@"Export Template"];
        [panel setPrompt:@"Export"];
        [panel setNameFieldStringValue:[NSString stringWithFormat:@"%@.mobileconfig", profileName]];
        [panel beginSheetModalForWindow:[[NSApp delegate] window] completionHandler:^(NSInteger result) {
            if (result == NSFileHandlingPanelOKButton) {
                NSURL *saveURL = [panel URL];
                [self exportProfileToURL:saveURL];
            }
        }];
}

- (void)verifyProfile {
    
    NSDictionary *configDict = _profileDict[@"Config"][@"Settings"];
    NSMutableDictionary *selectedDict = [NSMutableDictionary dictionary];
    for ( NSString *key in [configDict allKeys] ) {
        NSDictionary *payloadSettings = configDict[key];
        if ( ! [payloadSettings[@"Selected"] boolValue] && ! [key isEqualToString:@"com.apple.general"] ) {
            continue;
        }
        
        selectedDict[key] = configDict[key];
    }
    
    NSArray *selectedDomains = [selectedDict allKeys];
    NSArray *manifestDicts = [self manifestDictsForDomains:selectedDomains];
    
    for ( NSDictionary *manifestDict in manifestDicts ) {
        NSString *manifestDomain = manifestDict[@"Domain"];
        NSDictionary *settingsDict = selectedDict[manifestDomain];
        NSDictionary *settingsInfo = [[PFCManifestParser sharedParser] verifyManifest:manifestDict[@"ManifestContent"] settingsDict:settingsDict];
        if ( [settingsInfo count] != 0 ) {
            NSArray *warnings = settingsInfo[@"Warning"];
            for ( NSDictionary *warningDict in warnings ) {
                NSLog(@"[WARNING] %@", warningDict);
            }
            
            NSArray *errors = settingsInfo[@"Error"];
            for ( NSDictionary *errorDict in errors ) {
                NSLog(@"[ERROR] %@", errorDict);
            }
        }
    }
    
    NSMutableArray *payloadArray = [NSMutableArray array];
    for ( NSDictionary *manifestDict in manifestDicts ) {
        NSString *manifestDomain = manifestDict[@"Domain"];
        NSDictionary *settingsDict = selectedDict[manifestDomain];
        [self createPayloadFromManifestArray:manifestDict[@"ManifestContent"] settingsDict:settingsDict payloadArray:&payloadArray];
    }
    
    NSUInteger idx = [payloadArray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return [[item objectForKey:@"PayloadType"] isEqualToString:@"com.apple.profile"];
    }];
    
    if ( idx == NSNotFound ) {
        NSLog(@"[ERROR] No general settings found!");
        return;
    }
    
    [payloadArray removeObjectAtIndex:idx];
    NSLog(@"array: %@", payloadArray);
    NSNumber *payloadCount = @([payloadArray count]);
    if ( [payloadCount intValue] == 1 ) {
        [_textFieldPayloadsCount setStringValue:[NSString stringWithFormat:@"%ld Payload", (long)[payloadCount integerValue]]];
    } else {
        [_textFieldPayloadsCount setStringValue:[NSString stringWithFormat:@"%ld Payloads", (long)[payloadCount integerValue]]];
    }
}

- (void)exportProfileToURL:(NSURL *)profileURL {

    NSDictionary *configDict = _profileDict[@"Config"][@"Settings"];
    NSMutableDictionary *selectedDict = [NSMutableDictionary dictionary];
    for ( NSString *key in [configDict allKeys] ) {
        NSDictionary *payloadSettings = configDict[key];
        if ( ! [payloadSettings[@"Selected"] boolValue] && ! [key isEqualToString:@"com.apple.general"] ) {
            continue;
        }
        
        selectedDict[key] = configDict[key];
    }
    
    NSArray *selectedDomains = [selectedDict allKeys];
    NSArray *manifestDicts = [self manifestDictsForDomains:selectedDomains];
    
    for ( NSDictionary *manifestDict in manifestDicts ) {
        NSString *manifestDomain = manifestDict[@"Domain"];
        NSDictionary *settingsDict = selectedDict[manifestDomain];
        NSDictionary *settingsInfo = [[PFCManifestParser sharedParser] verifyManifest:manifestDict[@"ManifestContent"] settingsDict:settingsDict];
        if ( [settingsInfo count] != 0 ) {
            NSArray *warnings = settingsInfo[@"Warning"];
            for ( NSDictionary *warningDict in warnings ) {
                NSLog(@"[WARNING] %@", warningDict);
            }
            
            NSArray *errors = settingsInfo[@"Error"];
            for ( NSDictionary *errorDict in errors ) {
                NSLog(@"[ERROR] %@", errorDict);
            }
        }
    }
    
    // Create Profile
    NSMutableDictionary *profile = [NSMutableDictionary dictionary];
    profile[@"PayloadUUID"] = [[NSUUID UUID] UUIDString];
    profile[@"PayloadIdentifier"] = @"com.github.profilecreator.test";
    profile[@"PayloadType"] = @"Configuration";
    profile[@"PayloadVersion"] = @1;
    
    // Should be setting?
    profile[@"PayloadScope"] = @"User";
    //profile[@"ConsentText"] = @"";
    
    NSMutableArray *payloadArray = [NSMutableArray array];
    for ( NSDictionary *manifestDict in manifestDicts ) {
        NSString *manifestDomain = manifestDict[@"Domain"];
        NSDictionary *settingsDict = selectedDict[manifestDomain];
        [self createPayloadFromManifestArray:manifestDict[@"ManifestContent"] settingsDict:settingsDict payloadArray:&payloadArray];
    }
    
    NSUInteger idx = [payloadArray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return [[item objectForKey:@"PayloadType"] isEqualToString:@"com.apple.profile"];
    }];
    
    if ( idx == NSNotFound ) {
        NSLog(@"[ERROR] No general settings found!");
        return;
    }
    
    NSMutableDictionary *profileGeneral = [[payloadArray objectAtIndex:idx] mutableCopy];
    [payloadArray removeObjectAtIndex:idx];
    [profileGeneral removeObjectForKey:@"PayloadType"];
    [profile addEntriesFromDictionary:[profileGeneral copy]];
    
    
    // general
    //profile[@"DurationUntilRemoval"] = @"";
    //profile[@"RemovalDate"] = @"";
    //profile[@"PayloadOrganization"] = @"";
    //profile[@"PayloadExpirationDate"] = @"";
    //profile[@"PayloadDisplayName"] = @"";
    //profile[@"PayloadDescription"] = @"";
    //profile[@"PayloadRemovalDisallowed"] = @NO;
    
    // Payloads
    profile[@"PayloadContent"] = payloadArray ?: @[];
    NSError *error = nil;
    
    if ( ! [profile writeToURL:profileURL atomically:NO] ) {
        NSLog(@"[ERROR] write profile failed!");
    } else {
        if ( [profileURL checkResourceIsReachableAndReturnError:&error] ) {
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[ profileURL ]];
        } else {
            NSLog(@"[ERROR] %@", [error localizedDescription]);
        }
    }
}

- (IBAction)buttonCancel:(id)sender {
    [[self window] performClose:self];
}

- (void)createPayloadFromManifestArray:(NSArray *)manifestArray settingsDict:(NSDictionary *)settingsDict payloadArray:(NSMutableArray **)payloadArray {
    for ( NSDictionary *payloadDict in manifestArray ) {
        [self createPayloadFromCellDict:payloadDict settingsDict:settingsDict payloadArray:payloadArray];
    }
}

- (void)createPayloadFromCellDict:(NSDictionary *)payloadDict settingsDict:(NSDictionary *)settingsDict payloadArray:(NSMutableArray **)payloadArray {
    NSString *cellType = payloadDict[@"CellType"];
    if ( [cellType isEqualToString:@"TextField"] ) {
        [self createPayloadFromCellTypeTextField:payloadDict settingsDict:settingsDict payloadArray:payloadArray];
    } else if ( [cellType isEqualToString:@"TextFieldCheckbox"] ) {
        [self createPayloadFromCellTypeTextFieldCheckbox:payloadDict settingsDict:settingsDict payloadArray:payloadArray];
    } else if ( [cellType isEqualToString:@"TextFieldDaysHoursNoTitle"] ) {
        
    } else if ( [cellType isEqualToString:@"TextFieldHostPort"] ) {
        [self createPayloadFromCellTypeTextFieldHostPort:payloadDict settingsDict:settingsDict payloadArray:payloadArray];
    } else if ( [cellType isEqualToString:@"TextFieldHostPortCheckbox"] ) {
        
    } else if ( [cellType isEqualToString:@"TextFieldNoTitle"] ) {
        [self createPayloadFromCellTypeTextField:payloadDict settingsDict:settingsDict payloadArray:payloadArray];
    } else if ( [cellType isEqualToString:@"TextFieldNumber"] ) {
        [self createPayloadFromCellTypeTextFieldNumber:payloadDict settingsDict:settingsDict payloadArray:payloadArray];
    } else if ( [cellType isEqualToString:@"TextFieldNumberLeft"] ) {
        [self createPayloadFromCellTypeTextFieldNumber:payloadDict settingsDict:settingsDict payloadArray:payloadArray];
    } else if ( [cellType isEqualToString:@"Checkbox"] ) {
        [self createPayloadFromCellTypeCheckbox:payloadDict settingsDict:settingsDict payloadArray:payloadArray];
    } else if ( [cellType isEqualToString:@"CheckboxNoDescription"] ) {
        [self createPayloadFromCellTypeCheckbox:payloadDict settingsDict:settingsDict payloadArray:payloadArray];
    } else if ( [cellType isEqualToString:@"DatePickerNoTitle"] ) {

    } else if ( [cellType isEqualToString:@"File"] ) {
        
    } else if ( [cellType isEqualToString:@"PopUpButton"] ) {
        [self createPayloadFromCellTypePopUpButton:payloadDict settingsDict:settingsDict payloadArray:payloadArray];
    } else if ( [cellType isEqualToString:@"PopUpButtonLeft"] ) {
        [self createPayloadFromCellTypePopUpButton:payloadDict settingsDict:settingsDict payloadArray:payloadArray];
    } else if ( [cellType isEqualToString:@"PopUpButtonNoTitle"] ) {
        [self createPayloadFromCellTypePopUpButton:payloadDict settingsDict:settingsDict payloadArray:payloadArray];
    } else if ( [cellType isEqualToString:@"SegmentedControl"] ) {
        [self createPayloadFromCellTypeSegmentedControl:payloadDict settingsDict:settingsDict payloadArray:payloadArray];
    } else if ( [cellType isEqualToString:@"TableView"] ) {
        
    } else {
        NSLog(@"[ERROR] Unknown CellType: %@", cellType);
        NSLog(@"[ERROR] payloadDict: %@", payloadDict);
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Create CellTypes
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)createPayloadFromCellTypeTextField:(NSDictionary *)payloadDict settingsDict:(NSDictionary *)settingsDict payloadArray:(NSMutableArray **)payloadArray {
    
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
    id value = settings[@"Value"];
    if ( value == nil ) {
        value = payloadDict[@"DefaultValue"];
    }
    
    if ( value == nil || [value length] == 0 ) {
        if ( [payloadDict[@"Optional"] boolValue] ) {
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
    //NSString *payloadParentKey = payloadDict[@"ParentKey"];
    
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

- (void)createPayloadFromCellTypeTextFieldCheckbox:(NSDictionary *)payloadDict settingsDict:(NSDictionary *)settingsDict payloadArray:(NSMutableArray **)payloadArray {
    
    NSString *identifier = payloadDict[@"Identifier"];
    if ( [identifier length] == 0 ) {
        NSLog(@"[ERROR] No identifier!");
        return;
    }
    
    NSDictionary *settings = settingsDict[identifier] ?: @{};
    
    id value = settings[@"Value"];
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
        return ( item[@"PayloadValue"] ) ? YES : NO;
    }];
    
    if ( idxPayloadValue != NSNotFound ) {
        NSDictionary *payloadValueDict = [selectedValueArray objectAtIndex:idxPayloadValue];
        [selectedValueArray removeObjectAtIndex:idxPayloadValue];
        
        id value = payloadValueDict[@"PayloadValue"];
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
        //NSString *payloadParentKey = payloadDict[@"ParentKey"];
        
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
        return ( item[@"SharedKey"] ) ? YES : NO;
    }];
    
    if ( idxSharedKey != NSNotFound ) {
        NSDictionary *sharedKeyDict = [selectedValueArray objectAtIndex:idxSharedKey];
        [selectedValueArray removeObjectAtIndex:idxSharedKey];
        
        id value = sharedKeyDict[@"SharedKey"];
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
        
        [self createPayloadFromCellDict:valueKeysShared[value] settingsDict:settingsDict payloadArray:payloadArray];
    }
    
    
    if ( [selectedValueArray count] != 0 ) {
        [self createPayloadFromManifestArray:selectedValueArray settingsDict:settingsDict payloadArray:payloadArray];
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
    id value = settings[@"Value"];
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
    //NSString *payloadParentKey = payloadDict[@"ParentKey"];
    
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
    id value = settings[@"Value"];
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
    //NSString *payloadParentKey = payloadDict[@"ParentKey"];
    
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
        return ( item[@"PayloadValue"] ) ? YES : NO;
    }];
    
    if ( idxPayloadValue != NSNotFound ) {
        NSDictionary *payloadValueDict = [selectedValueArray objectAtIndex:idxPayloadValue];
        [selectedValueArray removeObjectAtIndex:idxPayloadValue];
        
        id value = payloadValueDict[@"PayloadValue"];
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
        //NSString *payloadParentKey = payloadDict[@"ParentKey"];
        
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
        return ( item[@"SharedKey"] ) ? YES : NO;
    }];
    
    if ( idxSharedKey != NSNotFound ) {
        NSDictionary *sharedKeyDict = [selectedValueArray objectAtIndex:idxSharedKey];
        [selectedValueArray removeObjectAtIndex:idxSharedKey];
        
        id value = sharedKeyDict[@"SharedKey"];
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
        
        [self createPayloadFromCellDict:valueKeysShared[value] settingsDict:settingsDict payloadArray:payloadArray];
    }
    
    
    if ( [selectedValueArray count] != 0 ) {
        [self createPayloadFromManifestArray:selectedValueArray settingsDict:settingsDict payloadArray:payloadArray];
    }
}

- (void)createPayloadFromCellTypePopUpButton:(NSDictionary *)payloadDict settingsDict:(NSDictionary *)settingsDict payloadArray:(NSMutableArray **)payloadArray {
    
    NSString *identifier = payloadDict[@"Identifier"];
    if ( [identifier length] == 0 ) {
        NSLog(@"[ERROR] No identifier!");
        return;
    }
    
    NSDictionary *settings = settingsDict[identifier] ?: @{};
    id value = settings[@"Value"];
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
        return ( item[@"PayloadValue"] ) ? YES : NO;
    }];

    if ( idxPayloadValue != NSNotFound ) {
        NSDictionary *payloadValueDict = [selectedValueArray objectAtIndex:idxPayloadValue];
        [selectedValueArray removeObjectAtIndex:idxPayloadValue];
    
        id value = payloadValueDict[@"PayloadValue"];
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
        //NSString *payloadParentKey = payloadDict[@"ParentKey"];
        
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
        return ( item[@"SharedKey"] ) ? YES : NO;
    }];
    
    if ( idxSharedKey != NSNotFound ) {
        NSDictionary *sharedKeyDict = [selectedValueArray objectAtIndex:idxSharedKey];
        [selectedValueArray removeObjectAtIndex:idxSharedKey];
        
        id value = sharedKeyDict[@"SharedKey"];
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
        
        [self createPayloadFromCellDict:valueKeysShared[value] settingsDict:settingsDict payloadArray:payloadArray];
    }
    
        
    if ( [selectedValueArray count] != 0 ) {
        [self createPayloadFromManifestArray:selectedValueArray settingsDict:settingsDict payloadArray:payloadArray];
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
        [self createPayloadFromManifestArray:valueKeys[selection] settingsDict:settingsDict payloadArray:payloadArray];
    }
}



- (NSArray *)manifestDictsForDomains:(NSArray *)domains {
    
    NSError *error = nil;
    NSMutableArray *manifestDicts = [NSMutableArray array];
    
    // ---------------------------------------------------------------------
    //  Get URL to manifest folder inside ProfileCreator.app
    // ---------------------------------------------------------------------
    NSURL *profileManifestFolderURL = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"Manifests"];
    if ( [profileManifestFolderURL checkResourceIsReachableAndReturnError:&error] ) {
        
        // ---------------------------------------------------------------------
        //  Put all profile manifest plist URLs in an array
        // ---------------------------------------------------------------------
        NSArray *manifestPlists = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:profileManifestFolderURL
                                                                includingPropertiesForKeys:@[]
                                                                                   options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                     error:nil];
        
        // ---------------------------------------------------------------------
        //  Loop through all profile manifests and add them to the menu array
        // ---------------------------------------------------------------------
        NSPredicate *predicateManifestPlists = [NSPredicate predicateWithFormat:@"self.pathExtension == 'plist'"];
        for ( NSURL *manifestURL in [manifestPlists filteredArrayUsingPredicate:predicateManifestPlists] ) {
            NSDictionary *manifestDict = [NSDictionary dictionaryWithContentsOfURL:manifestURL];
            if ( [manifestDict count] != 0 ) {
                NSString *manifestDomain = manifestDict[@"Domain"] ?: @"";
                if (
                    [domains containsObject:manifestDomain] ||
                    [manifestDomain isEqualToString:@"com.apple.general"]
                    ) {
                    [manifestDicts addObject:manifestDict];
                }
            } else {
                NSLog(@"[ERROR] Manifest %@ was empty!", [manifestURL lastPathComponent]);
            }
        }
    } else {
        NSLog(@"[ERROR] %@", [error localizedDescription]);
    }
    
    return manifestDicts;
}

@end
