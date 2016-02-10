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

@property NSMutableArray *arraySavedProfiles;
@property NSMutableArray *arrayUnsavedProfiles;
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
        _arraySavedProfiles = [[NSMutableArray alloc] init];
        _arrayUnsavedProfiles = [[NSMutableArray alloc] init];
        _savedProfilesFolderURL = [PFCGeneralUtility profileCreatorFolder:kPFCFolderSavedProfiles];
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
    
    // FIXME - Handle unsaved profiles as well
    return [self savedProfiles];
} // profiles

- (NSArray *)savedProfiles {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    // FIXME -  Don't know if checking modification date of save folder is the best way of determining to return cache for this data.
    //          Am happy for better ideas.
    
    NSError *error = nil;
    
    if ( ! _savedProfilesFolderURL ) {
        [self setSavedProfilesFolderURL:[PFCGeneralUtility profileCreatorFolder:kPFCFolderSavedProfiles]];
    }
    
    NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[_savedProfilesFolderURL path] ?: @"" error:&error];
    if ( [attributes count] != 0 ) {
        NSDate *modificationDate = (NSDate *)[attributes objectForKey: NSFileModificationDate];
        DDLogDebug(@"Profile save folder modification date: %@", modificationDate);
        DDLogDebug(@"Profile save folder cached modification date: %@", _savedProfilesModificationDate);
        
        if ( _savedProfilesModificationDate ) {
            if ( [modificationDate isEqualToDate:_savedProfilesModificationDate] ) {
                DDLogDebug(@"Profile save folder have not changed, returning cached profile array");
                
                return [_arraySavedProfiles copy];
            } else {
                DDLogDebug(@"Profile save folder have changed, reloading saved profiles from disk...");
            }
        }
        DDLogDebug(@"Updating profile save folder modification date to: %@", modificationDate);
        [self setSavedProfilesModificationDate:modificationDate];
    }
    
    [_arraySavedProfiles removeAllObjects];
    
    // ---------------------------------------------------------------------
    //  Read all saved profiles from disk
    // ---------------------------------------------------------------------
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
        
        NSDictionary *savedProfileDict = @{ PFCRuntimeKeyPath : [profileURL path],
                                            @"Config" : profileDict };

        [_arraySavedProfiles addObject:savedProfileDict];
    }
    
    return [_arraySavedProfiles copy];
} // savedProfiles

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Return Specific Profiles
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSArray *)profilesWithUUIDs:(NSArray *)profileUUIDs {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    if ( [profileUUIDs ?: @[] count] == 0 ) {
        return @[];
    }
    
    NSMutableArray *profileDicts = [[NSMutableArray alloc] init];
    [[self profiles] enumerateObjectsUsingBlock:^(NSDictionary *  _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
        if ( [profileUUIDs containsObject:dict[@"Config"][PFCProfileTemplateKeyUUID] ?: @""] ) {
            [profileDicts addObject:dict];
        }
    }];
    
    return [profileDicts copy];
} // profilesWithUUIDs

- (NSDictionary *)profileWithUUID:(NSString *)profileUUID {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    
    if ( [profileUUID length] != 0 ) {
        NSArray *profiles = [self profiles];
        NSUInteger index = [profiles indexOfObjectPassingTest:^BOOL(NSDictionary *  _Nonnull dict, NSUInteger idx, BOOL * _Nonnull stop) {
            return [dict[@"Config"][PFCProfileTemplateKeyUUID] isEqualToString:profileUUID];
        }];
        
        if ( index != NSNotFound ) {
            return profiles[index];
        }
    }
    return nil;
} // profileWithUUID

@end
