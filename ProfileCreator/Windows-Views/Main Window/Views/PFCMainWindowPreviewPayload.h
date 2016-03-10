//
//  PFCMainWindowPreviewPayload.h
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

#import <Cocoa/Cocoa.h>

@interface PFCMainWindowPreviewPayload : NSViewController

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
