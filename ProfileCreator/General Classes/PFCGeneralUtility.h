//
//  PFCGeneralUtility.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-02.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, PFCFolders) { kPFCFolderUserApplicationSupport = 0, kPFCFolderSavedProfiles, kPFCFolderSavedProfileGroups, kPFCFolderSavedProfileSmartGroups };

@interface PFCGeneralUtility : NSObject

+ (NSString *)newProfilePath;
+ (NSString *)newPathInGroupFolder:(PFCFolders)groupFolder;
+ (NSURL *)profileCreatorFolder:(NSInteger)folder;
+ (void)insertSubview:(NSView *)subview inSuperview:(NSView *)superview hidden:(BOOL)hidden;
+ (void)removeSubviewsFromView:(NSView *)superview;
+ (BOOL)version:(NSString *)version1 isLowerThanVersion:(NSString *)version2;
+ (void)setTableViewHeight:(int)tableHeight tableView:(NSScrollView *)scrollView;
+ (NSString *)dateIntervalFromNowToDate:(NSDate *)futureDate;

@end
