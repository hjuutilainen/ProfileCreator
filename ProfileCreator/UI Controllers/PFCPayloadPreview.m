//
//  PFCPayloadPreview.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-11.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCPayloadPreview.h"
#import "PFCTableViewCellsPayloadPreview.h"

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
    
    if ( ! _arrayPayloadInfo ) {
        [self setArrayPayloadInfo:[[NSMutableArray alloc] init]];
    }
    [_arrayPayloadInfo addObject:@{ @"Title" : @"Preview Not Implemented Yet" }];
    [_tableViewPayloadInfo reloadData];
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
    if ( [_arrayPayloadInfo count] == 0 || [_arrayPayloadInfo count] < row ) {
        return nil;
    }
    
    NSDictionary *infoDict = _arrayPayloadInfo[row];
    NSLog(@"infoDict=%@", infoDict);
    if ( [[tableColumn identifier] isEqualToString:@"TableColumnInfoTitle"] ) {
        CellViewInfoTitle *cellView = [tableView makeViewWithIdentifier:@"CellViewInfoTitle" owner:self];
        [cellView setIdentifier:nil]; // <-- Disables automatic retaining of the view ( and it's stored values ).
        return [cellView populateCellViewInfoTitle:cellView infoDict:infoDict row:row];
    } else {
        return nil;
    }
}

@end
