//
//  PFCProfileCreationTabBar.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-01-25.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class PFCProfileCreationTabView;

////////////////////////////////////////////////////////////////////////////////
#pragma mark PFCProfileCreationTabDelegate
////////////////////////////////////////////////////////////////////////////////
@protocol PFCProfileCreationTabDelegate
- (void)tabIndexSelected:(NSUInteger)tabIndex saveSettings:(BOOL)saveSettings sender:(id)sender;
- (BOOL)tabIndexShouldClose:(NSUInteger)tabIndex sender:(id)sender;
- (void)tabIndexClose:(NSUInteger)tabIndex sender:(id)sender;
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark PFCProfileCreationTab
////////////////////////////////////////////////////////////////////////////////
@interface PFCProfileCreationTab : NSViewController
@end

////////////////////////////////////////////////////////////////////////////////
#pragma mark PFCProfileCreationTabView
////////////////////////////////////////////////////////////////////////////////
@interface PFCProfileCreationTabView : NSView

// ------------------------------------------------------
//  Delegate
// ------------------------------------------------------
@property (nonatomic, weak) id delegate;

@property (weak) IBOutlet NSBox *borderBottom;
@property (weak) IBOutlet NSTextField *textFieldTitle;
@property (weak) IBOutlet NSTextField *textFieldErrorCount;
@property (weak) IBOutlet NSButton *buttonClose;
@property BOOL isSelected;
@property NSTrackingArea *trackingArea;

@property NSColor *colorSelected;
@property NSColor *colorDeSelected;
@property NSColor *colorDeSelectedMouseOver;
@property NSColor *color;

- (NSUInteger)tabIndex;
- (void)updateTitle:(NSString *)title;
- (void)updateErrorCount:(NSNumber *)errorCount;
- (IBAction)buttonClose:(id)sender;

@end
