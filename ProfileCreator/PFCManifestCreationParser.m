//
//  PFCManifestCreationParser.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2015-12-17.
//  Copyright © 2015 Erik Berglund. All rights reserved.
//

#import "PFCManifestCreationParser.h"
#import <Cocoa/Cocoa.h>

@implementation PFCManifestCreationParser

+ (NSDictionary *)manifestForPlistAtURL:(NSURL *)fileURL settingsDict:(NSMutableDictionary **)settingsDict {
    NSMutableDictionary *manifestDict = [[NSMutableDictionary alloc] init];
    [manifestDict addEntriesFromDictionary:[self manifestMenuForPlistAtURL:fileURL]];
    manifestDict[PFCManifestKeyManifestContent] = [self manifestArrayForPlistAtURL:fileURL settingsDict:settingsDict];
    manifestDict[PFCRuntimeManifestKeyPlistPath] = [fileURL path];
    return [manifestDict copy];
} // manifestForPlistAtURL

+ (NSDictionary *)manifestMenuForPlistAtURL:(NSURL *)fileURL {
    NSMutableDictionary *manifestDict = [[NSMutableDictionary alloc] init];
    
    manifestDict[PFCManifestKeyCellType] = @"Menu";
    manifestDict[PFCManifestKeyDescription] = @"Not Configured";
    
    NSString *domain = [[fileURL lastPathComponent] stringByDeletingPathExtension] ?: @"";
    if ( [domain length] != 0 ) {
        manifestDict[PFCManifestKeyDomain] = domain;
        manifestDict[PFCManifestKeyTitle] = domain;
        
        NSError *error = nil;
        NSURL *bundleURL = [(__bridge NSArray *)(LSCopyApplicationURLsForBundleIdentifier((__bridge CFStringRef _Nonnull)(domain), NULL)) firstObject];
        if ( [bundleURL checkResourceIsReachableAndReturnError:&error] ) {
            NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
            if ( bundle != nil ) {
                NSString *bundleName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
                if ( [bundleName length] != 0 ) {
                    manifestDict[PFCManifestKeyTitle] = bundleName;
                }
                
                NSImage *bundleIcon = [[NSWorkspace sharedWorkspace] iconForFile:[bundleURL path]];
                if ( bundleIcon ) {
                    manifestDict[PFCManifestKeyIconPathBundle] = [bundleURL path];
                }
            }
        }
    }
    
    return [manifestDict copy];
}

+ (NSArray *)manifestArrayForPlistAtURL:(NSURL *)fileURL settingsDict:(NSMutableDictionary **)settingsDict {
    return [self manifestArrayFromDict:[NSDictionary dictionaryWithContentsOfURL:fileURL] ?: @{} settingsDict:settingsDict];
} // manifestArrayForPlistAtURL:settingsDict

+ (NSArray *)manifestArrayFromDict:(NSDictionary *)dict settingsDict:(NSMutableDictionary **)settingsDict {
    NSMutableArray *manifestArray = [[NSMutableArray alloc] init];
    NSArray *dictKeys = [dict allKeys];
    for ( NSString *key in dictKeys ) {
        
        NSMutableDictionary *manifestDict = [[NSMutableDictionary alloc] init];
        
        // FIXME - Add preference for hiding certain keys
        // Check if user disabled all key hiding
        if ( @YES ) {
            
            // FIXME - Should probably add this as a key like "Hidden" instead of excluding so the user can show hidden keys later.
            // Like: manifestDict[PFCManifestKeyHidden] = @([self hideKey:key]);
            if ( [self hideKey:key] ) {
                continue;
            }
        }
        
        NSString *identifier = [[NSUUID UUID] UUIDString];
        manifestDict[PFCManifestKeyIdentifier] = identifier;
        manifestDict[PFCManifestKeyEnabled] = @YES;
        manifestDict[PFCManifestKeyPayloadKey] = key;
        manifestDict[PFCManifestKeyTitle] = key;
        
        id value = dict[key];
        NSString *typeString = [self typeStringFromValue:value];
        if ( [typeString length] != 0 ) {
            manifestDict[PFCManifestKeyPayloadValueType] = typeString;
            manifestDict[PFCManifestKeyCellType] = [self cellTypeFromTypeString:typeString];
            manifestDict[PFCManifestKeyDescription] = @"No Description";
            
            NSMutableDictionary *settingsDict = [[NSMutableDictionary alloc] init];
            
            // Read Settings
            if ( [typeString isEqualToString:@"Array"] ) {
                manifestDict[PFCManifestKeyTableViewColumns] = [self tableViewColumnsFromArray:value];
                settingsDict[@"Value"] = value;
            } else if ( [typeString isEqualToString:@"Dict"] ) {
                manifestDict[PFCManifestKeyAvailableValues] = @[ key ];
                manifestDict[PFCManifestKeyValueKeys] = @{ key : [self manifestArrayFromDict:value settingsDict:&settingsDict] };
            } else if ( [typeString isEqualToString:@"Boolean"] ) {
                settingsDict[@"Value"] = value;
            } else {
                settingsDict[@"Value"] = value;
            }
            settingsDict[identifier] = settingsDict ?: @{};
        } else {
            NSLog(@"[ERROR] TypeString was empty!");
            continue;
        }
        [manifestArray addObject:[manifestDict copy]];
    }
    
    return [manifestArray copy];
} // manifestArrayFromDict:settingsDict

+ (NSArray *)tableViewColumnsFromArray:(NSArray *)array {
    NSMutableArray *tableViewColumns = [[NSMutableArray alloc] init];
    NSString *typeString = [self typeStringFromValue:[array firstObject]];
    if ( [typeString isEqualToString:@"String"] ) {
        [tableViewColumns addObject:@{ PFCManifestKeyCellType : [self cellTypeFromTypeString:typeString] }];
    }
    return [tableViewColumns copy];
} // tableViewColumnsFromArray

+ (BOOL)hideKey:(NSString *)key {
    
    // FIXME - Move keysToHide to plist and write preferences.
    // This should be a user setting under preferences.
    // List all "default" disabled, and user can override by adding their own or disable some or all hiding
    
    NSArray *keysToHide = @[
                           @"NSWindow Frame",
                           @"NSNavPanelExpandedSizeForOpenMode",
                           @"NSNavPanelExpandedSizeForSaveMode",
                           @"NSNavPanelExpandedStateForSaveMode",
                           @"NSNavLastRootDirectory"
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
    if ( [typeString isEqualToString:@"String"] )   return @"TextField";
    if ( [typeString isEqualToString:@"Boolean"] )  return @"Checkbox";
    if ( [typeString isEqualToString:@"Integer"] )   return @"TextFieldNumber";
    if ( [typeString isEqualToString:@"Float"] )   return @"TextFieldNumber";
    if ( [typeString isEqualToString:@"Array"] )    return @"TableView";
    if ( [typeString isEqualToString:@"Dict"] )     return @"SegmentedControl";
    if ( [typeString isEqualToString:@"Date"] )     return @"TextFieldDate";
    if ( [typeString isEqualToString:@"Data"] )     return @"File";
    return @"Unknown";
} // cellTypeFromTypeString

@end
