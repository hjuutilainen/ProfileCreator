//
//  PFCProfileEditorSettings.h
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
@class PFCProfileEditor;

@interface PFCProfileEditorSettings : NSViewController

@property (readonly) BOOL showAdvancedSettings;
@property (readwrite) BOOL showKeysSupervised;

// Profile Name
@property (readwrite) NSString *profileName;
@property (readwrite) NSString *profileIdentifier;
@property (readwrite) NSString *profileIdentifierFormat;
@property (readwrite) NSString *profileUUID;

@property BOOL includePlatformOSX;
@property (readwrite) NSString *osxMinVersion;
@property (readwrite) NSString *osxMaxVersion;

@property BOOL includePlatformiOS;
@property (readwrite) NSString *iosMinVersion;
@property (readwrite) NSString *iosMaxVersion;

@property BOOL signProfile;
@property BOOL encryptProfile;

@property (weak) IBOutlet NSTextField *textFieldProfileName;

- (id)initWithProfile:(NSDictionary *)profile profileEditor:(PFCProfileEditor *)profileEditor;
- (void)selectOSVersion:(NSMenuItem *)menuItem;
- (void)setupDisplaySettings;
- (NSDictionary *)displayKeys;

@end
