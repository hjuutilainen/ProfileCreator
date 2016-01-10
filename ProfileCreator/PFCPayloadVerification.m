//
//  PFCPayloadVerification.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-01-06.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCPayloadVerification.h"

@implementation PFCPayloadVerification

+ (id)sharedInstance {
    static PFCPayloadVerification *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
} // sharedInstance

- (NSDictionary *)verifyManifest:(NSArray *)manifestArray settingsDict:(NSDictionary *)settingsDict {
    NSMutableArray *errorDict = [NSMutableArray array];
    for ( NSDictionary *payloadDict in manifestArray ) {
        if ( payloadDict[@"PayloadValue"] || payloadDict[@"SharedKey"] ) {
            continue;
        }
        NSDictionary *report = [[PFCPayloadVerification sharedInstance] verifyCellDict:payloadDict settingsDict:settingsDict];
        if ( [report count] != 0 ) {
            [errorDict addObject:report];
        }
    }
    
    return [self combinedDictFromArray:errorDict];
}

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

- (NSDictionary *)verifyCellDict:(NSDictionary *)cellDict settingsDict:(NSDictionary *)settingsDict {
    NSString *cellType = cellDict[@"CellType"];
    if ( [cellType isEqualToString:@"TextField"] ) {
        return [self verifyCellTypeTextField:cellDict settingsDict:settingsDict];
    } else if ( [cellType isEqualToString:@"TextFieldCheckbox"] ) {
        return [self verifyCellTypeTextFieldCheckbox:cellDict settingsDict:settingsDict];
    } else if ( [cellType isEqualToString:@"TextFieldDaysHoursNoTitle"] ) {
        return [self verifyCellTypeTextFieldDaysHoursNoTitle:cellDict settingsDict:settingsDict];
    } else if ( [cellType isEqualToString:@"TextFieldHostPort"] ) {
        return [self verifyCellTypeTextFieldHostPort:cellDict settingsDict:settingsDict];
    } else if ( [cellType isEqualToString:@"TextFieldHostPortCheckbox"] ) {
        return [self verifyCellTypeTextFieldHostPortCheckbox:cellDict settingsDict:settingsDict];
    } else if ( [cellType isEqualToString:@"TextFieldNoTitle"] ) {
        return [self verifyCellTypeTextField:cellDict settingsDict:settingsDict];
    } else if ( [cellType isEqualToString:@"TextFieldNumber"] ) {
        return [self verifyCellTypeTextFieldNumber:cellDict settingsDict:settingsDict];
    } else if ( [cellType isEqualToString:@"TextFieldNumberLeft"] ) {
        return [self verifyCellTypeTextFieldNumber:cellDict settingsDict:settingsDict];
    } else if ( [cellType isEqualToString:@"Checkbox"] ) {
        return [self verifyCellTypeCheckbox:cellDict settingsDict:settingsDict];
    } else if ( [cellType isEqualToString:@"CheckboxNoDescription"] ) {
        return [self verifyCellTypeCheckbox:cellDict settingsDict:settingsDict];
    } else if ( [cellType isEqualToString:@"DatePickerNoTitle"] ) {
        
    } else if ( [cellType isEqualToString:@"File"] ) {
        return [self verifyCellTypeFile:cellDict settingsDict:settingsDict];
    } else if ( [cellType isEqualToString:@"PopUpButton"] ) {
        return [self verifyCellTypePopUpButton:cellDict settingsDict:settingsDict];
    } else if ( [cellType isEqualToString:@"PopUpButtonLeft"] ) {
        return [self verifyCellTypePopUpButton:cellDict settingsDict:settingsDict];
    } else if ( [cellType isEqualToString:@"PopUpButtonNoTitle"] ) {
        return [self verifyCellTypePopUpButton:cellDict settingsDict:settingsDict];
    } else if ( [cellType isEqualToString:@"SegmentedControl"] ) {
        return [self verifyCellTypeSegmentedControl:cellDict settingsDict:settingsDict];
    } else if ( [cellType isEqualToString:@"TableView"] ) {
        
    } else {
        NSLog(@"[ERROR] Unknown CellType: %@", cellType);
        NSLog(@"[ERROR] cellDict: %@", cellDict);
    }
    
    return @{};
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Verify CellTypes
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSDictionary *)verifyCellTypeTextField:(NSDictionary *)cellDict settingsDict:(NSDictionary *)settingsDict {
    
    NSString *identifier = cellDict[@"Identifier"];
    NSDictionary *settings = settingsDict[identifier];
    if ( [settings count] == 0 ) {
        //NSLog(@"No settings!");
    }
    BOOL required = [cellDict[@"Required"] boolValue];
    NSString *value = settings[@"Value"];
    if ( [value length] == 0 ) {
        value = settings[@"DefaultValue"];
    }
    
    if ( required && [value length] == 0 ) {
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

- (NSDictionary *)verifyCellTypeTextFieldCheckbox:(NSDictionary *)cellDict settingsDict:(NSDictionary *)settingsDict {
    NSString *identifier = cellDict[@"Identifier"];
    NSDictionary *settings = settingsDict[identifier];
    if ( [settings count] == 0 ) {
        //NSLog(@"No settings!");
    }
    BOOL required = [cellDict[@"Required"] boolValue];
    NSString *value = settings[@"ValueTextField"];
    if ( [value length] == 0 ) {
        value = settings[@"DefaultValueTextField"];
    }
    
    if ( required && [value length] == 0 ) {
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

- (NSDictionary *)verifyCellTypeTextFieldDaysHoursNoTitle:(NSDictionary *)cellDict settingsDict:(NSDictionary *)settingsDict {
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
    
    if ( required && value == nil ) {
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
        return [self verifyManifest:valueKeys[checkboxState] settingsDict:settingsDict];
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
        return [self verifyManifest:valueKeys[selectedItem] settingsDict:settingsDict];
    }
    
    return nil;
}

- (NSDictionary *)verifyCellTypeSegmentedControl:(NSDictionary *)cellDict settingsDict:(NSDictionary *)settingsDict {
    NSMutableArray *reports = [NSMutableArray array];
    NSDictionary *valueKeys = cellDict[@"ValueKeys"];
    for ( NSString *selection in cellDict[@"AvailableValues"] ?: @[] ) {
        NSDictionary *reportDict = [self verifyManifest:valueKeys[selection] settingsDict:settingsDict];
        if ( [reportDict count] != 0 ) {
            [reports addObject:reportDict];
        }
    }
    return [self combinedDictFromArray:reports];
}

@end
