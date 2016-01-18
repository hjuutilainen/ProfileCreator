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
    manifestDict[PFCRuntimeManifestKeyValuePlistPath] = [fileURL path];
    return [manifestDict copy];
}

+ (NSDictionary *)manifestMenuForPlistAtURL:(NSURL *)fileURL {
    NSMutableDictionary *manifestMenuDict = [[NSMutableDictionary alloc] init];
    
    manifestMenuDict[@"CellType"] = @"Menu";
    manifestMenuDict[@"Description"] = @"Not Configured";
    
    NSString *domain = [[fileURL lastPathComponent] stringByDeletingPathExtension] ?: @"";
    if ( [domain length] != 0 ) {
        manifestMenuDict[@"Domain"] = domain;
        manifestMenuDict[@"Title"] = domain;
        
        NSError *error = nil;
        NSURL *bundleURL = [(__bridge NSArray *)(LSCopyApplicationURLsForBundleIdentifier((__bridge CFStringRef _Nonnull)(domain), NULL)) firstObject];
        if ( [bundleURL checkResourceIsReachableAndReturnError:&error] ) {
            NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
            if ( bundle != nil ) {
                NSString *bundleName = [bundle objectForInfoDictionaryKey:@"CFBundleName"];
                if ( [bundleName length] != 0 ) {
                    manifestMenuDict[@"Title"] = bundleName;
                }
                
                NSImage *bundleIcon = [[NSWorkspace sharedWorkspace] iconForFile:[bundleURL path]];
                if ( bundleIcon ) {
                    manifestMenuDict[@"IconPathBundle"] = [bundleURL path];
                }
            }
        }
    }
    
    return [manifestMenuDict copy];
}

+ (NSArray *)manifestArrayForPlistAtURL:(NSURL *)fileURL settingsDict:(NSMutableDictionary **)settingsDict {
    return [self manifestArrayFromDict:[NSDictionary dictionaryWithContentsOfURL:fileURL] ?: @{} settingsDict:settingsDict];
}

+ (NSArray *)manifestArrayFromDict:(NSDictionary *)dict settingsDict:(NSMutableDictionary **)settingsDict {
    NSMutableArray *manifestArray = [[NSMutableArray alloc] init];
    NSArray *dictKeys = [dict allKeys];
    for ( NSString *key in dictKeys ) {
        if ( @YES ) { // For a setting to allow ALL keys to be seen
            if ( [self isAppleKey:key] ) {
                //NSLog(@"%@ is an Apple key, ignoring...", key);
                continue;
            }
        }
        NSMutableDictionary *manifestDict = [[NSMutableDictionary alloc] init];
        manifestDict[@"Enabled"] = @YES;
        manifestDict[@"Key"] = key;
        manifestDict[@"Title"] = key;
        NSString *identifier = [[NSUUID UUID] UUIDString];
        manifestDict[@"Identifier"] = identifier;
        id value = dict[key];
        NSString *typeString = [self typeStringFromValue:value];
        if ( [typeString length] != 0 ) {
            manifestDict[@"Type"] = typeString;
            manifestDict[@"CellType"] = [self cellTypeFromTypeString:typeString];
            manifestDict[@"Description"] = @"No Description";
            
            NSMutableDictionary *settingsDict = [[NSMutableDictionary alloc] init];
            // Read Settings
            if ( [typeString isEqualToString:@"Array"] ) {
                manifestDict[@"TableViewColumns"] = [self tableViewColumnsFromArray:value];
                
                settingsDict[@"Value"] = value;
            } else if ( [typeString isEqualToString:@"Dict"] ) {
                manifestDict[@"AvailableValues"] = @[ key ];
                settingsDict[@"ValueKeys"] = @{ key : [self manifestArrayFromDict:value settingsDict:&settingsDict] };
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
}

+ (NSArray *)tableViewColumnsFromArray:(NSArray *)array {
    NSMutableArray *tableViewColumns = [[NSMutableArray alloc] init];
    NSString *typeString = [self typeStringFromValue:[array firstObject]];
    if ( [typeString isEqualToString:@"String"] ) {
        [tableViewColumns addObject:@{ @"CellType" : [self cellTypeFromTypeString:typeString] }];
    }
    return [tableViewColumns copy];
}

+ (BOOL)isAppleKey:(NSString *)key {
    NSArray *appleKeys = @[
                           @"NSWindow Frame",
                           @"NSNavPanelExpandedSizeForOpenMode",
                           @"NSNavPanelExpandedSizeForSaveMode",
                           @"NSNavPanelExpandedStateForSaveMode",
                           @"NSNavLastRootDirectory"
                           ];
    __block BOOL isAppleKey = NO;
    [appleKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( [key hasPrefix:obj] ) {
            isAppleKey = YES;
            *stop = YES;
        }
    }];
    return isAppleKey;
}

+ (NSDictionary *)dictFromDict:(NSDictionary *)dict {
    NSMutableDictionary *returnDict = [[NSMutableDictionary alloc] init];
    
    
    
    return [returnDict copy];
}

+ (NSDictionary *)dictFromArray:(NSArray *)array {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    
    
    return [dict copy];
}

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
}

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
}

@end
