//
//  PFCConstants.h
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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PFCSessionTypes) {
    /** Command Line Session **/
    kPFCSessionTypeCLI = 0,
    /** GUI Session **/
    kPFCSessionTypeGUI
};

typedef NS_ENUM(NSInteger, PFCStatus) {
    kPFCStatusLoadingSettings,
    kPFCStatusNoManifestSelection,
    kPFCStatusNoManifests,
    kPFCStatusNoManifestsCustom,
    kPFCStatusNoManifestsMCX,
    kPFCStatusNoMatches,
    kPFCStatusNoProfileSelected,
    kPFCStatusNoSelection,
    kPFCStatusNoSettings,
    kPFCStatusNotImplemented,
    kPFCStatusMultipleProfilesSelected,
    kPFCStatusErrorReadingSettings
};

typedef NS_ENUM(NSInteger, PFCPayloadLibrary) {
    kPFCPayloadLibraryApple = 0,
    kPFCPayloadLibraryUserPreferences,
    kPFCPayloadLibraryCustom,
    kPFCPayloadLibraryAll,
    kPFCPayloadLibraryLibraryPreferences,
    kPFCPayloadLibraryMCX,
    kPFCLibraryProfile
};

extern NSInteger const PFCMaximumPayloadCount;
extern NSInteger const PFCIndentLevelBaseConstant;
extern NSInteger const PFCSettingsColumnWidth;
extern int const PFCTableViewGroupRowHeight;
extern NSString *const PFCProfileDraggingType;

////////////////////////////////////////////////////////////////////////////////
#pragma mark CellType
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCCellTypeCheckbox;
extern NSString *const PFCCellTypeDatePicker;
extern NSString *const PFCCellTypeDatePickerNoTitle;
extern NSString *const PFCCellTypeFile;
extern NSString *const PFCCellTypePadding;
extern NSString *const PFCCellTypePopUpButton;
extern NSString *const PFCCellTypePopUpButtonCheckbox;
extern NSString *const PFCCellTypePopUpButtonLeft;
extern NSString *const PFCCellTypeSegmentedControl;
extern NSString *const PFCCellTypeRadioButton;
extern NSString *const PFCCellTypeTableView;
extern NSString *const PFCCellTypeTextField;
extern NSString *const PFCCellTypeTextFieldCheckbox;
extern NSString *const PFCCellTypeTextFieldDaysHoursNoTitle;
extern NSString *const PFCCellTypeTextFieldHostPort;
extern NSString *const PFCCellTypeTextFieldHostPortCheckbox;
extern NSString *const PFCCellTypeTextFieldNumber;
extern NSString *const PFCCellTypeTextFieldNumberLeft;
extern NSString *const PFCCellTypeTextLabel;
extern NSString *const PFCCellTypeTextView;

////////////////////////////////////////////////////////////////////////////////
#pragma mark TableView CellType
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCTableViewCellTypeCheckbox;
extern NSString *const PFCTableViewCellTypePopUpButton;
extern NSString *const PFCTableViewCellTypeTextField;
extern NSString *const PFCTableViewCellTypeTextFieldNumber;

////////////////////////////////////////////////////////////////////////////////
#pragma mark ValueType
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCValueTypeArray;
extern NSString *const PFCValueTypeBoolean;
extern NSString *const PFCValueTypeFloat;
extern NSString *const PFCValueTypeData;
extern NSString *const PFCValueTypeDate;
extern NSString *const PFCValueTypeDict;
extern NSString *const PFCValueTypeInteger;
extern NSString *const PFCValueTypeString;
extern NSString *const PFCValueTypeUnknown;

////////////////////////////////////////////////////////////////////////////////
#pragma mark ManifestKeys
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCManifestKeyAlignRight;
extern NSString *const PFCManifestKeyAllowedFileTypes;
extern NSString *const PFCManifestKeyAllowedFileExtensions;
extern NSString *const PFCManifestKeyAllowMultiplePayloads;
extern NSString *const PFCManifestKeyAvailability;
extern NSString *const PFCManifestKeyAvailabilityKey;
extern NSString *const PFCManifestKeyAvailabilityValue;
extern NSString *const PFCManifestKeyAvailabilityOS;
extern NSString *const PFCManifestKeyAvailabilitySelectionIdentifier;
extern NSString *const PFCManifestKeyAvailabilitySelectionValue;
extern NSString *const PFCManifestKeyAvailableFrom;
extern NSString *const PFCManifestKeyAvailable;
extern NSString *const PFCManifestKeyAvailableTo;
extern NSString *const PFCManifestKeyAvailableIf;
extern NSString *const PFCManifestKeyAvailableValues;
extern NSString *const PFCManifestKeyButtonTitle;
extern NSString *const PFCManifestKeyCellType;
extern NSString *const PFCManifestKeyDictKey;
extern NSString *const PFCManifestKeyDisabled;
extern NSString *const PFCManifestKeyDefaultValue;
extern NSString *const PFCManifestKeyDefaultValueCheckbox;
extern NSString *const PFCManifestKeyDefaultValueHost;
extern NSString *const PFCManifestKeyDefaultValuePort;
extern NSString *const PFCManifestKeyDefaultValueTextField;
extern NSString *const PFCManifestKeyDescription;
extern NSString *const PFCManifestKeyDomain;
extern NSString *const PFCManifestKeyEnabled;
extern NSString *const PFCManifestKeyFileInfoProcessor;
extern NSString *const PFCManifestKeyFilePrompt;
extern NSString *const PFCManifestKeyFontWeight;
extern NSString *const PFCManifestKeyHidden;
extern NSString *const PFCManifestKeyIconName;
extern NSString *const PFCManifestKeyIconPath;
extern NSString *const PFCManifestKeyIconPathBundle;
extern NSString *const PFCManifestKeyIdentifier;
extern NSString *const PFCManifestKeyIndentLevel;
extern NSString *const PFCManifestKeyIndentLeft;
extern NSString *const PFCManifestKeyInvertBoolean;
extern NSString *const PFCManifestKeyManifestContent;
extern NSString *const PFCManifestKeyMaxValue;
extern NSString *const PFCManifestKeyMinValue;
extern NSString *const PFCManifestKeyMinValueOffsetDays;
extern NSString *const PFCManifestKeyMinValueOffsetHours;
extern NSString *const PFCManifestKeyMinValueOffsetMinutes;
extern NSString *const PFCManifestKeyOptional;
extern NSString *const PFCManifestKeyOptionalCheckbox;
extern NSString *const PFCManifestKeyOptionalPort;
extern NSString *const PFCManifestKeyOptionalHost;
extern NSString *const PFCManifestKeyOptionalTextField;
extern NSString *const PFCManifestKeyParentKey;
extern NSString *const PFCManifestKeyPayloadDescription;
extern NSString *const PFCManifestKeyPayloadDisplayName;
extern NSString *const PFCManifestKeyPayloadIdentifier;
extern NSString *const PFCManifestKeyPayloadKey;
extern NSString *const PFCManifestKeyPayloadKeyCheckbox;
extern NSString *const PFCManifestKeyPayloadKeyHost;
extern NSString *const PFCManifestKeyPayloadKeyPort;
extern NSString *const PFCManifestKeyPayloadKeyTextField;
extern NSString *const PFCManifestKeyPayloadOrganization;
extern NSString *const PFCManifestKeyPayloadParentKey;
extern NSString *const PFCManifestKeyPayloadParentKeyCheckbox;
extern NSString *const PFCManifestKeyPayloadParentKeyHost;
extern NSString *const PFCManifestKeyPayloadParentKeyPort;
extern NSString *const PFCManifestKeyPayloadParentKeyTextField;
extern NSString *const PFCManifestKeyPayloadParentValueType;
extern NSString *const PFCManifestKeyPayloadScope;
extern NSString *const PFCManifestKeyPayloadTabTitle;
extern NSString *const PFCManifestKeyPayloadType;
extern NSString *const PFCManifestKeyPayloadTypeHost;
extern NSString *const PFCManifestKeyPayloadTypePort;
extern NSString *const PFCManifestKeyPayloadTypes;
extern NSString *const PFCManifestKeyPayloadTypeCheckbox;
extern NSString *const PFCManifestKeyPayloadTypeTextField;
extern NSString *const PFCManifestKeyPayloadUUID;
extern NSString *const PFCManifestKeyPayloadValueType;
extern NSString *const PFCManifestKeyPayloadValueTypeCheckbox;
extern NSString *const PFCManifestKeyPayloadValueTypeHost;
extern NSString *const PFCManifestKeyPayloadValueTypePort;
extern NSString *const PFCManifestKeyPayloadValueTypeTextField;
extern NSString *const PFCManifestKeyPayloadValue;
extern NSString *const PFCManifestKeyPayloadVersion;
extern NSString *const PFCManifestKeyPlaceholderValue;
extern NSString *const PFCManifestKeyPlaceholderValueHost;
extern NSString *const PFCManifestKeyPlaceholderValuePort;
extern NSString *const PFCManifestKeyPlaceholderValueTextField;
extern NSString *const PFCManifestKeyPopUpButtonWidth;
extern NSString *const PFCManifestKeyRequired;
extern NSString *const PFCManifestKeyRequiredCheckbox;
extern NSString *const PFCManifestKeyRequiredHost;
extern NSString *const PFCManifestKeyRequiredPort;
extern NSString *const PFCManifestKeyRequiredTextField;
extern NSString *const PFCManifestKeySharedKey;
extern NSString *const PFCManifestKeyShowDateInterval;
extern NSString *const PFCManifestKeyShowDateTime;
extern NSString *const PFCManifestKeySupervisedOnly;
extern NSString *const PFCManifestKeyTableViewColumns;
extern NSString *const PFCManifestKeyTableViewColumnTitle;
extern NSString *const PFCManifestKeyTableViewColumnWidth;
extern NSString *const PFCManifestKeyTitle;
extern NSString *const PFCManifestKeyToolTipDescription;
extern NSString *const PFCManifestKeyUnit;
extern NSString *const PFCManifestKeyValueKeys;
extern NSString *const PFCManifestKeyValueKeysShared;

////////////////////////////////////////////////////////////////////////////////
#pragma mark ManifestDomains
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCManifestDomainGeneral;

////////////////////////////////////////////////////////////////////////////////
#pragma mark ManifestReportKeys
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCManifestReportTitleKey;
extern NSString *const PFCManifestReportMessageKey;

////////////////////////////////////////////////////////////////////////////////
#pragma mark UserDefaults
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCUserDefaultsLogLevel;

////////////////////////////////////////////////////////////////////////////////
#pragma mark ButtonTitles
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCButtonTitleCancel;
extern NSString *const PFCButtonTitleDelete;
extern NSString *const PFCButtonTitleRemove;

////////////////////////////////////////////////////////////////////////////////
#pragma mark AlertKeys
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCAlertTagKey;

////////////////////////////////////////////////////////////////////////////////
#pragma mark AlertTags
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCAlertTagDeleteGroups;
extern NSString *const PFCAlertTagDeleteProfiles;
extern NSString *const PFCAlertTagDeleteProfilesInGroup;

////////////////////////////////////////////////////////////////////////////////
#pragma mark FileInfoKeys
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCFileInfoTitle;
extern NSString *const PFCFileInfoLabelTop;
extern NSString *const PFCFileInfoDescriptionTop;
extern NSString *const PFCFileInfoLabelMiddle;
extern NSString *const PFCFileInfoDescriptionMiddle;
extern NSString *const PFCFileInfoLabelBottom;
extern NSString *const PFCFileInfoDescriptionBottom;

////////////////////////////////////////////////////////////////////////////////
#pragma mark FontWeights
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCFontWeightBold;
extern NSString *const PFCFontWeightRegular;

////////////////////////////////////////////////////////////////////////////////
#pragma mark RuntimeKeys
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCRuntimeKeyPath;
extern NSString *const PFCRuntimeKeyPayloadLibrary;
extern NSString *const PFCRuntimeKeyProfileEditor;
extern NSString *const PFCRuntimeKeyProfileExporter;

////////////////////////////////////////////////////////////////////////////////
#pragma mark MCXManifestKeys
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCMCXManifestKeyDescription;
extern NSString *const PFCMCXManifestKeyDefault;
extern NSString *const PFCMCXManifestKeyDomain;
extern NSString *const PFCMCXManifestKeyName;
extern NSString *const PFCMCXManifestKeySubkeys;
extern NSString *const PFCMCXManifestKeyTargets;
extern NSString *const PFCMCXManifestKeyTitle;
extern NSString *const PFCMCXManifestKeyType;
extern NSString *const PFCMCXManifestKeyVersion;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Other
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCDefaultProfileName;
extern NSString *const PFCDefaultProfileGroupName;
extern NSString *const PFCDefaultProfileIdentifierFormat;

////////////////////////////////////////////////////////////////////////////////
#pragma mark ProfileTemplateKeys
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCProfileTemplateKeyName;
extern NSString *const PFCProfileTemplateKeyPath;
extern NSString *const PFCProfileTemplateKeySettings;
extern NSString *const PFCProfileTemplateKeySettingsError;
extern NSString *const PFCProfileTemplateKeyDisplaySettings;
extern NSString *const PFCProfileTemplateKeyUUID;
extern NSString *const PFCProfileTemplateKeySign;
extern NSString *const PFCProfileTemplateKeySigningCertificate;
extern NSString *const PFCProfileTemplateKeyEncrypt;
extern NSString *const PFCProfileTemplateKeyEncryptionCertificate;
extern NSString *const PFCProfileTemplateKeyIdentifier;
extern NSString *const PFCProfileTemplateKeyIdentifierFormat;
extern NSString *const PFCProfileTemplateExtension;

////////////////////////////////////////////////////////////////////////////////
#pragma mark PFCProfileDisplaySettingsKeys
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCProfileDisplaySettingsKeyAdvancedSettings;
extern NSString *const PFCProfileDisplaySettingsKeyDistributionType;
extern NSString *const PFCProfileDisplaySettingsKeyDistributionTypeAny;
extern NSString *const PFCProfileDisplaySettingsKeyDistributionTypeManual;
extern NSString *const PFCProfileDisplaySettingsKeyDistributionTypeOTA;
extern NSString *const PFCProfileDisplaySettingsKeyPayloadScope;
extern NSString *const PFCProfileDisplaySettingsKeyPayloadScopeAny;
extern NSString *const PFCProfileDisplaySettingsKeyPayloadScopeSystem;
extern NSString *const PFCProfileDisplaySettingsKeyPayloadScopeUser;
extern NSString *const PFCProfileDisplaySettingsKeyPlatform;
extern NSString *const PFCProfileDisplaySettingsKeyPlatformOSX;
extern NSString *const PFCProfileDisplaySettingsKeyPlatformOSXMaxVersion;
extern NSString *const PFCProfileDisplaySettingsKeyPlatformOSXMinVersion;
extern NSString *const PFCProfileDisplaySettingsKeyPlatformiOS;
extern NSString *const PFCProfileDisplaySettingsKeyPlatformiOSMaxVersion;
extern NSString *const PFCProfileDisplaySettingsKeyPlatformiOSMinVersion;
extern NSString *const PFCProfileDisplaySettingsKeySupervised;

////////////////////////////////////////////////////////////////////////////////
#pragma mark ProfileGroupKeys
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCProfileGroupKeyName;
extern NSString *const PFCProfileGroupKeyPath;
extern NSString *const PFCProfileGroupKeyProfiles;
extern NSString *const PFCProfileGroupKeyUUID;
extern NSString *const PFCProfileGroupExtension;

////////////////////////////////////////////////////////////////////////////////
#pragma mark SettingsKeys
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCSettingsKeyEnabled;
extern NSString *const PFCSettingsKeyFilePath;
extern NSString *const PFCSettingsKeySelected;
extern NSString *const PFCSettingsKeyTableViewContent;
extern NSString *const PFCSettingsKeyValue;
extern NSString *const PFCSettingsKeyValueCheckbox;
extern NSString *const PFCSettingsKeyValueHost;
extern NSString *const PFCSettingsKeyValuePort;
extern NSString *const PFCSettingsKeyValueRadioButton;
extern NSString *const PFCSettingsKeyValueTextField;
