//
//  PFCProfileExport.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-21.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCProfileExport.h"
#import "PFCConstants.h"
#import "PFCLog.h"
#import "PFCManifestLibrary.h"

@interface PFCProfileExport()

@property PFCMainWindow *mainWindow;
@property NSDictionary *settingsProfile;

@end

@implementation PFCProfileExport

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Init/Dealloc
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (id)initWithProfileSettings:(NSDictionary *)settings mainWindow:(PFCMainWindow *)mainWindow {
    self = [super init];
    if ( self != nil ) {
        _settingsProfile = settings;
        _mainWindow = mainWindow;
    }
    return self;
} // initWithProfileSettings:sender

- (void)dealloc {
    
} // dealloc

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Export Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (void)exportProfileToURL:(NSURL *)url {
    
    // -------------------------------------------------------------------------
    //  Get only settings and domains for payloads selected.
    //  THe application saves all settings, even if they are made in payloads that's not enabled
    // -------------------------------------------------------------------------
    NSDictionary *settingsAll = _settingsProfile[@"Config"][PFCProfileTemplateKeySettings] ?: @{};
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] init];
    
    for ( NSString *domain in [settings allKeys] ) {
        if ( ! [settings[domain][PFCSettingsKeySelected] boolValue] && ! [domain isEqualToString:@"com.apple.general"] ) {
            continue;
        }
        
        settings[domain] = settingsAll[domain];
    }
    NSArray *selectedDomains = [settings allKeys];
    NSArray *selectedManifests = [[PFCManifestLibrary sharedLibrary] manifestsWithDomains:selectedDomains];
    
    DDLogDebug(@"selectedManifests=%@", selectedManifests);
    /*
    NSArray *manifestDicts = [self manifestDictsForDomains:selectedDomains];
    
    for ( NSDictionary *manifestDict in manifestDicts ) {
        NSString *manifestDomain = manifestDict[@"Domain"];
        NSDictionary *settingsDict = selectedDict[manifestDomain];
        NSDictionary *verificationReport = [[PFCManifestParser sharedParser] settingsErrorForManifestContent:manifestDict[@"ManifestContent"] settings:settingsDict];
        if ( [verificationReport count] != 0 ) {
            NSArray *warnings = verificationReport[@"Warning"];
            for ( NSDictionary *warningDict in warnings ) {
                NSLog(@"[WARNING] %@", warningDict);
            }
            
            NSArray *errors = verificationReport[@"Error"];
            for ( NSDictionary *errorDict in errors ) {
                NSLog(@"[ERROR] %@", errorDict);
            }
        }
    }
    */
    /*
    // Create Profile
    NSMutableDictionary *profile = [NSMutableDictionary dictionary];
    profile[@"PayloadUUID"] = [[NSUUID UUID] UUIDString];
    profile[@"PayloadIdentifier"] = @"com.github.profilecreator.test";
    profile[@"PayloadType"] = @"Configuration";
    profile[@"PayloadVersion"] = @1;
    
    // Should be setting?
    profile[@"PayloadScope"] = @"User";
    //profile[@"ConsentText"] = @"";
    
    NSMutableArray *payloadArray = [NSMutableArray array];
    for ( NSDictionary *manifestDict in manifestDicts ) {
        NSString *manifestDomain = manifestDict[@"Domain"];
        NSDictionary *settingsDict = selectedDict[manifestDomain];
        [self createPayloadFromManifestArray:manifestDict[@"ManifestContent"] settingsDict:settingsDict payloadArray:&payloadArray];
    }
    
    NSUInteger idx = [payloadArray indexOfObjectPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return [[item objectForKey:@"PayloadType"] isEqualToString:@"com.apple.profile"];
    }];
    
    if ( idx == NSNotFound ) {
        NSLog(@"[ERROR] No general settings found!");
        return;
    }
    
    NSMutableDictionary *profileGeneral = [[payloadArray objectAtIndex:idx] mutableCopy];
    [payloadArray removeObjectAtIndex:idx];
    [profileGeneral removeObjectForKey:@"PayloadType"];
    [profile addEntriesFromDictionary:[profileGeneral copy]];
    
    
    // general
    //profile[@"DurationUntilRemoval"] = @"";
    //profile[@"RemovalDate"] = @"";
    //profile[@"PayloadOrganization"] = @"";
    //profile[@"PayloadExpirationDate"] = @"";
    //profile[@"PayloadDisplayName"] = @"";
    //profile[@"PayloadDescription"] = @"";
    //profile[@"PayloadRemovalDisallowed"] = @NO;
    
    // Payloads
    profile[@"PayloadContent"] = payloadArray ?: @[];
    NSError *error = nil;
    
    if ( ! [profile writeToURL:profileURL atomically:NO] ) {
        NSLog(@"[ERROR] write profile failed!");
    } else {
        if ( [profileURL checkResourceIsReachableAndReturnError:&error] ) {
            [[NSWorkspace sharedWorkspace] activateFileViewerSelectingURLs:@[ profileURL ]];
        } else {
            NSLog(@"[ERROR] %@", [error localizedDescription]);
        }
    }
    */
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Profile Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Payload Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSMutableDictionary *)payloadDictForType:(NSString *)payloadType payloadSettings:(NSDictionary *)payloadSettings {
    
    NSString *payloadUUID = payloadSettings[@"UUID"];
    if ( [payloadUUID length] == 0 ) {
        DDLogWarn(@"No UUID found for payload type: %@", payloadType);
        payloadUUID = [[NSUUID UUID] UUIDString];
    }
    
    return [NSMutableDictionary dictionaryWithDictionary:@{ @"PayloadType" : payloadType,
                                                            @"PayloadVersion" : @1, // Could be different!?
                                                            @"PayloadIdentifier" : @"Identifier", //Need fix
                                                            @"PayloadUUID" : payloadUUID,
                                                            @"PayloadDisplayName" : @"DisplayName", //Need fix
                                                            @"PayloadDescription" : @"Description", //Need fix
                                                            @"PayloadOrganization" : @"Organization" //Need fix
                                                            }];
}

@end
