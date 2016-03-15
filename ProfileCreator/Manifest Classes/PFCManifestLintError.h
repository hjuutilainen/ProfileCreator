//
//  PFCManifestLintError.h
//  ProfileCreator
//
//  Created by Erik Berglund on 2016-03-13.
//  Copyright © 2016 Erik Berglund. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PFCLintErrorCodes) {
    /** KeyIgnored */
    kPFCLintErrorKeyIgnored,
    kPFCLintErrorKeyRequiredNotFound,
    kPFCLintErrorKeySuggestedNotFound,
    kPFCLintErrorValueInvalid,
    kPFCLintErrorValueRequiredNotFound,
    kPFCLintErrorDuplicate,
    kPFCLintErrorResourceNotFound,
    kPFCLintErrorKeyIncompatible
};

typedef NS_ENUM(NSInteger, PFCLintErrorSeverity) {
    /** Error **/
    kPFCLintErrorSeverityError,
    /** Warning **/
    kPFCLintErrorSeverityWarning,
    /** Notice **/
    kPFCLintErrorSeverityNotice,
    /** Info **/
    kPFCLintErrorSeverityInfo,
    /** Debug **/
    kPFCLintErrorSeverityDebug,
};

@interface PFCManifestLintError : NSObject

+ (NSString *)nameForSeverity:(PFCLintErrorSeverity)severity;
+ (NSDictionary *)errorWithCode:(PFCLintErrorCodes)code key:(NSString *)key keyPath:(NSString *)keyPath value:(id)value manifest:(NSDictionary *)manifest overrides:(NSDictionary *)overrides;

@end
