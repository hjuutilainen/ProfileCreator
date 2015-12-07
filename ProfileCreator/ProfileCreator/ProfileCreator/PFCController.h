//
//  PFCController.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2015-12-07.
//  Copyright © 2015 Erik Berglund. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "PFCProfileCreationWindowController.h"

@interface PFCController : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSWindow *window;

@property PFCProfileCreationWindowController *profileWindowController;

// Te be used when opening multiple profile windows
@property NSMutableArray *profileWindows;

@property (weak) IBOutlet NSButton *buttonCreateProfile;
- (IBAction)buttonCreateProfile:(id)sender;

@end
