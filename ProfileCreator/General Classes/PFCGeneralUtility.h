//
//  PFCGeneralUtility.h
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

typedef NS_ENUM(NSInteger, PFCFolders) { kPFCFolderUserApplicationSupport = 0, kPFCFolderSavedProfiles, kPFCFolderSavedProfileGroups, kPFCFolderSavedProfileSmartGroups };

@interface PFCGeneralUtility : NSObject

+ (NSString *)newProfilePathForUUID:(NSString *)uuid;
+ (NSString *)newPathInGroupFolder:(PFCFolders)groupFolder;
+ (NSURL *)profileCreatorFolder:(NSInteger)folder;
+ (void)insertSubview:(NSView *)subview inSuperview:(NSView *)superview hidden:(BOOL)hidden;
+ (void)removeSubviewsFromView:(NSView *)superview;
+ (BOOL)version:(NSString *)version1 isLowerThanVersion:(NSString *)version2;
+ (void)setTableViewHeight:(int)tableHeight tableView:(NSScrollView *)scrollView;
+ (NSString *)dateIntervalFromNowToDate:(NSDate *)futureDate;
+ (void)setupOSVersionsButtonOSXMin:(NSPopUpButton *)osxMinVersion osxMax:(NSPopUpButton *)osxMaxVersion iOSMin:(NSPopUpButton *)iosMinVersion iOSMax:(NSPopUpButton *)iosMaxVersion sender:(id)sender;

@end
