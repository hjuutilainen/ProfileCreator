//
//  PFCGeneralUtility.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-02.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCConstants.h"
#import "PFCGeneralUtility.h"
#import "PFCLog.h"
#import "NSView+NSLayoutConstraintFilter.h"

@implementation PFCGeneralUtility

+ (NSURL *)profileCreatorFolder:(NSInteger)folder {
    switch (folder) {
    case kPFCFolderUserApplicationSupport: {
        NSURL *userApplicationSupport = [[NSFileManager defaultManager] URLForDirectory:NSApplicationSupportDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];

        return [userApplicationSupport URLByAppendingPathComponent:@"ProfileCreator"];
    } break;

    case kPFCFolderSavedProfiles: {
        return [[self profileCreatorFolder:kPFCFolderUserApplicationSupport] URLByAppendingPathComponent:@"Profiles"];
    } break;

    case kPFCFolderSavedProfileGroups: {
        return [[self profileCreatorFolder:kPFCFolderUserApplicationSupport] URLByAppendingPathComponent:@"Groups"];
    } break;

    case kPFCFolderSavedProfileSmartGroups: {
        return [[self profileCreatorFolder:kPFCFolderUserApplicationSupport] URLByAppendingPathComponent:@"SmartGroups"];
    } break;
    default:
        return nil;
        break;
    }
}

+ (NSString *)newProfilePath {
    NSString *profileFileName = [NSString stringWithFormat:@"%@.pfcconf", [[NSUUID UUID] UUIDString]];
    NSURL *profileURL = [[PFCGeneralUtility profileCreatorFolder:kPFCFolderSavedProfiles] URLByAppendingPathComponent:profileFileName];
    return [profileURL path];
}

+ (NSString *)newProfileGroupPath {
    NSString *profileGroupFileName = [NSString stringWithFormat:@"%@.pfcgrp", [[NSUUID UUID] UUIDString]];
    NSURL *profileGroupURL = [[PFCGeneralUtility profileCreatorFolder:kPFCFolderSavedProfileGroups] URLByAppendingPathComponent:profileGroupFileName];
    return [profileGroupURL path];
}

+ (void)insertSubview:(NSView *)subview inSuperview:(NSView *)superview hidden:(BOOL)hidden {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    [superview addSubview:subview positioned:NSWindowAbove relativeTo:nil];
    [subview setTranslatesAutoresizingMaskIntoConstraints:NO];
    [superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[subview]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(subview)]];
    [superview addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[subview]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(subview)]];
    [superview setHidden:NO];
    [subview setHidden:hidden];
} // insertSubview:inSuperview:hidden

+ (void)setTableViewHeight:(int)tableHeight tableView:(NSScrollView *)scrollView {
    NSLayoutConstraint *constraint = [scrollView constraintForAttribute:NSLayoutAttributeHeight];
    [constraint setConstant:tableHeight];
} // setTableViewHeight

+ (void)removeSubviewsFromView:(NSView *)superview {
    for (NSView *view in [superview subviews]) {
        [view removeFromSuperview];
    }
}

+ (BOOL)version:(NSString *)version1 isLowerThanVersion:(NSString *)version2 {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    DDLogDebug(@"Is version: %@ lower than version: %@", version1, version2);

    if ([version1 isEqualToString:@"Latest"]) {
        version1 = @"999";
    }

    if ([version2 isEqualToString:@"Latest"]) {
        version2 = @"999";
    }
    DDLogDebug(@"version1=%@", version1);
    DDLogDebug(@"version2=%@", version2);
    DDLogDebug(@"ascending=%@", ([version1 compare:version2 options:NSNumericSearch] == NSOrderedAscending) ? @"YES" : @"NO");
    if ([version1 isEqualToString:version2]) {
        return YES;
    } else {
        return [version1 compare:version2 options:NSNumericSearch] == NSOrderedAscending;
    }
} // version:isLaterThanVersion

@end
