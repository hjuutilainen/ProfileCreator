//
//  PFCManifestLibrary.h
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

#import "PFCConstants.h"
#import <Foundation/Foundation.h>

@interface PFCManifestLibrary : NSObject

// -----------------------------------------------------------------------------
//  Class Methods
// -----------------------------------------------------------------------------
+ (id)sharedLibrary;

// -----------------------------------------------------------------------------
//  Cache properties
// -----------------------------------------------------------------------------
@property NSArray *cachedLibraryAll;
@property NSArray *cachedLibraryApple;
@property NSArray *cachedLibraryUserLibraryPreferencesLocal;
@property NSArray *cachedLibraryLibraryPreferencesLocal;
@property NSArray *cachedLibraryCustom;
@property NSArray *cachedLibraryMCX;
@property NSMutableDictionary *cachedLocalSettings;

// -----------------------------------------------------------------------------
//  Library Methods
// -----------------------------------------------------------------------------
- (NSArray *)libraryApple:(NSError **)error acceptCached:(BOOL)acceptCached;
- (NSArray *)libraryUserLibraryPreferencesLocal:(NSError **)error acceptCached:(BOOL)acceptCached;
- (NSArray *)libraryLibraryPreferencesLocal:(NSError **)error acceptCached:(BOOL)acceptCached;
- (NSArray *)libraryCustom:(NSError **)error acceptCached:(BOOL)acceptCached;
- (NSArray *)libraryMCX:(NSError **)error acceptCached:(BOOL)acceptCached;
- (NSDictionary *)manifestFromLibrary:(PFCPayloadLibrary)library withDomain:(NSString *)domain;
- (NSArray *)manifestsWithDomains:(NSArray *)domains;

@end
