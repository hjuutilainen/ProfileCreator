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

+ (NSDictionary *)manifestForPlistAtURL:(NSURL *)fileURL {
    NSMutableDictionary *manifestDict = [[NSMutableDictionary alloc] init];
    
    [manifestDict addEntriesFromDictionary:[self manifestMenuForPlistAtURL:fileURL]];
    manifestDict[@"PayloadKeys"] = [self manifestSettingsForPlistAtURL:fileURL];
    
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

+ (NSArray *)manifestSettingsForPlistAtURL:(NSURL *)fileURL {
    return [self arrayFromDict:[NSDictionary dictionaryWithContentsOfURL:fileURL] ?: @{}];
}

+ (NSArray *)arrayFromDict:(NSDictionary *)dict {
    NSMutableArray *manifestArray = [[NSMutableArray alloc] init];
    NSArray *dictKeys = [dict allKeys];
    for ( NSString *key in dictKeys ) {
        if ( @YES ) {
            if ( [self isAppleKey:key] ) {
                NSLog(@"%@ is an Apple key, ignoring...", key);
                continue;
            }
        }
        NSMutableDictionary *manifestDict = [[NSMutableDictionary alloc] init];
        manifestDict[@"Enabled"] = @YES;
        manifestDict[@"Key"] = key;
        manifestDict[@"Title"] = key;
        id value = dict[key];
        NSString *typeString = [self typeStringFromValue:value];
        if ( [typeString length] != 0 ) {
            manifestDict[@"Type"] = typeString;
            manifestDict[@"CellType"] = [self cellTypeFromTypeString:typeString];
            manifestDict[@"Description"] = @"No Description";
            if ( [typeString isEqualToString:@"Array"] ) {
                manifestDict[@"TableViewColumns"] = [self tableViewColumnsFromArray:value];
                manifestDict[@"Value"] = value;
            } else if ( [typeString isEqualToString:@"Dict"] ) {
                manifestDict[@"AvailableValues"] = @[ key ];
                manifestDict[@"ValueKeys"] = @{ key : [self arrayFromDict:value] };
            } else if ( [typeString isEqualToString:@"Boolean"] ) {
                //manifestDict[@"FontWeight"] = @"Bold";
                //manifestDict[@"IndentLeft"] = @YES;
                manifestDict[@"Value"] = value;
            } else {
                manifestDict[@"Value"] = value;
            }
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
        // Figure out what kind
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
    if ( [typeString isEqualToString:@"Number"] )   return @"TextFieldNumber";
    if ( [typeString isEqualToString:@"Array"] )    return @"TableView";
    if ( [typeString isEqualToString:@"Dict"] )     return @"SegmentedControl";
    if ( [typeString isEqualToString:@"Date"] )     return @"TextFieldDate";
    if ( [typeString isEqualToString:@"Data"] )     return @"File";
    return @"Unknown";
}

@end
