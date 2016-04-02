//
//  PFCButtons.m
//  ProfileCreator
//
//  Created by Erik Berglund.
//  Copyright (c) 2016 ProfileCreator. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

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

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super initWithCoder:coder])) {
        [self customInit];
    }
    return self;
} // initWithCoder

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
}

- (void)mouseDown:(NSEvent *)theEvent {
}

- (void)mouseUp:(NSEvent *)theEvent {
    // Selects here
} // mouseUp

- (void)mouseEntered:(NSEvent *)theEvent {
} // mouseEntered

- (void)mouseExited:(NSEvent *)theEvent {
} // mouseExited

- (void)updateTrackingAreas {
    if (_trackingArea != nil) {
        [self removeTrackingArea:_trackingArea];
    }

    NSUInteger opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    [self setTrackingArea:[[NSTrackingArea alloc] initWithRect:[self bounds] options:opts owner:self userInfo:nil]];
    [self addTrackingArea:_trackingArea];
} // updateTrackingAreas

@end
