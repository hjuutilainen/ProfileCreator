//
//  PFCCellTypeTextFieldDaysHours.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-02-25.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface PFCTextFieldDaysHoursNoTitleCellView : NSTableCellView

@property id sender;
@property NSString *cellIdentifier;
@property NSNumber *stepperValueRemovalIntervalDays;
@property NSNumber *stepperValueRemovalIntervalHours;
@property (weak) IBOutlet NSTextField *settingDays;
@property (weak) IBOutlet NSStepper *settingStepperDays;
@property (weak) IBOutlet NSTextField *settingHours;
@property (weak) IBOutlet NSStepper *settingStepperHours;

- (PFCTextFieldDaysHoursNoTitleCellView *)populateCellView:(PFCTextFieldDaysHoursNoTitleCellView *)cellView
                                                  manifest:(NSDictionary *)manifest
                                                  settings:(NSDictionary *)settings
                                             settingsLocal:(NSDictionary *)settingsLocal
                                               displayKeys:(NSDictionary *)displayKeys
                                                       row:(NSInteger)row
                                                    sender:(id)sender;

@end
