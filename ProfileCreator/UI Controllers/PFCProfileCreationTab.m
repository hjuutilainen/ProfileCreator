//
//  PFCProfileCreationTabBar.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-01-25.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCProfileCreationTab.h"

@interface PFCProfileCreationTab ()

@end

@implementation PFCProfileCreationTab

- (id)init {
    self = [super initWithNibName:@"PFCProfileCreationTab" bundle:nil];
    if (self != nil) {
        
    }
    return self;
} // init

- (void)viewDidLoad {
    [super viewDidLoad];
} // viewDidLoad

@end

@implementation PFCProfileCreationTabView

- (void)commonInit {
    _color = [NSColor clearColor];
    _colorSelected = [NSColor clearColor];
    _colorDeSelected = [[NSColor blackColor] colorWithAlphaComponent:0.1f];
    _colorDeSelectedMouseOver = [[NSColor blackColor] colorWithAlphaComponent:0.14f];
    
    // --------------------------------------------------------------
    //  Add Notification Observers
    // --------------------------------------------------------------
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tabIndexSelected:) name:@"selectTab" object:nil];
}

- (id)initWithFrame:(CGRect)aRect {
    if ((self = [super initWithFrame:aRect])) {
        [self commonInit];
    }
    return self;
} // initWithFrame

- (id)initWithCoder:(NSCoder*)coder {
    if ((self = [super initWithCoder:coder])) {
        [self commonInit];
    }
    return self;
} // initWithCoder

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"selectTab" object:nil];
} // dealloc

- (void)tabIndexSelected:(NSNotification *)notification {
    NSInteger indexSelected = [[notification userInfo][@"TabIndex"] integerValue];
    if ( [self tabIndex] == indexSelected ) {
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

- (NSInteger)tabIndex {
    id superview = [self superview];
    if ( [superview isKindOfClass:[NSStackView class]] ) {
        return [[(NSStackView *)superview views] indexOfObject:self];
    }
    return -1;
} // tabIndex

- (void)selectTab {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectTab"
                                                        object:self
                                                      userInfo:@{ @"TabIndex" : @([self tabIndex]) }];
} // selectTab

- (void)mouseDown:(NSEvent *)theEvent {
    [self selectTab];
} // mouseDown

- (void)mouseEntered:(NSEvent *)theEvent {
    
    // FIXME - Animate this change like safari tabs
    [_buttonClose setHidden:NO];
    if ( ! _isSelected ) {
        [self setColor:_colorDeSelectedMouseOver];
        [self display];
    }
} // mouseEntered

- (void)mouseExited:(NSEvent *)theEvent {
    
    // FIXME - Animate this change like safari tabs
    [_buttonClose setHidden:YES];
    if ( _isSelected ) {
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
    NSAttributedString *errorCountString = [[NSAttributedString alloc] initWithString:[errorCount stringValue] attributes:@{ NSForegroundColorAttributeName : [NSColor redColor] }];
    [_textFieldErrorCount setAttributedStringValue:errorCountString];
    if ( errorCount == 0 ) {
        [_textFieldErrorCount setHidden:YES];
    } else {
        [_textFieldErrorCount setHidden:NO];
    }
} // updateTitle

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

- (void)drawRect:(NSRect)aRect {
    [_color set];
    NSRectFillUsingOperation(aRect, NSCompositeSourceOver);
} // drawRect

- (IBAction)buttonClose:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"closeTab"
                                                        object:self
                                                      userInfo:@{ @"TabIndex" : @([self tabIndex]), @"TabView" : self }];
} // buttonClose

@end