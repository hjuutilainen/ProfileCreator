//
//  PFCProfileExportWindowController.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-01-05.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFCProfileExportWindowController : NSWindowController
@property (weak) IBOutlet NSTextField *textFieldName;
@property (weak) IBOutlet NSTextField *textFieldPayloadsCount;

@property NSDictionary *profileDict;

@property id parentObject;

@property (weak) IBOutlet NSStackView *stackView;

- (id)initWithProfileDict:(NSDictionary *)profileDict sender:(id)sender;

@property (weak) IBOutlet NSButton *buttonExport;
- (IBAction)buttonExport:(id)sender;

- (IBAction)buttonCancel:(id)sender;

@end
