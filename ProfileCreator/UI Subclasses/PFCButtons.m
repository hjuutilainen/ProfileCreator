//
//  PFCButtons.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-01-31.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCButtons.h"

@implementation PFCMenuButton

- (void)customInit {
    // Do custom
}

- (id)initWithFrame:(CGRect)aRect {
    if ((self = [super initWithFrame:aRect])) {
        [self customInit];
    }
    return self;
} // initWithFrame

- (id)initWithCoder:(NSCoder*)coder {
    if ((self = [super initWithCoder:coder])) {
        [self customInit];
    }
    return self;
} // initWithCoder

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)mouseDown:(NSEvent *)theEvent {
    NSLog(@"mouseDown");
}

- (void)mouseUp:(NSEvent *)theEvent {
    // Selects here
    NSLog(@"mouseUp");
} // mouseUp

- (void)mouseEntered:(NSEvent *)theEvent {
    NSLog(@"mouseEntered");
} // mouseEntered

- (void)mouseExited:(NSEvent *)theEvent {
    NSLog(@"mouseExited");
} // mouseExited

- (void)updateTrackingAreas {
    if (_trackingArea != nil ) {
        [self removeTrackingArea:_trackingArea];
    }
    
    int opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    [self setTrackingArea:[[NSTrackingArea alloc] initWithRect:[self bounds]
                                                       options:opts
                                                         owner:self
                                                      userInfo:nil]];
    [self addTrackingArea:_trackingArea];
} // updateTrackingAreas

@end
