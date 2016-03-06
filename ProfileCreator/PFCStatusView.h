//
//  PFCStatusView.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-03-05.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFCStatusView : NSViewController

@property NSNumber *counter;

- (id)initWithStatusType:(PFCStatus)status;
- (void)showStatus:(PFCStatus)status;

@end
