//
//  PFCCellTypeTextFieldDaysHours.m
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
#import "PFCCellTypeTextFieldDaysHours.h"
#import "PFCCellTypes.h"
#import "PFCConstants.h"
#import "PFCManifestUtility.h"
#import "PFCProfileEditorManifest.h"

@implementation PFCTextFieldDaysHoursNoTitleCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self addObserver:self forKeyPath:NSStringFromSelector(@selector(stepperValueRemovalIntervalDays)) options:NSKeyValueObservingOptionNew context:nil];
        [self addObserver:self forKeyPath:NSStringFromSelector(@selector(stepperValueRemovalIntervalHours)) options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
} // initWithCoder

- (void)dealloc {
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(stepperValueRemovalIntervalDays))];
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(stepperValueRemovalIntervalHours))];
} // dealloc

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)__unused object change:(NSDictionary *)__unused change context:(void *)__unused context {
    if ((_sender != nil && [_cellIdentifier length] != 0) && ([keyPath isEqualToString:@"stepperValueRemovalIntervalDays"] || [keyPath isEqualToString:@"stepperValueRemovalIntervalHours"])) {
        int seconds = (([_stepperValueRemovalIntervalDays intValue] * 86400) + ([_stepperValueRemovalIntervalHours intValue] * 60));
        NSMutableDictionary *settingsDict = [[(PFCProfileEditorManifest *)_sender settingsManifest] mutableCopy];
        if (seconds == 0) {
            [settingsDict removeObjectForKey:_cellIdentifier];
        } else {
            NSMutableDictionary *cellDict = [settingsDict[_cellIdentifier] mutableCopy] ?: [[NSMutableDictionary alloc] init];
            cellDict[PFCSettingsKeyValue] = @(seconds);
            settingsDict[_cellIdentifier] = cellDict;
        }
        [(PFCProfileEditorManifest *)_sender setSettingsManifest:settingsDict];
    }
} // observeValueForKeyPath

- (PFCTextFieldDaysHoursNoTitleCellView *)populateCellView:(PFCTextFieldDaysHoursNoTitleCellView *)cellView
                                                  manifest:(NSDictionary *)manifest
                                                  settings:(NSDictionary *)settings
                                             settingsLocal:(NSDictionary *)settingsLocal
                                               displayKeys:(NSDictionary *)displayKeys
                                                       row:(NSInteger)row
                                                    sender:(id)sender {

    // -------------------------------------------------------------------------
    //  Set sender and sender properties to be used later
    // -------------------------------------------------------------------------
    [self setSender:sender];
    [self setCellIdentifier:manifest[PFCManifestKeyIdentifier] ?: @""];

    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [[PFCAvailability sharedInstance] requiredForManifestContentDict:manifest displayKeys:displayKeys];

    BOOL enabled = YES;
    if (!required && settings[PFCSettingsKeyEnabled] != nil) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }

    // -------------------------------------------------------------------------
    //  Initialize text fields from settings
    // -------------------------------------------------------------------------
    if (_stepperValueRemovalIntervalHours == nil || _stepperValueRemovalIntervalHours == nil) {
        NSNumber *seconds;
        if (settings[PFCSettingsKeyValue] != nil) {
            seconds = settings[PFCSettingsKeyValue] ?: @0;
        } else {
            seconds = settingsLocal[PFCSettingsKeyValue] ?: @0;
        }

        NSCalendar *calendarUS = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
        [calendarUS setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
        NSUInteger unitFlags = NSCalendarUnitDay | NSCalendarUnitHour;

        NSDate *startDate = [NSDate date];
        NSDate *endDate = [startDate dateByAddingTimeInterval:[seconds doubleValue]];

        NSDateComponents *components = [calendarUS components:unitFlags fromDate:startDate toDate:endDate options:0];
        [self setStepperValueRemovalIntervalDays:@([components day]) ?: @0];
        [self setStepperValueRemovalIntervalHours:@([components hour]) ?: @0];
    }

    // ---------------------------------------------------------------------
    //  Days
    // ---------------------------------------------------------------------
    [[cellView settingDays] setEnabled:enabled];
    [[cellView settingDays] setTag:row];
    [[cellView settingStepperDays] bind:NSValueBinding
                               toObject:self
                            withKeyPath:NSStringFromSelector(@selector(stepperValueRemovalIntervalDays))
                                options:@{
                                    NSContinuouslyUpdatesValueBindingOption : @YES
                                }];

    // ---------------------------------------------------------------------
    //  Hours
    // ---------------------------------------------------------------------
    [[cellView settingHours] setEnabled:enabled];
    [[cellView settingHours] setTag:row];
    [[cellView settingHours] bind:NSValueBinding
                         toObject:self
                      withKeyPath:NSStringFromSelector(@selector(stepperValueRemovalIntervalHours))
                          options:@{
                              NSContinuouslyUpdatesValueBindingOption : @YES
                          }];
    [[cellView settingStepperHours] bind:NSValueBinding
                                toObject:self
                             withKeyPath:NSStringFromSelector(@selector(stepperValueRemovalIntervalHours))
                                 options:@{
                                     NSContinuouslyUpdatesValueBindingOption : @YES
                                 }];

    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifest] ?: @""];

    return cellView;
} // populateCellViewSettingsTextFieldDaysHoursNoTitle:settingsDict:row

@end
