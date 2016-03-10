//
//  PFCGeneralUtility.m
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

#import "NSView+NSLayoutConstraintFilter.h"
#import "PFCConstants.h"
#import "PFCGeneralUtility.h"
#import "PFCLog.h"

@implementation PFCGeneralUtility

+ (NSURL *)profileCreatorFolder:(NSInteger)folder {
    DDLogVerbose(@"%s", __PRETTY_FUNCTION__);
    DDLogDebug(@"Folder: %ld", (long)folder);

    if (folder == NSNotFound) {
        return nil;
    }

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
    NSURL *profileURL = [[self.class profileCreatorFolder:kPFCFolderSavedProfiles] URLByAppendingPathComponent:profileFileName];
    return [profileURL path];
}

+ (NSString *)newPathInGroupFolder:(PFCFolders)groupFolder {
    NSString *profileGroupFileName = [NSString stringWithFormat:@"%@.pfcgrp", [[NSUUID UUID] UUIDString]];
    NSURL *profileGroupURL = [[self.class profileCreatorFolder:groupFolder] URLByAppendingPathComponent:profileGroupFileName];
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
    DDLogDebug(@"Is version: %@ lower than version: %@", version1, version2);

    if ([version1 isEqualToString:@"Latest"]) {
        version1 = @"999";
    }

    if ([version2 isEqualToString:@"Latest"]) {
        version2 = @"999";
    }
    DDLogDebug(@"returning=%@", ([version1 compare:version2 options:NSNumericSearch] == NSOrderedAscending) ? @"YES" : @"NO");
    if ([version1 isEqualToString:version2]) {
        return YES;
    } else {
        return [version1 compare:version2 options:NSNumericSearch] == NSOrderedAscending;
    }
} // version:isLaterThanVersion

+ (NSString *)dateIntervalFromNowToDate:(NSDate *)futureDate {

    // -------------------------------------------------------------------------
    //  Set allowed date units to year, month and day
    // -------------------------------------------------------------------------
    unsigned int allowedUnits = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;

    // -------------------------------------------------------------------------
    //  Use calendar US
    // -------------------------------------------------------------------------
    NSCalendar *calendarUS = [NSCalendar calendarWithIdentifier:NSCalendarIdentifierGregorian];
    [calendarUS setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];

    // -------------------------------------------------------------------------
    //  Remove all components except the allowed date units
    // -------------------------------------------------------------------------
    NSDateComponents *components = [calendarUS components:allowedUnits fromDate:futureDate];
    NSDate *date = [calendarUS dateFromComponents:components];
    NSDate *currentDate = [calendarUS dateFromComponents:[calendarUS components:allowedUnits fromDate:[NSDate date]]];

    // -------------------------------------------------------------------------
    //  Calculate the date interval
    // -------------------------------------------------------------------------
    NSTimeInterval secondsBetween = [date timeIntervalSinceDate:currentDate];

    // -------------------------------------------------------------------------
    //  Create date formatter to create the date in spelled out string format
    // -------------------------------------------------------------------------
    NSDateComponentsFormatter *dateComponentsFormatter = [[NSDateComponentsFormatter alloc] init];
    [dateComponentsFormatter setAllowedUnits:allowedUnits];
    [dateComponentsFormatter setMaximumUnitCount:3];
    [dateComponentsFormatter setUnitsStyle:NSDateComponentsFormatterUnitsStyleFull];
    [dateComponentsFormatter setCalendar:calendarUS];

    return [dateComponentsFormatter stringFromTimeInterval:secondsBetween];
} // dateIntervalFromNowToDate

@end
