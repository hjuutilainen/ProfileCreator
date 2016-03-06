//
//  PFCMainWindowPayloadPreview.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-27.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCMainWindow.h"
#import "PFCStatusView.h"
#import <Cocoa/Cocoa.h>

@interface PFCMainWindowPreview : NSViewController

@property (weak) IBOutlet NSView *viewPreviewSuperview;

@property PFCStatusView *viewStatus;

- (id)initWithMainWindow:(PFCMainWindow *)mainWindow;
- (void)updatePreviewWithProfileDict:(NSDictionary *)profileDict;

- (void)showProfilePreview;
- (void)showProfilePreviewError;
- (void)showProfilePreviewNoSelection;
- (void)showProfilePreviewMultipleSelections:(NSNumber *)count;

@end
