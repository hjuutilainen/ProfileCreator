//
//  PFCCellTypeFile.m
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
#import "PFCCellTypeFile.h"
#import "PFCCellTypes.h"
#import "PFCConstants.h"
#import "PFCError.h"
#import "PFCFileInfoProcessors.h"
#import "PFCLog.h"
#import "PFCManifestUtility.h"
#import "PFCProfileEditor.h"

@interface PFCFileCellView ()

@property id fileInfoProcessor;
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSView *settingFileView;
@property (weak) IBOutlet NSTextField *settingFileViewPrompt;
@property (weak) IBOutlet NSTextField *settingFileTitle;
@property (weak) IBOutlet NSTextField *settingFileDescriptionLabel1;
@property (weak) IBOutlet NSTextField *settingFileDescription1;
@property (weak) IBOutlet NSTextField *settingFileDescriptionLabel2;
@property (weak) IBOutlet NSTextField *settingFileDescription2;
@property (weak) IBOutlet NSTextField *settingFileDescriptionLabel3;
@property (weak) IBOutlet NSTextField *settingFileDescription3;
@property (weak) IBOutlet NSImageView *settingFileIcon;

@end

@implementation PFCFileCellView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)setInfoForFileAtURL:(NSURL *)fileURL withFileInfoProcessor:(NSString *)fileInfoProcessor {

    if (!_fileInfoProcessor) {
        [self setFileInfoProcessor:[PFCFileInfoProcessors fileInfoProcessorWithName:fileInfoProcessor fileURL:fileURL]];
    } else {
        [_fileInfoProcessor setFileURL:fileURL];
    }

    // ---------------------------------------------------------------------
    //  Retrieve file info from the processor
    // ---------------------------------------------------------------------
    NSDictionary *fileInfo = [_fileInfoProcessor fileInfo];
    if ([fileInfo count] != 0) {
        [_settingFileTitle setStringValue:fileInfo[PFCFileInfoTitle] ?: [fileURL lastPathComponent]];

        if (fileInfo[PFCFileInfoDescription1] != nil) {
            [_settingFileDescriptionLabel1 setStringValue:fileInfo[PFCFileInfoLabel1] ?: @""];
            [_settingFileDescription1 setStringValue:fileInfo[PFCFileInfoDescription1] ?: @""];

            [_settingFileDescriptionLabel1 setHidden:NO];
            [_settingFileDescription1 setHidden:NO];
        } else {
            [_settingFileDescriptionLabel1 setHidden:YES];
            [_settingFileDescription1 setHidden:YES];
        }

        if (fileInfo[PFCFileInfoDescription2] != nil) {
            [_settingFileDescriptionLabel2 setStringValue:fileInfo[PFCFileInfoLabel2] ?: @""];
            [_settingFileDescription2 setStringValue:fileInfo[PFCFileInfoDescription2] ?: @""];

            [_settingFileDescriptionLabel2 setHidden:NO];
            [_settingFileDescription2 setHidden:NO];
        } else {
            [_settingFileDescriptionLabel2 setHidden:YES];
            [_settingFileDescription2 setHidden:YES];
        }

        if (fileInfo[PFCFileInfoDescription3] != nil) {
            [_settingFileDescriptionLabel3 setStringValue:fileInfo[PFCFileInfoLabel3] ?: @""];
            [_settingFileDescription3 setStringValue:fileInfo[PFCFileInfoDescription3] ?: @""];

            [_settingFileDescriptionLabel3 setHidden:NO];
            [_settingFileDescription3 setHidden:NO];
        } else {
            [_settingFileDescriptionLabel3 setHidden:YES];
            [_settingFileDescription3 setHidden:YES];
        }
    }
}

- (PFCFileCellView *)populateCellView:(PFCFileCellView *)cellView
                             manifest:(NSDictionary *)manifest
                             settings:(NSDictionary *)settings
                        settingsLocal:(NSDictionary *)settingsLocal
                          displayKeys:(NSDictionary *)displayKeys
                                  row:(NSInteger)row
                               sender:(id)sender {

    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [[PFCAvailability sharedInstance] requiredForManifestContentDict:manifest displayKeys:displayKeys];

    BOOL enabled = YES;
    if (!required && settings[PFCSettingsKeyEnabled] != nil) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }

    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[PFCManifestKeyTitle] ?: @""];
    if (enabled) {
        [[cellView settingTitle] setTextColor:[NSColor blackColor]];
    } else {
        [[cellView settingTitle] setTextColor:[NSColor grayColor]];
    }

    // ---------------------------------------------------------------------
    //  Description
    // ---------------------------------------------------------------------
    [[cellView settingDescription] setStringValue:manifest[PFCManifestKeyDescription] ?: @""];

    // ---------------------------------------------------------------------
    //  Tool Tip
    // ---------------------------------------------------------------------
    [cellView setToolTip:[[PFCManifestUtility sharedUtility] toolTipForManifestContentDict:manifest] ?: @""];

    // ---------------------------------------------------------------------
    //  Button Title
    // ---------------------------------------------------------------------
    NSString *buttonTitle = manifest[PFCManifestKeyButtonTitle] ?: @"Add File...";
    [[cellView settingButtonAdd] setTitle:buttonTitle ?: @"Add File..."];
    [[cellView settingButtonAdd] setEnabled:enabled];

    // ---------------------------------------------------------------------
    //  Button Action
    // ---------------------------------------------------------------------
    [[cellView settingButtonAdd] setAction:@selector(selectFile:)];
    [[cellView settingButtonAdd] setTarget:sender];
    [[cellView settingButtonAdd] setTag:row];

    // ---------------------------------------------------------------------
    //  File View Prompt Message
    // ---------------------------------------------------------------------
    [[cellView settingFileViewPrompt] setStringValue:manifest[PFCManifestKeyFilePrompt] ?: @""];

    // ---------------------------------------------------------------------
    //  Add Border to file view
    // ---------------------------------------------------------------------
    [[cellView settingFileView] setWantsLayer:YES];
    [[[cellView settingFileView] layer] setMasksToBounds:YES];
    [[[cellView settingFileView] layer] setBorderWidth:0.5f];
    [[[cellView settingFileView] layer] setBorderColor:[[NSColor grayColor] CGColor]];

    // ---------------------------------------------------------------------
    //  Show prompt if no file is selected
    // ---------------------------------------------------------------------
    if ([settings[PFCSettingsKeyFilePath] length] == 0) {
        [[cellView settingFileViewPrompt] setHidden:NO];
        [[cellView settingFileIcon] setHidden:YES];
        [[cellView settingFileTitle] setHidden:YES];
        [[cellView settingFileDescriptionLabel1] setHidden:YES];
        [[cellView settingFileDescription1] setHidden:YES];
        [[cellView settingFileDescriptionLabel2] setHidden:YES];
        [[cellView settingFileDescription2] setHidden:YES];
        [[cellView settingFileDescriptionLabel3] setHidden:YES];
        [[cellView settingFileDescription3] setHidden:YES];
        return cellView;
    }

    // ---------------------------------------------------------------------
    //  Check that file exist
    // ---------------------------------------------------------------------
    NSError *error = nil;
    NSURL *fileURL = [NSURL fileURLWithPath:settings[PFCSettingsKeyFilePath]];
    if (![fileURL checkResourceIsReachableAndReturnError:&error]) {
        DDLogError(@"%@", [error localizedDescription]);
    }

    // ---------------------------------------------------------------------
    //  File Icon
    // ---------------------------------------------------------------------
    NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:[fileURL path]];
    if (icon) {
        [[cellView settingFileIcon] setImage:icon];
    }

    // ---------------------------------------------------------------------
    //  File Info
    // ---------------------------------------------------------------------
    if ([fileURL checkResourceIsReachableAndReturnError:nil]) {
        [self setInfoForFileAtURL:fileURL withFileInfoProcessor:manifest[PFCManifestKeyFileInfoProcessor]];
    }

    // ---------------------------------------------------------------------
    //  Show file info
    // ---------------------------------------------------------------------
    [[cellView settingFileViewPrompt] setHidden:YES];
    [[cellView settingFileIcon] setHidden:NO];
    [[cellView settingFileTitle] setHidden:NO];

    return cellView;
} // populateCellViewSettingsFile:settings:row

+ (NSDictionary *)verifyCellType:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings displayKeys:(NSDictionary *)displayKeys {

    // -------------------------------------------------------------------------
    //  Verify this manifest content dict contains an 'Identifier'. Else stop.
    // -------------------------------------------------------------------------
    NSString *identifier = manifestContentDict[PFCManifestKeyIdentifier];
    if ([identifier length] == 0) {
        return nil;
    }

    NSDictionary *contentDictSettings = settings[identifier];
    if ([contentDictSettings count] == 0) {
        DDLogDebug(@"No settings!");
    }

    // BOOL required = [cellDict[@"Required"] boolValue];
    NSString *filePath = contentDictSettings[@"FilePath"];
    NSURL *fileURL = [NSURL fileURLWithPath:filePath ?: @""];
    NSError *error = nil;
    if (![fileURL checkResourceIsReachableAndReturnError:&error]) {
        return @{ identifier : @[ [PFCError verificationReportWithMessage:@"" severity:kPFCSeverityError manifestContentDict:manifestContentDict] ] };
    }

    NSArray *allowedFileTypes = manifestContentDict[PFCManifestKeyAllowedFileTypes];
    if ([allowedFileTypes count] != 0) {
        NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
        NSString *fileType;
        if ([fileURL getResourceValue:&fileType forKey:NSURLTypeIdentifierKey error:&error]) {
            __block BOOL validFileType = NO;
            [allowedFileTypes enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
              if ([workspace type:fileType conformsToType:obj]) {
                  validFileType = YES;
                  *stop = YES;
              }
            }];

            if (!validFileType) {
                return @{ identifier : @[ [PFCError verificationReportWithMessage:@"Invalid File Type" severity:kPFCSeverityError manifestContentDict:manifestContentDict] ] };
            }
        } else {
            DDLogError(@"%@", [error localizedDescription]);
        }
    }

    return nil;
}

@end
