//
//  PFCConstants.m
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

NSInteger const PFCMaximumPayloadCount = 8;
int const PFCTableViewGroupRowHeight = 24;
NSString *const PFCProfileDraggingType = @"PFCProfileDraggingType";

////////////////////////////////////////////////////////////////////////////////
#pragma mark CellType
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCCellTypeCheckbox = @"Checkbox";
NSString *const PFCCellTypeCheckboxNoDescription = @"CheckboxNoDescription";
NSString *const PFCCellTypeDatePicker = @"DatePicker";
NSString *const PFCCellTypeDatePickerNoTitle = @"DatePickerNoTitle";
NSString *const PFCCellTypeFile = @"File";
NSString *const PFCCellTypeMenu = @"Menu";
NSString *const PFCCellTypePadding = @"Padding";
NSString *const PFCCellTypePopUpButton = @"PopUpButton";
NSString *const PFCCellTypePopUpButtonLeft = @"PopUpButtonLeft";
NSString *const PFCCellTypePopUpButtonNoTitle = @"PopUpButtonNoTitle";
NSString *const PFCCellTypeSegmentedControl = @"SegmentedControl";
NSString *const PFCCellTypeTableView = @"TableView";
NSString *const PFCCellTypeTextField = @"TextField";
NSString *const PFCCellTypeTextFieldCheckbox = @"TextFieldCheckbox";
NSString *const PFCCellTypeTextFieldDaysHoursNoTitle = @"TextFieldDaysHoursNoTitle";
NSString *const PFCCellTypeTextFieldHostPort = @"TextFieldHostPort";
NSString *const PFCCellTypeTextFieldHostPortCheckbox = @"TextFieldHostPortCheckbox";
NSString *const PFCCellTypeTextFieldNoTitle = @"TextFieldNoTitle";
NSString *const PFCCellTypeTextFieldNumber = @"TextFieldNumber";
NSString *const PFCCellTypeTextFieldNumberLeft = @"TextFieldNumberLeft";
NSString *const PFCCellTypeTextView = @"TextView";

////////////////////////////////////////////////////////////////////////////////
#pragma mark TableView CellType
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCTableViewCellTypeCheckbox = @"TableViewCheckbox";
NSString *const PFCTableViewCellTypePopUpButton = @"TableViewPopUpButton";
NSString *const PFCTableViewCellTypeTextField = @"TableViewTextField";
NSString *const PFCTableViewCellTypeTextFieldNumber = @"TableViewTextFieldNumber";

////////////////////////////////////////////////////////////////////////////////
#pragma mark ValueType
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCValueTypeArray = @"Array";
NSString *const PFCValueTypeBoolean = @"Boolean";
NSString *const PFCValueTypeFloat = @"Float";
NSString *const PFCValueTypeData = @"Data";
NSString *const PFCValueTypeDate = @"Date";
NSString *const PFCValueTypeDict = @"Dict";
NSString *const PFCValueTypeInteger = @"Integer";
NSString *const PFCValueTypeString = @"String";
NSString *const PFCValueTypeUnknown = @"Unknown";

////////////////////////////////////////////////////////////////////////////////
#pragma mark ManifestKeys
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCManifestKeyAllowedFileTypes = @"AllowedFileTypes";
NSString *const PFCManifestKeyAllowedFileExtensions = @"AllowedFileExtensions";
NSString *const PFCManifestKeyAllowMultiplePayloads = @"AllowMultiplePayloads";
NSString *const PFCManifestKeyAvailability = @"Availability";
NSString *const PFCManifestKeyAvailableValues = @"AvailableValues";
NSString *const PFCManifestKeyButtonTitle = @"ButtonTitle";
NSString *const PFCManifestKeyCellType = @"CellType";
NSString *const PFCManifestKeyDictKey = @"DictKey";
NSString *const PFCManifestKeyDisabled = @"Disabled";
NSString *const PFCManifestKeyDefaultValue = @"DefaultValue";
NSString *const PFCManifestKeyDefaultValueCheckbox = @"DefaultValueCheckbox";
NSString *const PFCManifestKeyDefaultValueHost = @"DefaultValueHost";
NSString *const PFCManifestKeyDefaultValuePort = @"DefaultValuePort";
NSString *const PFCManifestKeyDefaultValueTextField = @"DefaultValueTextField";
NSString *const PFCManifestKeyDescription = @"Description";
NSString *const PFCManifestKeyDomain = @"Domain";
NSString *const PFCManifestKeyFileInfoProcessor = @"FileInfoProcessor";
NSString *const PFCManifestKeyFilePrompt = @"FilePrompt";
NSString *const PFCManifestKeyFontWeight = @"FontWeight";
NSString *const PFCManifestKeyHidden = @"Hidden";
NSString *const PFCManifestKeyIconName = @"IconName";
NSString *const PFCManifestKeyIconPath = @"IconPath";
NSString *const PFCManifestKeyIconPathBundle = @"IconPathBundle";
NSString *const PFCManifestKeyIdentifier = @"Identifier";
NSString *const PFCManifestKeyIndentLevel = @"IndentLevel";
NSString *const PFCManifestKeyIndentLeft = @"IndentLeft";
NSString *const PFCManifestKeyManifestContent = @"ManifestContent";
NSString *const PFCManifestKeyMaxValue = @"MaxValue";
NSString *const PFCManifestKeyMinValue = @"MinValue";
NSString *const PFCManifestKeyMinValueOffsetDays = @"MinValueOffsetDays";
NSString *const PFCManifestKeyMinValueOffsetHours = @"MinValueOffsetHours";
NSString *const PFCManifestKeyMinValueOffsetMinutes = @"MinValueOffsetMinutes";
NSString *const PFCManifestKeyOptional = @"Optional";
NSString *const PFCManifestKeyOptionalCheckbox = @"OptionalCheckbox";
NSString *const PFCManifestKeyOptionalPort = @"OptionalPort";
NSString *const PFCManifestKeyOptionalHost = @"OptionalHost";
NSString *const PFCManifestKeyOptionalTextField = @"OptionalTextField";
NSString *const PFCManifestKeyParentKey = @"ParentKey";
NSString *const PFCManifestKeyPayloadDescription = @"PayloadDescription";
NSString *const PFCManifestKeyPayloadDisplayName = @"PayloadDisplayName";
NSString *const PFCManifestKeyPayloadIdentifier = @"PayloadIdentifier";
NSString *const PFCManifestKeyPayloadKey = @"PayloadKey";
NSString *const PFCManifestKeyPayloadKeyCheckbox = @"PayloadKeyCheckbox";
NSString *const PFCManifestKeyPayloadKeyHost = @"PayloadKeyHost";
NSString *const PFCManifestKeyPayloadKeyPort = @"PayloadKeyPort";
NSString *const PFCManifestKeyPayloadKeyTextField = @"PayloadKeyTextField";
NSString *const PFCManifestKeyPayloadOrganization = @"PayloadOrganization";
NSString *const PFCManifestKeyPayloadParentKey = @"PayloadParentKey";
NSString *const PFCManifestKeyPayloadParentKeyCheckbox = @"PayloadParentKeyCheckbox";
NSString *const PFCManifestKeyPayloadParentKeyHost = @"PayloadParentKeyHost";
NSString *const PFCManifestKeyPayloadParentKeyPort = @"PayloadParentKeyPort";
NSString *const PFCManifestKeyPayloadParentKeyTextField = @"PayloadParentKeyTextField";
NSString *const PFCManifestKeyPayloadParentValueType = @"PayloadParentValueType";
NSString *const PFCManifestKeyPayloadScope = @"PayloadScope";
NSString *const PFCManifestKeyPayloadTabTitle = @"PayloadTabTitle";
NSString *const PFCManifestKeyPayloadType = @"PayloadType";
NSString *const PFCManifestKeyPayloadTypeHost = @"PayloadTypeHost";
NSString *const PFCManifestKeyPayloadTypePort = @"PayloadTypePort";
NSString *const PFCManifestKeyPayloadTypes = @"PayloadTypes";
NSString *const PFCManifestKeyPayloadTypeCheckbox = @"PayloadTypeCheckbox";
NSString *const PFCManifestKeyPayloadTypeTextField = @"PayloadTypeTextField";
NSString *const PFCManifestKeyPayloadUUID = @"PayloadUUID";
NSString *const PFCManifestKeyPayloadValueType = @"PayloadValueType";
NSString *const PFCManifestKeyPayloadValueTypeCheckbox = @"PayloadValueTypeCheckbox";
NSString *const PFCManifestKeyPayloadValueTypeHost = @"PayloadValueTypeHost";
NSString *const PFCManifestKeyPayloadValueTypePort = @"PayloadValueTypePort";
NSString *const PFCManifestKeyPayloadValueTypeTextField = @"PayloadValueTypeTextField";
NSString *const PFCManifestKeyPayloadValue = @"PayloadValue";
NSString *const PFCManifestKeyPayloadVersion = @"PayloadVersion";
NSString *const PFCManifestKeyPlaceholderValue = @"PlaceholderValue";
NSString *const PFCManifestKeyPlaceholderValueHost = @"PlaceholderValueHost";
NSString *const PFCManifestKeyPlaceholderValuePort = @"PlaceholderValuePort";
NSString *const PFCManifestKeyPlaceholderValueTextField = @"PlaceholderValueTextField";
NSString *const PFCManifestKeyRequired = @"Required";
NSString *const PFCManifestKeyRequiredCheckbox = @"RequiredCheckbox";
NSString *const PFCManifestKeyRequiredHost = @"RequiredHost";
NSString *const PFCManifestKeyRequiredPort = @"RequiredPort";
NSString *const PFCManifestKeyRequiredTextField = @"RequiredTextField";
NSString *const PFCManifestKeySharedKey = @"SharedKey";
NSString *const PFCManifestKeyShowDateInterval = @"ShowDateInterval";
NSString *const PFCManifestKeyShowDateTime = @"ShowDateTime";
NSString *const PFCManifestKeySupervisedOnly = @"SupervisedOnly";
NSString *const PFCManifestKeyTableViewColumns = @"TableViewColumns";
NSString *const PFCManifestKeyTableViewColumnTitle = @"Title";
NSString *const PFCManifestKeyTitle = @"Title";
NSString *const PFCManifestKeyToolTipDescription = @"ToolTipDescription";
NSString *const PFCManifestKeyUnit = @"Unit";
NSString *const PFCManifestKeyValueKeys = @"ValueKeys";
NSString *const PFCManifestKeyValueKeysShared = @"ValueKeysShared";

////////////////////////////////////////////////////////////////////////////////
#pragma mark ManifestReportKeys
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCManifestReportTitleKey = @"ReportTitle";
NSString *const PFCManifestReportMessageKey = @"ReportMessage";

////////////////////////////////////////////////////////////////////////////////
#pragma mark UserDefaults
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCUserDefaultsLogLevel = @"LogLevel";

////////////////////////////////////////////////////////////////////////////////
#pragma mark ButtonTitles
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCButtonTitleCancel = @"Cancel";
NSString *const PFCButtonTitleDelete = @"Delete";
NSString *const PFCButtonTitleRemove = @"Remove";

////////////////////////////////////////////////////////////////////////////////
#pragma mark AlertKeys
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCAlertTagKey = @"AlertTag";

////////////////////////////////////////////////////////////////////////////////
#pragma mark AlertTags
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCAlertTagDeleteGroups = @"AlertTagDeleteGroups";
NSString *const PFCAlertTagDeleteProfiles = @"AlertTagDeleteProfiles";
NSString *const PFCAlertTagDeleteProfilesInGroup = @"AlertTagDeleteProfilesInGroup";

////////////////////////////////////////////////////////////////////////////////
#pragma mark FileInfoKeys
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCFileInfoTitle = @"Title";
NSString *const PFCFileInfoLabelTop = @"LabelTop";
NSString *const PFCFileInfoDescriptionTop = @"DescriptionTop";
NSString *const PFCFileInfoLabelMiddle = @"LabelMiddle";
NSString *const PFCFileInfoDescriptionMiddle = @"DescriptionMiddle";
NSString *const PFCFileInfoLabelBottom = @"LabelBottom";
NSString *const PFCFileInfoDescriptionBottom = @"DescriptionBottom";

////////////////////////////////////////////////////////////////////////////////
#pragma mark FontWeights
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCFontWeightBold = @"Bold";

////////////////////////////////////////////////////////////////////////////////
#pragma mark RuntimeKeys
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCRuntimeKeyPath = @"Path";
NSString *const PFCRuntimeKeyPayloadLibrary = @"PayloadLibrary";
NSString *const PFCRuntimeKeyProfileEditor = @"ProfileEditor";
NSString *const PFCRuntimeKeyProfileExporter = @"ProfileExporter";

////////////////////////////////////////////////////////////////////////////////
#pragma mark MCXManifestKeys
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCMCXManifestKeyDescription = @"pfm_description";
NSString *const PFCMCXManifestKeyDefault = @"pfm_default";
NSString *const PFCMCXManifestKeyDomain = @"pfm_domain";
NSString *const PFCMCXManifestKeyName = @"pfm_name";
NSString *const PFCMCXManifestKeySubkeys = @"pfm_subkeys";
NSString *const PFCMCXManifestKeyTargets = @"pfm_targets";
NSString *const PFCMCXManifestKeyTitle = @"pfm_title";
NSString *const PFCMCXManifestKeyType = @"pfm_type";
NSString *const PFCMCXManifestKeyVersion = @"pfm_version";

////////////////////////////////////////////////////////////////////////////////
#pragma mark Other
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCDefaultProfileName = @"Untitled Profile...";
NSString *const PFCDefaultProfileGroupName = @"Untitled Group";
NSString *const PFCDefaultProfileIdentifierFormat = @"com.github.ProfileCreator.%PROFILEUUID%";

////////////////////////////////////////////////////////////////////////////////
#pragma mark ProfileTemplateKeys
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCProfileTemplateKeyName = @"Name";
NSString *const PFCProfileTemplateKeyPath = @"Path";
NSString *const PFCProfileTemplateKeySettings = @"Settings";
NSString *const PFCProfileTemplateKeySettingsError = @"SettingsError";
NSString *const PFCProfileTemplateKeyDisplaySettings = @"DisplaySettings";
NSString *const PFCProfileTemplateKeyUUID = @"UUID";
NSString *const PFCProfileTemplateKeyIdentifier = @"Identifier";
NSString *const PFCProfileTemplateKeyIdentifierFormat = @"IdentifierFormat";
NSString *const PFCProfileTemplateKeySign = @"Sign";
NSString *const PFCProfileTemplateKeySigningCertificate = @"SigningCertificate";
NSString *const PFCProfileTemplateKeyEncrypt = @"Encrypt";
NSString *const PFCProfileTemplateKeyEncryptionCertificate = @"EncryptionCertificate";
NSString *const PFCProfileTemplateExtension = @"pfcconf";

////////////////////////////////////////////////////////////////////////////////
#pragma mark PFCProfileDisplaySettingsKeys
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCProfileDisplaySettingsKeyAdvancedSettings = @"AdvancedSettings";
NSString *const PFCProfileDisplaySettingsKeyPlatform = @"Platform";
NSString *const PFCProfileDisplaySettingsKeyPlatformOSX = @"OSX";
NSString *const PFCProfileDisplaySettingsKeyPlatformOSXMaxVersion = @"OSXMaxVersion";
NSString *const PFCProfileDisplaySettingsKeyPlatformOSXMinVersion = @"OSXMinVersion";
NSString *const PFCProfileDisplaySettingsKeyPlatformiOS = @"iOS";
NSString *const PFCProfileDisplaySettingsKeyPlatformiOSMaxVersion = @"iOSMaxVersion";
NSString *const PFCProfileDisplaySettingsKeyPlatformiOSMinVersion = @"iOSMinVersion";
NSString *const PFCProfileDisplaySettingsKeySupervised = @"Supervised";

////////////////////////////////////////////////////////////////////////////////
#pragma mark ProfileGroupKeys
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCProfileGroupKeyName = @"Name";
NSString *const PFCProfileGroupKeyPath = @"Path";
NSString *const PFCProfileGroupKeyProfiles = @"Profiles";
NSString *const PFCProfileGroupKeyUUID = @"UUID";
NSString *const PFCProfileGroupExtension = @"pfcgrp";

////////////////////////////////////////////////////////////////////////////////
#pragma mark SettingsKeys
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCSettingsKeyEnabled = @"Enabled";
NSString *const PFCSettingsKeyFilePath = @"FilePath";
NSString *const PFCSettingsKeySelected = @"Selected";
NSString *const PFCSettingsKeyTableViewContent = @"TableViewContent";
NSString *const PFCSettingsKeyValue = @"Value";
NSString *const PFCSettingsKeyValueCheckbox = @"ValueCheckbox";
NSString *const PFCSettingsKeyValueHost = @"ValueHost";
NSString *const PFCSettingsKeyValuePort = @"ValuePort";
NSString *const PFCSettingsKeyValueTextField = @"ValueTextField";
