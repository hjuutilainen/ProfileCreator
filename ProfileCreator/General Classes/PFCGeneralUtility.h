//
//  PFCGeneralUtility.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-02.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, PFCFolders) {
    kPFCFolderUserApplicationSupport = 0,
    kPFCFolderSavedProfiles,
    kPFCFolderSavedProfileGroups,
    kPFCFolderSavedProfileSmartGroups
};

@interface PFCGeneralUtility : NSObject

+ (NSArray *)savedProfileURLs;
+ (NSString *)newProfilePath;
+ (NSString *)newProfileGroupPath;
+ (NSURL *)profileCreatorFolder:(NSInteger)folder;
+ (void)insertSubview:(NSView *)subview inSuperview:(NSView *)superview hidden:(BOOL)hidden;

@end
