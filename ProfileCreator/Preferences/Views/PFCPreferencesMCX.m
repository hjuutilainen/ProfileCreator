//
//  PFCPreferencesMCX.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-03-01.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCPreferencesMCX.h"
#import "PFCLog.h"
#import "PFCODManager.h"

@interface PFCPreferencesMCX ()

- (IBAction)buttonTestOD:(id)sender;
@property (weak) IBOutlet NSProgressIndicator *progressIndicatorTestOD;

@end

@implementation PFCPreferencesMCX

- (id)init {
    self = [super initWithNibName:@"PFCPreferencesMCX" bundle:nil];
    if ( self != nil ) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)buttonTestOD:(id)sender {
    [sender setEnabled:NO];
    [_progressIndicatorTestOD setHidden:NO];
    [_progressIndicatorTestOD startAnimation:self];
    
    void (^odConnectionStatusAndNodes)(NSError *, NSArray *) = ^void(NSError *error, NSArray *nodes) {
        if ( error != nil || [nodes count] == 0 ) {
            [[NSUserDefaults standardUserDefaults] setObject:nodes forKey:@"ODNodes"];
            [[NSAlert alertWithError:error] beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow] completionHandler:^(NSModalResponse returnCode) {
                
            }];
        } else if ( [nodes count] != 0 ) {
            [[NSUserDefaults standardUserDefaults] setObject:nodes forKey:@"ODNodes"];
            DDLogDebug(@"Nodes returned from Open Directory: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"ODNodes"]);
        }
        [sender setEnabled:YES];
        [_progressIndicatorTestOD setHidden:YES];
        [_progressIndicatorTestOD stopAnimation:self];
    };
    
    PFCODManager *odManager = [[PFCODManager alloc] init];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [odManager testConnection:odConnectionStatusAndNodes];
    });
}

@end
