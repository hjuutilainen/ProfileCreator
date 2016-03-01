//
//  PFCPreferences.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-03-01.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCPreferences.h"
#import "PFCPreferencesGeneral.h"
#import "PFCPreferencesMCX.h"
#import "PFCPreferencesLogging.h"
#import "PFCGeneralUtility.h"

@interface PFCPreferences ()

@property (weak) IBOutlet NSView *viewPreferences;

@property PFCPreferencesGeneral *general;
- (IBAction)toolbarItemGeneral:(id)sender;

@property PFCPreferencesMCX *mcx;
- (IBAction)toolbarItemMCX:(id)sender;

@property PFCPreferencesLogging *logging;
- (IBAction)toolbarItemLogging:(id)sender;

@end

@implementation PFCPreferences

- (id)init {
    self = [super initWithWindowNibName:@"PFCPreferences"];
    if ( self != nil ) {
        
    }
    return self;
}

- (void)windowDidLoad {
    [super windowDidLoad];
    
    [self setGeneral:[[PFCPreferencesGeneral alloc] init]];
    [self setMcx:[[PFCPreferencesMCX alloc] init]];
    [self setLogging:[[PFCPreferencesLogging alloc] init]];
    [self toolbarItemGeneral:nil];
}

- (IBAction)toolbarItemGeneral:(id) __unused sender {
    [[self window] setTitle:@"General"];
    [PFCGeneralUtility removeSubviewsFromView:_viewPreferences];
    [self updateWindowSizeForView:[_general view]];
    [PFCGeneralUtility insertSubview:[_general view] inSuperview:_viewPreferences hidden:NO];
}

- (IBAction)toolbarItemMCX:(id) __unused sender {
    [[self window] setTitle:@"MCX"];
    [PFCGeneralUtility removeSubviewsFromView:_viewPreferences];
    [self updateWindowSizeForView:[_mcx view]];
    [PFCGeneralUtility insertSubview:[_mcx view] inSuperview:_viewPreferences hidden:NO];
}

- (IBAction)toolbarItemLogging:(id)sender {
    [[self window] setTitle:@"Logging"];
    [PFCGeneralUtility removeSubviewsFromView:_viewPreferences];
    [self updateWindowSizeForView:[_logging view]];
    [PFCGeneralUtility insertSubview:[_logging view] inSuperview:_viewPreferences hidden:NO];
}

- (void)updateWindowSizeForView:(NSView *)view {
    
    NSRect frame = [[self window] frame];
    NSRect oldView = [_viewPreferences frame];
    NSRect newView = [view frame];
    
    //frame.origin.y = ( frame.size.height + (( frame.size.height - oldView.size.height ) + newView.size.height ) );
    frame.size.height = ( ( frame.size.height - oldView.size.height ) + newView.size.height );
    
    [[self window] setFrame:frame display:YES animate:YES];
    
    /*
     NSDictionary *windowResize = [NSDictionary dictionaryWithObjectsAndKeys: [self window], NSViewAnimationTargetKey,[NSValue valueWithRect: frame],NSViewAnimationEndFrameKey, nil];
     NSDictionary *oldFadeOut = [NSDictionary dictionaryWithObjectsAndKeys:@{}, NSViewAnimationTargetKey,NSViewAnimationFadeOutEffect,NSViewAnimationEffectKey, nil];
     NSDictionary *newFadeIn = [NSDictionary dictionaryWithObjectsAndKeys:@{}, NSViewAnimationTargetKey,NSViewAnimationFadeInEffect, NSViewAnimationEffectKey, nil];
     
     NSArray *animations = [NSArray arrayWithObjects:windowResize, newFadeIn, oldFadeOut, nil];
     NSViewAnimation *animation = [[NSViewAnimation alloc] initWithViewAnimations: animations];
     
     [animation setAnimationBlockingMode: NSAnimationBlocking];
     [animation setAnimationCurve: NSAnimationEaseIn];
     [animation setDuration: 2];
     [animation startAnimation];
     */
}

@end
