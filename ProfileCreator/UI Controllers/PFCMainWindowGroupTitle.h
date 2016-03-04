//
//  PFCProfileGroupTitle.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-06.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef NS_ENUM(NSInteger, PFCProfileGroups) { kPFCProfileGroupAll = 0, kPFCProfileGroups, kPFCProfileSmartGroups };

////////////////////////////////////////////////////////////////////////////////
#pragma mark PFCProfileGroupDelegate
////////////////////////////////////////////////////////////////////////////////
@protocol PFCGroupDelegate
- (void)createNewGroupOfType:(PFCProfileGroups)group;
@end

@interface PFCMainWindowGroupTitle : NSViewController
- (id)initWithGroup:(PFCProfileGroups)group sender:(id)sender;
+ (NSImage *)iconForGroup:(PFCProfileGroups)group;
@end

@interface PFCMainWindowGroupTitleView : NSView

// ------------------------------------------------------
//  Delegate
// ------------------------------------------------------
@property (nonatomic, weak) id delegate;

@property PFCProfileGroups group;
@property NSTrackingArea *trackingArea;
@property (weak) IBOutlet NSTextField *textFieldTitle;
@property (weak) IBOutlet NSButton *buttonAddGroup;
- (IBAction)buttonAddGroup:(id)sender;

@end
