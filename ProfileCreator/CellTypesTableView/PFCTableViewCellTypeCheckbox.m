//
//  PFCTableViewCellTypeCheckbox.m
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
#import "PFCTableViewCellTypeCheckbox.h"
#import "PFCTableViewCellTypeProtocol.h"

@interface PFCTableViewCheckboxCellView ()

@property (readwrite) NSString *columnIdentifier;

@end

@implementation PFCTableViewCheckboxCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (instancetype)populateTableViewCellView:(id)cellView settings:(NSDictionary *)settings columnIdentifier:(NSString *)columnIdentifier row:(NSInteger)row sender:(id)sender {

    // ---------------------------------------------------------------------
    //  ColumnIdentifier
    // ---------------------------------------------------------------------
    [cellView setColumnIdentifier:columnIdentifier];

    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    BOOL checkboxState = NO;
    if (settings[PFCSettingsKeyValue] != nil) {
        checkboxState = [settings[PFCSettingsKeyValue] boolValue];
    } else if (settings[@"DefaultValue"]) {
        checkboxState = [settings[@"DefaultValue"] boolValue];
    }
    [[cellView checkbox] setState:checkboxState];

    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView checkbox] setAction:@selector(checkbox:)];
    [[cellView checkbox] setTarget:sender];
    [[cellView checkbox] setTag:row];

    return cellView;
}

/*
+ (NSDictionary *)verifyCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings displayKeys:(NSDictionary *)displayKeys {

NSString *checkboxState = [settings[PFCSettingsKeyValue] boolValue] ? @"True" : @"False";
NSDictionary *valueKeys = manifestContentDict[PFCManifestKeyValueKeys];
if (valueKeys[checkboxState]) {
    return [[PFCManifestParser sharedParser] settingsErrorForManifestContent:valueKeys[checkboxState] settings:settings displayKeys:displayKeys];
}

return nil;
}

+ (void)createPayloadForCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings payloads:(NSMutableArray *__autoreleasing *)payloads sender:(PFCProfileExport *)sender {
// -------------------------------------------------------------------------
//  Verify required keys for CellType: 'Checkbox'
// -------------------------------------------------------------------------
if (![sender verifyRequiredManifestContentDictKeys:@[ PFCManifestKeyIdentifier, PFCManifestKeyPayloadType, PFCManifestKeyPayloadKey ] manifestContentDict:manifestContentDict]) {
    return;
}

// -------------------------------------------------------------------------
//  Get value for Checkbox
// -------------------------------------------------------------------------
NSDictionary *contentDictSettings = settings[manifestContentDict[PFCManifestKeyIdentifier]] ?: @{};
id value = contentDictSettings[PFCSettingsKeyValue];
if (value == nil) {
    value = manifestContentDict[PFCManifestKeyDefaultValue];
}

// -------------------------------------------------------------------------
//  Verify CheckboxValue is of the expected class type(s)
// -------------------------------------------------------------------------
BOOL checkboxState = NO;
if (value == nil) {
    DDLogWarn(@"CheckboxValue is empty");

    if ([manifestContentDict[PFCManifestKeyOptional] boolValue]) {
        DDLogDebug(@"PayloadKey: %@ is optional, skipping", manifestContentDict[PFCManifestKeyPayloadKey]);
        return;
    }
} else if (![[value class] isEqualTo:[@(YES) class]] && ![[value class] isEqualTo:[@(0) class]]) {
    return [sender payloadErrorForValueClass:NSStringFromClass([value class])
                                  payloadKey:manifestContentDict[PFCManifestKeyPayloadType]
                            exptectedClasses:@[ NSStringFromClass([@(YES) class]), NSStringFromClass([@(0) class]) ]];
} else {
    checkboxState = [(NSNumber *)value boolValue];
    DDLogDebug(@"CheckboxValue: %@", (checkboxState) ? @"YES" : @"NO");
}

// ---------------------------------------------------------------------
//  Resolve any nested payload keys
//  FIXME - Need to implement this for nested keys
// ---------------------------------------------------------------------
// NSString *payloadParentKey = payloadDict[PFCManifestParentKey];

// -------------------------------------------------------------------------
//  Get index of current payload in payload array
// -------------------------------------------------------------------------
NSUInteger index = [*payloads indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
  return [item[PFCManifestKeyPayloadUUID] isEqualToString:settings[manifestContentDict[PFCManifestKeyPayloadType]][PFCProfileTemplateKeyUUID] ?: @""];
}];

// ----------------------------------------------------------------------------------
//  Create mutable version of current payload, or create new payload if none existed
// ----------------------------------------------------------------------------------
NSMutableDictionary *payloadDictDict;
if (index != NSNotFound) {
    payloadDictDict = [[*payloads objectAtIndex:index] mutableCopy];
} else {
    payloadDictDict = [sender payloadRootFromManifest:manifestContentDict settings:settings payloadType:nil payloadUUID:nil];
}

// -------------------------------------------------------------------------
//  Add current key and value to payload
// -------------------------------------------------------------------------
payloadDictDict[manifestContentDict[PFCManifestKeyPayloadKey]] = @(checkboxState);

// -------------------------------------------------------------------------
//  Save payload to payload array
// -------------------------------------------------------------------------
if (index != NSNotFound) {
    [*payloads replaceObjectAtIndex:index withObject:[payloadDictDict copy]];
} else {
    [*payloads addObject:[payloadDictDict copy]];
}

// -------------------------------------------------------------------------
//
// -------------------------------------------------------------------------
[sender createPayloadFromValueKey:(checkboxState) ? @"True" : @"False"
                  availableValues:manifestContentDict[PFCManifestKeyAvailableValues]
              manifestContentDict:manifestContentDict
                         settings:settings
                       payloadKey:nil
                      payloadType:nil
                      payloadUUID:nil
                         payloads:payloads];
}

+ (NSArray *)lintReportForManifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath sender:(PFCManifestLint *)sender {
NSMutableArray *lintReport = [[NSMutableArray alloc] init];

NSArray *allowedTypes = @[ PFCValueTypeBoolean ];

// -------------------------------------------------------------------------
//  DefaultValue
// -------------------------------------------------------------------------
[lintReport addObject:[sender reportForDefaultValueKey:PFCManifestKeyDefaultValue manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:allowedTypes]];

// -------------------------------------------------------------------------
//  Title/Description
// -------------------------------------------------------------------------
[lintReport addObject:[sender reportForTitle:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
[lintReport addObject:[sender reportForDescription:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

// -------------------------------------------------------------------------
//  Indentation
// -------------------------------------------------------------------------
[lintReport addObject:[sender reportForIndentLeft:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
[lintReport addObject:[sender reportForIndentLevel:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

// -------------------------------------------------------------------------
//  Payload
// -------------------------------------------------------------------------
[lintReport addObjectsFromArray:[sender reportForPayloadKeys:nil manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:allowedTypes]];

// -------------------------------------------------------------------------
//  ValueKeys
// -------------------------------------------------------------------------
[lintReport addObjectsFromArray:[sender reportForValueKeys:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath required:NO availableValues:@[ @"True", @"False" ]]];

return [lintReport copy];
}
*/
@end
