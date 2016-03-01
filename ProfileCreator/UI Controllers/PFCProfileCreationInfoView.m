//
//  PFCProfileCreationInfoView.m
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

#import "NSView+NSLayoutConstraintFilter.h"
#import "PFCConstants.h"
#import "PFCProfileCreationInfoView.h"
#import "PFCTableViewCellsProfileInfo.h"
#import "PFCViews.h"

int const PFCTableViewPayloadInfoRowHeight = 17;

@implementation PFCProfileCreationInfoView

- (id)initWithDelegate:(id<PFCProfileCreationInfoDelegate>)delegate {
    self = [super initWithNibName:@"PFCProfileCreationInfoView" bundle:nil];
    if (self != nil) {
        _delegate = delegate;

        _arrayPayloadInfo = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)insertSubview:(NSView *)subview inSuperview:(NSView *)superview hidden:(BOOL)hidden {
    [superview addSubview:subview positioned:NSWindowAbove relativeTo:nil];
    [subview setTranslatesAutoresizingMaskIntoConstraints:NO];

    NSArray *constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[subview]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(subview)];
    [superview addConstraints:constraintsArray];

    constraintsArray = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|[subview]|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(subview)];
    [superview addConstraints:constraintsArray];
    [superview setHidden:NO];
    [subview setHidden:hidden];
} // insertSubview:inSuperview:hidden

- (void)updateInfoForManifestContentDict:(NSDictionary *)manifestContentDict {
    if ([manifestContentDict count] == 0) {
        return;
    }

    [self removeSubviews];
    [self insertSubview:_viewManifestContent inSuperview:[self view] hidden:NO];
    [self updateInfoForCellType:manifestContentDict[PFCManifestKeyCellType] ?: @"Unknown" manifestContentDict:manifestContentDict];
}

- (void)updateInfoForManifestDict:(NSDictionary *)manifestDict {
    if ([manifestDict count] == 0) {
        return;
    }

    [self removeSubviews];
    [self insertSubview:_viewManifestContent inSuperview:[self view] hidden:NO];
}

- (void)removeSubviews {
    for (NSView *view in [[self view] subviews]) {
        [view removeFromSuperview];
    }
}

- (void)updatePayloadInfoForManifestContentDict:(NSDictionary *)manifestContentDict {

    // -------------------------------------------------------------------------
    //  Clear table view from old content
    // -------------------------------------------------------------------------
    [_arrayPayloadInfo removeAllObjects];

    // -------------------------------------------------------------------------
    //  Create array of available payload keys
    // -------------------------------------------------------------------------
    NSArray *payloadKeys = @[
        PFCManifestKeyPayloadType,
        PFCManifestKeyPayloadKey,
        PFCManifestKeyPayloadKeyCheckbox,
        PFCManifestKeyPayloadKeyHost,
        PFCManifestKeyPayloadKeyPort,
        PFCManifestKeyPayloadKeyTextField,
        PFCManifestKeyPayloadParentKey,
        PFCManifestKeyPayloadParentKeyCheckbox,
        PFCManifestKeyPayloadParentKeyHost,
        PFCManifestKeyPayloadParentKeyPort,
        PFCManifestKeyPayloadParentKeyTextField,
        PFCManifestKeyPayloadValueType,
        PFCManifestKeyPayloadParentValueType
    ];

    // -------------------------------------------------------------------------
    //  Loop through each payload key and add available keys to info table view
    // -------------------------------------------------------------------------
    for (NSString *key in payloadKeys) {
        if (manifestContentDict[key] != nil) {
            [_arrayPayloadInfo addObject:@{ @"Title" : key ?: @"", @"Value" : manifestContentDict[key] ?: @"" }];
        }
    }

    // -------------------------------------------------------------------------
    //  If current manifest doesn't define any payload, add ino
    // -------------------------------------------------------------------------
    if ([_arrayPayloadInfo count] == 0) {
        [_arrayPayloadInfo addObject:@{ @"Title" : @"No Payload Info" }];
    }

    // -------------------------------------------------------------------------
    //  Reload table view data
    // -------------------------------------------------------------------------
    [_tableViewPayloadInfo reloadData];

    // -------------------------------------------------------------------------
    //  Adjust table view height to content
    // -------------------------------------------------------------------------
    [self setTableViewHeight:PFCTableViewPayloadInfoRowHeight * (int)[_arrayPayloadInfo count] tableView:_scrollViewPayloadInfo];
}

- (void)updateInfoForCellType:(NSString *)cellType manifestContentDict:(NSDictionary *)manifestContentDict {

    [self updatePayloadInfoForManifestContentDict:manifestContentDict];
}

- (void)updateinfoForCellTypeTextField:(NSDictionary *)manifestContentDict {
}

- (void)setTableViewHeight:(int)tableHeight tableView:(NSScrollView *)scrollView {
    NSLayoutConstraint *constraint = [scrollView constraintForAttribute:NSLayoutAttributeHeight];
    [constraint setConstant:tableHeight];
} // setTableViewHeight

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_arrayPayloadInfo count];
} // numberOfRowsInTableView

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {

    // ---------------------------------------------------------------------
    //  Verify the info array isn't empty, if so stop here
    // ---------------------------------------------------------------------
    if ([_arrayPayloadInfo count] == 0 || [_arrayPayloadInfo count] < row) {
        return nil;
    }

    NSDictionary *infoDict = _arrayPayloadInfo[row];
    if ([[tableColumn identifier] isEqualToString:@"TableColumnInfoTitle"]) {
        CellViewPayloadInfoTitle *cellView = [tableView makeViewWithIdentifier:@"CellViewPayloadInfoTitle" owner:self];
        [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
        return [cellView populateCellViewPayloadInfoTitle:cellView infoDict:infoDict row:row];
    } else if ([[tableColumn identifier] isEqualToString:@"TableColumnInfoValue"]) {
        CellViewPayloadInfoValue *cellView = [tableView makeViewWithIdentifier:@"CellViewPayloadInfoValue" owner:self];
        [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
        return [cellView populateCellViewPayloadInfoValue:cellView infoDict:infoDict row:row];
    } else {
        return nil;
    }
}

@end
