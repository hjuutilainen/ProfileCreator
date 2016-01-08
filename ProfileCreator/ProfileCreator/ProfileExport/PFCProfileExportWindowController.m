//
//  PFCProfileExportWindowController.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-01-05.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCProfileExportWindowController.h"
#import "PFCPayloadVerification.h"

@interface PFCProfileExportWindowController ()

@end

@implementation PFCProfileExportWindowController


- (id)initWithProfileDict:(NSDictionary *)profileDict {
    self = [super initWithWindowNibName:@"PFCProfileExportWindowController"];
    if (self != nil) {
        _profileDict = profileDict;
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    [self updateProfileInfo];
}

- (void)updateProfileInfo {
    if ( [_profileDict count] == 0 ) {
        NSLog(@"[ERROR] No profile!");
        return;
    }
    
    NSString *profileName = _profileDict[@"Config"][@"Name"];
    [_textFieldName setStringValue:profileName];
}

- (IBAction)buttonExport:(id)sender {
    
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
        NSDictionary *settingsInfo = [[PFCPayloadVerification sharedInstance] verifyManifest:manifestDict[@"PayloadKeys"] settingsDict:settingsDict];
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
    profile[@"PayloadScope"] = @"System";
    profile[@"ConsentText"] = @"";
    
    NSMutableArray *payloadArray = [NSMutableArray array];
    for ( NSDictionary *manifestDict in manifestDicts ) {
        NSString *manifestDomain = manifestDict[@"Domain"];
        NSDictionary *settingsDict = selectedDict[manifestDomain];
        [self createPayloadFromManifestArray:manifestDict[@"PayloadKeys"] settingsDict:settingsDict payloadArray:&payloadArray];
    }
    
    // general
    profile[@"DurationUntilRemoval"] = @"";
    profile[@"RemovalDate"] = @"";
    profile[@"PayloadOrganization"] = @"";
    profile[@"PayloadExpirationDate"] = @"";
    profile[@"PayloadDisplayName"] = @"";
    profile[@"PayloadDescription"] = @"";
    profile[@"PayloadRemovalDisallowed"] = @NO;
    
    // Payloads
    profile[@"PayloadContent"] = @[];
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
        
    } else if ( [cellType isEqualToString:@"TextFieldDaysHoursNoTitle"] ) {
        
    } else if ( [cellType isEqualToString:@"TextFieldHostPort"] ) {
        
    } else if ( [cellType isEqualToString:@"TextFieldHostPortCheckbox"] ) {
        
    } else if ( [cellType isEqualToString:@"TextFieldNoTitle"] ) {
        [self createPayloadFromCellTypeTextField:payloadDict settingsDict:settingsDict payloadArray:payloadArray];
    } else if ( [cellType isEqualToString:@"TextFieldNumber"] ) {
        
    } else if ( [cellType isEqualToString:@"TextFieldNumberLeft"] ) {
        
    } else if ( [cellType isEqualToString:@"Checkbox"] ) {
        
    } else if ( [cellType isEqualToString:@"CheckboxNoDescription"] ) {
        
    } else if ( [cellType isEqualToString:@"File"] ) {
        
    } else if ( [cellType isEqualToString:@"PopUpButton"] ) {
        
    } else if ( [cellType isEqualToString:@"PopUpButtonLeft"] ) {
        
    } else if ( [cellType isEqualToString:@"PopUpButtonNoTitle"] ) {
        
    } else if ( [cellType isEqualToString:@"SegmentedControl"] ) {
        
    } else if ( [cellType isEqualToString:@"TableView"] ) {
        
    } else {
        NSLog(@"[ERROR] Unknown CellType: %@", cellType);
    }
}

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
    
    if ( value == nil ) {
        value = @"";
    } else if ( ! [[value class] isSubclassOfClass:[NSString class]] ) {
        NSLog(@"[ERROR] value is not of the correct class!");
        NSLog(@"[ERROR] value class: %@", [value class]);
        NSLog(@"[ERROR] expected class: %@", [NSString class]);
        return;
    }
    
    NSString *payloadParentKey = payloadDict[@"ParentKey"];
    
    NSUInteger idx = [*payloadArray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return [[item objectForKey:@"PayloadType"] isEqualToString:payloadType];
    }];
    
    NSMutableDictionary *payloadDictDict;
    if ( idx != NSNotFound ) {
        payloadDictDict = [[*payloadArray objectAtIndex:idx] mutableCopy];
    } else {
        payloadDictDict = [NSMutableDictionary dictionaryWithDictionary:@{ @"PayloadType" : payloadType }];
    }
    
    payloadDictDict[payloadKey] = value;
    
    if ( idx != NSNotFound ) {
        [*payloadArray replaceObjectAtIndex:idx withObject:[payloadDictDict copy]];
    } else {
        [*payloadArray addObject:[payloadDictDict copy]];
    }
    
    NSLog(@"%@", *payloadArray);
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
