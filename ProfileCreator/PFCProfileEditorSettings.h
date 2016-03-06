//
//  PFCProfileEditorSettings.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-03-06.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCProfileEditor.h"
#import <Cocoa/Cocoa.h>

@interface PFCProfileEditorSettings : NSViewController

@property BOOL showKeysDisabled;
@property BOOL showKeysHidden;
@property BOOL showKeysSupervised;

// Profile Name
@property (readwrite) NSString *profileName;
@property (readwrite) NSString *profileIdentifier;
@property (readwrite) NSString *profileIdentifierFormat;
@property (readwrite) NSString *profileUUID;

@property BOOL includePlatformOSX;
@property (readwrite) NSString *osxMinVersion;
@property (readwrite) NSString *osxMaxVersion;

@property BOOL includePlatformiOS;
@property (readwrite) NSString *iosMinVersion;
@property (readwrite) NSString *iosMaxVersion;

@property BOOL signProfile;
@property BOOL encryptProfile;

@property (weak) IBOutlet NSTextField *textFieldProfileName;

- (id)initWithProfile:(NSDictionary *)profile profileEditor:(PFCProfileEditor *)profileEditor;
- (NSDictionary *)displayKeys;

@end
