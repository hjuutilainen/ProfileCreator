//
//  PFCPreferencesMCX.m
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

#import "PFCLog.h"
#import "PFCODManager.h"
#import "PFCPreferencesMCX.h"

@interface PFCPreferencesMCX ()

- (IBAction)buttonTestOD:(id)sender;
@property (weak) IBOutlet NSProgressIndicator *progressIndicatorTestOD;

@end

@implementation PFCPreferencesMCX

- (id)init {
    self = [super initWithNibName:@"PFCPreferencesMCX" bundle:nil];
    if (self != nil) {
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
      if (error != nil || nodes.count == 0) {
          [[NSUserDefaults standardUserDefaults] setObject:nodes forKey:@"ODNodes"];
          [[NSAlert alertWithError:error] beginSheetModalForWindow:[[NSApplication sharedApplication] mainWindow]
                                                 completionHandler:^(NSModalResponse returnCode){

                                                 }];
      } else if (nodes.count != 0) {
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
