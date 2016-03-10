//
//  PFCProfileEditorManifestTab.m
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

#import "PFCProfileEditorManifestTab.h"

@interface PFCProfileEditorManifestTab ()

@end

@implementation PFCProfileEditorManifestTab

- (id)init {
    self = [super initWithNibName:@"PFCProfileEditorManifestTab" bundle:nil];
    if (self != nil) {
    }
    return self;
} // init

- (void)viewDidLoad {
    [super viewDidLoad];
} // viewDidLoad

@end

@implementation PFCProfileEditorManifestTabView

- (void)customInit {
    _color = [NSColor clearColor];
    _colorSelected = [NSColor clearColor];
    _colorDeSelected = [[NSColor blackColor] colorWithAlphaComponent:0.1f];
    _colorDeSelectedMouseOver = [[NSColor blackColor] colorWithAlphaComponent:0.14f];

    // --------------------------------------------------------------
    //  Add Notification Observers
    // --------------------------------------------------------------
    [self addObserver:self forKeyPath:@"isSelected" options:NSKeyValueObservingOptionNew context:nil];
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

- (void)dealloc {
    _delegate = nil;
    [self removeObserver:self forKeyPath:@"isSelected" context:nil];
} // dealloc

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)__unused object change:(NSDictionary *)change context:(void *)__unused context {
    if ([keyPath isEqualToString:@"isSelected"]) {
        if (_isSelected) {
            [_borderBottom setHidden:YES];
            [self setColor:_colorSelected];
            [self display];
        } else {
            [_borderBottom setHidden:NO];
            [self setColor:_colorDeSelected];
            [self display];
        }
    }
} // observeValueForKeyPath:ofObject:change:context

- (void)tabIndexSelected:(NSNotification *)notification {
    NSInteger indexSelected = [[notification userInfo][@"TabIndex"] integerValue];
    if ([self tabIndex] == indexSelected) {
        [_borderBottom setHidden:YES];
        [self setColor:_colorSelected];
        [self display];
        [self setIsSelected:YES];
    } else {
        [_borderBottom setHidden:NO];
        [self setColor:_colorDeSelected];
        [self display];
        [self setIsSelected:NO];
    }
} // tabIndexSelected

- (NSUInteger)tabIndex {
    id superview = [self superview];
    if ([superview isKindOfClass:[NSStackView class]]) {
        return [[(NSStackView *)superview views] indexOfObject:self];
    }
    return (NSUInteger)-1;
} // tabIndex

- (void)selectTab {
    if (_delegate) {
        [_delegate selectTab:[self tabIndex] saveSettings:YES sender:self];
    }
} // selectTab

- (void)mouseDown:(NSEvent *)theEvent {
    [self selectTab];
} // mouseDown

- (void)mouseEntered:(NSEvent *)theEvent {

    // FIXME - Animate this change like safari tabs
    [_buttonClose setHidden:NO];
    if (!_isSelected) {
        [self setColor:_colorDeSelectedMouseOver];
        [self display];
    }
} // mouseEntered

- (void)mouseExited:(NSEvent *)theEvent {

    // FIXME - Animate this change like safari tabs
    [_buttonClose setHidden:YES];
    if (_isSelected) {
        [self setColor:_colorSelected];
        [self display];
    } else {
        [self setColor:_colorDeSelected];
        [self display];
    }
} // mouseExited

- (void)updateTitle:(NSString *)title {
    [_textFieldTitle setStringValue:title ?: @""];
} // updateTitle

- (void)updateErrorCount:(NSNumber *)errorCount {
    NSAttributedString *errorCountString = [[NSAttributedString alloc] initWithString:[errorCount stringValue] attributes:@{NSForegroundColorAttributeName : [NSColor redColor]}];
    [_textFieldErrorCount setAttributedStringValue:errorCountString];
    if ([errorCount integerValue] == 0) {
        [_textFieldErrorCount setHidden:YES];
    } else {
        [_textFieldErrorCount setHidden:NO];
    }
} // updateTitle

- (void)updateTrackingAreas {
    if (_trackingArea != nil) {
        [self removeTrackingArea:_trackingArea];
    }

    NSUInteger opts = (NSTrackingMouseEnteredAndExited | NSTrackingActiveAlways);
    [self setTrackingArea:[[NSTrackingArea alloc] initWithRect:[self bounds] options:opts owner:self userInfo:nil]];
    [self addTrackingArea:_trackingArea];
} // updateTrackingAreas

- (void)drawRect:(NSRect)aRect {
    [_color set];
    NSRectFillUsingOperation(aRect, NSCompositeSourceOver);
} // drawRect

- (IBAction)buttonClose:(id)sender {
    if (_delegate) {
        if ([_delegate shouldCloseTab:[self tabIndex] sender:self]) {
            [_delegate closeTab:[self tabIndex] sender:self];
        }
    }
} // buttonClose

@end
