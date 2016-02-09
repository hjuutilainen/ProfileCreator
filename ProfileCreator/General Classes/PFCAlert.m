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

- (void)showAlertDeleteGroup:(NSString *)groupName alertInfo:(NSDictionary *)alertInfo {
    NSAlert *alert = [[NSAlert alloc] init];
    [alert addButtonWithTitle:PFCButtonTitleCancel];    //NSAlertFirstButton
    [alert addButtonWithTitle:PFCButtonTitleDelete];    //NSAlertSecondButton
    [alert setMessageText:[NSString stringWithFormat:@"Are you sure you want to delete the group \"%@\"?", groupName]];
    [alert setAlertStyle:NSCriticalAlertStyle];
    [alert beginSheetModalForWindow:[_delegate window] completionHandler:^(NSInteger returnCode) {
        [_delegate alertReturnCode:returnCode alertInfo:alertInfo];
    }];
} // showAlertDeleteGroup:alertInfo

@end
