//
//  PFCPayloadPreview.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-11.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCPayloadPreview.h"

@interface PFCPayloadPreview ()

@end

@implementation PFCPayloadPreview

- (id)init {
    self = [super initWithNibName:@"PFCPayloadPreview" bundle:nil];
    if (self != nil) {
        [[self view] setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self setIsCollapsed:YES];
    }
    return self;
} // init

- (void)viewDidLoad {
    [super viewDidLoad];
} // viewDidLoad

- (IBAction)buttonDisclosureTriangle:(id)sender {
    if ( _isCollapsed ) {
        [self setIsCollapsed:NO];
        [[self view] removeConstraint:_layoutConstraintDescriptionBottom];
    } else {
        [self setIsCollapsed:YES];
        [[self view] addConstraint:_layoutConstraintDescriptionBottom];
    }
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        [context setDuration:0.15f];
        [context setAllowsImplicitAnimation:YES];
        [[[self view] superview] layoutSubtreeIfNeeded];
    } completionHandler:NULL];
}

@end
