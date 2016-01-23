//
//  PFCManifestParser.m
//  ProfileCreator

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
#pragma mark Parse Manifest
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)arrayForManifestContent:(NSArray *)manifestContent settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for ( NSDictionary *manifestContentDict in manifestContent ) {
        [array addObjectsFromArray:[self arrayForManifestContentDict:manifestContentDict settings:settings settingsLocal:settingsLocal parentKeys:nil]];
    }
    return [array copy];
} // arrayForManifestContent:settings:settingsLocal

- (NSArray *)arrayForManifestContentDict:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal parentKeys:(NSMutableArray *)parentKeys {
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
#pragma mark Parse ManifestContent Dict CellTypes
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
#pragma mark Parse ManifestContent Dict SubKeys (ValueKeys)
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
            [array addObjectsFromArray:[self arrayForManifestContentDict:mutableValueDict settings:settings settingsLocal:settingsLocal parentKeys:parentKeys]];
        }
        
        // -----------------------------------------------------------------------------------------------------------
        //  Remove the current manifest's identifer from the parentKeys array so subsequent dict's doesn't get tagged
        // -----------------------------------------------------------------------------------------------------------
        [parentKeys removeObject:identifier];
    }
    
    return [array copy];
} // arrayFromValueKeysForDict:value:settings:settingsLocal:parentKeys

@end
