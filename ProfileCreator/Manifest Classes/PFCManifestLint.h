//
//  PFCManifestLinter.h
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

@interface PFCManifestLint : NSObject

- (NSArray *)reportForManifests:(NSArray *)manifests;

// -----------------------------------------------------------------------------
//  AvailableValues
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForAvailableValues:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath;

// -----------------------------------------------------------------------------
//  DefaultValue(...)
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForDefaultValueKey:(NSString *)key
                       manifestContentDict:(NSDictionary *)manifestContentDict
                                  manifest:(NSDictionary *)manifest
                             parentKeyPath:(NSString *)parentKeyPath
                              allowedTypes:(NSArray *)allowedTypes;

// -----------------------------------------------------------------------------
//  Description
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForDescription:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath;

// -----------------------------------------------------------------------------
//  IndentLevel
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForIndentLevel:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath;

// -----------------------------------------------------------------------------
//  PayloadKey(...)
// -----------------------------------------------------------------------------
- (NSArray *)reportForPayloadKeys:(NSArray *)payloadKeys
              manifestContentDict:(NSDictionary *)manifestContentDict
                         manifest:(NSDictionary *)manifest
                    parentKeyPath:(NSString *)parentKeyPath
                     allowedTypes:(NSArray *)allowedTypes;

// -----------------------------------------------------------------------------
//  PlaceholderValue(...)
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForPlaceholderValueKey:(NSString *)key
                           manifestContentDict:(NSDictionary *)manifestContentDict
                                      manifest:(NSDictionary *)manifest
                                 parentKeyPath:(NSString *)parentKeyPath
                                  allowedTypes:(NSArray *)allowedTypes;

// -----------------------------------------------------------------------------
//  Title
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForTitle:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath;

// -----------------------------------------------------------------------------
//  ValueKeys
// -----------------------------------------------------------------------------
- (NSArray *)reportForValueKeys:(NSDictionary *)manifestContentDict
                       manifest:(NSDictionary *)manifest
                  parentKeyPath:(NSString *)parentKeyPath
                       required:(BOOL)required
                availableValues:(NSArray *)availableValues;

// -----------------------------------------------------------------------------
//  ValueKeysShared
// -----------------------------------------------------------------------------
- (NSArray *)reportForValueKeysShared:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath;

@end
