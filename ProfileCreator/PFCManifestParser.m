//
//  PFCManifestParser.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-01-22.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCManifestParser.h"
#import "PFCConstants.h"

@implementation PFCManifestParser

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initialization
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

+ (id)sharedParser {
    static PFCManifestParser *sharedParser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedParser = [[self alloc] init];
    });
    return sharedParser;
} // sharedParser

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark -
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)arrayForManifestContent:(NSArray *)manifestContent settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for ( NSDictionary *manifestContentDict in manifestContent ) {
        [array addObjectsFromArray:[self arrayForManifestContentDict:manifestContentDict settings:settings settingsLocal:settingsLocal parentKeys:nil]];
    }
    return [array copy];
} // settingsArrayForManifest:settings

- (NSArray *)arrayForManifestContentDict:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal parentKeys:(NSMutableArray *)parentKeys {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSString *cellType = manifestContentDict[PFCManifestKeyCellType];
    NSLog(@"cellType=%@", cellType);
    NSLog(@"identifier=%@", manifestContentDict[PFCManifestKeyIdentifier]);
    NSLog(@"parentKeys=%@", parentKeys);
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
    } else {
        NSLog(@"[ERROR] Unknown CellType: %@", cellType);
    }
    
    return [array copy];
} // arrayFromManifestContentDict:settings

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark CellTypes
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)arrayFromCellTypeCheckbox:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal parentKeys:(NSMutableArray *)parentKeys {
    
    if ( [manifestContentDict[@"ValueKeys"] ?: @{} count] == 0 ) {
        return @[ manifestContentDict ];
    }
    
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    if ( [identifier length] == 0 ) {
        return @[ manifestContentDict ];
    }
    
    NSDictionary *cellSettings = settings[identifier];
    if ( [cellSettings count] == 0 ) {
        return @[ manifestContentDict ];
    }
    
    BOOL checkboxState = NO;
    if ( cellSettings[@"Value"] != nil ) {
        checkboxState = [cellSettings[@"Value"] boolValue];
    } else if ( manifestContentDict[@"DefaultValue"] ) {
        checkboxState = [manifestContentDict[@"DefaultValue"] boolValue];
    } else if ( settingsLocal[identifier][@"Value"] ) {
        checkboxState = [settingsLocal[identifier][@"Value"] boolValue];
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:manifestContentDict, nil];
    [array addObjectsFromArray:[self arrayFromValueKeysForDict:manifestContentDict value:checkboxState ? @"True" : @"False" settings:settings settingsLocal:settingsLocal parentKeys:parentKeys]];
    return [array copy];
} // arrayFromCellTypeCheckbox:settings

- (NSArray *)arrayFromCellTypePopUpButton:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal parentKeys:(NSMutableArray *)parentKeys {
    NSLog(@"arrayFromCellTypePopUpButton");
    if ( [manifestContentDict[@"ValueKeys"] ?: @{} count] == 0 || [manifestContentDict[@"AvailableValues"] ?: @[] count] == 0 ) {
        return @[ manifestContentDict ];
    }
    
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    NSLog(@"manifestContentDict=%@", manifestContentDict);
    if ( [identifier length] == 0 ) {
        return @[ manifestContentDict ];
    }
    
    NSString *selectedItem;
    if ( [settings[identifier][@"Value"] length] != 0 ) {
        selectedItem = settings[identifier][@"Value"];
    } else if (  [manifestContentDict[@"DefaultValue"] length] != 0 ) {
        selectedItem = manifestContentDict[@"DefaultValue"];
    } else if (  [settingsLocal[identifier][@"Value"] length] != 0 ) {
        selectedItem = settingsLocal[identifier][@"Value"];
    }
    NSLog(@"selectedItem=%@", selectedItem);
    NSArray *availableValues = manifestContentDict[@"AvailableValues"] ?: @[];
    if ( [selectedItem length] == 0 || ! [availableValues containsObject:selectedItem] ) {
        selectedItem = [availableValues firstObject];
    }
    NSLog(@"selectedItem=%@", selectedItem);
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:manifestContentDict, nil];
    [array addObjectsFromArray:[self arrayFromValueKeysForDict:manifestContentDict value:selectedItem settings:settings settingsLocal:settingsLocal parentKeys:parentKeys]];
    return [array copy];
} // arrayFromCellTypePopUpButton:settings

- (NSArray *)arrayFromCellTypeSegmentedControl:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal parentKeys:(NSMutableArray *)parentKeys {
    
    if ( [manifestContentDict[@"ValueKeys"] ?: @{} count] == 0 || [manifestContentDict[@"AvailableValues"] ?: @[] count] == 0 ) {
        return @[ manifestContentDict ];
    }
    
    NSNumber *selectedSegment;
    if ( manifestContentDict[@"Value"] != nil ) {
        selectedSegment = manifestContentDict[@"Value"];
    }
    
    NSArray *availableValues = manifestContentDict[@"AvailableValues"] ?: @[];
    
    NSString *selectedSegmentString;
    if ( selectedSegment == nil ) {
        selectedSegmentString = [availableValues firstObject];
    } else if ( [selectedSegment intValue] <= [availableValues count] ) {
        selectedSegmentString = availableValues[[selectedSegment intValue]];
    } else {
        return @[ manifestContentDict ];
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:manifestContentDict, nil];
    [array addObjectsFromArray:[self arrayFromValueKeysForDict:manifestContentDict value:selectedSegmentString settings:settings settingsLocal:settingsLocal parentKeys:parentKeys]];
    return [array copy];
} // arrayFromCellTypeSegmentedControl:settings

- (NSArray *)arrayFromCellTypeTextFieldCheckbox:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal parentKeys:(NSMutableArray *)parentKeys {
    
    if ( [manifestContentDict[@"ValueKeys"] ?: @{} count] == 0 ) {
        return @[ manifestContentDict ];
    }
    
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    if ( [identifier length] == 0 ) {
        return @[ manifestContentDict ];
    }
    
    NSDictionary *cellSettings = settings[identifier];
    if ( [cellSettings count] == 0 ) {
        return @[ manifestContentDict ];
    }
    
    BOOL checkboxState = NO;
    if ( cellSettings[@"ValueCheckbox"] != nil ) {
        checkboxState = [cellSettings[@"ValueCheckbox"] boolValue];
    } else if ( manifestContentDict[@"DefaultValueCheckbox"] ) {
        checkboxState = [manifestContentDict[@"DefaultValueCheckbox"] boolValue];
    } else if ( settingsLocal[identifier][@"ValueCheckbox"] ) {
        checkboxState = [settingsLocal[identifier][@"ValueCheckbox"] boolValue];
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithObjects:manifestContentDict, nil];
    [array addObjectsFromArray:[self arrayFromValueKeysForDict:manifestContentDict value:checkboxState ? @"True" : @"False" settings:settings settingsLocal:settingsLocal parentKeys:parentKeys]];
    return [array copy];
} // arrayFromCellTypeTextField:settings

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark 
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)arrayFromValueKeysForDict:(NSDictionary *)manifestContentDict value:(NSString *)value settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal parentKeys:(NSMutableArray *)parentKeys {
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    NSDictionary *valueKeys = manifestContentDict[@"ValueKeys"] ?: @{};
    if ( [valueKeys count] != 0 ) {
        
        // ---------------------------------------------------------------------------
        //  If selected object (valueString) in dict valueKeys is not an array, stop.
        // ---------------------------------------------------------------------------
        if ( ! [[valueKeys[value] class] isSubclassOfClass:[NSArray class]] ) {
            NSLog(@"Selected value is: %@", [valueKeys[value] class]);
            return @[];
        }
        
        // ---------------------------------------------------------------------
        //  If manifestContentDict doesn't have an identifier, stop.
        //  The identifier is required to be able to remove the dicts when the user changes selection
        // ---------------------------------------------------------------------
        NSString *identifier = manifestContentDict[@"Identifier"] ?: @"";
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
                NSDictionary *valueKeysShared = manifestContentDict[@"ValueKeysShared"];
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
            //  Run the current manifest and add
            // -----------------------------------------------------------------
            [array addObjectsFromArray:[self arrayForManifestContentDict:mutableValueDict settings:settings settingsLocal:settingsLocal parentKeys:parentKeys]];
        }
        
        // -----------------------------------------------------------------------------------------------------------
        //  Remove the current manifest's identifer from the parentKeys array so subsequent dict's doesn't get tagged
        // -----------------------------------------------------------------------------------------------------------
        [parentKeys removeObject:identifier];
    }
    
    return [array copy];
}

@end
