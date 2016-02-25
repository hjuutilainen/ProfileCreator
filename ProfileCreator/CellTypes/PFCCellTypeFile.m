//
//  PFCCellTypeFile.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-25.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCCellTypeFile.h"
#import "PFCConstants.h"
#import "PFCManifestUtility.h"
#import "PFCProfileEditor.h"
#import "PFCFileInfoProcessors.h"
#import "PFCLog.h"

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
    
    if ( ! _fileInfoProcessor ) {
        [self setFileInfoProcessor:[PFCFileInfoProcessors fileInfoProcessorWithName:fileInfoProcessor fileURL:fileURL]];
    } else {
        [_fileInfoProcessor setFileURL:fileURL];
    }
    
    // ---------------------------------------------------------------------
    //  Retrieve file info from the processor
    // ---------------------------------------------------------------------
    NSDictionary *fileInfo = [_fileInfoProcessor fileInfo];
    if ( [fileInfo count] != 0 ) {
        [_settingFileTitle setStringValue:fileInfo[PFCFileInfoTitle] ?: [fileURL lastPathComponent]];
        
        if ( fileInfo[PFCFileInfoDescription1] != nil ) {
            [_settingFileDescriptionLabel1 setStringValue:fileInfo[PFCFileInfoLabel1] ?: @""];
            [_settingFileDescription1 setStringValue:fileInfo[PFCFileInfoDescription1] ?: @""];
            
            [_settingFileDescriptionLabel1 setHidden:NO];
            [_settingFileDescription1 setHidden:NO];
        } else {
            [_settingFileDescriptionLabel1 setHidden:YES];
            [_settingFileDescription1 setHidden:YES];
        }
        
        if ( fileInfo[PFCFileInfoDescription2] != nil ) {
            [_settingFileDescriptionLabel2 setStringValue:fileInfo[PFCFileInfoLabel2] ?: @""];
            [_settingFileDescription2 setStringValue:fileInfo[PFCFileInfoDescription2] ?: @""];
            
            [_settingFileDescriptionLabel2 setHidden:NO];
            [_settingFileDescription2 setHidden:NO];
        } else {
            [_settingFileDescriptionLabel2 setHidden:YES];
            [_settingFileDescription2 setHidden:YES];
        }
        
        if ( fileInfo[PFCFileInfoDescription3] != nil ) {
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

- (PFCFileCellView *)populateCellView:(PFCFileCellView *)cellView manifest:(NSDictionary *)manifest settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal row:(NSInteger)row sender:(id)sender {
    
    // ---------------------------------------------------------------------------------------
    //  Get required and enabled state of this cell view
    //  Every CellView is enabled by default, only if user has deselected it will be disabled
    // ---------------------------------------------------------------------------------------
    BOOL required = [manifest[PFCManifestKeyRequired] boolValue];
    
    BOOL enabled = YES;
    if ( ! required && settings[PFCSettingsKeyEnabled] != nil ) {
        enabled = [settings[PFCSettingsKeyEnabled] boolValue];
    }
    
    // ---------------------------------------------------------------------
    //  Title
    // ---------------------------------------------------------------------
    [[cellView settingTitle] setStringValue:manifest[PFCManifestKeyTitle] ?: @""];
    if ( enabled ) {
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
    if ( [settings[PFCSettingsKeyFilePath] length] == 0 ) {
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
    if ( ! [fileURL checkResourceIsReachableAndReturnError:&error] ) {
        DDLogError(@"%@", [error localizedDescription]);
    }
    
    // ---------------------------------------------------------------------
    //  File Icon
    // ---------------------------------------------------------------------
    NSImage *icon = [[NSWorkspace sharedWorkspace] iconForFile:[fileURL path]];
    if ( icon ) {
        [[cellView settingFileIcon] setImage:icon];
    }
    
    // ---------------------------------------------------------------------
    //  File Info
    // ---------------------------------------------------------------------
    if ( [fileURL checkResourceIsReachableAndReturnError:nil] ) {
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

@end
