### Important - This application is currently in initial development.
___

# UI Preview

Here is a static preview of how the UI of the application is developing.  
_As it's still is being developed a lot is still going to change._

## Main Window

This is the main window for the application:

![MainWindow](https://github.com/ProfileCreator/ProfileCreatorResources/blob/master/Screenshots/readme/MainWindow.png)

1. **Organization Panel**  
 This sidebar panel organizes all created profiles into groups.  
 Smart Groups will also be available, as well as shortcuts for local profiles installed or applied through MCX.

2. **Profile List**  
 This is the list of profiles for the selected group in the organiation panel.

3. **Preview**  
 This view shows a preview for the selected profile.  
 Settings will be expanded further to show a lot more relevant information.  
 Payloads can be unfolded to show a glance of the configured settings, or any error that need to be resolved.

## Profile Editor

This is what the profile editing window will look like:

![ProfileEditor](https://github.com/ProfileCreator/ProfileCreatorResources/blob/master/Screenshots/readme/ProfileEditor.png)

1. **Profile Payloads**  
 Top left holds all payloads selected to be included in the profile.

2. **Payload Library**  
 This is the library of all available payloads to configure.  
 Currently separated by Apple profiles, MCX, local settings (Preferences) and Custom.

3. **Payload View**  
 Displays the settings for the currently selected payload.  
 This is where you edit your payload settings.  
 You can add multiple payloads in the + button top left.

4. **Payload Content Visibility**  
 This popover allows you to change what keys are displayed in the payload view.  
 This makes it easier to ignore OS Platforms, versions or specifically hidden keys.

# ProfileCreator
OS X Application to create configuration profiles.

# System Requirements
ProfileCreator requires Mac OS X 10.10 or newer.

# Acknowledgements

ProfileCreator makes use of the following open source components:

* [CocoaLumberjack](https://github.com/CocoaLumberjack/CocoaLumberjack)
* [RFOverlayScrollView](https://github.com/rheinfabrik/RFOverlayScrollView)
* [NSView+NSLayoutConstraintFilter](https://github.com/iluuu1994/ITSearchField/blob/8c4350bf7422a4d9d6a1ee4de6dccfd8d41d52e4/Expanding%20Search/Expanding%20Search/NSView%2BNSLayoutConstraintFilter.h)

UI Icons from the following sites:

* [icons8.com](https://icons8.com)

# License
    Copyright 2016 Erik Berglund. All rights reserved.
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at
    
      http://www.apache.org/licenses/LICENSE-2.0
    
    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
