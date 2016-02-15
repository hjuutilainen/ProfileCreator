//
//  PFCProfileUtility.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-07.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCProfileUtility.h"
#import "PFCGeneralUtility.h"
#import "PFCConstants.h"
#import "PFCLog.h"

@interface PFCProfileUtility ()

@property NSMutableDictionary *profilesDict; // All

@property NSMutableArray *arraySavedProfiles;
@property NSMutableDictionary *dictSavedProfiles;

@property NSMutableArray *arrayUnsavedProfiles;
@property NSMutableDictionary *dictUnsavedProfiles;

@property NSDate *savedProfilesModificationDate;
@property NSURL *savedProfilesFolderURL;

@end

@implementation PFCProfileUtility

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Initialization
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

+ (id)sharedUtility {
    static PFCProfileUtility *sharedUtility = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
        sharedUtility = [[self alloc] init];
    });
    return sharedUtility;
} // sharedUtility

- (id)init {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    self = [super init];
    if ( self ) {
        _profilesDict = [[NSMutableDictionary alloc] init];
        _arraySavedProfiles = [[NSMutableArray alloc] init];
        _arrayUnsavedProfiles = [[NSMutableArray alloc] init];
        _savedProfilesFolderURL = [PFCGeneralUtility profileCreatorFolder:kPFCFolderSavedProfiles];
        _dictSavedProfiles = [[NSMutableDictionary alloc] init];
        _dictUnsavedProfiles = [[NSMutableDictionary alloc] init];
    }
    return self;
} // init

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Utility Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)savedProfileURLs {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    if ( ! _savedProfilesFolderURL ) {
        [self setSavedProfilesFolderURL:[PFCGeneralUtility profileCreatorFolder:kPFCFolderSavedProfiles]];
    }
    
    if ( ! [_savedProfilesFolderURL checkResourceIsReachableAndReturnError:nil] ) {
        return nil;
    } else {
        NSArray *savedProfilesContent = [[NSFileManager defaultManager] contentsOfDirectoryAtURL:_savedProfilesFolderURL
                                                                      includingPropertiesForKeys:@[]
                                                                                         options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                                           error:nil];
        
        return [savedProfilesContent filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"pathExtension == '%@'", PFCProfileTemplateExtension]]];
    }
} // savedProfileURLs

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Return All Profiles
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)profiles {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    if ( ! [self shouldUpdateProfileCache] ) {
        return [self allProfiles];
    } else {
        [self updateProfileCache];
        return [self allProfiles];
    }
} // profiles

- (NSDate *)savedProfilesFolderModificationDate {
    if ( ! _savedProfilesFolderURL ) {
        [self setSavedProfilesFolderURL:[PFCGeneralUtility profileCreatorFolder:kPFCFolderSavedProfiles]];
    }
    
    NSError *error = nil;
    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[_savedProfilesFolderURL path] ?: @"" error:&error];
    if ( [attributes count] != 0 ) {
        return (NSDate *)[attributes objectForKey: NSFileModificationDate];
    }
    return nil;
}

- (BOOL)shouldUpdateProfileCache {
    
    // FIXME -  Don't know if checking modification date of save folder is the best way of determining to return cache for this data.
    //          Am happy for better ideas.
    
    NSDate *modificationDate = [self savedProfilesFolderModificationDate];
    if ( modificationDate ) {
        DDLogDebug(@"Profile save folder modification date: %@", modificationDate);
        DDLogDebug(@"Profile save folder cached modification date: %@", _savedProfilesModificationDate);
        
        if ( _savedProfilesModificationDate ) {
            if ( [modificationDate isEqualToDate:_savedProfilesModificationDate] ) {
                DDLogDebug(@"Profile save folder have not changed, returning cached profile array");
                return NO;
            } else {
                DDLogDebug(@"Profile save folder have changed, reloading saved profiles from disk...");
            }
        }
    }
    return YES;
}

- (void)addUnsavedProfile:(NSDictionary *)profile {
    [_arrayUnsavedProfiles addObject:profile];
    NSString *uuid = profile[@"Config"][PFCProfileTemplateKeyUUID];
    _dictUnsavedProfiles[uuid] = profile;
    _profilesDict[uuid] = profile;
} // addUnsavedProfile

- (void)removeUnsavedProfileWithUUID:(NSString *)uuid {
    NSInteger index = [_arrayUnsavedProfiles indexOfObjectPassingTest:^BOOL(NSDictionary *  _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
        return [dict[@"Config"][PFCProfileTemplateKeyUUID] isEqualToString:uuid];
    }];
    
    if ( index != NSNotFound ) {
        [_arrayUnsavedProfiles removeObjectAtIndex:index];
    }
    
    [_dictUnsavedProfiles removeObjectForKey:uuid];
    [_profilesDict removeObjectForKey:uuid];
} // removeUnsavedProfileWithUUID

- (NSArray *)allProfiles {
    NSMutableArray *profiles = [[NSMutableArray alloc] initWithArray:_arraySavedProfiles];
    [profiles addObjectsFromArray:_arrayUnsavedProfiles];
    return [profiles copy];
} // allProfiles

- (NSArray *)allProfileUUIDs {
    if ( [self shouldUpdateProfileCache] ) {
        [self updateProfileCache];
    }
    return [_profilesDict allKeys];
} // allProfileUUIDs

- (NSArray *)allProfileNamesExceptProfileWithUUID:(NSString *)profileUUID {
    if ( [self shouldUpdateProfileCache] ) {
        [self updateProfileCache];
    }
    NSMutableArray *names = [[NSMutableArray alloc] init];
    [[_profilesDict allKeys] enumerateObjectsUsingBlock:^(NSString * _Nonnull uuid, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( ! [profileUUID isEqualToString:uuid] ) {
            NSDictionary *profile = _profilesDict[uuid] ?: @{};
            [names addObject:profile[@"Config"][PFCProfileTemplateKeyName] ?: @""];
        }
    }];
    [names removeObject:@""];
    return [names copy];
} // allProfileNames

- (void)updateProfileCache {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    NSDate *modificationDate = [self savedProfilesFolderModificationDate];
    if ( modificationDate ) {
        DDLogDebug(@"Updating profile save folder modification date to: %@", modificationDate);
        [self setSavedProfilesModificationDate:modificationDate];
    }
    
    [_arraySavedProfiles removeAllObjects];
    [_dictSavedProfiles removeAllObjects];
    [_profilesDict removeAllObjects];
    
    // -------------------------------------------------------------------------
    //  Read all saved profiles from disk
    // -------------------------------------------------------------------------
    for ( NSURL *profileURL in [self savedProfileURLs] ?: @[] ) {
        
        NSDictionary *profileDict = [NSDictionary dictionaryWithContentsOfURL:profileURL];
        if ( [profileDict count] == 0 ) {
            DDLogError(@"Couldn't read profile at path: %@", [profileURL path]);
            continue;
        }
        
        // FIXME - Add sanity checking to see if this actually is a profile save
        
        NSString *name = profileDict[PFCProfileTemplateKeyName];
        if ( [name length] == 0 ) {
            DDLogError(@"Couldn't read profile name for profile at path: %@", [profileURL path]);
            continue;
        }
        
        // ---------------------------------------------------------------------
        //  If profile was saved, remove it from unsaved profiles
        // ---------------------------------------------------------------------
        NSString *uuid = profileDict[PFCProfileTemplateKeyUUID];
        if ( [uuid length] != 0 ) {
            if ( [_arrayUnsavedProfiles containsObject:uuid] ) {
                [_arrayUnsavedProfiles removeObject:uuid];
            }
        }
        
        NSDictionary *savedProfileDict = @{ PFCRuntimeKeyPath : [profileURL path],
                                            @"Config" : profileDict };
        
        
        
        [_arraySavedProfiles addObject:savedProfileDict];
        _dictSavedProfiles[uuid] = savedProfileDict;
    }
    
    [_profilesDict addEntriesFromDictionary:_dictSavedProfiles];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Return Specific Profiles
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)profilesWithUUIDs:(NSArray *)profileUUIDs {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    DDLogDebug(@"Profile UUIDs: %@", profileUUIDs);
    if ( [self shouldUpdateProfileCache] ) {
        [self updateProfileCache];
    }
    NSMutableArray *profileDicts = [[NSMutableArray alloc] init];
    for ( NSString *uuid in profileUUIDs ) {
        [profileDicts addObject:_profilesDict[uuid] ?: @{}];
    }
    [profileDicts removeObject:@{}];
    
    return [profileDicts copy];
    
} // profilesWithUUIDs

- (NSDictionary *)profileWithUUID:(NSString *)uuid {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    DDLogDebug(@"Profile UUID: %@", uuid);
    if ( [self shouldUpdateProfileCache] ) {
        [self updateProfileCache];
    }
    return _profilesDict[uuid] ?: @{};
} // profileWithUUID

- (BOOL)deleteProfileWithUUID:(NSString *)uuid error:(NSError **)error {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    DDLogDebug(@"Profile UUID: %@", uuid);
    
    NSDictionary *profile = [self profileWithUUID:uuid];
    
    NSString *profilePath = profile[PFCProfileTemplateKeyPath] ?: @"";
    NSURL *profileURL = [NSURL fileURLWithPath:profilePath];
    if ( [profileURL checkResourceIsReachableAndReturnError:nil] ) {
        return [[NSFileManager defaultManager] removeItemAtURL:profileURL error:error];
    }
    return YES;
}

@end
