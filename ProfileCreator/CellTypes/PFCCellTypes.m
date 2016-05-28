//
//  PFCCellTypes.m
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

#import "PFCCellTypeProtocol.h"
#import "PFCCellTypes.h"
#import "PFCConstants.h"
#import "PFCGeneralUtility.h"
#import "PFCLog.h"

@implementation PFCCellTypes

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initialization
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

+ (id)sharedInstance {
    static PFCCellTypes *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
} // sharedUtility

- (CGFloat)rowHeightForManifestContentDict:(NSDictionary *)manifestContentDict {
    NSString *cellType = manifestContentDict[PFCManifestKeyCellType];
    if ([cellType isEqualToString:PFCCellTypePadding]) {
        return [manifestContentDict[@"PaddingHeight"] floatValue] ?: 20.0f;
    } else if ([cellType isEqualToString:PFCCellTypeSegmentedControl]) {
        return 38.0f;
    } else if ([cellType isEqualToString:PFCCellTypeDatePickerNoTitle] || [cellType isEqualToString:PFCCellTypeTextFieldDaysHoursNoTitle]) {
        return 39.0f;
    } else if ([cellType isEqualToString:PFCCellTypeCheckbox]) {
        if ([manifestContentDict[PFCManifestKeyDescription] length] == 0) {
            DDLogDebug(@"Returning Height: 26.0f");
            return 26.0f;
        } else {
            DDLogDebug(@"Returning Height: 52.0f");
            return 52.0f;
        }
    } else if ([cellType isEqualToString:PFCCellTypePopUpButtonLeft]) {
        return 53.0f;
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldNumberLeft]) {
        return 54.0f;
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldHostPort] || [cellType isEqualToString:PFCCellTypeTextFieldCheckbox] || [cellType isEqualToString:PFCCellTypeTextFieldHostPortCheckbox]) {
        return 81.0f;
    } else if ([cellType isEqualToString:PFCCellTypeTextFieldNumber]) {
        CGFloat baseHeight = 80.0f;
        if ([manifestContentDict[PFCManifestKeyTitle] length] == 0) {
            baseHeight = (baseHeight - 23.0f);
        }
        if ([manifestContentDict[PFCManifestKeyDescription] length] == 0) {
            baseHeight = (baseHeight - 24.0f);
        }
        return baseHeight;

        // ---------------------------------------------------------------------
        //  TextField
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypeTextField]) {
        CGFloat baseHeight = 80.0f;
        if ([manifestContentDict[PFCManifestKeyTitle] length] == 0) {
            baseHeight = (baseHeight - 23.0f);
        }
        if ([manifestContentDict[PFCManifestKeyDescription] length] == 0) {
            baseHeight = (baseHeight - 26.0f);
        }
        return baseHeight;

        // ---------------------------------------------------------------------
        //  PopUpButton
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypePopUpButton]) {
        CGFloat baseHeight = 80.0f;
        if ([manifestContentDict[PFCManifestKeyTitle] length] == 0) {
            baseHeight = (baseHeight - 16.0f);
        }
        if ([manifestContentDict[PFCManifestKeyDescription] length] == 0) {
            baseHeight = (baseHeight - 22.0f);
        }
        return baseHeight;

        // ---------------------------------------------------------------------
        //  PopUpButtonCheckbox
        // ---------------------------------------------------------------------
    } else if ([cellType isEqualToString:PFCCellTypePopUpButtonCheckbox]) {
        CGFloat baseHeight = 80.0f;
        if ([manifestContentDict[PFCManifestKeyTitle] length] == 0) {
            baseHeight = (baseHeight - 16.0f);
        }
        if ([manifestContentDict[PFCManifestKeyDescription] length] == 0) {
            baseHeight = (baseHeight - 22.0f);
        }
        return baseHeight;
    } else if ([cellType isEqualToString:PFCCellTypeDatePicker]) {
        return 83.0f;
    } else if ([cellType isEqualToString:PFCCellTypeTextLabel]) {
        CGFloat baseHeight = 46.0f;
        if ([manifestContentDict[PFCManifestKeyTitle] length] == 0) {
            baseHeight = (baseHeight - 19.0f);
        }
        if ([manifestContentDict[PFCManifestKeyDescription] length] == 0) {
            baseHeight = (baseHeight - 19.0f);
        }
        return baseHeight;
    } else if ([cellType isEqualToString:PFCCellTypeTextView]) {
        return 114.0f;
    } else if ([cellType isEqualToString:PFCCellTypeFile]) {
        return 192.0f;
    } else if ([cellType isEqualToString:PFCCellTypeTableView]) {
        CGFloat baseHeight = 212.0f;
        if ([manifestContentDict[PFCManifestKeyTitle] length] == 0) {
            baseHeight = (baseHeight - 23.0f);
        }
        if ([manifestContentDict[PFCManifestKeyDescription] length] == 0) {
            baseHeight = (baseHeight - 20.0f);
        }
        return baseHeight;
    } else if ([cellType isEqualToString:PFCCellTypeRadioButton]) {
        CGFloat baseHeight = 93.0f;
        if ([manifestContentDict[PFCManifestKeyTitle] length] == 0) {
            baseHeight = (baseHeight - 23.0f);
        }
        if ([manifestContentDict[PFCManifestKeyDescription] length] == 0) {
            baseHeight = (baseHeight - 19.0f);
        }

        NSInteger buttonCount = [manifestContentDict[PFCManifestKeyAvailableValues] ?: @[] count];
        return (baseHeight + (buttonCount - 2) * 22);
    } else {
        DDLogError(@"Unknown CellType: %@ in %s", cellType, __PRETTY_FUNCTION__);
    }
    return 1;
}

+ (NSTextField *)textFieldWithString:(NSString *)string placeholderString:(NSString *)placeholderString tag:(NSInteger)tag textAlignRight:(BOOL)alignRight enabled:(BOOL)enabled target:(id)target {
    NSTextField *textField = [[NSTextField alloc] init];
    [textField setTranslatesAutoresizingMaskIntoConstraints:NO];
    [textField setLineBreakMode:NSLineBreakByClipping];
    [textField setBordered:YES];
    [textField setBezeled:YES];
    [textField setBezelStyle:NSTextFieldSquareBezel];
    [textField setDrawsBackground:NO];
    [textField setEditable:YES];
    [textField setSelectable:YES];
    [textField setTextColor:[NSColor controlTextColor]];
    [textField setBackgroundColor:[NSColor controlBackgroundColor]];
    [textField setTarget:target];
    [textField setDelegate:target];
    [textField setTag:tag];
    [textField setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]]];
    [textField setEnabled:enabled];
    [textField setStringValue:string];
    [textField setPlaceholderString:placeholderString];

    if (alignRight) {
        [textField setAlignment:NSRightTextAlignment];
    }
    return textField;
}

+ (NSTextField *)textFieldTitleWithString:(NSString *)string
                                    width:(CGFloat)width
                                      tag:(NSInteger)tag
                               fontWeight:(NSString *)fontWeight
                           textAlignRight:(BOOL)alignRight
                                  enabled:(BOOL)enabled
                                   target:(id)target {
    NSTextField *textFieldTitle = [[NSTextField alloc] init];
    [textFieldTitle setTranslatesAutoresizingMaskIntoConstraints:NO];
    [textFieldTitle setLineBreakMode:NSLineBreakByWordWrapping];
    [textFieldTitle setBordered:NO];
    [textFieldTitle setBezeled:NO];
    [textFieldTitle setDrawsBackground:NO];
    [textFieldTitle setEditable:NO];
    [textFieldTitle setSelectable:NO];
    [textFieldTitle setTarget:target];
    [textFieldTitle setTag:tag];
    [textFieldTitle setPreferredMaxLayoutWidth:width];
    [textFieldTitle setStringValue:string];

    if (enabled) {
        [textFieldTitle setTextColor:[NSColor blackColor]];
    } else {
        [textFieldTitle setTextColor:[NSColor grayColor]];
    }

    if ([fontWeight ?: @"" isEqualToString:PFCFontWeightRegular]) {
        [textFieldTitle setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]]];
    } else {
        [textFieldTitle setFont:[NSFont boldSystemFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]]];
    }

    if (alignRight) {
        [textFieldTitle setAlignment:NSRightTextAlignment];
    }
    return textFieldTitle;
}

+ (NSTextField *)textFieldDescriptionWithString:(NSString *)string width:(CGFloat)width tag:(NSInteger)tag textAlignRight:(BOOL)alignRight enabled:(BOOL)enabled target:(id)target {
    NSTextField *textFieldDescription = [[NSTextField alloc] init];
    [textFieldDescription setTranslatesAutoresizingMaskIntoConstraints:NO];
    [textFieldDescription setBordered:NO];
    [textFieldDescription setBezeled:NO];
    [textFieldDescription setDrawsBackground:NO];
    [textFieldDescription setEditable:NO];
    [textFieldDescription setSelectable:NO];
    [textFieldDescription setTextColor:[NSColor controlShadowColor]];
    [textFieldDescription setFont:[NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]]];
    [textFieldDescription setTarget:target];
    [textFieldDescription setTag:tag];
    [textFieldDescription setPreferredMaxLayoutWidth:width];
    [textFieldDescription setStringValue:string];

    if (alignRight) {
        [textFieldDescription setAlignment:NSRightTextAlignment];
    }
    return textFieldDescription;
}

@end
