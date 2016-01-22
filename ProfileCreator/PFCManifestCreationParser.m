//
//  PFCManifestCreationParser.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2015-12-17.
//  Copyright © 2015 Erik Berglund. All rights reserved.
//

#import "PFCManifestCreationParser.h"
#import "PFCConstants.h"
#import <Cocoa/Cocoa.h>

@implementation PFCManifestCreationParser

+ (NSDictionary *)manifestForPlistAtURL:(NSURL *)fileURL settingsDict:(NSMutableDictionary *)settingsDict {
    NSMutableDictionary *manifestDict = [[NSMutableDictionary alloc] init];
    
    // ---------------------------------------------------------------------
    //  Create Manifest Menu
    // ---------------------------------------------------------------------
    [manifestDict addEntriesFromDictionary:[self manifestMenuForPlistAtURL:fileURL]];
    
    // ---------------------------------------------------------------------
    //  Create Manifest Content
    // ---------------------------------------------------------------------
    manifestDict[PFCManifestKeyManifestContent] = [self manifestContentForPlistAtURL:fileURL settingsDict:settingsDict];
    
    // ---------------------------------------------------------------------
    //  Add path to source plist
    // ---------------------------------------------------------------------
    manifestDict[PFCRuntimeKeyPlistPath] = [fileURL path];
    return [manifestDict copy];
} // manifestForPlistAtURL

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Manifest Menu
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

+ (NSDictionary *)manifestMenuForPlistAtURL:(NSURL *)fileURL {
    
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
#pragma mark Manifest Content
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

+ (NSArray *)manifestContentForPlistAtURL:(NSURL *)fileURL settingsDict:(NSMutableDictionary *)settingsDict {
    return [self manifestContentArrayFromDict:[NSDictionary dictionaryWithContentsOfURL:fileURL] ?: @{} settingsDict:settingsDict];
} // manifestArrayForPlistAtURL:settingsDict

+ (NSArray *)manifestContentArrayFromDict:(NSDictionary *)dict settingsDict:(NSMutableDictionary *)settingsDict {
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
            if ( [self hideKey:key] ) {
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
        NSString *typeString = [self typeStringFromValue:value];
        if ( [typeString length] != 0 ) {
            
            // -----------------------------------------------------------------
            //  Add all static keys for the value type
            // -----------------------------------------------------------------
            manifestDict[PFCManifestKeyPayloadValueType] = typeString;
            manifestDict[PFCManifestKeyCellType] = [self cellTypeFromTypeString:typeString];
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
                manifestDict[PFCManifestKeyValueKeys] = @{ key : [self manifestContentArrayFromDict:value settingsDict:identifierSettingsDict] };
                
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
#pragma mark Utility Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

+ (NSArray *)tableViewColumnsFromArray:(NSArray *)array settings:(NSMutableDictionary *)settings {
    NSMutableArray *tableViewColumns = [[NSMutableArray alloc] init];
    
    // -------------------------------------------------------------------------
    //  Check what type the array contains
    // -------------------------------------------------------------------------
    NSString *typeString = [self typeStringFromValue:[array firstObject]];
    
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
                                      PFCManifestKeyCellType : [self cellTypeFromTypeString:typeString]
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
            NSString *valueTypeString = [self typeStringFromValue:templateDict[key]];
            [tableViewColumns addObject:@{
                                          PFCManifestKeyTitle : key,
                                          PFCManifestKeyCellType : [self cellTypeFromTypeString:valueTypeString]
                                          }];
        }
        
        // -----------------------------------------------------------------------------
        //  Add all current settings to the "TableViewContent" array
        // -----------------------------------------------------------------------------
        NSMutableArray *tableViewContent = [[NSMutableArray alloc] init];
        for ( NSDictionary *dict in array ) {
            NSMutableDictionary *contentDict = [[NSMutableDictionary alloc] init];
            for ( NSString *key in [dict allKeys] ) {
                NSString *valueTypeString = [self typeStringFromValue:dict[key]];
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

+ (BOOL)hideKey:(NSString *)key {
    
    // -------------------------------------------------------------------------
    //  FIXME - Move keysToHide to plist and write a preferences for this.
    //  This should be a user setting under preferences.
    //  List all "default" disabled, and user can override by adding their own or disable some or all hiding
    // -------------------------------------------------------------------------
    
    NSArray *keysToHide = @[
                            @"NSWindow",
                            @"NSNavPanelExpandedSizeForOpenMode",
                            @"NSNavPanelExpandedSizeForSaveMode",
                            @"NSNavPanelExpandedStateForSaveMode",
                            @"NSNavLastRootDirectory",
                            @"NSSplitView",
                            @"NSOutlineView",
                            @"NSTableView",
                            @"NSToolbar"
                            ];
    
    __block BOOL hideKey = NO;
    [keysToHide enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( [key hasPrefix:obj] ) {
            hideKey = YES;
            *stop = YES;
        }
    }];
    return hideKey;
} // hideKey

+ (NSString *)typeStringFromValue:(id)value {
    id valueClass = [value class];
    if ( [value isKindOfClass:[NSString class]] )       return @"String";
    if ( [valueClass isEqualTo:[@(YES) class]] )        return @"Boolean";
    if ( [valueClass isEqualTo:[@(0) class]] ) {
        CFNumberType numberType = CFNumberGetType((CFNumberRef)value);
        
        /*
         Use the CFNumberTypes to determine what number type the value is.
         
         kCFNumberSInt8Type     = 1,
         kCFNumberSInt16Type    = 2,
         kCFNumberSInt32Type    = 3,
         kCFNumberSInt64Type    = 4,
         kCFNumberFloat32Type   = 5,
         kCFNumberFloat64Type   = 6,
         kCFNumberCharType      = 7,
         kCFNumberShortType     = 8,
         kCFNumberIntType       = 9,
         kCFNumberLongType      = 10,
         kCFNumberLongLongType  = 11,
         kCFNumberFloatType     = 12,
         kCFNumberDoubleType    = 13,
         kCFNumberCFIndexType   = 14,
         kCFNumberNSIntegerType = 15,
         kCFNumberCGFloatType   = 16,
         kCFNumberMaxType       = 16
         */
        
        if ( numberType <= 4 )                          return @"Integer";
        if ( 5 <= numberType && numberType <= 6 )       return @"Float";
        
        NSLog(@"[ERROR] Unknown CFNumberType: %ld", numberType);
        return @"Number";
    }
    if ( [value isKindOfClass:[NSArray class]] )        return @"Array";
    if ( [value isKindOfClass:[NSDictionary class]] )   return @"Dict";
    if ( [value isKindOfClass:[NSDate class]] )         return @"Date";
    if ( [value isKindOfClass:[NSData class]] )         return @"Data";
    return @"Unknown";
} // typeStringFromValue

+ (NSString *)cellTypeFromTypeString:(NSString *)typeString {
    if ( [typeString isEqualToString:@"String"] )   return PFCCellTypeTextField;
    if ( [typeString isEqualToString:@"Boolean"] )  return PFCCellTypeCheckbox;
    if ( [typeString isEqualToString:@"Integer"] )  return PFCCellTypeTextFieldNumber;
    if ( [typeString isEqualToString:@"Float"] )    return PFCCellTypeTextFieldNumber;
    if ( [typeString isEqualToString:@"Array"] )    return PFCCellTypeTableView;
    if ( [typeString isEqualToString:@"Dict"] )     return PFCCellTypeSegmentedControl;
    if ( [typeString isEqualToString:@"Date"] )     return PFCCellTypeDatePicker;
    if ( [typeString isEqualToString:@"Data"] )     return PFCCellTypeFile;
    return @"Unknown";
} // cellTypeFromTypeString

@end
