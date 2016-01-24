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

////////////////////////////////////////////////////////////////////////////////
#pragma mark CellType
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCCellTypeCheckbox;
extern NSString *const PFCCellTypeCheckboxNoDescription;
extern NSString *const PFCCellTypeDatePicker;
extern NSString *const PFCCellTypeDatePickerNoTitle;
extern NSString *const PFCCellTypeFile;
extern NSString *const PFCCellTypeMenu;
extern NSString *const PFCCellTypePadding;
extern NSString *const PFCCellTypePopUpButton;
extern NSString *const PFCCellTypePopUpButtonLeft;
extern NSString *const PFCCellTypePopUpButtonNoTitle;
extern NSString *const PFCCellTypeSegmentedControl;
extern NSString *const PFCCellTypeTableView;
extern NSString *const PFCCellTypeTextField;
extern NSString *const PFCCellTypeTextFieldCheckbox;
extern NSString *const PFCCellTypeTextFieldDaysHoursNoTitle;
extern NSString *const PFCCellTypeTextFieldHostPort;
extern NSString *const PFCCellTypeTextFieldHostPortCheckbox;
extern NSString *const PFCCellTypeTextFieldNoTitle;
extern NSString *const PFCCellTypeTextFieldNumber;
extern NSString *const PFCCellTypeTextFieldNumberLeft;

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
extern NSString *const PFCManifestKeyAllowedFileTypes;
extern NSString *const PFCManifestKeyAllowMultiplePayloads;
extern NSString *const PFCManifestKeyAvailableValues;
extern NSString *const PFCManifestKeyButtonTitle;
extern NSString *const PFCManifestKeyCellType;
extern NSString *const PFCManifestKeyDefaultValue;
extern NSString *const PFCManifestKeyDefaultValueCheckbox;
extern NSString *const PFCManifestKeyDefaultValueHost;
extern NSString *const PFCManifestKeyDefaultValuePort;
extern NSString *const PFCManifestKeyDefaultValueTextField;
extern NSString *const PFCManifestKeyDescription;
extern NSString *const PFCManifestKeyDomain;
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
extern NSString *const PFCManifestKeyManifestContent;
extern NSString *const PFCManifestKeyMaxValue;
extern NSString *const PFCManifestKeyMinValue;
extern NSString *const PFCManifestKeyOptional;
extern NSString *const PFCManifestKeyParentKey;
extern NSString *const PFCManifestKeyPayloadKey;
extern NSString *const PFCManifestKeyPayloadKeyCheckbox;
extern NSString *const PFCManifestKeyPayloadKeyHost;
extern NSString *const PFCManifestKeyPayloadKeyPort;
extern NSString *const PFCManifestKeyPayloadKeyTextField;
extern NSString *const PFCManifestKeyPayloadParentKey;
extern NSString *const PFCManifestKeyPayloadParentKeyCheckbox;
extern NSString *const PFCManifestKeyPayloadParentKeyHost;
extern NSString *const PFCManifestKeyPayloadParentKeyPort;
extern NSString *const PFCManifestKeyPayloadParentKeyTextField;
extern NSString *const PFCManifestKeyPayloadParentValueType;
extern NSString *const PFCManifestKeyPayloadType;
extern NSString *const PFCManifestKeyPayloadValueType;
extern NSString *const PFCManifestKeyPayloadValue;
extern NSString *const PFCManifestKeyPlaceholderValue;
extern NSString *const PFCManifestKeyPlaceholderValueHost;
extern NSString *const PFCManifestKeyPlaceholderValuePort;
extern NSString *const PFCManifestKeyPlaceholderValueTextField;
extern NSString *const PFCManifestKeyRequired;
extern NSString *const PFCManifestKeyRequiredHost;
extern NSString *const PFCManifestKeyRequiredPort;
extern NSString *const PFCManifestKeySharedKey;
extern NSString *const PFCManifestKeyTableViewColumns;
extern NSString *const PFCManifestKeyTitle;
extern NSString *const PFCManifestKeyToolTipDescription;
extern NSString *const PFCManifestKeyUnit;
extern NSString *const PFCManifestKeyValueKeys;
extern NSString *const PFCManifestKeyValueKeysShared;

////////////////////////////////////////////////////////////////////////////////
#pragma mark FontWeights
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCFontWeightBold;

////////////////////////////////////////////////////////////////////////////////
#pragma mark RuntimeKeys
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCRuntimeKeyPlistPath;
extern NSString *const PFCRuntimeKeyProfileEditor;
extern NSString *const PFCRuntimeKeyProfileExporter;
extern NSString *const PFCRuntimeKeyPath;

////////////////////////////////////////////////////////////////////////////////
#pragma mark Other
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCDefaultProfileName;

////////////////////////////////////////////////////////////////////////////////
#pragma mark ProfileTemplateKeys
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCProfileTemplateKeyName;
extern NSString *const PFCProfileTemplateKeySettings;
extern NSString *const PFCProfileTemplateKeyUUID;

////////////////////////////////////////////////////////////////////////////////
#pragma mark SettingsKeys
////////////////////////////////////////////////////////////////////////////////
extern NSString *const PFCSettingsKeyEnabled;
extern NSString *const PFCSettingsKeySelected;
extern NSString *const PFCSettingsKeyValue;
extern NSString *const PFCSettingsKeyValueCheckbox;
extern NSString *const PFCSettingsKeyValueHost;
extern NSString *const PFCSettingsKeyValuePort;
extern NSString *const PFCSettingsKeyValueTextField;
