//
//  PFCCellTypes.h
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

@interface PFCCellTypes : NSObject

// -----------------------------------------------------------------------------
//  Class Methods
// -----------------------------------------------------------------------------
+ (id)sharedInstance;

// -----------------------------------------------------------------------------
//  Instance Methods
// -----------------------------------------------------------------------------
- (CGFloat)rowHeightForManifestContentDict:(NSDictionary *)manifestContentDict;

// -----------------------------------------------------------------------------
//  TextField
// -----------------------------------------------------------------------------
+ (NSTextField *)textFieldWithString:(NSString *)string placeholderString:(NSString *)placeholderString tag:(NSInteger)tag textAlignRight:(BOOL)alignRight enabled:(BOOL)enabled target:(id)target;

// -----------------------------------------------------------------------------
//  TextFieldNumber
// -----------------------------------------------------------------------------
+ (NSTextField *)textFieldNumberWithString:(NSString *)string
                         placeholderString:(NSString *)placeholderString
                                       tag:(NSInteger)tag
                                  minValue:(NSNumber *)minValue
                                  maxValue:(NSNumber *)maxValue
                            textAlignRight:(BOOL)alignRight
                                   enabled:(BOOL)enabled
                                    target:(id)target;

// -----------------------------------------------------------------------------
//  TextFieldTitle
// -----------------------------------------------------------------------------
+ (NSTextField *)textFieldTitleWithString:(NSString *)string
                                    width:(CGFloat)width
                                      tag:(NSInteger)tag
                               fontWeight:(NSString *)fontWeight
                           textAlignRight:(BOOL)alignRight
                                  enabled:(BOOL)enabled
                                   target:(id)target;

// -----------------------------------------------------------------------------
//  TextFieldDescription
// -----------------------------------------------------------------------------
+ (NSTextField *)textFieldDescriptionWithString:(NSString *)string width:(CGFloat)width tag:(NSInteger)tag textAlignRight:(BOOL)alignRight enabled:(BOOL)enabled target:(id)target;

@end
