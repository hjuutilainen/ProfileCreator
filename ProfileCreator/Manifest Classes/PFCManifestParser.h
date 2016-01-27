//
//  PFCManifestParser.h
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

@interface PFCManifestParser : NSObject

// -----------------------------------------------------------------------------
//  Class Methods
// -----------------------------------------------------------------------------
+ (id)sharedParser;

// -----------------------------------------------------------------------------
//  TableView arrays from Manifest
// -----------------------------------------------------------------------------
- (NSArray *)arrayFromManifestContent:(NSArray *)manifestContent settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal showDisabled:(BOOL)showDisabled showHidden:(BOOL)showHidden;
- (NSArray *)arrayFromManifestContentDict:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings settingsLocal:(NSDictionary *)settingsLocal parentKeys:(NSMutableArray *)parentKeys;

// -----------------------------------------------------------------------------
//  Create Manifest
// -----------------------------------------------------------------------------
- (NSDictionary *)manifestFromPlistAtURL:(NSURL *)fileURL settings:(NSMutableDictionary *)settings;

// -----------------------------------------------------------------------------
//  Verify Manifest
// -----------------------------------------------------------------------------
- (NSDictionary *)verifyManifestContent:(NSArray *)ManifestContent settings:(NSDictionary *)settings;
- (NSDictionary *)verifyManifestContentDict:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings;

@end