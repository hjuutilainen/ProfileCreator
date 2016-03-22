//
//  PFCManifestLibrary.m
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

#import "PFCLog.h"
#import "PFCManifestLibrary.h"
#import "PFCManifestParser.h"

@implementation PFCManifestLibrary

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initialization
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

+ (id)sharedLibrary {
    // FIXME - Unsure if this has to be a singleton, figured it would be used alot and then not keep alloc/deallocing all the time
    static PFCManifestLibrary *sharedLibrary = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
      sharedLibrary = [[self alloc] init];
    });
    return sharedLibrary;
} // sharedParser

- (id)init {
    self = [super init];
    if (self) {
        _cachedLocalSettings = [[NSMutableDictionary alloc] init];
    }
    return self;
} // init

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Library Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)libraryAll:(NSError *__autoreleasing *)error acceptCached:(BOOL)acceptCached {

    if (acceptCached && _cachedLibraryAll) {
        return _cachedLibraryAll;
    }

    NSMutableArray *libraryAll = [[NSMutableArray alloc] init];
    [libraryAll addObjectsFromArray:[self libraryApple:nil acceptCached:acceptCached]];
    [libraryAll addObjectsFromArray:[self libraryUserLibraryPreferencesLocal:nil acceptCached:acceptCached]];
    [libraryAll addObjectsFromArray:[self libraryLibraryPreferencesLocal:nil acceptCached:acceptCached]];

    _cachedLibraryAll = [libraryAll copy];
    return _cachedLibraryAll;
}

- (NSArray *)libraryApple:(NSError *__autoreleasing *)error acceptCached:(BOOL)acceptCached {

    if (acceptCached && _cachedLibraryApple) {
        return _cachedLibraryApple;
    }

    // ---------------------------------------------------------------------
    //  Get path to manifest folder inside ProfileCreator.app
    // ---------------------------------------------------------------------
    NSURL *profileManifestFolderURL = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"Manifests"];
    if (![profileManifestFolderURL checkResourceIsReachableAndReturnError:error]) {
        return nil;
    } else {

        NSMutableArray *libraryApple = [[NSMutableArray alloc] init];

        // ---------------------------------------------------------------------
        //  Put all profile manifest plist URLs in an array
        // ---------------------------------------------------------------------
        NSArray *dirContents =
            [[NSFileManager defaultManager] contentsOfDirectoryAtURL:profileManifestFolderURL includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];

        // ---------------------------------------------------------------------
        //  Return all manifests matching predicate
        // ---------------------------------------------------------------------
        NSPredicate *predicateManifestPlists = [NSPredicate predicateWithFormat:@"self.pathExtension == 'plist'"];
        NSArray *manifestURLs = [dirContents filteredArrayUsingPredicate:predicateManifestPlists];
        for (NSURL *manifestURL in manifestURLs ?: @[]) {
            NSMutableDictionary *manifestDict = [[NSDictionary dictionaryWithContentsOfURL:manifestURL] mutableCopy];
            if ([manifestDict count] != 0) {
                manifestDict[PFCRuntimeKeyPath] = [manifestURL path];
                [libraryApple addObject:[manifestDict copy]];
            }
        }

        _cachedLibraryApple = [libraryApple copy];
        return _cachedLibraryApple;
    }
} // libraryApple

- (NSArray *)libraryUserLibraryPreferencesLocal:(NSError *__autoreleasing *)error acceptCached:(BOOL)acceptCached {

    if (acceptCached && _cachedLibraryUserLibraryPreferencesLocal) {
        return _cachedLibraryUserLibraryPreferencesLocal;
    }

    // -------------------------------------------------------------------------
    //  Get path to user library folder
    // -------------------------------------------------------------------------
    NSURL *userLibraryURL = [[NSFileManager defaultManager] URLForDirectory:NSLibraryDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:error];
    if (userLibraryURL == nil) {
        return nil;
    }

    // -------------------------------------------------------------------------
    //  Get path to user library preferences folder
    // -------------------------------------------------------------------------
    NSURL *userLibraryPreferencesURL = [userLibraryURL URLByAppendingPathComponent:@"Preferences"];
    if (![userLibraryPreferencesURL checkResourceIsReachableAndReturnError:error]) {
        return nil;
    } else {
        _cachedLibraryUserLibraryPreferencesLocal = [self manifestsFromPlistsAtURL:userLibraryPreferencesURL];
        return _cachedLibraryUserLibraryPreferencesLocal;
    }
} // libraryUserLibraryPreferencesLocal:settingsLocal

- (NSArray *)libraryLibraryPreferencesLocal:(NSError *__autoreleasing *)error acceptCached:(BOOL)acceptCached {

    if (acceptCached && _cachedLibraryLibraryPreferencesLocal) {
        return _cachedLibraryLibraryPreferencesLocal;
    }

    // -------------------------------------------------------------------------
    //  Get path to user library folder
    // -------------------------------------------------------------------------
    NSURL *libraryURL = [[NSFileManager defaultManager] URLForDirectory:NSLibraryDirectory inDomain:NSLocalDomainMask appropriateForURL:nil create:NO error:error];
    if (libraryURL == nil) {
        return nil;
    }

    // -------------------------------------------------------------------------
    //  Get path to user library preferences folder
    // -------------------------------------------------------------------------
    NSURL *libraryPreferencesURL = [libraryURL URLByAppendingPathComponent:@"Preferences"];
    if (![libraryPreferencesURL checkResourceIsReachableAndReturnError:error]) {
        return nil;
    } else {
        _cachedLibraryLibraryPreferencesLocal = [self manifestsFromPlistsAtURL:libraryPreferencesURL];
        return _cachedLibraryLibraryPreferencesLocal;
    }
} // libraryLibraryPreferencesLocal:settingsLocal

- (NSArray *)libraryCustom:(NSError *__autoreleasing *)error acceptCached:(BOOL)acceptCached {

    if (acceptCached && _cachedLibraryCustom) {
        return _cachedLibraryCustom;
    }

    return nil;
}

- (NSArray *)libraryMCX:(NSError *__autoreleasing *)error acceptCached:(BOOL)__unused acceptCached {

    if (_cachedLibraryMCX) {
        return _cachedLibraryMCX;
    }

    // -------------------------------------------------------------------------
    //  Get path to core services folder
    // -------------------------------------------------------------------------
    NSURL *coreServicesURL = [[NSFileManager defaultManager] URLForDirectory:NSCoreServiceDirectory inDomain:NSSystemDomainMask appropriateForURL:nil create:NO error:error];
    if (coreServicesURL == nil) {
        return nil;
    }

    // -------------------------------------------------------------------------
    //  Get path to managed client's resource folder
    // -------------------------------------------------------------------------
    NSURL *managedClientURL = [coreServicesURL URLByAppendingPathComponent:@"/ManagedClient.app/Contents/Resources"];
    if (![managedClientURL checkResourceIsReachableAndReturnError:error]) {
        return nil;
    } else {
        _cachedLibraryMCX = [self manifestsFromMCXManifestsAtURL:managedClientURL];
        return _cachedLibraryMCX;
    }
} // libraryMCX:acceptCached

- (NSArray *)manifestsWithDomains:(NSArray *)domains {

    NSError *error = nil;
    NSArray *manifestLibrary = [self libraryAll:&error acceptCached:YES];
    if ([manifestLibrary count] == 0) {
        DDLogError(@"%@", [error localizedDescription]);
        return @[];
    }

    NSMutableArray *manifests = [[NSMutableArray alloc] init];

    for (NSDictionary *manifest in manifestLibrary) {
        if ([domains containsObject:manifest[PFCManifestKeyDomain]]) {
            [manifests addObject:manifest];
        }
    }
    return [manifests copy];
} // manifestsWithDomains

- (NSDictionary *)manifestFromLibrary:(PFCPayloadLibrary)library withDomain:(NSString *)domain {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);

    NSError *error = nil;

    NSArray *manifestLibrary;
    switch (library) {
    case kPFCPayloadLibraryAll: {
        DDLogDebug(@"Payload library: All");
        manifestLibrary = [self libraryAll:&error acceptCached:YES];
        break;
    }

    case kPFCPayloadLibraryApple: {
        DDLogDebug(@"Payload library: Apple");
        manifestLibrary = [self libraryApple:&error acceptCached:YES];
        break;
    }

    case kPFCPayloadLibraryUserPreferences: {
        DDLogDebug(@"Payload library: Library User Preferences");
        manifestLibrary = [self libraryUserLibraryPreferencesLocal:&error acceptCached:YES];
        break;
    }

    case kPFCPayloadLibraryLibraryPreferences: {
        DDLogDebug(@"Payload library: Library Preferences");
        manifestLibrary = [self libraryLibraryPreferencesLocal:&error acceptCached:YES];
        break;
    }

    case kPFCPayloadLibraryMCX: {
        DDLogDebug(@"Payload library: Library MCX");
        manifestLibrary = [self libraryMCX:&error acceptCached:YES];
    }

    case kPFCPayloadLibraryCustom: {
        DDLogDebug(@"Payload library: Library Custom");
        manifestLibrary = [self libraryCustom:&error acceptCached:YES];
        break;
    }

    default:
        break;
    }

    if ([manifestLibrary count] == 0) {
        DDLogError(@"%@", [error localizedDescription]);
        return @{};
    }

    for (NSDictionary *manifest in manifestLibrary ?: @[]) {
        NSString *manifestDomain = manifest[PFCManifestKeyDomain] ?: @"";
        if ([manifestDomain isEqualToString:domain]) {
            return manifest;
        }
    }
    return @{};
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Shared Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)manifestsFromPlistsAtURL:(NSURL *)folderURL {

    // ---------------------------------------------------------------------
    //  Get all contents of user library preferences folder
    // ---------------------------------------------------------------------
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:folderURL includingPropertiesForKeys:@[] options:NSDirectoryEnumerationSkipsHiddenFiles error:nil];

    // ---------------------------------------------------------------------
    //  Create a manifest for all files ending with .plist
    // ---------------------------------------------------------------------
    NSMutableArray *library = [[NSMutableArray alloc] init];
    NSMutableDictionary *settings;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension='plist'"];
    for (NSURL *plistURL in [dirContents filteredArrayUsingPredicate:predicate]) {
        settings = [[NSMutableDictionary alloc] init];
        NSDictionary *manifest = [[PFCManifestParser sharedParser] manifestFromPlistAtURL:plistURL settings:settings];
        if ([manifest count] != 0) {
            NSString *manifestDomain = manifest[PFCManifestKeyDomain] ?: @"";
            [library addObject:manifest];
            _cachedLocalSettings[manifestDomain] = settings;
        }
    }

    // ---------------------------------------------------------------------
    //  Return all non-empty created manifests
    // ---------------------------------------------------------------------
    return [library copy];
} // manifestsAtURL:settingsLocal

- (NSArray *)manifestsFromMCXManifestsAtURL:(NSURL *)folderURL {

    NSFileManager *localFileManager = [[NSFileManager alloc] init];
    NSDirectoryEnumerator *dirEnum = [localFileManager enumeratorAtURL:folderURL
                                            includingPropertiesForKeys:@[ NSURLIsDirectoryKey ]
                                                               options:NSDirectoryEnumerationSkipsHiddenFiles
                                                          errorHandler:^BOOL(NSURL *_Nonnull url, NSError *_Nonnull error) {
                                                            DDLogDebug(@"Enumerator Error: %@", [error localizedDescription]);
                                                            return YES;
                                                          }];

    NSURL *file;
    NSMutableArray *mcxManifestFiles = [[NSMutableArray alloc] init];
    while ((file = [dirEnum nextObject])) {
        NSNumber *isDirectory;
        BOOL success = [file getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
        if (success && ![isDirectory boolValue] && [[file pathExtension] isEqualToString:@"manifest"]) {
            NSDictionary *manifest = [[PFCManifestParser sharedParser] manifestFromMCXManifestAtURL:file];
            if ([manifest count] != 0) {
                [mcxManifestFiles addObject:manifest];
            }
        }
    }
    return [mcxManifestFiles copy];
} // manifestsFromMCXManifestsAtURL:folderURL

@end
