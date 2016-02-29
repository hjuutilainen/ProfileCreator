//
//  PFCMainWindowSort.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-29.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCMainWindowSort.h"

@interface PFCMainWindowSort ()

@property (weak) IBOutlet NSPopUpButton *popUpButtonSort;
- (IBAction)popUpButtonSort:(id)sender;

@end

@implementation PFCMainWindowSort

- (id)init {
    self = [super initWithNibName:@"PFCMainWindowSort" bundle:nil];
    if ( self != nil ) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupPopUpButton];
}

- (void)setupPopUpButton {
    NSMenu *menu = [[NSMenu alloc] init];
    
    NSMenuItem *menuItemAlphabetically = [[NSMenuItem alloc] init];
    [menuItemAlphabetically setTitle:@"Alphabetically"];
    [menu addItem:menuItemAlphabetically];
    
    [menu addItem:[NSMenuItem separatorItem]];
    
    NSMenuItem *menuItemAscending = [[NSMenuItem alloc] init];
    [menuItemAscending setTitle:@"Ascending"];
    [menu addItem:menuItemAscending];
    
    NSMenuItem *menuItemDescending = [[NSMenuItem alloc] init];
    [menuItemDescending setTitle:@"Descending"];
    [menu addItem:menuItemDescending];
    
    [_popUpButtonSort setMenu:menu];
}

- (IBAction)popUpButtonSort:(id)sender {
    NSLog(@"popUpButtonSort=%@", sender);
    NSLog(@"%@", [sender selectedItem]);
}

@end
