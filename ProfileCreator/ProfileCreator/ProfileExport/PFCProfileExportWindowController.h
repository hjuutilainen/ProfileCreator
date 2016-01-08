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

@property NSDictionary *profileDict;

- (id)initWithProfileDict:(NSDictionary *)profileDict;

@property (weak) IBOutlet NSButton *buttonExport;
- (IBAction)buttonExport:(id)sender;

@end
