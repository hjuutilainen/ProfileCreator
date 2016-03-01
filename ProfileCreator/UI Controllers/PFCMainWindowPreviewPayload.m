//
//  PFCPayloadPreview.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-11.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "NSView+NSLayoutConstraintFilter.h"
#import "PFCLog.h"
#import "PFCMainWindowPreviewPayload.h"
#import "PFCTableViewCellsPayloadPreview.h"
@import QuartzCore;

@interface PFCMainWindowPreviewPayload ()

@property (weak) IBOutlet NSScrollView *scrollViewTableView;

@end

@implementation PFCMainWindowPreviewPayload

- (id)init {
    self = [super initWithNibName:@"PFCMainWindowPreviewPayload" bundle:nil];
    if (self != nil) {
        [[self view] setTranslatesAutoresizingMaskIntoConstraints:NO];
        [self addObserver:self forKeyPath:@"payloadErrorCount" options:0 context:nil];
        [self setIsCollapsed:YES];
    }
    return self;
} // init

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *, id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"payloadErrorCount"]) {

        // Error is inverted, didn't find a good name.
        BOOL error = ([_payloadErrorCount integerValue] == 0);
        [_textFieldPayloadErrorCount setHidden:error];
        if (error) {
            [_textFieldPayloadName setTextColor:[NSColor labelColor]];
            [_textFieldPayloadDescription setTextColor:[NSColor secondaryLabelColor]];
        } else {
            [_textFieldPayloadName setTextColor:[NSColor redColor]];
            [_textFieldPayloadDescription setTextColor:[NSColor redColor]];
        }
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"payloadErrorCount"];
} // dealloc

- (void)viewDidLoad {
    [super viewDidLoad];

    if (!_arrayPayloadInfo) {
        [self setArrayPayloadInfo:[[NSMutableArray alloc] init]];
    }
    [_arrayPayloadInfo addObject:@{ @"Title" : @"Preview Not Implemented Yet" }];
    [_tableViewPayloadInfo reloadData];
} // viewDidLoad

- (void)setTableViewHeight:(int)tableHeight tableView:(NSScrollView *)scrollView {
    NSLayoutConstraint *constraint = [scrollView constraintForAttribute:NSLayoutAttributeHeight];
    [constraint setConstant:tableHeight];
} // setTableViewHeight

- (IBAction)buttonDisclosureTriangle:(id)sender {
    if (_isCollapsed) {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *_Nonnull context) {
          [context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
          self.layoutConstraintDescriptionBottom.animator.constant += ([[_scrollViewTableView constraintForAttribute:NSLayoutAttributeHeight] constant] + 7);
          [[[self view] superview] layoutSubtreeIfNeeded];
        }
            completionHandler:^{
              [[self view] removeConstraint:_layoutConstraintDescriptionBottom];
              [self setIsCollapsed:NO];
            }];
    } else {
        [_layoutConstraintDescriptionBottom setConstant:(self.view.bounds.size.height - 47.0f)];
        [[self view] addConstraint:_layoutConstraintDescriptionBottom];
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext *_Nonnull context) {
          [context setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
          [[_layoutConstraintDescriptionBottom animator] setConstant:7];
          [[[self view] superview] layoutSubtreeIfNeeded];
        }
            completionHandler:^{
              [self setIsCollapsed:YES];
            }];
    }
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableView DataSource Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_arrayPayloadInfo count];
} // numberOfRowsInTableView

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {

    // ---------------------------------------------------------------------
    //  Verify the info array isn't empty, if so stop here
    // ---------------------------------------------------------------------
    if ([_arrayPayloadInfo count] == 0 || [_arrayPayloadInfo count] < row) {
        return nil;
    }

    NSDictionary *infoDict = _arrayPayloadInfo[row];
    if ([[tableColumn identifier] isEqualToString:@"TableColumnInfoTitle"]) {
        CellViewInfoTitle *cellView = [tableView makeViewWithIdentifier:@"CellViewInfoTitle" owner:self];
        [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
        return [cellView populateCellViewInfoTitle:cellView infoDict:infoDict row:row];
    } else {
        return nil;
    }
}

@end
