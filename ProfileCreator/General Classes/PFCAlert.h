//
//  PFCAlert.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-08.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

////////////////////////////////////////////////////////////////////////////////
#pragma mark Protocol: PFCAlertDelegate
////////////////////////////////////////////////////////////////////////////////
@protocol PFCAlertDelegate
- (void)alertReturnCode:(NSInteger)returnCode alertInfo:(NSDictionary *)alertInfo;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark PFCAlert
////////////////////////////////////////////////////////////////////////////////
@interface PFCAlert : NSObject

// ------------------------------------------------------
//  Delegate
// ------------------------------------------------------
@property (nonatomic, weak) id delegate;

// ------------------------------------------------------
//  Instance Methods
// ------------------------------------------------------
- (id)initWithDelegate:(id<PFCAlertDelegate>)delegate;
- (void)showAlertDeleteGroup:(NSString *)groupName alertInfo:(NSDictionary *)alertInfo;
@end
