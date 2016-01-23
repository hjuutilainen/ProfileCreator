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

#import "PFCManifestParser.h"
#import "PFCConstants.h"
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
        sharedParser = [[self alloc] init];
    });
    return sharedParser;
} // sharedParser

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TableView Array Parsing
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)arrayFromManifestContent:(NSArray *)manifestContent settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for ( NSDictionary *manifestContentDict in manifestContent ) {
        [array addObjectsFromArray:[self arrayFromManifestContentDict:manifestContentDict settings:settings settingsLocal:settingsLocal parentKeys:nil]];
    }
    return [array copy];
} // arrayFromManifestContent:settings:settingsLocal

- (NSArray *)arrayFromManifestContentDict:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal parentKeys:(NSMutableArray *)parentKeys {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    // ------------------------------------------------------------------------------------------------------
    //  Get current manifest content dict 'CellType' and call the correct method to add any possible subkeys
    // ------------------------------------------------------------------------------------------------------
    NSString *cellType = manifestContentDict[PFCManifestKeyCellType] ?: @"";
    if ( [cellType isEqualToString:PFCCellTypeCheckbox] ) {
        [array addObjectsFromArray:[self arrayFromCellTypeCheckbox:manifestContentDict settings:settings settingsLocal:settingsLocal parentKeys:parentKeys]];
    } else if ( [cellType isEqualToString:PFCCellTypeCheckboxNoDescription] ) {
        [array addObjectsFromArray:[self arrayFromCellTypeCheckbox:manifestContentDict settings:settings settingsLocal:settingsLocal parentKeys:parentKeys]];
    } else if ( [cellType isEqualToString:PFCCellTypeDatePicker] ) {
        return @[ manifestContentDict ];
    } else if ( [cellType isEqualToString:PFCCellTypeDatePickerNoTitle] ) {
        return @[ manifestContentDict ];
    } else if ( [cellType isEqualToString:PFCCellTypeFile] ) {
        return @[ manifestContentDict ];
    } else if ( [cellType isEqualToString:PFCCellTypePadding] ) {
        return @[ manifestContentDict ];
    } else if ( [cellType isEqualToString:PFCCellTypePopUpButton] ) {
        [array addObjectsFromArray:[self arrayFromCellTypePopUpButton:manifestContentDict settings:settings settingsLocal:settingsLocal parentKeys:parentKeys]];
    } else if ( [cellType isEqualToString:PFCCellTypePopUpButtonLeft] ) {
        [array addObjectsFromArray:[self arrayFromCellTypePopUpButton:manifestContentDict settings:settings settingsLocal:settingsLocal parentKeys:parentKeys]];
    } else if ( [cellType isEqualToString:PFCCellTypePopUpButtonNoTitle] ) {
        [array addObjectsFromArray:[self arrayFromCellTypePopUpButton:manifestContentDict settings:settings settingsLocal:settingsLocal parentKeys:parentKeys]];
    } else if ( [cellType isEqualToString:PFCCellTypeSegmentedControl] ) {
        [array addObjectsFromArray:[self arrayFromCellTypeSegmentedControl:manifestContentDict settings:settings settingsLocal:settingsLocal parentKeys:parentKeys]];
    } else if ( [cellType isEqualToString:PFCCellTypeTableView] ) {
        return @[ manifestContentDict ];
    } else if ( [cellType isEqualToString:PFCCellTypeTextField] ) {
        return @[ manifestContentDict ];
    } else if ( [cellType isEqualToString:PFCCellTypeTextFieldCheckbox] ) {
        [array addObjectsFromArray:[self arrayFromCellTypeTextFieldCheckbox:manifestContentDict settings:settings settingsLocal:settingsLocal parentKeys:parentKeys]];
    } else if ( [cellType isEqualToString:PFCCellTypeTextFieldDaysHoursNoTitle] ) {
        return @[ manifestContentDict ];
    } else if ( [cellType isEqualToString:PFCCellTypeTextFieldHostPort] ) {
        return @[ manifestContentDict ];
    } else if ( [cellType isEqualToString:PFCCellTypeTextFieldHostPortCheckbox] ) {
        [array addObjectsFromArray:[self arrayFromCellTypeTextFieldCheckbox:manifestContentDict settings:settings settingsLocal:settingsLocal parentKeys:parentKeys]];
    } else if ( [cellType isEqualToString:PFCCellTypeTextFieldNoTitle] ) {
        return @[ manifestContentDict ];
    } else if ( [cellType isEqualToString:PFCCellTypeTextFieldNumber] ) {
        return @[ manifestContentDict ];
    } else if ( [cellType isEqualToString:PFCCellTypeTextFieldNumberLeft] ) {
        return @[ manifestContentDict ];
    } else if ( [cellType length] != 0 ) {
        NSLog(@"[ERROR] Unknown CellType: %@ for Identifier: %@", cellType, manifestContentDict[PFCManifestKeyIdentifier] ?: @"-");
    } else {
        //NSLog(@"[DEBUG] No CellType for manifest content dict: %@", manifestContentDict);
    }
    
    return [array copy];
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
    if ( [manifestContentDict[PFCManifestKeyValueKeys] ?: @{} count] == 0 ) {
        return @[ manifestContentDict ];
    }
    
    // -------------------------------------------------------------------------
    //  Verify this manifest content dict contains an 'Identifier'. Else stop.
    // -------------------------------------------------------------------------
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    if ( [identifier length] == 0 ) {
        return @[ manifestContentDict ];
    }
    
    // -------------------------------------------------------------------------
    //  Get current state of the checkbox
    // -------------------------------------------------------------------------
    BOOL checkboxState = NO;
    if ( settings[identifier][@"Value"] != nil ) {
        checkboxState = [settings[identifier][@"Value"] boolValue];
    } else if ( manifestContentDict[PFCManifestKeyDefaultValue] ) {
        checkboxState = [manifestContentDict[PFCManifestKeyDefaultValue] boolValue];
    } else if ( settingsLocal[identifier][@"Value"] ) {
        checkboxState = [settingsLocal[identifier][@"Value"] boolValue];
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
    if ( [manifestContentDict[PFCManifestKeyValueKeys] ?: @{} count] == 0 || [manifestContentDict[PFCManifestKeyAvailableValues] ?: @[] count] == 0 ) {
        return @[ manifestContentDict ];
    }
    
    // -------------------------------------------------------------------------
    //  Verify this manifest content dict contains an 'Identifier'. Else stop.
    // -------------------------------------------------------------------------
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    if ( [identifier length] == 0 ) {
        return @[ manifestContentDict ];
    }
    
    // -------------------------------------------------------------------------
    //  Get current selection of the PopUpButton
    // -------------------------------------------------------------------------
    NSString *selectedItem;
    if ( [settings[identifier][@"Value"] length] != 0 ) {
        selectedItem = settings[identifier][@"Value"];
    } else if (  [manifestContentDict[PFCManifestKeyDefaultValue] length] != 0 ) {
        selectedItem = manifestContentDict[PFCManifestKeyDefaultValue];
    } else if (  [settingsLocal[identifier][@"Value"] length] != 0 ) {
        selectedItem = settingsLocal[identifier][@"Value"];
    }

    // -------------------------------------------------------------------------
    //  Verify selection was made and that it exists in 'AvailableValues'
    //  If not, select first item in 'AvailableValues'
    // -------------------------------------------------------------------------
    NSArray *availableValues = manifestContentDict[PFCManifestKeyAvailableValues] ?: @[];
    if ( [selectedItem length] == 0 || ! [availableValues containsObject:selectedItem] ) {
        NSLog(@"[WARNING] PopUpButton selection is invalid, selecting first available item");
        selectedItem = [availableValues firstObject];
    }

    // -------------------------------------------------------------------------
    //  Add any subkeys the current manifest content dict contains
    // -------------------------------------------------------------------------
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:manifestContentDict, nil];
    [array addObjectsFromArray:[self arrayFromValueKeysForDict:manifestContentDict value:selectedItem settings:settings settingsLocal:settingsLocal parentKeys:parentKeys]];
    return [array copy];
} // arrayFromCellTypePopUpButton:settings:settingsLocal:parentKeys

- (NSArray *)arrayFromCellTypeSegmentedControl:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal parentKeys:(NSMutableArray *)parentKeys {
    
    // ----------------------------------------------------------------------------------------------
    //  Verify this manifest content dict contains any 'ValueKeys' and 'AvailableValues'. Else stop.
    // ----------------------------------------------------------------------------------------------
    if ( [manifestContentDict[PFCManifestKeyValueKeys] ?: @{} count] == 0 || [manifestContentDict[PFCManifestKeyAvailableValues] ?: @[] count] == 0 ) {
        return @[ manifestContentDict ];
    }
    
    // -------------------------------------------------------------------------
    //  Verify this manifest content dict contains an 'Identifier'. Else stop.
    // -------------------------------------------------------------------------
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    if ( [identifier length] == 0 ) {
        return @[ manifestContentDict ];
    }
    
    // -------------------------------------------------------------------------
    //  Get current selection of the SegmentedControl
    // -------------------------------------------------------------------------
    NSNumber *selectedSegment;
    if ( manifestContentDict[@"Value"] != nil ) {
        selectedSegment = manifestContentDict[@"Value"];
    }
    
    // -------------------------------------------------------------------------
    //  Verify selection was made and that it exists in 'AvailableValues'
    //  If not, select first item in 'AvailableValues'
    // -------------------------------------------------------------------------
    NSString *selectedSegmentString;
    NSArray *availableValues = manifestContentDict[PFCManifestKeyAvailableValues] ?: @[];
    if ( selectedSegment == nil ) {
        selectedSegmentString = [availableValues firstObject];
    } else if ( [selectedSegment intValue] <= [availableValues count] ) {
        selectedSegmentString = availableValues[[selectedSegment intValue]];
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

- (NSArray *)arrayFromCellTypeTextFieldCheckbox:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal parentKeys:(NSMutableArray *)parentKeys {
    
    // -------------------------------------------------------------------------
    //  Verify this manifest content dict contains any 'ValueKeys'. Else stop.
    // -------------------------------------------------------------------------
    if ( [manifestContentDict[PFCManifestKeyValueKeys] ?: @{} count] == 0 ) {
        return @[ manifestContentDict ];
    }
    
    // -------------------------------------------------------------------------
    //  Verify this manifest content dict contains an 'Identifier'. Else stop.
    // -------------------------------------------------------------------------
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    if ( [identifier length] == 0 ) {
        return @[ manifestContentDict ];
    }
    
    // -------------------------------------------------------------------------
    //  Get current state of the checkbox
    // -------------------------------------------------------------------------
    BOOL checkboxState = NO;
    if ( settings[identifier][@"ValueCheckbox"] != nil ) {
        checkboxState = [settings[identifier][@"ValueCheckbox"] boolValue];
    } else if ( manifestContentDict[PFCManifestKeyDefaultValueCheckbox] ) {
        checkboxState = [manifestContentDict[PFCManifestKeyDefaultValueCheckbox] boolValue];
    } else if ( settingsLocal[identifier][@"ValueCheckbox"] ) {
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

- (NSArray *)arrayFromValueKeysForDict:(NSDictionary *)manifestContentDict value:(NSString *)value settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal parentKeys:(NSMutableArray *)parentKeys {
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSDictionary *valueKeys = manifestContentDict[PFCManifestKeyValueKeys] ?: @{};
    if ( [valueKeys count] != 0 ) {
        
        // ---------------------------------------------------------------------------
        //  If selected object (valueString) in dict valueKeys is not an array, stop.
        // ---------------------------------------------------------------------------
        if ( ! [[valueKeys[value] class] isSubclassOfClass:[NSArray class]] ) {
            /*
            NSLog(@"[DEBUG] Selected value is: %@", value);
            NSLog(@"[DEBUG] Selected value class is: %@", [valueKeys[value] class]);
            NSLog(@"[DEBUG] Available ValueKeys: %@", valueKeys);
             */
            return @[];
        }
        
        // ---------------------------------------------------------------------
        //  If manifestContentDict doesn't have an identifier, stop.
        //  The identifier is required to be able to remove the dicts when the user changes selection
        // ---------------------------------------------------------------------
        NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier] ?: @"";
        if ( [identifier length] == 0 ) {
            NSLog(@"[ERROR] No identifier!");
            return @[];
        }
        
        // ---------------------------------------------------------------------
        //  Check if any sub keys exist for selected value
        // ---------------------------------------------------------------------
        NSArray *valueKeyArray = [valueKeys[value] mutableCopy] ?: @[];
        for ( NSDictionary *valueDict in valueKeyArray ) {
            if ( [valueDict count] == 0 ) {
                continue;
            }
            
            // --------------------------------------------------------------------------------------------
            //  If the key 'SharedKey' is present, the dict array to add is in the 'ValueKeysShared' array
            // --------------------------------------------------------------------------------------------
            NSMutableDictionary *mutableValueDict;
            if ( [valueDict[@"SharedKey"] length] != 0 ) {
                
                // ---------------------------------------------------------------
                //  Get the shared key dict from the manifest's 'ValueKeysShared'
                // ---------------------------------------------------------------
                NSString *sharedKey = valueDict[@"SharedKey"];
                NSDictionary *valueKeysShared = manifestContentDict[PFCManifestKeyValueKeysShared];
                if ( [valueKeysShared count] != 0 ) {
                    mutableValueDict = valueKeysShared[sharedKey];
                } else {
                    NSLog(@"Shared Key is defined, but no ValueKeysShared dict was found!");
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
            if ( parentKeys == nil ) {
                parentKeys = [[NSMutableArray alloc] init];
            }
            
            if ( ! [parentKeys containsObject:identifier] ) {
                [parentKeys addObject:identifier];
            }

            mutableValueDict[@"ParentKey"] = [parentKeys copy];
            
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
    NSMutableDictionary *manifestDict = [[NSMutableDictionary alloc] init];
    
    // ---------------------------------------------------------------------
    //  Create Manifest Root
    // ---------------------------------------------------------------------
    [manifestDict addEntriesFromDictionary:[self manifestRootFromPlistAtURL:fileURL]];
    
    // ---------------------------------------------------------------------
    //  Create Manifest Content
    // ---------------------------------------------------------------------
    manifestDict[PFCManifestKeyManifestContent] = [self manifestContentFromPlistAtURL:fileURL settings:settings];
    
    // ---------------------------------------------------------------------
    //  Add path to source plist
    // ---------------------------------------------------------------------
    manifestDict[PFCRuntimeKeyPlistPath] = [fileURL path];
    return [manifestDict copy];
} // manifestForPlistAtURL

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Create Manifest Root
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSDictionary *)manifestRootFromPlistAtURL:(NSURL *)fileURL {
    
    NSMutableDictionary *manifestDict = [[NSMutableDictionary alloc] init];
    
    // ---------------------------------------------------------------------
    //  Set the required CellType for the Menu
    // ---------------------------------------------------------------------
    manifestDict[PFCManifestKeyCellType] = @"Menu";
    
    // ---------------------------------------------------------------------
    //  Set the domain to the plist name (without the file extension)
    // ---------------------------------------------------------------------
    NSString *domain = [[fileURL lastPathComponent] stringByDeletingPathExtension] ?: @"";
    if ( [domain length] != 0 ) {
        
        // ---------------------------------------------------------------------
        //  Set both the "Domain" and "Title" to the domain
        // ---------------------------------------------------------------------
        manifestDict[PFCManifestKeyDomain] = domain;
        manifestDict[PFCManifestKeyTitle] = domain;
        
        // -----------------------------------------------------------------------------
        //  Check if any applications can be found using the domain as bundle identifier
        // -----------------------------------------------------------------------------
        NSURL *bundleURL = [(__bridge NSArray *)(LSCopyApplicationURLsForBundleIdentifier((__bridge CFStringRef _Nonnull)(domain), NULL)) firstObject];
        if ( [bundleURL checkResourceIsReachableAndReturnError:nil] ) {
            NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
            if ( bundle != nil ) {
                
                // -----------------------------------------------------------------------------
                //  If the bundle name could be retrieved, set that as the manifest "Title" key
                // -----------------------------------------------------------------------------
                NSString *bundleName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
                if ( [bundleName length] != 0 ) {
                    manifestDict[PFCManifestKeyTitle] = bundleName;
                }
                
                // ----------------------------------------------------------------------------------------
                //  If the bundle icon could be retrieved, set the bundle path as the "IconPathBundle" key
                // ----------------------------------------------------------------------------------------
                NSImage *bundleIcon = [[NSWorkspace sharedWorkspace] iconForFile:[bundleURL path]];
                if ( bundleIcon ) {
                    manifestDict[PFCManifestKeyIconPathBundle] = [bundleURL path];
                }
            }
        }
    }
    
    return [manifestDict copy];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Create Manifest Content
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)manifestContentFromPlistAtURL:(NSURL *)fileURL settings:(NSMutableDictionary *)settings {
    return [self manifestContentFromDict:[NSDictionary dictionaryWithContentsOfURL:fileURL] ?: @{} settingsDict:settings];
} // manifestContentFromPlistAtURL:settingsDict

- (NSArray *)manifestContentFromDict:(NSDictionary *)dict settingsDict:(NSMutableDictionary *)settingsDict {
    NSMutableArray *manifestArray = [[NSMutableArray alloc] init];
    
    // -----------------------------------------------------------------------------------------
    //  Loop through all keys in the dict and create an array of "ManifestContent" dictionaries
    // -----------------------------------------------------------------------------------------
    NSArray *dictKeys = [dict allKeys];
    for ( NSString *key in dictKeys ) {
        
        NSMutableDictionary *manifestDict = [[NSMutableDictionary alloc] init];
        
        // -----------------------------------------------------------------------------------------
        //  FIXME - Add preference for hiding system keys (like window position etc.)
        // -----------------------------------------------------------------------------------------
        if ( @YES ) {
            
            // -----------------------------------------------------------------------------------------
            // FIXME - Should probably add this as a key like "Hidden" instead of excluding so the user can show hidden keys later.
            // Like: manifestDict[PFCManifestKeyHidden] = @([self hideKey:key]);
            // -----------------------------------------------------------------------------------------
            if ( [[PFCManifestUtility sharedUtility] hideKey:key] ) {
                continue;
            }
        }
        
        // ---------------------------------------------------------------------------------
        //  Generate an identifier and add all static key/value pairs like "PayloadKey" etc.
        // ---------------------------------------------------------------------------------
        NSString *identifier = [[NSUUID UUID] UUIDString];
        manifestDict[PFCManifestKeyIdentifier] = identifier;
        manifestDict[PFCManifestKeyEnabled] = @YES;
        manifestDict[PFCManifestKeyPayloadKey] = key;
        manifestDict[PFCManifestKeyTitle] = key;
        
        // ---------------------------------------------------------------------
        //  Cast the value to id and check what type the value is stored as
        // ---------------------------------------------------------------------
        id value = dict[key];
        NSString *typeString = [[PFCManifestUtility sharedUtility] typeStringFromValue:value];
        if ( [typeString length] != 0 ) {
            
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
            if ( [typeString isEqualToString:@"Array"] ) {
                manifestDict[PFCManifestKeyTableViewColumns] = [self tableViewColumnsFromArray:value settings:identifierSettingsDict];
                
                // -------------------------------------------------------------
                //  Dict - CellType: PFCCellTypeSegmentedControl
                // -------------------------------------------------------------
            } else if ( [typeString isEqualToString:@"Dict"] ) {
                manifestDict[PFCManifestKeyAvailableValues] = @[ key ];
                manifestDict[PFCManifestKeyValueKeys] = @{ key : [self manifestContentFromDict:value settingsDict:identifierSettingsDict] };
                
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
                identifierSettingsDict[@"Value"] = value;
            }
            
            // -----------------------------------------------------------------
            //  Store all settings in the passed settingsDict
            // -----------------------------------------------------------------
            settingsDict[identifier] = [identifierSettingsDict copy] ?: @{};
        } else {
            NSLog(@"[ERROR] TypeString was empty!");
            continue;
        }
        [manifestArray addObject:[manifestDict copy]];
    }
    
    return [manifestArray copy];
} // manifestArrayFromDict:settingsDict

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
    if (
        [typeString isEqualToString:@"String"] ||
        [typeString isEqualToString:@"Integer"] ||
        [typeString isEqualToString:@"Float"] ) {
        
        // ---------------------------------------------------------------------
        //  Create a unique columen title
        // ---------------------------------------------------------------------
        NSString *columnTitle = [[NSUUID UUID] UUIDString];
        
        // ---------------------------------------------------------------------
        //  Add the manifest settings to describe the tableview column
        // ---------------------------------------------------------------------
        [tableViewColumns addObject:@{
                                      PFCManifestKeyTitle : columnTitle,
                                      PFCManifestKeyCellType : [[PFCManifestUtility sharedUtility] cellTypeFromTypeString:typeString]
                                      }];
        
        // ---------------------------------------------------------------------
        //  Add all current settings to the "TableViewContent" array
        // ---------------------------------------------------------------------
        NSMutableArray *tableViewContent = [[NSMutableArray alloc] init];
        for ( NSString *string in array ) {
            [tableViewContent addObject:@{ columnTitle : @{ @"Value" : string } }];
        }
        
        settings[@"TableViewContent"] = [tableViewContent copy];
        
        // -------------------------------------------------------------------------
        //  Array content: Dict
        // -------------------------------------------------------------------------
    } else if ( [typeString isEqualToString:@"Dict"] ) {
        
        
        // -----------------------------------------------------------------------------
        //  FIXME - This assumes that all dicts in the array look the same. Should fix.
        //  Add the manifest settings to describe the tableview columns
        // -----------------------------------------------------------------------------
        NSDictionary *templateDict = [array firstObject];
        for ( NSString *key in [templateDict allKeys] ) {
            NSString *valueTypeString = [[PFCManifestUtility sharedUtility] typeStringFromValue:templateDict[key]];
            [tableViewColumns addObject:@{
                                          PFCManifestKeyTitle : key,
                                          PFCManifestKeyCellType : [[PFCManifestUtility sharedUtility] cellTypeFromTypeString:valueTypeString]
                                          }];
        }
        
        // -----------------------------------------------------------------------------
        //  Add all current settings to the "TableViewContent" array
        // -----------------------------------------------------------------------------
        NSMutableArray *tableViewContent = [[NSMutableArray alloc] init];
        for ( NSDictionary *dict in array ) {
            NSMutableDictionary *contentDict = [[NSMutableDictionary alloc] init];
            for ( NSString *key in [dict allKeys] ) {
                NSString *valueTypeString = [[PFCManifestUtility sharedUtility] typeStringFromValue:dict[key]];
                if ( [valueTypeString isEqualToString:@"String"] ) {
                    contentDict[key] = @{ @"Value" : dict[key] };
                } else if ( [valueTypeString isEqualToString:@"Boolean"] ) {
                    contentDict[key] = @{ @"Value" : dict[key] };
                } else {
                    //NSLog(@"key=%@", dict[key]);
                }
            }
            
            [tableViewContent addObject:[contentDict copy]];
        }
        
        settings[@"TableViewContent"] = [tableViewContent copy];
    }
    return [tableViewColumns copy];
} // tableViewColumnsFromArray

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Verify Manifests
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSDictionary *)verifyManifestContent:(NSArray *)manifestContent settings:(NSDictionary *)settings {
    NSMutableArray *errorDict = [NSMutableArray array];
    for ( NSDictionary *manifestContentDict in manifestContent ) {
        if ( manifestContentDict[@"PayloadValue"] || manifestContentDict[@"SharedKey"] ) {
            continue;
        }
        NSDictionary *report = [self verifyManifestContentDict:manifestContentDict settings:settings];
        if ( [report count] != 0 ) {
            [errorDict addObject:report];
        }
    }
    
    return [self combinedDictFromArray:errorDict];
}

- (NSDictionary *)verifyManifestContentDict:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings {
    NSString *cellType = manifestContentDict[@"CellType"];
    if ( [cellType isEqualToString:@"TextField"] ) {
        return [self verifyCellTypeTextField:manifestContentDict settings:settings];
    } else if ( [cellType isEqualToString:@"TextFieldCheckbox"] ) {
        return [self verifyCellTypeTextFieldCheckbox:manifestContentDict settings:settings];
    } else if ( [cellType isEqualToString:@"TextFieldDaysHoursNoTitle"] ) {
        return [self verifyCellTypeTextFieldDaysHoursNoTitle:manifestContentDict settings:settings];
    } else if ( [cellType isEqualToString:@"TextFieldHostPort"] ) {
        return [self verifyCellTypeTextFieldHostPort:manifestContentDict settingsDict:settings];
    } else if ( [cellType isEqualToString:@"TextFieldHostPortCheckbox"] ) {
        return [self verifyCellTypeTextFieldHostPortCheckbox:manifestContentDict settingsDict:settings];
    } else if ( [cellType isEqualToString:@"TextFieldNoTitle"] ) {
        return [self verifyCellTypeTextField:manifestContentDict settings:settings];
    } else if ( [cellType isEqualToString:@"TextFieldNumber"] ) {
        return [self verifyCellTypeTextFieldNumber:manifestContentDict settingsDict:settings];
    } else if ( [cellType isEqualToString:@"TextFieldNumberLeft"] ) {
        return [self verifyCellTypeTextFieldNumber:manifestContentDict settingsDict:settings];
    } else if ( [cellType isEqualToString:@"Checkbox"] ) {
        return [self verifyCellTypeCheckbox:manifestContentDict settingsDict:settings];
    } else if ( [cellType isEqualToString:@"CheckboxNoDescription"] ) {
        return [self verifyCellTypeCheckbox:manifestContentDict settingsDict:settings];
    } else if ( [cellType isEqualToString:@"DatePickerNoTitle"] ) {
        
    } else if ( [cellType isEqualToString:@"File"] ) {
        return [self verifyCellTypeFile:manifestContentDict settingsDict:settings];
    } else if ( [cellType isEqualToString:@"PopUpButton"] ) {
        return [self verifyCellTypePopUpButton:manifestContentDict settingsDict:settings];
    } else if ( [cellType isEqualToString:@"PopUpButtonLeft"] ) {
        return [self verifyCellTypePopUpButton:manifestContentDict settingsDict:settings];
    } else if ( [cellType isEqualToString:@"PopUpButtonNoTitle"] ) {
        return [self verifyCellTypePopUpButton:manifestContentDict settingsDict:settings];
    } else if ( [cellType isEqualToString:@"SegmentedControl"] ) {
        return [self verifyCellTypeSegmentedControl:manifestContentDict settingsDict:settings];
    } else if ( [cellType isEqualToString:@"TableView"] ) {
        
    } else if ( [cellType length] != 0 ) {
        //NSLog(@"[ERROR] Unknown CellType: %@ for Identifier: %@", cellType, manifestContentDict[PFCManifestKeyIdentifier] ?: @"-");
    } else {
        //NSLog(@"[DEBUG] No CellType for manifest content dict: %@", manifestContentDict);
    }
    
    return @{};
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Verify Manifests CellTypes
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSDictionary *)verifyCellTypeTextField:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings {
    
    NSString *identifier = manifestContentDict[@"Identifier"];
    NSDictionary *contentDictSettings = settings[identifier];
    if ( [contentDictSettings count] == 0 ) {
        //NSLog(@"No settings!");
    }
    BOOL required = [manifestContentDict[@"Required"] boolValue];
    NSString *value = contentDictSettings[@"Value"];
    if ( [value length] == 0 ) {
        value = contentDictSettings[@"DefaultValue"];
    }
    
    if ( required && [value length] == 0 ) {
        return @{
                 @"Error" : @[@{
                                  @"Message" : @"",
                                  @"Identifier" : manifestContentDict[@"Identifier"] ?: @"Unknown",
                                  @"PayloadKey" : manifestContentDict[@"PayloadKey"] ?: @"Unknown"
                                  }]
                 };
    }
    
    return nil;
}

- (NSDictionary *)verifyCellTypeTextFieldCheckbox:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings {
    NSString *identifier = manifestContentDict[@"Identifier"];
    NSDictionary *contentDictSettings = settings[identifier];
    if ( [contentDictSettings count] == 0 ) {
        //NSLog(@"No settings!");
    }
    BOOL required = [manifestContentDict[@"Required"] boolValue];
    NSString *value = contentDictSettings[@"ValueTextField"];
    if ( [value length] == 0 ) {
        value = contentDictSettings[@"DefaultValueTextField"];
    }
    
    if ( required && [value length] == 0 ) {
        return @{
                 @"Error" : @[@{
                                  @"Message" : @"",
                                  @"Identifier" : manifestContentDict[@"Identifier"] ?: @"Unknown",
                                  @"PayloadKey" : manifestContentDict[@"PayloadKey"] ?: @"Unknown"
                                  }]
                 };
    }
    
    return nil;
}

- (NSDictionary *)verifyCellTypeTextFieldDaysHoursNoTitle:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings {
    NSString *identifier = manifestContentDict[@"Identifier"];
    NSDictionary *contentDictSettings = settings[identifier];
    if ( [contentDictSettings count] == 0 ) {
        //NSLog(@"No settings!");
    }
    BOOL required = [manifestContentDict[@"Required"] boolValue];
    NSNumber *value = contentDictSettings[@"Value"];
    if ( value == nil ) {
        value = contentDictSettings[@"DefaultValue"];
    }
    
    if ( required && value == nil ) {
        return @{
                 @"Error" : @[@{
                                  @"Message" : @"",
                                  @"Identifier" : manifestContentDict[@"Identifier"] ?: @"Unknown",
                                  @"PayloadKey" : manifestContentDict[@"PayloadKey"] ?: @"Unknown"
                                  }]
                 };
    }
    
    return nil;
}

- (NSDictionary *)verifyCellTypeTextFieldHostPort:(NSDictionary *)cellDict settingsDict:(NSDictionary *)settingsDict {
    NSString *identifier = cellDict[@"Identifier"];
    NSDictionary *settings = settingsDict[identifier];
    if ( [settings count] == 0 ) {
        //NSLog(@"No settings!");
    }
    // Host
    NSMutableArray *array = [NSMutableArray array];
    
    BOOL requiredHost;
    if ( cellDict[@"RequiredHost"] != nil ) {
        requiredHost = [cellDict[@"RequiredHost"] boolValue];
    } else {
        requiredHost = [cellDict[@"Required"] boolValue];
    }
    
    NSString *valueHost = settings[@"ValueHost"];
    if ( [valueHost length] == 0 ) {
        valueHost = settings[@"DefaultValueHost"];
    }
    
    if ( requiredHost && [valueHost length] == 0 ) {
        [array addObject:@{
                           @"Message" : @"",
                           @"Identifier" : cellDict[@"Identifier"] ?: @"Unknown",
                           @"PayloadKey" : cellDict[@"PayloadKeyHost"] ?: @"Unknown"
                           }];
    }
    
    
    // Port
    BOOL requiredPort;
    if ( cellDict[@"RequiredPort"] != nil ) {
        requiredPort = [cellDict[@"RequiredPort"] boolValue];
    } else {
        requiredPort = [cellDict[@"Required"] boolValue];
    }
    NSString *valuePort = settings[@"ValuePort"];
    if ( [valuePort length] == 0 ) {
        valuePort = settings[@"DefaultValuePort"];
    }
    
    if ( requiredPort && [valuePort length] == 0 ) {
        [array addObject:@{
                           @"Message" : @"",
                           @"Identifier" : cellDict[@"Identifier"] ?: @"Unknown",
                           @"PayloadKey" : cellDict[@"PayloadKeyPort"] ?: @"Unknown"
                           }];
    }
    
    if ( [array count] != 0 ) {
        return @{ @"Error" : [array copy] };
    }
    
    return nil;
}

- (NSDictionary *)verifyCellTypeTextFieldHostPortCheckbox:(NSDictionary *)cellDict settingsDict:(NSDictionary *)settingsDict {
    NSString *identifier = cellDict[@"Identifier"];
    NSDictionary *settings = settingsDict[identifier];
    if ( [settings count] == 0 ) {
        //NSLog(@"No settings!");
    }
    // Host
    NSMutableArray *array = [NSMutableArray array];
    
    BOOL requiredHost;
    if ( cellDict[@"RequiredHost"] != nil ) {
        requiredHost = [cellDict[@"RequiredHost"] boolValue];
    } else {
        requiredHost = [cellDict[@"Required"] boolValue];
    }
    
    NSString *valueHost = settings[@"ValueHost"];
    if ( [valueHost length] == 0 ) {
        valueHost = settings[@"DefaultValueHost"];
    }
    
    if ( requiredHost && [valueHost length] == 0 ) {
        [array addObject:@{
                           @"Message" : @"",
                           @"Identifier" : cellDict[@"Identifier"] ?: @"Unknown",
                           @"PayloadKey" : cellDict[@"PayloadKeyHost"] ?: @"Unknown"
                           }];
    }
    
    
    // Port
    BOOL requiredPort;
    if ( cellDict[@"RequiredPort"] != nil ) {
        requiredPort = [cellDict[@"RequiredPort"] boolValue];
    } else {
        requiredPort = [cellDict[@"Required"] boolValue];
    }
    NSNumber *valuePort = settings[@"ValuePort"];
    if ( valuePort == nil ) {
        valuePort = settings[@"DefaultValuePort"];
    }
    
    if ( requiredPort && valuePort == nil ) {
        [array addObject:@{
                           @"Message" : @"",
                           @"Identifier" : cellDict[@"Identifier"] ?: @"Unknown",
                           @"PayloadKey" : cellDict[@"PayloadKeyPort"] ?: @"Unknown"
                           }];
    }
    
    if ( [array count] != 0 ) {
        return @{ @"Error" : [array copy] };
    }
    
    return nil;
}

- (NSDictionary *)verifyCellTypeTextFieldNumber:(NSDictionary *)cellDict settingsDict:(NSDictionary *)settingsDict {
    
    NSString *identifier = cellDict[@"Identifier"];
    NSDictionary *settings = settingsDict[identifier];
    if ( [settings count] == 0 ) {
        //NSLog(@"No settings!");
    }
    BOOL required = [cellDict[@"Required"] boolValue];
    NSNumber *value = settings[@"Value"];
    if ( value == nil ) {
        value = settings[@"DefaultValue"];
    }
    
    NSNumber *minValue = cellDict[@"MinValue"];
    NSNumber *maxValue = cellDict[@"MaxValue"];
    
    if ( required && ( value == nil || value <= minValue || maxValue < value ) ) {
        return @{
                 @"Error" : @[@{
                                  @"Message" : @"",
                                  @"Identifier" : cellDict[@"Identifier"] ?: @"Unknown",
                                  @"PayloadKey" : cellDict[@"PayloadKey"] ?: @"Unknown"
                                  }]
                 };
    }
    
    return nil;
}

- (NSDictionary *)verifyCellTypeCheckbox:(NSDictionary *)cellDict settingsDict:(NSDictionary *)settingsDict {
    
    NSString *checkboxState = [settingsDict[@"Value"] boolValue] ? @"True" : @"False";
    NSDictionary *valueKeys = cellDict[@"ValueKeys"];
    if ( valueKeys[checkboxState] ) {
        return [self verifyManifestContent:valueKeys[checkboxState] settings:settingsDict];
    }
    
    return nil;
}

- (NSDictionary *)verifyCellTypeFile:(NSDictionary *)cellDict settingsDict:(NSDictionary *)settingsDict {
    
    NSString *identifier = cellDict[@"Identifier"];
    NSDictionary *settings = settingsDict[identifier];
    if ( [settings count] == 0 ) {
        //NSLog(@"No settings!");
    }
    //BOOL required = [cellDict[@"Required"] boolValue];
    NSString *filePath = settings[@"FilePath"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath ?: @""];
    NSError *error = nil;
    if ( ! [fileURL checkResourceIsReachableAndReturnError:&error] ) {
        return @{
                 @"Error" : @[@{
                                  @"Message" : [error localizedDescription] ?: @"",
                                  @"Identifier" : cellDict[@"Identifier"] ?: @"Unknown",
                                  @"PayloadKey" : cellDict[@"PayloadKey"] ?: @"Unknown"
                                  }]
                 };
    }
    
    NSArray *allowedFileTypes = cellDict[@"AllowedFileTypes"];
    if ( [allowedFileTypes count] != 0 ) {
        NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
        NSString *fileType;
        NSError *error;
        if ([fileURL getResourceValue:&fileType forKey:NSURLTypeIdentifierKey error:&error]) {
            __block BOOL validFileType = NO;
            [allowedFileTypes enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([workspace type:fileType conformsToType:obj]) {
                    validFileType = YES;
                    *stop = YES;
                }
            }];
            
            if ( ! validFileType ) {
                return @{
                         @"Error" : @[@{
                                          @"Message" : @"Invalid File Type",
                                          @"Identifier" : cellDict[@"Identifier"] ?: @"Unknown",
                                          @"PayloadKey" : cellDict[@"PayloadKey"] ?: @"Unknown"
                                          }]
                         };
            }
        } else {
            NSLog(@"[ERROR] %@", [error localizedDescription]);
        }
    }
    
    return nil;
}

- (NSDictionary *)verifyCellTypePopUpButton:(NSDictionary *)cellDict settingsDict:(NSDictionary *)settingsDict {
    
    NSString *selectedItem = settingsDict[@"Value"];
    if ( [selectedItem length] == 0 ) {
        selectedItem = cellDict[@"DefaultValue"];
    }
    
    if ( [selectedItem length] == 0 ) {
        return @{
                 @"Error" : @[@{
                                  @"Message" : @"No selection!",
                                  @"Identifier" : cellDict[@"Identifier"] ?: @"Unknown",
                                  @"PayloadKey" : cellDict[@"PayloadKey"] ?: @"Unknown"
                                  }]
                 };
    }
    
    if ( ! [cellDict[@"AvailableValues"] ?: @[] containsObject:selectedItem] ) {
        return @{
                 @"Error" : @[@{
                                  @"Message" : @"Invalid selection!",
                                  @"Identifier" : cellDict[@"Identifier"] ?: @"Unknown",
                                  @"PayloadKey" : cellDict[@"PayloadKey"] ?: @"Unknown"
                                  }]
                 };
    }
    
    NSDictionary *valueKeys = cellDict[@"ValueKeys"];
    if ( valueKeys[selectedItem] ) {
        return [self verifyManifestContent:valueKeys[selectedItem] settings:settingsDict];
    }
    
    return nil;
}

- (NSDictionary *)verifyCellTypeSegmentedControl:(NSDictionary *)cellDict settingsDict:(NSDictionary *)settingsDict {
    NSMutableArray *reports = [NSMutableArray array];
    NSDictionary *valueKeys = cellDict[@"ValueKeys"];
    for ( NSString *selection in cellDict[@"AvailableValues"] ?: @[] ) {
        NSDictionary *reportDict = [self verifyManifestContent:valueKeys[selection] settings:settingsDict];
        if ( [reportDict count] != 0 ) {
            [reports addObject:reportDict];
        }
    }
    return [self combinedDictFromArray:reports];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Verify Manifest Utility Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSDictionary *)combinedDictFromArray:(NSArray *)array {
    
    NSMutableArray *error = [NSMutableArray array];
    NSMutableArray *warning = [NSMutableArray array];
    
    for ( NSDictionary *dict in array ) {
        if ( [dict[@"Error"] count] != 0 ) {
            [error addObjectsFromArray:dict[@"Error"]];
        }
        if ( [dict[@"Warning"] count] != 0 ) {
            [warning addObjectsFromArray:dict[@"Warning"]];
        }
    }
    
    NSMutableDictionary *returnDict = [NSMutableDictionary dictionary];
    if ( [warning count] != 0 ) {
        returnDict[@"Warning"] = [warning copy];
    }
    if ( [error count] != 0 ) {
        returnDict[@"Error"] = [error copy];
    }
    
    return returnDict;
}

@end
