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
//  AllowedFileTypes
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForAllowedFileTypes:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath;

// -----------------------------------------------------------------------------
//  AllowedFileExtensions
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForAllowedFileExtensions:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath;

// -----------------------------------------------------------------------------
//  AvailableValues
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForAvailableValues:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath;

// -----------------------------------------------------------------------------
//  ButtonTitle
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForButtonTitle:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath;

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
//  FileInfoProcessor
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForFileInfoProcessor:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath;

// -----------------------------------------------------------------------------
//  FilePrompt
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForFilePrompt:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath;

// -----------------------------------------------------------------------------
//  FontWeight
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForFontWeight:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath;

// -----------------------------------------------------------------------------
//  IndentLeft
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForIndentLeft:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath;

// -----------------------------------------------------------------------------
//  IndentLevel
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForIndentLevel:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath;

// -----------------------------------------------------------------------------
//  MaxValue
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForMaxValue:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath;

// -----------------------------------------------------------------------------
//  MinValue
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForMinValue:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath;

// -----------------------------------------------------------------------------
//  MinValueOffsetDays
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForMinValueOffsetDays:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath;

// -----------------------------------------------------------------------------
//  MinValueOffsetHours
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForMinValueOffsetHours:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath;

// -----------------------------------------------------------------------------
//  MinValueOffsetMinutes
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForMinValueOffsetMinutes:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath;

// -----------------------------------------------------------------------------
//  Optional(...)
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForOptionalKey:(NSString *)key manifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath;

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
//  Required(...)
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForRequiredKey:(NSString *)key manifestContentDict:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath;

// -----------------------------------------------------------------------------
//  ShowDateInterval
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForShowDateInterval:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath;

// -----------------------------------------------------------------------------
//  ShowDateTime
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForShowDateTime:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath;

// -----------------------------------------------------------------------------
//  Title
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForTitle:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath;

// -----------------------------------------------------------------------------
//  Unit
// -----------------------------------------------------------------------------
- (NSDictionary *)reportForUnit:(NSDictionary *)manifestContentDict manifest:(NSDictionary *)manifest parentKeyPath:(NSString *)parentKeyPath;

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
