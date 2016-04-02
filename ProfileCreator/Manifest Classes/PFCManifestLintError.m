//
//  PFCManifestLintError.m
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

#import "PFCConstants.h"
#import "PFCManifestLintError.h"
#import "PFCManifestUtility.h"

@implementation PFCManifestLintError

+ (NSString *)nameForSeverity:(PFCLintErrorSeverity)severity {
    switch (severity) {
    case kPFCLintErrorSeverityError:
        return @"Error";
        break;

    case kPFCLintErrorSeverityWarning:
        return @"Warning";
        break;

    case kPFCLintErrorSeverityInfo:
        return @"Info";
        break;

    case kPFCLintErrorSeverityNotice:
        return @"Notice";
        break;

    case kPFCLintErrorSeverityDebug:
        return @"Debug";
        break;
    }
}

+ (NSDictionary *)infoForKey:(NSString *)key keyPath:(NSString *)keyPath value:(id)value manifest:(NSDictionary *)manifest {
    return @{
        @"ManifestDomain" : manifest[PFCManifestKeyDomain] ?: @"",
        @"ManifestKey" : key ?: @"",
        @"ManifestKeyPath" : [NSString stringWithFormat:@"%@:%@", keyPath ?: @"", key ?: @""],
        @"ManifestKeyValue" : [self dictValueForValue:value],
        @"ManifestPath" : manifest[PFCRuntimeKeyPath] ?: @""
    };
}

+ (id)dictValueForValue:(id)value {
    NSString *valueType = [[PFCManifestUtility sharedUtility] typeStringFromValue:value];
    if ([valueType isEqualToString:PFCValueTypeString]) {
        return (NSString *)value;
    } else if ([valueType isEqualToString:PFCValueTypeBoolean]) {
        return @([value boolValue]);
    } else if ([valueType isEqualToString:PFCValueTypeInteger]) {
        return @([value integerValue]);
    } else if ([valueType isEqualToString:PFCValueTypeFloat]) {
        return @([value floatValue]);
    } else if ([valueType isEqualToString:PFCValueTypeArray]) {
        return (NSArray *)value;
    } else if ([valueType isEqualToString:PFCValueTypeDict]) {
        return (NSDictionary *)value;
    } else if ([valueType isEqualToString:PFCValueTypeDate]) {
        return (NSDate *)value;
    } else if ([valueType isEqualToString:PFCValueTypeData]) {
        return (NSData *)value;
    } else {
        return @"<Empty>";
    }
}

+ (NSDictionary *)errorWithCode:(PFCLintErrorCodes)code key:(NSString *)key keyPath:(NSString *)keyPath value:(id)value manifest:(NSDictionary *)manifest overrides:(NSDictionary *)overrides {
    NSMutableDictionary *reportDict = [NSMutableDictionary dictionaryWithDictionary:[self infoForKey:key keyPath:keyPath value:value manifest:manifest]];

    NSString *errorMessage;
    NSNumber *errorSeverity;
    NSString *errorRecovery;

    switch (code) {
    case kPFCLintErrorKeyIgnored:
        errorMessage = @"Key will be ignored by the application.";
        errorSeverity = @(kPFCLintErrorSeverityInfo);
        errorRecovery = @"Remove ignored key";
        break;

    case kPFCLintErrorKeyIncompatible:
        errorMessage = @"Key is incompatible in current manifest content dict";
        errorSeverity = @(kPFCLintErrorSeverityInfo);
        errorRecovery = @"Remove incompatible key";
        break;

    case kPFCLintErrorKeyRequiredNotFound:
        errorMessage = @"Required key not found";
        errorSeverity = @(kPFCLintErrorSeverityError);
        errorRecovery = @"Add required key";
        break;

    case kPFCLintErrorKeySuggestedNotFound:
        errorMessage = @"Suggested key not found";
        errorSeverity = @(kPFCLintErrorSeverityInfo);
        errorRecovery = @"Add suggested key";
        break;

    case kPFCLintErrorValueInvalid:
        errorMessage = @"Value for key is invalid";
        errorSeverity = @(kPFCLintErrorSeverityError);
        errorRecovery = @"Update value";
        break;

    case kPFCLintErrorValueRequiredNotFound:
        errorMessage = @"Required value not found";
        errorSeverity = @(kPFCLintErrorSeverityError);
        errorRecovery = @"Update value definition";
        break;

    case kPFCLintErrorDuplicate:
        errorMessage = @"Multiple manifest share unique value";
        errorSeverity = @(kPFCLintErrorSeverityWarning);
        errorRecovery = @"";
        break;

    case kPFCLintErrorResourceNotFound:
        errorMessage = @"Resource defined in value not be found";
        errorSeverity = @(kPFCLintErrorSeverityInfo);
        errorRecovery = @"Update value or add missing resource";
        break;
    }

    if ([overrides[@"ErrorMessage"] length] != 0) {
        errorMessage = overrides[@"ErrorMessage"];
    }

    if (overrides[@"ErrorSeverity"] != nil) {
        errorSeverity = @([overrides[@"ErrorSeverity"] integerValue]);
    }

    if ([overrides[@"ErrorRecovery"] length] != 0) {
        errorRecovery = overrides[@"ErrorRecovery"];
    }

    [reportDict addEntriesFromDictionary:@{
        @"LintErrorCode" : @(code),
        @"LintErrorMessage" : errorMessage ?: @"",
        @"LintErrorSeverity" : errorSeverity,
        @"LintErrorSuggestedRecovery" : errorRecovery ?: @""
    }];

    return [reportDict copy];
}

@end
