//
//  PFCTableViewCellTypeTextField.m
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

#import "PFCConstants.h"
#import "PFCLog.h"
#import "PFCProfileExport.h"
#import "PFCTableViewCellTypeTextField.h"

@interface PFCTableViewTextFieldCellView ()
@property (readwrite) NSString *columnIdentifier;
@end

@implementation PFCTableViewTextFieldCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (instancetype)populateTableViewCellView:(id)cellView
                                 settings:(NSDictionary *)settings
                               columnDict:(NSDictionary *)columnDict
                         columnIdentifier:(NSString *)columnIdentifier
                                      row:(NSInteger)row
                                   sender:(id)sender {

    // ---------------------------------------------------------------------
    //  ColumnIdentifier
    // ---------------------------------------------------------------------
    [cellView setColumnIdentifier:columnIdentifier];

    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSString *value = settings[PFCSettingsKeyValue] ?: @"";
    if ([value length] == 0) {
        if ([settings[@"DefaultValue"] length] != 0) {
            value = settings[@"DefaultValue"] ?: @"";
        }
    }
    [[cellView textField] setDelegate:sender];
    [[cellView textField] setStringValue:value];
    [[cellView textField] setTag:row];

    // ---------------------------------------------------------------------
    //  Placeholder Value
    // ---------------------------------------------------------------------
    if ([columnDict[PFCManifestKeyPlaceholderValue] length] != 0) {
        [[cellView textField] setPlaceholderString:columnDict[PFCManifestKeyPlaceholderValue] ?: @""];
    } else {
        [[cellView textField] setPlaceholderString:columnDict[PFCManifestKeyTitle] ?: @""];
    }

    /*
    else if (required) {
        [[cellView settingTextField] setPlaceholderString:@"Required"];
    } else if (optional) {
        [[cellView settingTextField] setPlaceholderString:@"Optional"];
    }
*/
    return cellView;
}

+ (id)valueForCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings sender:(PFCProfileExport *)sender {

    // -------------------------------------------------------------------------
    //  Get value for current PayloadKey
    // -------------------------------------------------------------------------
    NSDictionary *contentDictSettings = settings[manifestContentDict[PFCManifestKeyIdentifier]] ?: @{};
    id value = contentDictSettings[PFCSettingsKeyValue];
    if (value == nil) {
        value = manifestContentDict[PFCManifestKeyDefaultValue];
    }

    // -------------------------------------------------------------------------
    //  Verify value is of the expected class type(s)
    // -------------------------------------------------------------------------
    if (value == nil || ([[value class] isSubclassOfClass:[NSString class]] && [value length] == 0)) {
        DDLogDebug(@"PayloadValue is empty");

        if ([manifestContentDict[PFCManifestKeyOptional] boolValue]) {
            DDLogDebug(@"PayloadKey: %@ is optional, skipping", manifestContentDict[PFCManifestKeyPayloadKey]);
            return nil;
        }

        value = @"";
    } else if (![[value class] isSubclassOfClass:[NSString class]]) {
        [sender payloadErrorForValueClass:NSStringFromClass([value class]) payloadKey:manifestContentDict[PFCManifestKeyPayloadType] exptectedClasses:@[ NSStringFromClass([NSString class]) ]];
        return nil;
    } else {
        DDLogDebug(@"PayloadValue: %@", value);
    }

    return value;
}

+ (void)createPayloadForCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings payloadDict:(NSMutableDictionary **)payloadDict sender:(PFCProfileExport *)sender {

    id value = [self.class valueForCellType:manifestContentDict settings:settings sender:sender];
    if (value != nil) {
        // -------------------------------------------------------------------------
        //  Resolve any nested payload keys
        //  FIXME - Need to implement this for nested keys
        // -------------------------------------------------------------------------
        // NSString *payloadParentKey = payloadDict[PFCManifestParentKey];

        // -------------------------------------------------------------------------
        //  Add current key and value to payload
        // -------------------------------------------------------------------------
        NSAssert([[value class] isSubclassOfClass:[NSString class]], @"Value is not subclass of NSString.");
        [*payloadDict setObject:value forKey:manifestContentDict[PFCManifestKeyPayloadKey]];
    }
}

@end
