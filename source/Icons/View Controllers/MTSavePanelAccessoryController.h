/*
     MTSavePanelAccessoryController.h
     Copyright 2023-2024 SAP SE
     
     Licensed under the Apache License, Version 2.0 (the "License");
     you may not use this file except in compliance with the License.
     You may obtain a copy of the License at
     
     http://www.apache.org/licenses/LICENSE-2.0
     
     Unless required by applicable law or agreed to in writing, software
     distributed under the License is distributed on an "AS IS" BASIS,
     WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
     See the License for the specific language governing permissions and
     limitations under the License.
*/

#import <Cocoa/Cocoa.h>

@interface MTSavePanelAccessoryController : NSViewController <NSMenuDelegate>

/*!
 @property      sourceImage
 @abstract      Specifies the image used for the icon set.
 @discussion    The value of this property is a NSImage object. It is used to determine
                the best size for the icon set and to display an upscale warning if the
                user selects a size that is too big.
*/
@property (nonatomic, strong, readwrite) NSImage *sourceImage;

@end
