//
//  PFCManifestUtility.h
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

@interface PFCManifestUtility : NSObject

// -----------------------------------------------------------------------------
//  Class Methods
// -----------------------------------------------------------------------------
+ (id)sharedUtility;

// -----------------------------------------------------------------------------
//  Utility Methods
// -----------------------------------------------------------------------------
- (CGFloat)constantForIndentationLevel:(NSNumber *)indentationLevel baseConstant:(NSNumber *)baseConstant;
- (NSImage *)iconForManifest:(NSDictionary *)manifest;
- (BOOL)hideKey:(NSString *)key;
- (NSString *)typeStringFromValue:(id)value;
- (NSString *)cellTypeFromTypeString:(NSString *)typeString;
- (BOOL)showManifestContentDict:(NSDictionary *)manifestContentDict settings:(NSDictionary *)settings showDisabled:(BOOL)showDisabled showHidden:(BOOL)showHidden;
- (NSString *)toolTipForManifestContentDict:(NSDictionary *)manifestContentDict;
@end
