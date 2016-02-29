//
//  PFCProfileGroupTitle.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-06.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, PFCProfileGroups) {
    kPFCProfileGroupAll = 0,
    kPFCProfileGroups,
    kPFCProfileSmartGroups
};

////////////////////////////////////////////////////////////////////////////////
#pragma mark PFCProfileGroupDelegate
////////////////////////////////////////////////////////////////////////////////
@protocol PFCProfileGroupDelegate
- (void)createNewGroupOfType:(PFCProfileGroups)group;
@end


@interface PFCMainWindowGroupsTitle : NSViewController
@end

@interface PFCMainWindowGroupsTitleView : NSView

// ------------------------------------------------------
//  Delegate
// ------------------------------------------------------
@property (nonatomic, weak) id delegate;

@property PFCProfileGroups profileGroup;

@property (weak) IBOutlet NSTextField *textFieldTitle;
@property (weak) IBOutlet NSButton *buttonAddGroup;
- (IBAction)buttonAddGroup:(id)sender;
@property NSTrackingArea *trackingArea;

@end