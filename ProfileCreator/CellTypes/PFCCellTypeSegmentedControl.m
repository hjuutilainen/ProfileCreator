//
//  PFCCellTypeSegmentedControl.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-25.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

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
