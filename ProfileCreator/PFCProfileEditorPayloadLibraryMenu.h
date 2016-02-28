//
//  PFCProfileEditorPayloadLibraryMenu.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-25.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "PFCProfileEditor.h"

@interface PFCProfileEditorPayloadLibraryMenu : NSViewController

@property (weak) IBOutlet NSView *viewButtons;
@property (weak) IBOutlet NSBox *lineTop;
@property (weak) IBOutlet NSBox *lineBottom;

- (id)initWithProfileEditor:(PFCProfileEditor *)profileEditor;

@end
