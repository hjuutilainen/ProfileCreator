//
//  PFCODManager.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-03-01.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCODManager.h"
#import <OpenDirectory/OpenDirectory.h>

@interface PFCODManager ()

@property (copy, nonatomic) void (^odConnectionStatusAndNodes)(NSError *error, NSArray *nodes);
@property (copy, nonatomic) void (^notificatonComplete)(NSError *error);

@end

@implementation PFCODManager

- (void)testConnection:(void (^)(NSError *, NSArray *))odConnectionStatusAndNodes {
    if (odConnectionStatusAndNodes && !self.odConnectionStatusAndNodes) {
        self.odConnectionStatusAndNodes = odConnectionStatusAndNodes;
    }

    NSError *error = nil;
    ODSession *session = [self newSession:&error];
    if (session) {
        ODNode *node = [ODNode nodeWithSession:session type:kODNodeTypeAuthentication error:&error];
        if (node != nil) {
            NSArray *subnodes = [node subnodeNamesAndReturnError:&error];
            if ([subnodes count] != 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                  self.odConnectionStatusAndNodes(nil, subnodes);
                });
                return;
            }
        }
    }

    dispatch_async(dispatch_get_main_queue(), ^{
      self.odConnectionStatusAndNodes(error, nil);
    });
}

- (ODSession *)newSession:(NSError **)error {                   // Erik
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults]; // Testar
    NSString *odAddress = [ud objectForKey:@"ODAddress"];
    NSString *odPort = [[ud objectForKey:@"ODPort"] stringValue] ?: @"0";

    if ([odAddress length] != 0 && [odPort length] != 0) {
        return [ODSession sessionWithOptions:@{
            ODSessionProxyAddress : odAddress,
            ODSessionProxyPort : odPort,
            ODSessionProxyUsername : [ud objectForKey:@"ODUsername"] ?: @"",
            ODSessionProxyPassword : [ud objectForKey:@"ODPassword"] ?: @""
        }
                                       error:error];
    } else {
        *error = [NSError errorWithDomain:@"" code:-1 userInfo:@{ NSLocalizedDescriptionKey : @"Verify both address and port is entered" }];
    }
    return nil;
}

@end
