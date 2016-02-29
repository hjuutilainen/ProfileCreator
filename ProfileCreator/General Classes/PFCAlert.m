//
//  PFCAlert.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-08.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCAlert.h"
#import "PFCConstants.h"

@implementation PFCAlert

- (id)initWithDelegate:(id<PFCAlertDelegate>)delegate {
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
} // initWithDelegate

- (void)showAlertDeleteGroups:(NSArray *)groupNames alertInfo:(NSDictionary *)alertInfo {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:PFCButtonTitleCancel];    //NSAlertFirstButton
    [alert addButtonWithTitle:PFCButtonTitleDelete];    //NSAlertSecondButton
    NSInteger groupCount = [groupNames count];
    id groupList;
    if ( groupCount == 1 ) {
        groupList = [NSString stringWithFormat:@"\"%@\"", [groupNames firstObject]];
    } else {
        groupList = [[NSMutableString alloc] init];
        for ( NSString *groupName in groupNames ) {
            [groupList appendString:[NSString stringWithFormat:@"   • %@\n", groupName]];
        }
    }
    [alert setMessageText:[NSString stringWithFormat:@"Are you sure you want to remove %@ %@ %@", (groupCount == 1) ? @"the group" : @"these groups:\n\n", groupList, (groupCount == 1) ? @"?" : @""]];
    [alert setInformativeText:@"No profile will be deleted"];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert beginSheetModalForWindow:[_delegate window] completionHandler:^(NSInteger returnCode) {
        [_delegate alertReturnCode:returnCode alertInfo:alertInfo];
    }];
} // showAlertDeleteGroup:alertInfo

- (void)showAlertDeleteProfiles:(NSArray *)profileNames alertInfo:(NSDictionary *)alertInfo {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:PFCButtonTitleCancel];    //NSAlertFirstButton
    [alert addButtonWithTitle:PFCButtonTitleDelete];    //NSAlertSecondButton
    NSInteger profileCount = [profileNames count];
    id profileList;
    if ( profileCount == 1 ) {
        profileList = [NSString stringWithFormat:@"\"%@\"", [profileNames firstObject]];
    } else {
        profileList = [[NSMutableString alloc] init];
        for ( NSString *profileName in profileNames ) {
            [profileList appendString:[NSString stringWithFormat:@"   • %@\n", profileName]];
        }
    }
    if ( profileCount == 1 ) {
        [alert setMessageText:[NSString stringWithFormat:@"Are you sure you want to delete the profile %@?", profileList]];
        [alert setInformativeText:@"This cannot be undone."];
    } else {
        [alert setMessageText:@"Are you sure you want to delete the following profiles:"];
        [alert setInformativeText:[NSString stringWithFormat:@"%@\nThis cannot be undone.", profileList]];
    }
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert beginSheetModalForWindow:[_delegate window] completionHandler:^(NSInteger returnCode) {
        [_delegate alertReturnCode:returnCode alertInfo:alertInfo];
    }];
} // showAlertDeleteProfiles:alertInfo

- (void)showAlertDeleteProfiles:(NSArray *)profileNames fromGroup:(NSString *)groupName alertInfo:(NSDictionary *)alertInfo {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:PFCButtonTitleCancel];    //NSAlertFirstButton
    [alert addButtonWithTitle:PFCButtonTitleDelete];    //NSAlertSecondButton
    NSInteger profileCount = [profileNames count];
    id profileList;
    if ( profileCount == 1 ) {
        profileList = [NSString stringWithFormat:@"\"%@\"", [profileNames firstObject]];
    } else {
        profileList = [[NSMutableString alloc] init];
        for ( NSString *profileName in profileNames ) {
            [profileList appendString:[NSString stringWithFormat:@"   • %@\n", profileName]];
        }
    }
    [alert setMessageText:[NSString stringWithFormat:@"Are you sure you want to remove %@ from group \"%@\"?", (profileCount == 1) ? [NSString stringWithFormat:@"%@ %@", @"the profile", profileList] : @"the following profiles", groupName]];
    [alert setInformativeText:[NSString stringWithFormat:@"%@%@", (profileCount == 1) ? @"" : [NSString stringWithFormat:@"%@\n", profileList], @"No profile will be deleted"]];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert beginSheetModalForWindow:[_delegate window] completionHandler:^(NSInteger returnCode) {
        [_delegate alertReturnCode:returnCode alertInfo:alertInfo];
    }];
} // showAlertDeleteProfilesFromGroup:alertInfo

@end
