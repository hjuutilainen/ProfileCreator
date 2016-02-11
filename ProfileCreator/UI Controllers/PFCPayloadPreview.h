//
//  PFCPayloadPreview.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-11.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFCPayloadPreview : NSViewController

@property (weak) IBOutlet NSTextField *textFieldPayloadName;
@property (weak) IBOutlet NSButton *buttonDisclosureTriangle;
- (IBAction)buttonDisclosureTriangle:(id)sender;

@end
