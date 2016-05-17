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
#import "PFCLog.h"
#import "PFCManifestLint.h"
#import "PFCManifestParser.h"
#import "PFCProfileEditor.h"
#import "PFCProfileExport.h"

@interface PFCSegmentedControlCellView ()

@end

@implementation PFCSegmentedControlCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
} // drawRect

- (instancetype)populateCellView:(PFCSegmentedControlCellView *)cellView
             manifestContentDict:(NSDictionary *)manifestContentDict
                        manifest:(NSDictionary *)manifest
                        settings:(NSDictionary *)settings
                   settingsLocal:(NSDictionary *)settingsLocal
                     displayKeys:(NSDictionary *)displayKeys
                             row:(NSInteger)row
                          sender:(id)sender {

    // ---------------------------------------------------------------------
    //  Reset Segmented Control
    // ---------------------------------------------------------------------
    [cellView.settingSegmentedControl setSegmentCount:0];

    // ---------------------------------------------------------------------
    //  Segmented Control Titles
    // ---------------------------------------------------------------------
    NSArray *availableSelections = manifest[PFCManifestKeyAvailableValues] ?: @[];
    [cellView.settingSegmentedControl setSegmentCount:(NSInteger)availableSelections.count];
    [availableSelections enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
      [cellView.settingSegmentedControl setLabel:obj forSegment:(NSInteger)idx];
    }];

    // ---------------------------------------------------------------------
    //  Select saved selection or 0 if never saved
    // ---------------------------------------------------------------------
    [cellView.settingSegmentedControl setSelected:YES forSegment:[manifest[PFCSettingsKeyValue] integerValue] ?: 0];

    // ---------------------------------------------------------------------
    //  Target Action
    // ---------------------------------------------------------------------
    [cellView.settingSegmentedControl setAction:@selector(segmentedControl:)];
    [cellView.settingSegmentedControl setTarget:sender];
    [cellView.settingSegmentedControl setTag:row];

    return cellView;
} // populateCellViewSettingsSegmentedControl:manifest:row:sender

+ (NSDictionary *)verifyCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings displayKeys:(NSDictionary *)displayKeys {
    NSMutableDictionary *report = [[NSMutableDictionary alloc] init];
    NSDictionary *valueKeys = manifestContentDict[PFCManifestKeyValueKeys];
    for (NSString *selection in manifestContentDict[PFCManifestKeyAvailableValues] ?: @[]) {
        NSDictionary *settingsError = [[PFCManifestParser sharedParser] settingsErrorForManifestContent:valueKeys[selection] settings:settings displayKeys:displayKeys];
        if (settingsError.count != 0) {
            [report addEntriesFromDictionary:settingsError];
        }
    }
    return [report copy];
}

+ (void)createPayloadForCellType:(NSDictionary *)manifestContentDict
                        manifest:(NSDictionary *)manifest
                        settings:(NSDictionary *)settings
                        payloads:(NSMutableArray *__autoreleasing *)payloads
                          sender:(id)sender {

    // -------------------------------------------------------------------------
    //  Verify required keys for CellType: 'SegmentedControl'
    // -------------------------------------------------------------------------
    if (![sender verifyRequiredManifestContentDictKeys:@[ PFCManifestKeyAvailableValues, PFCManifestKeyValueKeys ] manifestContentDict:manifestContentDict]) {
        return;
    }

    // -------------------------------------------------------------------------
    //  Verify AvailableValues isn't empty
    // -------------------------------------------------------------------------
    NSArray *availableValues = manifestContentDict[PFCManifestKeyAvailableValues] ?: @[];
    if (availableValues.count == 0) {
        DDLogError(@"AvailableValues is empty");
        return;
    }

    // -------------------------------------------------------------------------
    //  Verify ValueKeys isn't empty
    // -------------------------------------------------------------------------
    NSDictionary *valueKeys = manifestContentDict[PFCManifestKeyValueKeys] ?: @{};
    if (valueKeys.count == 0) {
        DDLogError(@"ValueKeys is empty");
        return;
    }

    // -------------------------------------------------------------------------
    //  Loop through all values in "AvailableValues" and add to payloads
    // -------------------------------------------------------------------------
    for (NSString *selection in availableValues) {
        [sender createPayloadFromManifestContent:valueKeys[selection] manifest:manifest settings:settings payloads:payloads];
    }
}

+ (NSArray *)lintReportForManifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath sender:(PFCManifestLint *)sender {
    NSMutableArray *lintReport = [[NSMutableArray alloc] init];

    // -------------------------------------------------------------------------
    //  AvailableValues/ValueKeys
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForAvailableValues:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    [lintReport addObjectsFromArray:[sender reportForValueKeys:manifestContentDict
                                                      manifest:manifest
                                                 parentKeyPath:parentKeyPath
                                                      required:YES
                                               availableValues:manifestContentDict[PFCManifestKeyAvailableValues]]];
    [lintReport addObjectsFromArray:[sender reportForValueKeysShared:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    return [lintReport copy];
}

@end
