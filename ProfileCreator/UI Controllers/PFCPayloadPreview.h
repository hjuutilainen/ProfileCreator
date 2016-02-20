//
//  PFCPayloadPreview.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-11.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFCPayloadPreview : NSViewController

@property BOOL isCollapsed;

@property NSString *payloadErrorCount;
@property NSString *payloadName;
@property NSString *payloadDescription;
@property NSImage *payloadIcon;

@property (weak) IBOutlet NSTextField *textFieldPayloadErrorCount;

@property NSMutableArray *arrayPayloadInfo;
@property (weak) IBOutlet NSImageView *imageViewPayload;

@property (weak) IBOutlet NSTableView *tableViewPayloadInfo;
@property (strong) IBOutlet NSLayoutConstraint *layoutConstraintDescriptionBottom;
@property (weak) IBOutlet NSTextField *textFieldPayloadDescription;

@property (weak) IBOutlet NSTextField *textFieldPayloadName;
@property (weak) IBOutlet NSButton *buttonDisclosureTriangle;
- (IBAction)buttonDisclosureTriangle:(id)sender;

@end