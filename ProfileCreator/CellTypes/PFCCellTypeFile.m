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
#import "PFCManifestLint.h"
#import "PFCManifestUtility.h"
#import "PFCProfileEditor.h"

@interface PFCFileCellView ()

@property id fileInfoProcessor;
@property (weak) IBOutlet NSTextField *settingTitle;
@property (weak) IBOutlet NSTextField *settingDescription;
@property (weak) IBOutlet NSView *settingFileView;
@property (weak) IBOutlet NSTextField *settingFileViewPrompt;
@property (weak) IBOutlet NSTextField *settingFileTitle;
@property (weak) IBOutlet NSTextField *settingFileDescriptionLabelTop;
@property (weak) IBOutlet NSTextField *settingFileDescriptionTop;
@property (weak) IBOutlet NSTextField *settingFileDescriptionLabelMiddle;
@property (weak) IBOutlet NSTextField *settingFileDescriptionMiddle;
@property (weak) IBOutlet NSTextField *settingFileDescriptionLabelBottom;
@property (weak) IBOutlet NSTextField *settingFileDescriptionBottom;
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

        if (fileInfo[PFCFileInfoDescriptionTop] != nil) {
            [_settingFileDescriptionLabelTop setStringValue:fileInfo[PFCFileInfoLabelTop] ?: @""];
            [_settingFileDescriptionTop setStringValue:fileInfo[PFCFileInfoDescriptionTop] ?: @""];

            [_settingFileDescriptionLabelTop setHidden:NO];
            [_settingFileDescriptionTop setHidden:NO];
        } else {
            [_settingFileDescriptionLabelTop setHidden:YES];
            [_settingFileDescriptionTop setHidden:YES];
        }

        if (fileInfo[PFCFileInfoDescriptionMiddle] != nil) {
            [_settingFileDescriptionLabelMiddle setStringValue:fileInfo[PFCFileInfoLabelMiddle] ?: @""];
            [_settingFileDescriptionMiddle setStringValue:fileInfo[PFCFileInfoDescriptionMiddle] ?: @""];

            [_settingFileDescriptionLabelMiddle setHidden:NO];
            [_settingFileDescriptionMiddle setHidden:NO];
        } else {
            [_settingFileDescriptionLabelMiddle setHidden:YES];
            [_settingFileDescriptionMiddle setHidden:YES];
        }

        if (fileInfo[PFCFileInfoDescriptionBottom] != nil) {
            [_settingFileDescriptionLabelBottom setStringValue:fileInfo[PFCFileInfoLabelBottom] ?: @""];
            [_settingFileDescriptionBottom setStringValue:fileInfo[PFCFileInfoDescriptionBottom] ?: @""];

            [_settingFileDescriptionLabelBottom setHidden:NO];
            [_settingFileDescriptionBottom setHidden:NO];
        } else {
            [_settingFileDescriptionLabelBottom setHidden:YES];
            [_settingFileDescriptionBottom setHidden:YES];
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
        [[cellView settingFileDescriptionLabelTop] setHidden:YES];
        [[cellView settingFileDescriptionTop] setHidden:YES];
        [[cellView settingFileDescriptionLabelMiddle] setHidden:YES];
        [[cellView settingFileDescriptionMiddle] setHidden:YES];
        [[cellView settingFileDescriptionLabelBottom] setHidden:YES];
        [[cellView settingFileDescriptionBottom] setHidden:YES];
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

+ (NSArray *)lintReportForManifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath sender:(PFCManifestLint *)sender {
    NSMutableArray *lintReport = [[NSMutableArray alloc] init];

    NSArray *allowedTypes = @[ PFCValueTypeData ]; // This is not correct, placeholder.

    // -------------------------------------------------------------------------
    //  AllowedInput
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForAllowedFileTypes:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    [lintReport addObject:[sender reportForAllowedFileExtensions:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  Prompts
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForButtonTitle:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    [lintReport addObject:[sender reportForFilePrompt:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  Title/Description
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForTitle:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];
    [lintReport addObject:[sender reportForDescription:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  FileInfoProcessor
    // -------------------------------------------------------------------------
    [lintReport addObject:[sender reportForFileInfoProcessor:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath]];

    // -------------------------------------------------------------------------
    //  Payload
    // -------------------------------------------------------------------------
    [lintReport addObjectsFromArray:[sender reportForPayloadKeys:nil manifestContentDict:manifestContentDict manifest:manifest parentKeyPath:parentKeyPath allowedTypes:allowedTypes]];

    return [lintReport copy];
}

@end
