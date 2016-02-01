//
//  PFCManifestLibrary.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-01-31.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCManifestLibrary.h"
#import "PFCConstants.h"
#import "PFCLog.h"
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
    if ( self ) {
        _cachedLocalSettings = [[NSMutableDictionary alloc] init];
    }
    return self;
} // init

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Library Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)libraryApple:(NSError *__autoreleasing *)error acceptCached:(BOOL)acceptCached {
    
    if ( acceptCached && _cachedLibraryApple ) {
        return _cachedLibraryApple;
    }
    
    // ---------------------------------------------------------------------
    //  Get path to manifest folder inside ProfileCreator.app
    // ---------------------------------------------------------------------
    NSURL *profileManifestFolderURL = [[[NSBundle mainBundle] resourceURL] URLByAppendingPathComponent:@"Manifests"];
    if ( ! [profileManifestFolderURL checkResourceIsReachableAndReturnError:error] ) {
        return nil;
    } else {
        
        // ---------------------------------------------------------------------
        //  Put all profile manifest plist URLs in an array
        // ---------------------------------------------------------------------
        NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:profileManifestFolderURL
                                                             includingPropertiesForKeys:@[]
                                                                                options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                  error:nil];
        
        // ---------------------------------------------------------------------
        //  Return all manifests matching predicate
        // ---------------------------------------------------------------------
        NSPredicate *predicateManifestPlists = [NSPredicate predicateWithFormat:@"self.pathExtension == 'plist'"];
        _cachedLibraryApple = [dirContents filteredArrayUsingPredicate:predicateManifestPlists];
        return _cachedLibraryApple;
    }
} // libraryApple

- (NSArray *)libraryUserLibraryPreferencesLocal:(NSError *__autoreleasing *)error acceptCached:(BOOL)acceptCached {
    
    if ( acceptCached && _cachedLibraryUserLibraryPreferencesLocal ) {
        return _cachedLibraryUserLibraryPreferencesLocal;
    }
    
    // -------------------------------------------------------------------------
    //  Get path to user library folder
    // -------------------------------------------------------------------------
    NSURL *userLibraryURL = [[NSFileManager defaultManager] URLForDirectory:NSLibraryDirectory
                                                                   inDomain:NSUserDomainMask
                                                          appropriateForURL:nil
                                                                     create:NO
                                                                      error:error];
    if ( userLibraryURL == nil ) {
        return nil;
    }
    
    // -------------------------------------------------------------------------
    //  Get path to user library preferences folder
    // -------------------------------------------------------------------------
    NSURL *userLibraryPreferencesURL = [userLibraryURL URLByAppendingPathComponent:@"Preferences"];
    if ( ! [userLibraryPreferencesURL checkResourceIsReachableAndReturnError:error] ) {
        return nil;
    } else {
        _cachedLibraryUserLibraryPreferencesLocal = [self manifestsFromPlistsAtURL:userLibraryPreferencesURL];
        return _cachedLibraryUserLibraryPreferencesLocal;
    }
} // libraryUserLibraryPreferencesLocal:settingsLocal

- (NSArray *)libraryLibraryPreferencesLocal:(NSError *__autoreleasing *)error acceptCached:(BOOL)acceptCached {
    
    if ( acceptCached && _cachedLibraryLibraryPreferencesLocal ) {
        return _cachedLibraryLibraryPreferencesLocal;
    }
    
    // -------------------------------------------------------------------------
    //  Get path to user library folder
    // -------------------------------------------------------------------------
    NSURL *libraryURL = [[NSFileManager defaultManager] URLForDirectory:NSLibraryDirectory
                                                               inDomain:NSLocalDomainMask
                                                      appropriateForURL:nil
                                                                 create:NO
                                                                  error:error];
    if ( libraryURL == nil ) {
        return nil;
    }
    
    // -------------------------------------------------------------------------
    //  Get path to user library preferences folder
    // -------------------------------------------------------------------------
    NSURL *libraryPreferencesURL = [libraryURL URLByAppendingPathComponent:@"Preferences"];
    if ( ! [libraryPreferencesURL checkResourceIsReachableAndReturnError:error] ) {
        return nil;
    } else {
        _cachedLibraryLibraryPreferencesLocal = [self manifestsFromPlistsAtURL:libraryPreferencesURL];
        return _cachedLibraryLibraryPreferencesLocal;
    }
} // libraryLibraryPreferencesLocal:settingsLocal

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Shared Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)manifestsFromPlistsAtURL:(NSURL *)folderURL {
    
    // ---------------------------------------------------------------------
    //  Get all contents of user library preferences folder
    // ---------------------------------------------------------------------
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:folderURL
                                                         includingPropertiesForKeys:@[]
                                                                            options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                              error:nil];
    
    // ---------------------------------------------------------------------
    //  Create a manifest for all files ending with .plist
    // ---------------------------------------------------------------------
    NSMutableArray *library = [[NSMutableArray alloc] init];
    NSMutableDictionary *settings;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"pathExtension='plist'"];
    for ( NSURL *plistURL in [dirContents filteredArrayUsingPredicate:predicate] ) {
        settings = [[NSMutableDictionary alloc] init];
        NSDictionary *manifest = [[PFCManifestParser sharedParser] manifestFromPlistAtURL:plistURL settings:settings];
        if ( [manifest count] != 0 ) {
            NSString *manifestDomain = manifest[PFCManifestKeyDomain] ?: @"";
            [library addObject:manifest];
            _cachedLocalSettings[manifestDomain] = settings;
        } else {
            DDLogDebug(@"Plist at path: %@ did not create a manifest", [plistURL path]);
        }
    }
    
    // ---------------------------------------------------------------------
    //  Return all non-empty created manifests
    // ---------------------------------------------------------------------
    return [library copy];
} // manifestsAtURL:settingsLocal

@end
