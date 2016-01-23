//
//  PFCManifestTools.m
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

#import "PFCManifestUtility.h"
#import "PFCConstants.h"

@implementation PFCManifestUtility

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initialization
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

+ (id)sharedUtility {
    // FIXME - Unsure if this has to be a singleton, figured it would be used alot and then not keep alloc/deallocing all the time
    static PFCManifestUtility *sharedTools = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedTools = [[self alloc] init];
    });
    return sharedTools;
} // sharedParser

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Utility Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSImage *)iconForManifest:(NSDictionary *)manifest {
    
    NSImage *icon = [[NSBundle mainBundle] imageForResource:manifest[PFCManifestKeyIconName]];
    if ( icon ) {
        return icon;
    }
    
    NSURL *iconURL = [NSURL fileURLWithPath:manifest[PFCManifestKeyIconPath] ?: @""];
    if ( [iconURL checkResourceIsReachableAndReturnError:nil] ) {
        NSImage *icon = [[NSImage alloc] initWithContentsOfURL:iconURL];
        if ( icon ) {
            return icon;
        }
    }
    
    iconURL = [NSURL fileURLWithPath:manifest[PFCManifestKeyIconPathBundle] ?: @""];
    if ( [iconURL checkResourceIsReachableAndReturnError:nil] ) {
        NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:[iconURL path]];
        if ( icon ) {
            return icon;
        }
    }
    
    // FIXME - Should probaby return a bundled default icon.
    return nil;
} // iconForManifest

- (BOOL)hideKey:(NSString *)key {
    
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

- (NSString *)typeStringFromValue:(id)value {
    id valueClass = [value class];
    if ( [value isKindOfClass:[NSString class]] )       return PFCValueTypeString;
    if ( [valueClass isEqualTo:[@(YES) class]] )        return PFCValueTypeBoolean;
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
        
        if ( numberType <= 4 )                          return PFCValueTypeInteger;
        if ( 5 <= numberType && numberType <= 6 )       return PFCValueTypeFloat;
        
        NSLog(@"[ERROR] Unknown CFNumberType: %ld", numberType);
        return @"Number";
    }
    if ( [value isKindOfClass:[NSArray class]] )        return PFCValueTypeArray;
    if ( [value isKindOfClass:[NSDictionary class]] )   return PFCValueTypeDict;
    if ( [value isKindOfClass:[NSDate class]] )         return PFCValueTypeDate;
    if ( [value isKindOfClass:[NSData class]] )         return PFCValueTypeData;
    return @"Unknown";
} // typeStringFromValue

- (NSString *)cellTypeFromTypeString:(NSString *)typeString {
    if ( [typeString isEqualToString:PFCValueTypeString] )   return PFCCellTypeTextField;
    if ( [typeString isEqualToString:PFCValueTypeBoolean] )  return PFCCellTypeCheckbox;
    if ( [typeString isEqualToString:PFCValueTypeInteger] )  return PFCCellTypeTextFieldNumber;
    if ( [typeString isEqualToString:PFCValueTypeFloat] )    return PFCCellTypeTextFieldNumber;
    if ( [typeString isEqualToString:PFCValueTypeArray] )    return PFCCellTypeTableView;
    if ( [typeString isEqualToString:PFCValueTypeDict] )     return PFCCellTypeSegmentedControl;
    if ( [typeString isEqualToString:PFCValueTypeDate] )     return PFCCellTypeDatePicker;
    if ( [typeString isEqualToString:PFCValueTypeData] )     return PFCCellTypeFile;
    return @"Unknown";
} // cellTypeFromTypeString

@end
