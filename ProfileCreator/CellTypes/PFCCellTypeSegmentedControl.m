//
//  PFCCellTypeSegmentedControl.m
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

#import "PFCCellTypeSegmentedControl.h"
#import "PFCConstants.h"
#import "PFCProfileEditor.h"

@interface PFCSegmentedControlCellView ()

@end

@implementation PFCSegmentedControlCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (PFCSegmentedControlCellView *)populateCellView:(PFCSegmentedControlCellView *)cellView
                                         manifest:(NSDictionary *)manifest
                                         settings:(NSDictionary *)settings
                                    settingsLocal:(NSDictionary *)settingsLocal
                                      displayKeys:(NSDictionary *)displayKeys
                                              row:(NSInteger)row
                                           sender:(id)sender {

    // ---------------------------------------------------------------------
    //  Reset Segmented Control
    // ---------------------------------------------------------------------
    [[cellView settingSegmentedControl] setSegmentCount:0];

    // ---------------------------------------------------------------------
    //  Segmented Control Titles
    // ---------------------------------------------------------------------
    NSArray *availableSelections = manifest[PFCManifestKeyAvailableValues] ?: @[];
    [[cellView settingSegmentedControl] setSegmentCount:(NSInteger)[availableSelections count]];
    [availableSelections enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
      [[cellView settingSegmentedControl] setLabel:obj forSegment:(NSInteger)idx];
    }];

    // ---------------------------------------------------------------------
    //  Select saved selection or 0 if never saved
    // ---------------------------------------------------------------------
    [[cellView settingSegmentedControl] setSelected:YES forSegment:[manifest[PFCSettingsKeyValue] integerValue] ?: 0];

    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [[cellView settingSegmentedControl] setAction:@selector(segmentedControl:)];
    [[cellView settingSegmentedControl] setTarget:sender];
    [[cellView settingSegmentedControl] setTag:row];

    return cellView;
} // populateCellViewSettingsSegmentedControl:manifest:row:sender

@end
