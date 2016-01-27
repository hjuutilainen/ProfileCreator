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
NSString *const PFCManifestKeyAllowMultiplePayloads = @"AllowMultiplePayloads";
NSString *const PFCManifestKeyAvailableValues = @"AvailableValues";
NSString *const PFCManifestKeyButtonTitle = @"ButtonTitle";
NSString *const PFCManifestKeyCellType = @"CellType";
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
NSString *const PFCManifestKeyOptional = @"Optional";
NSString *const PFCManifestKeyParentKey = @"ParentKey";
NSString *const PFCManifestKeyPayloadKey = @"PayloadKey";
NSString *const PFCManifestKeyPayloadKeyCheckbox = @"PayloadKeyCheckbox";
NSString *const PFCManifestKeyPayloadKeyHost = @"PayloadKeyHost";
NSString *const PFCManifestKeyPayloadKeyPort = @"PayloadKeyPort";
NSString *const PFCManifestKeyPayloadKeyTextField = @"PayloadKeyTextField";
NSString *const PFCManifestKeyPayloadParentKey = @"PayloadParentKey";
NSString *const PFCManifestKeyPayloadParentKeyCheckbox = @"PayloadParentKeyCheckbox";
NSString *const PFCManifestKeyPayloadParentKeyHost = @"PayloadParentKeyHost";
NSString *const PFCManifestKeyPayloadParentKeyPort = @"PayloadParentKeyPort";
NSString *const PFCManifestKeyPayloadParentKeyTextField = @"PayloadParentKeyTextField";
NSString *const PFCManifestKeyPayloadParentValueType = @"PayloadParentValueType";
NSString *const PFCManifestKeyPayloadTabTitle = @"PayloadTabTitle";
NSString *const PFCManifestKeyPayloadType = @"PayloadType";
NSString *const PFCManifestKeyPayloadValueType = @"PayloadValueType";
NSString *const PFCManifestKeyPayloadValue = @"PayloadValue";
NSString *const PFCManifestKeyPlaceholderValue = @"PlaceholderValue";
NSString *const PFCManifestKeyPlaceholderValueHost = @"PlaceholderValueHost";
NSString *const PFCManifestKeyPlaceholderValuePort = @"PlaceholderValuePort";
NSString *const PFCManifestKeyPlaceholderValueTextField = @"PlaceholderValueTextField";
NSString *const PFCManifestKeyRequired = @"Required";
NSString *const PFCManifestKeyRequiredHost = @"RequiredHost";
NSString *const PFCManifestKeyRequiredPort = @"RequiredPort";
NSString *const PFCManifestKeySharedKey = @"SharedKey";
NSString *const PFCManifestKeyTableViewColumns = @"TableViewColumns";
NSString *const PFCManifestKeyTitle = @"Title";
NSString *const PFCManifestKeyToolTipDescription = @"ToolTipDescription";
NSString *const PFCManifestKeyUnit = @"Unit";
NSString *const PFCManifestKeyValueKeys = @"ValueKeys";
NSString *const PFCManifestKeyValueKeysShared = @"ValueKeysShared";

////////////////////////////////////////////////////////////////////////////////
#pragma mark UserDefaults
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCUserDefaultsLogLevel = @"LogLevel";

////////////////////////////////////////////////////////////////////////////////
#pragma mark FontWeights
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCFontWeightBold = @"Bold";

////////////////////////////////////////////////////////////////////////////////
#pragma mark RuntimeKeys
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCRuntimeKeyPath = @"Path";
NSString *const PFCRuntimeKeyPlistPath = @"PlistPath";
NSString *const PFCRuntimeKeyProfileEditor = @"ProfileEditor";
NSString *const PFCRuntimeKeyProfileExporter = @"ProfileExporter";

////////////////////////////////////////////////////////////////////////////////
#pragma mark Other
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCDefaultProfileName = @"Untitled Profile...";

////////////////////////////////////////////////////////////////////////////////
#pragma mark ProfileTemplateKeys
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCProfileTemplateKeyName = @"Name";
NSString *const PFCProfileTemplateKeyPath = @"Path";
NSString *const PFCProfileTemplateKeySettings = @"Settings";
NSString *const PFCProfileTemplateKeyUUID = @"UUID";

////////////////////////////////////////////////////////////////////////////////
#pragma mark SettingsKeys
////////////////////////////////////////////////////////////////////////////////
NSString *const PFCSettingsKeyEnabled = @"Enabled";
NSString *const PFCSettingsKeySelected = @"Selected";
NSString *const PFCSettingsKeyValue = @"Value";
NSString *const PFCSettingsKeyValueCheckbox = @"ValueCheckbox";
NSString *const PFCSettingsKeyValueHost = @"ValueHost";
NSString *const PFCSettingsKeyValuePort = @"ValuePort";
NSString *const PFCSettingsKeyValueTextField = @"ValueTextField";