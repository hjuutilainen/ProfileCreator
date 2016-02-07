//
//  PFCProfileGroupTitle.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-06.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

////////////////////////////////////////////////////////////////////////////////
#pragma mark PFCProfileGroupDelegate
////////////////////////////////////////////////////////////////////////////////
@protocol PFCProfileGroupDelegate
- (void)addGroup;
@end


@interface PFCProfileGroupTitle : NSViewController
@end

@interface PFCProfileGroupTitleView : NSView

// ------------------------------------------------------
//  Delegate
// ------------------------------------------------------
@property (nonatomic, weak) id delegate;
@property (weak) IBOutlet NSButton *buttonAddGroup;
- (IBAction)buttonAddGroup:(id)sender;

@property                 NSTrackingArea *trackingArea;

@end