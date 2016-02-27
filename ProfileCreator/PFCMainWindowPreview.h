//
//  PFCMainWindowPayloadPreview.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-27.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PFCMainWindow.h"

@interface PFCMainWindowPreview : NSViewController

@property (weak) IBOutlet NSView *viewPreviewSuperview;
@property (weak) IBOutlet NSView *viewPreviewSelectionUnavailable;
@property BOOL profilePreviewHidden;
@property BOOL profilePreviewSelectionUnavailableHidden;

- (id)initWithMainWindow:(PFCMainWindow *)mainWindow;
- (void)updatePreviewWithProfileDict:(NSDictionary *)profileDict;

- (void)showProfilePreview;
- (void)showProfilePreviewError;
- (void)showProfilePreviewNoSelection;
- (void)showProfilePreviewMultipleSelections:(NSNumber *)count;

@end
