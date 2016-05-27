//
//  PFCCellTypeDatePicker.m
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

#import "PFCAvailability.h"
#import "PFCCellTypeDatePicker.h"
#import "PFCCellTypes.h"
#import "PFCConstants.h"
#import "PFCError.h"
#import "PFCGeneralUtility.h"
#import "PFCLog.h"
#import "PFCManifestLint.h"
#import "PFCManifestUtility.h"
#import "PFCProfileEditor.h"
#import "PFCProfileExport.h"

@interface PFCDatePickerCellView ()

@property (strong) IBOutlet NSLayoutConstraint *constraintLeading;
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSTextField *settingDateDescription;

@end

@implementation PFCDatePickerCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (instancetype)populateCellView:(PFCDatePickerCellView *)cellView
             manifestContentDict:(NSDictionary *)manifestContentDict
                        manifest:(NSDictionary *)manifest
                        settings:(NSDictionary *)settings
                    settingsUser:(NSDictionary *)settingsUser
                   settingsLocal:(NSDictionary *)settingsLocal
                     displayKeys:(NSDictionary *)displayKeys
                             row:(NSInteger)row
                          sender:(id)sender {

    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [[PFCAvailability sharedInstance] requiredForManifestContentDict:manifestContentDict displayKeys:displayKeys];

    BOOL enabled = YES;
    if (!required && settingsUser[PFCSettingsKeyEnabled] != nil) {
        enabled = [settingsUser[PFCSettingsKeyEnabled] boolValue];
    }

    BOOL supervisedOnly = [manifestContentDict[PFCManifestKeySupervisedOnly] boolValue];

    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:[NSString stringWithFormat:@"%@%@", manifestContentDict[PFCManifestKeyTitle], (supervisedOnly) ? @" (supervised only)" : @""] ?: @""];
    if (enabled) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }

    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifestContentDict[PFCManifestKeyDescription] ?: @""];

    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSDate *date;
    if (settingsUser[PFCSettingsKeyValue] != nil) {
        date = settingsUser[PFCSettingsKeyValue] ?: [NSDate date];
    } else if (manifestContentDict[PFCManifestKeyDefaultValue]) {
        date = manifestContentDict[PFCManifestKeyDefaultValue] ?: [NSDate date];
    } else if (settingsLocal[PFCSettingsKeyValue]) {
        date = settingsLocal[PFCSettingsKeyValue] ?: [NSDate date];
    }
    [[cellView settingDatePicker] setDateValue:date ?: [NSDate date]];

    // ---------------------------------------------------------------------
    //  Indentation
    // ---------------------------------------------------------------------
    if ([manifestContentDict[PFCManifestKeyIndentLeft] boolValue]) {
        [[cellView constraintLeading] setConstant:120];
    } else if (manifestContentDict[PFCManifestKeyIndentLevel] != nil) {
        NSInteger constraintConstant = [[PFCManifestUtility sharedUtility] constantForIndentationLevel:[manifestContentDict[PFCManifestKeyIndentLevel] integerValue] baseConstant:112 offset:0];
        [[cellView constraintLeading] setConstant:constraintConstant];
    } else {
        [[cellView constraintLeading] setConstant:112];
    }

    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifestContentDict] ?: @""];

    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingDatePicker] setAction:@selector(datePickerSelection:)];
    [[cellView settingDatePicker] setTarget:sender];
    [[cellView settingDatePicker] setTag:row];

    // ---------------------------------------------------------------------
    //  Set minimum value selectable by offset from now
    // ---------------------------------------------------------------------
    if (manifestContentDict[PFCManifestKeyMinValueOffsetDays] != nil || manifestContentDict[PFCManifestKeyMinValueOffsetHours] != nil ||
        manifestContentDict[PFCManifestKeyMinValueOffsetMinutes] != nil) {

        NSInteger days = [manifestContentDict[PFCManifestKeyMinValueOffsetDays] integerValue] ?: 0;
        NSInteger hours = [manifestContentDict[PFCManifestKeyMinValueOffsetHours] integerValue] ?: 0;
        NSInteger minutes = [manifestContentDict[PFCManifestKeyMinValueOffsetMinutes] integerValue] ?: 0;

        NSCalendar *calendarUS = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [calendarUS setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [calendarUS setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setDay:days];
        [offsetComponents setHour:hours];
        [offsetComponents setMinute:minutes];
        NSDate *dateTomorrow = [calendarUS dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
        [[cellView settingDatePicker] setMinDate:dateTomorrow];
    }

    // ---------------------------------------------------------------------
    //  Set date picker elements
    // ---------------------------------------------------------------------
    if ([manifestContentDict[PFCManifestKeyShowDateTime] boolValue]) {
        [[cellView settingDatePicker] setDatePickerElements:NSYearMonthDayDatePickerElementFlag | NSHourMinuteDatePickerElementFlag];
    } else {
        [[cellView settingDatePicker] setDatePickerElements:NSYearMonthDayDatePickerElementFlag];
    }

    // ---------------------------------------------------------------------
    //  Date interval between now and selected date in text
    // ---------------------------------------------------------------------
    if ([manifestContentDict[PFCManifestKeyShowDateInterval] boolValue]) {
        NSDate *datePickerDate = [[cellView settingDatePicker] dateValue];
        [[cellView settingDateDescription] setStringValue:[PFCGeneralUtility dateIntervalFromNowToDate:datePickerDate] ?: @""];
    }

    return cellView;
} // populateCellViewDatePicker

+ (NSDictionary *)verifyCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings displayKeys:(NSDictionary *)displayKeys {

    // -------------------------------------------------------------------------
    //  Verify this manifest content dict contains an 'Identifier'. Else stop.
    // -------------------------------------------------------------------------
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    if (identifier.length == 0) {
        return nil;
    }

    NSDictionary *contentDictSettings = settings[identifier];
    if (contentDictSettings.count == 0) {
        DDLogDebug(@"No settings!");
    }

    BOOL required = [[PFCAvailability sharedInstance] requiredForManifestContentDict:manifestContentDict displayKeys:displayKeys];
    NSDate *value = [contentDictSettings[PFCSettingsKeyValue] dateValue];
    if (value != nil) {
        value = [contentDictSettings[PFCManifestKeyDefaultValue] dateValue];
    }

    // FIX Min/Max value check
    // If value is greater than offset days.
    // Add both min and max and "hard" value.

    if (required && value == nil) {
        return @{ identifier : @[ [PFCError verificationReportWithMessage:@"" severity:kPFCSeverityError manifestContentDict:manifestContentDict] ] };
    }

    return nil;
}

+ (void)createPayloadForCellType:(NSDictionary *)manifestContentDict
                        manifest:(NSDictionary *)manifest
                        settings:(NSDictionary *)settings
                        payloads:(NSMutableArray *__autoreleasing *)payloads
                          sender:(PFCProfileExport *)sender {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    // -------------------------------------------------------------------------
    //  Verify required keys for CellType: 'DatePicker'
    // -------------------------------------------------------------------------
    if (![sender verifyRequiredManifestContentDictKeys:@[ PFCManifestKeyIdentifier, PFCManifestKeyPayloadType, PFCManifestKeyPayloadKey ] manifestContentDict:manifestContentDict]) {
        return;
    }

    // -------------------------------------------------------------------------
    //  Get value for current PayloadKey
    // -------------------------------------------------------------------------
    NSDictionary *contentDictSettings = settings[manifestContentDict[PFCManifestKeyIdentifier]] ?: @{};

    // This might fail, should probably check some more before using 'dateValue'
    id value = contentDictSettings[PFCSettingsKeyValue];
    if (value == nil) {
        value = manifestContentDict[PFCManifestKeyDefaultValue];
    }

    // -------------------------------------------------------------------------
    //  Verify value is of the expected class type(s)
    // -------------------------------------------------------------------------
    if (value == nil || ([[value class] isSubclassOfClass:[NSDate class]] && value == nil)) {
        DDLogDebug(@"PayloadValue is empty");

        if ([manifestContentDict[PFCManifestKeyOptional] boolValue]) {
            DDLogDebug(@"PayloadKey: %@ is optional, skipping", manifestContentDict[PFCManifestKeyPayloadKey]);
            return;
        }

        value = @"";
    } else if (![[value class] isSubclassOfClass:[NSDate class]]) {
        return [sender payloadErrorForValueClass:NSStringFromClass([value class]) payloadKey:manifestContentDict[PFCManifestKeyPayloadType] exptectedClasses:@[ NSStringFromClass([NSDate class]) ]];
    } else {
        DDLogDebug(@"PayloadValue: %@", value);
    }

    // -------------------------------------------------------------------------
    //  Resolve any nested payload keys
    //  FIXME - Need to implement this for nested keys
    // -------------------------------------------------------------------------
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
    payloadDictDict[manifestContentDict[PFCManifestKeyPayloadKey]] = value;

    // -------------------------------------------------------------------------
    //  Save payload to payload array
    // -------------------------------------------------------------------------
    if (index != NSNotFound) {
        [*payloads replaceObjectAtIndex:index withObject:[payloadDictDict copy]];
    } else {
        [*payloads addObject:[payloadDictDict copy]];
    }
}

+ (NSArray *)lintReportForManifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath sender:(PFCManifestLint *)sender {
    NSMutableArray *lintReport = [[NSMutableArray alloc] init];

    NSArray *allowedTypes = @[ PFCValueTypeDate ];

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
    //  ValueOffset
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForMinValueOffsetDays:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    [lintReport addObject:[sender reportForMinValueOffsetHours:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    [lintReport addObject:[sender reportForMinValueOffsetMinutes:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  Show Date Input
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForShowDateInterval:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    [lintReport addObject:[sender reportForShowDateTime:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    return [lintReport copy];
}

@end

@interface PFCDatePickerNoTitleCellView ()

@property (strong) IBOutlet NSLayoutConstraint *constraintLeading;

@end

@implementation PFCDatePickerNoTitleCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (instancetype)populateCellView:(PFCDatePickerNoTitleCellView *)cellView
             manifestContentDict:(NSDictionary *)manifestContentDict
                        manifest:(NSDictionary *)manifest
                        settings:(NSDictionary *)settings
                    settingsUser:(NSDictionary *)settingsUser
                   settingsLocal:(NSDictionary *)settingsLocal
                     displayKeys:(NSDictionary *)displayKeys
                             row:(NSInteger)row
                          sender:(id)sender {

    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [[PFCAvailability sharedInstance] requiredForManifestContentDict:manifestContentDict displayKeys:displayKeys];

    BOOL enabled = YES;
    if (!required && settingsUser[PFCSettingsKeyEnabled] != nil) {
        enabled = [settingsUser[PFCSettingsKeyEnabled] boolValue];
    }

    // ---------------------------------------------------------------------
    //  Value
    // ---------------------------------------------------------------------
    NSDate *date;
    if (settingsUser[PFCSettingsKeyValue] != nil) {
        date = settingsUser[PFCSettingsKeyValue] ?: [NSDate date];
    } else if (manifestContentDict[PFCManifestKeyDefaultValue]) {
        date = manifestContentDict[PFCManifestKeyDefaultValue] ?: [NSDate date];
    } else if (settingsLocal[PFCSettingsKeyValue]) {
        date = settingsLocal[PFCSettingsKeyValue] ?: [NSDate date];
    }
    [[cellView settingDatePicker] setDateValue:date ?: [NSDate date]];

    // ---------------------------------------------------------------------
    //  Indentation
    // ---------------------------------------------------------------------
    if ([manifestContentDict[PFCManifestKeyIndentLeft] boolValue]) {
        [[cellView constraintLeading] setConstant:120];
    } else if (manifestContentDict[PFCManifestKeyIndentLevel] != nil) {
        NSInteger constraintConstant = [[PFCManifestUtility sharedUtility] constantForIndentationLevel:[manifestContentDict[PFCManifestKeyIndentLevel] integerValue] baseConstant:112 offset:0];
        [[cellView constraintLeading] setConstant:constraintConstant];
    } else {
        [[cellView constraintLeading] setConstant:112];
    }

    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifestContentDict] ?: @""];

    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingDatePicker] setAction:@selector(datePickerSelection:)];
    [[cellView settingDatePicker] setTarget:sender];
    [[cellView settingDatePicker] setTag:row];

    // ---------------------------------------------------------------------
    //  Set minimum value selectable by offset from now
    // ---------------------------------------------------------------------
    if (manifestContentDict[PFCManifestKeyMinValueOffsetDays] != nil || manifestContentDict[PFCManifestKeyMinValueOffsetHours] != nil ||
        manifestContentDict[PFCManifestKeyMinValueOffsetMinutes] != nil) {

        NSInteger days = [manifestContentDict[PFCManifestKeyMinValueOffsetDays] integerValue] ?: 0;
        NSInteger hours = [manifestContentDict[PFCManifestKeyMinValueOffsetHours] integerValue] ?: 0;
        NSInteger minutes = [manifestContentDict[PFCManifestKeyMinValueOffsetMinutes] integerValue] ?: 0;

        NSCalendar *calendarUS = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [calendarUS setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]];
        [calendarUS setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+0:00"]];
        NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
        [offsetComponents setDay:days];
        [offsetComponents setHour:hours];
        [offsetComponents setMinute:minutes];
        NSDate *dateTomorrow = [calendarUS dateByAddingComponents:offsetComponents toDate:[NSDate date] options:0];
        [[cellView settingDatePicker] setMinDate:dateTomorrow];
    }

    // ---------------------------------------------------------------------
    //  Set date picker elements
    // ---------------------------------------------------------------------
    if ([manifestContentDict[PFCManifestKeyShowDateTime] boolValue]) {
        [[cellView settingDatePicker] setDatePickerElements:NSYearMonthDayDatePickerElementFlag | NSHourMinuteSecondDatePickerElementFlag];
    } else {
        [[cellView settingDatePicker] setDatePickerElements:NSYearMonthDayDatePickerElementFlag];
    }

    // ---------------------------------------------------------------------
    //  Date interval between now and selected date in text
    // ---------------------------------------------------------------------
    if ([manifestContentDict[PFCManifestKeyShowDateInterval] boolValue]) {
        NSDate *datePickerDate = [[cellView settingDatePicker] dateValue];
        [[cellView settingDateDescription] setStringValue:[PFCGeneralUtility dateIntervalFromNowToDate:datePickerDate] ?: @""];
    }

    return cellView;
} // populateCellViewCheckbox:settings:row

+ (NSDictionary *)verifyCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings displayKeys:(NSDictionary *)displayKeys {
    return [PFCDatePickerCellView verifyCellType:manifestContentDict settings:settings displayKeys:displayKeys];
}

+ (void)createPayloadForCellType:(NSDictionary *)manifestContentDict
                        manifest:(NSDictionary *)manifest
                        settings:(NSDictionary *)settings
                        payloads:(NSMutableArray *__autoreleasing *)payloads
                          sender:(PFCProfileExport *)sender {
    return [PFCDatePickerCellView createPayloadForCellType:manifestContentDict manifest:manifest settings:settings payloads:payloads sender:sender];
}

+ (NSArray *)lintReportForManifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath sender:(PFCManifestLint *)sender {
    NSMutableArray *lintReport = [[NSMutableArray alloc] init];

    NSArray *allowedTypes = @[ PFCValueTypeDate ];

    // -------------------------------------------------------------------------
    //  DefaultValue
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForDefaultValueKey:PFCManifestKeyDefaultValue manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:allowedTypes]];

    // -------------------------------------------------------------------------
    //  Indentation
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForIndentLeft:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    [lintReport addObject:[sender reportForIndentLevel:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  Payload
    // -------------------------------------------------------------------------
    [lintReport addObjectsFromArray:[sender reportForPayloadKeys:nil manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:@[ PFCValueTypeDate ]]];

    // -------------------------------------------------------------------------
    //  ValueOffset
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForMinValueOffsetDays:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    [lintReport addObject:[sender reportForMinValueOffsetHours:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    [lintReport addObject:[sender reportForMinValueOffsetMinutes:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  Show Date Input
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForShowDateInterval:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    [lintReport addObject:[sender reportForShowDateTime:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    return [lintReport copy];
}

@end
