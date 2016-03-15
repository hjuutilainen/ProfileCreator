//
//  PFCManifestLinter.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-03-13.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCLog.h"
#import "PFCManifestLibrary.h"
#import "PFCManifestLint.h"
#import "PFCManifestLintError.h"
#import "PFCManifestLinter.h"
#import "PFCManifestUtility.h"

@interface PFCManifestLinter ()

@property (weak) IBOutlet NSButton *buttonRun;
- (IBAction)buttonRun:(id)sender;
@property (weak) IBOutlet NSProgressIndicator *progressIndicatorRun;

@property NSArray *arrayReportAll;

@property NSMutableArray *arrayReport;
@property (weak) IBOutlet NSTableView *tableViewReport;

@property NSInteger selectedSeverity;

@end

@implementation PFCManifestLinter

static NSParagraphStyle *paragraphStyle(NSTextAlignment textAlignment) {
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setAlignment:textAlignment];
    return [style copy];
}

- (id)init {
    self = [super initWithWindowNibName:@"PFCManifestLinter"];
    if (self != nil) {

        _arrayReport = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:NSStringFromSelector(@selector(selectedSeverity)) context:nil];
}

- (void)windowDidLoad {
    [super windowDidLoad];

    [self addObserver:self forKeyPath:NSStringFromSelector(@selector(selectedSeverity)) options:NSKeyValueObservingOptionNew context:nil];
}

- (IBAction)buttonRun:(id)sender {

    [sender setEnabled:NO];
    [_progressIndicatorRun startAnimation:self];

    dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(taskQueue, ^{

      NSError *error = nil;
      NSArray *manifests = [[PFCManifestLibrary sharedLibrary] libraryAll:&error acceptCached:YES];
      if ([manifests count] != 0) {
          DDLogInfo(@"Found %lu manifests...", (unsigned long)[manifests count]);

          PFCManifestLint *linter = [[PFCManifestLint alloc] init];
          [self setArrayReportAll:[linter reportForManifests:manifests]];
          // DDLogDebug(@"Lint Report: %@", _arrayReportAll);

          if ([_arrayReportAll count] != 0) {
              dispatch_async(dispatch_get_main_queue(), ^{
                [_tableViewReport beginUpdates];
                [_arrayReport removeAllObjects];
                [_arrayReport addObjectsFromArray:[self arrayForSeverity:_selectedSeverity]];
                [_tableViewReport reloadData];
                [_tableViewReport endUpdates];
                dispatch_async(dispatch_get_main_queue(), ^{
                  [sender setEnabled:YES];
                  [_progressIndicatorRun stopAnimation:self];
                });
              });
          } else {
              // FIXME - Should notify user that all manifests passed without notice
              DDLogInfo(@"All manifests passed without remark");
              dispatch_async(dispatch_get_main_queue(), ^{
                [sender setEnabled:YES];
                [_progressIndicatorRun stopAnimation:self];
              });
          }
      } else {
          // FIXME - Should notify user that we didn't find any manifests.
          DDLogError(@"No manifests returned for linting");
          DDLogError(@"%@", [error localizedDescription]);
          dispatch_async(dispatch_get_main_queue(), ^{
            [sender setEnabled:YES];
            [_progressIndicatorRun stopAnimation:self];
          });
      }
    });
}

- (NSArray *)arrayForSeverity:(PFCLintErrorSeverity)severity {
    return [_arrayReportAll filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"%K <= %@", @"LintErrorSeverity", @(severity)]];
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableView DataSource Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [_arrayReport count];
} // numberOfRowsInTableView

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSTableView Delegate Methods
#pragma mark -
////////////////////////////////////////////////////////////////////////////////

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    NSDictionary *lintDict = _arrayReport[row];
    NSString *identifier = [tableColumn identifier];
    if ([@[ @"ManifestDomain", @"ManifestKey", @"ManifestKeyPath", @"LintErrorMessage", @"LintErrorSuggestedRecovery" ] containsObject:identifier]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"Text" owner:self];
        [[cellView textField] setStringValue:lintDict[identifier]];
        return cellView;
    } else if ([identifier isEqualToString:@"LintErrorCode"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"Text" owner:self];
        [[cellView textField] setAttributedStringValue:[[NSAttributedString alloc] initWithString:[lintDict[identifier] stringValue]
                                                                                       attributes:@{
                                                                                           NSFontAttributeName : [NSFont systemFontOfSize:[NSFont systemFontSizeForControlSize:NSRegularControlSize]],
                                                                                           NSParagraphStyleAttributeName : paragraphStyle(NSTextAlignmentCenter)
                                                                                       }]];
        return cellView;
    } else if ([identifier isEqualToString:@"LintErrorSeverity"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"Text" owner:self];
        [[cellView textField] setStringValue:[PFCManifestLintError nameForSeverity:[lintDict[identifier] integerValue]]];
        return cellView;
    } else if ([identifier isEqualToString:@"ManifestKeyValue"]) {
        NSTableCellView *cellView;
        NSString *valueType = [[PFCManifestUtility sharedUtility] typeStringFromValue:lintDict[identifier]];
        if ([valueType isEqualToString:PFCValueTypeString]) {
            cellView = [tableView makeViewWithIdentifier:@"Text" owner:self];
            [[cellView textField] setStringValue:lintDict[identifier]];
        } else if ([valueType isEqualToString:PFCValueTypeBoolean]) {
            cellView = [tableView makeViewWithIdentifier:@"Text" owner:self];
            [[cellView textField] setStringValue:[NSString stringWithFormat:@"<%@>", ([lintDict[identifier] boolValue]) ? @"True" : @"False"]];
        } else if ([valueType isEqualToString:PFCValueTypeInteger] || [valueType isEqualToString:PFCValueTypeFloat]) {
            cellView = [tableView makeViewWithIdentifier:@"Number" owner:self];
            [[cellView textField] setStringValue:[lintDict[identifier] stringValue]];
        } else if ([valueType isEqualToString:PFCValueTypeArray]) {
        } else if ([valueType isEqualToString:PFCValueTypeDict]) {
        } else if ([valueType isEqualToString:PFCValueTypeDate]) {
        } else if ([valueType isEqualToString:PFCValueTypeData]) {
        } else {
        }

        return cellView;
    }

    return nil;
}

////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSKeyValueObserving
#pragma mark -
////////////////////////////////////////////////////////////////////////////////
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)__unused object change:(NSDictionary *)__unused change context:(void *)__unused context {
    if ([keyPath isEqualToString:NSStringFromSelector(@selector(selectedSeverity))]) {
        [_tableViewReport beginUpdates];
        [_arrayReport removeAllObjects];
        [_arrayReport addObjectsFromArray:[self arrayForSeverity:_selectedSeverity]];
        [_tableViewReport reloadData];
        [_tableViewReport endUpdates];
    }
}

@end
