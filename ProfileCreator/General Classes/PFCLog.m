//
//  PFCLog.m
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-01-27.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import "PFCLog.h"
#import "PFCLogFormatter.h"
#import "PFCConstants.h"

DDLogLevel ddLogLevel;

@implementation PFCLog

+ (void)configureLoggingForSession:(int)sessionType {
    
    // --------------------------------------------------------------
    //  Log to Console (Xcode/Commandline)
    // --------------------------------------------------------------
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [[DDTTYLogger sharedInstance] setLogFormatter:[[PFCLogFormatter alloc] init]];
    
    // --------------------------------------------------------------
    //  Log to File
    // --------------------------------------------------------------
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    [fileLogger setMaximumFileSize:10000000]; // 10000000 = 10 MB
    [fileLogger setRollingFrequency:0];
    [[fileLogger logFileManager] setMaximumNumberOfLogFiles:7];
    [fileLogger setLogFormatter:[[PFCLogFormatter alloc] init]];
    [DDLog addLogger:fileLogger];
    
    // --------------------------------------------------------------
    //  Set log level from setting in application preferences
    // --------------------------------------------------------------
    NSNumber *logLevel = [[NSUserDefaults standardUserDefaults] objectForKey:PFCUserDefaultsLogLevel];
    if ( logLevel ) {

        // --------------------------------------------------------------
        //  If log level was set to Debug, lower to Info
        // --------------------------------------------------------------
        if ( [logLevel intValue] == (int)DDLogLevelDebug ) {
            ddLogLevel = DDLogLevelInfo;
            [[NSUserDefaults standardUserDefaults] setObject:@((int)ddLogLevel) forKey:PFCUserDefaultsLogLevel];
        } else {
            ddLogLevel = (DDLogLevel)[logLevel intValue];
        }
    } else {
        ddLogLevel = DDLogLevelWarning;
        [[NSUserDefaults standardUserDefaults] setObject:@((int)ddLogLevel) forKey:PFCUserDefaultsLogLevel];
    }
    
    // FIXME - Force Verbose Logging
    ddLogLevel = DDLogLevelVerbose;
    
    NSString *logLevelName;
    
    switch (sessionType) {
        case kPFCSessionTypeCLI:
            
            break;
        case kPFCSessionTypeGUI:
            DDLogInfo(@"Starting ProfileCreator version %@ (build %@)...", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]);
            switch (ddLogLevel) {
                case 1:
                    logLevelName = @"Error";
                    break;
                case 3:
                    logLevelName = @"Warn";
                    break;
                case 7:
                    logLevelName = @"Info";
                    break;
                case 15:
                    logLevelName = @"Debug";
                    break;
                default:
                    logLevelName = [@((int)ddLogLevel) stringValue];
                    break;
            }
            DDLogInfo(@"Log level: %@", logLevelName);
            break;
        default:
            break;
    }
} // configureLoggingForSession

+ (DDFileLogger *)fileLogger {
    NSArray *allLoggers = [DDLog allLoggers];
    NSUInteger indexOfFileLogger = [allLoggers indexOfObjectPassingTest:^(id logger, NSUInteger __unused idx, BOOL __unused *stop) {
        return [logger isKindOfClass:[DDFileLogger class]];
    }];
    
    return indexOfFileLogger == NSNotFound ? nil : [allLoggers objectAtIndex:indexOfFileLogger];
} // fileLogger

@end
