/*
     MTBundle.h
     Copyright 2022-2025 SAP SE
     
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

#import <Foundation/Foundation.h>

/*!
 @abstract This class extends the NSBundle class and provides a method to help a plug-in to get it's container bundle.
 */

@interface NSBundle (MTBundle)

/*!
 @method        containerBundleForClass:
 @abstract      Get the container bundle of a plug-in (app extension, docktile plug-in).
 @param         aClass The plug-in's class.
 @discussion    Returns the container bundle (the main bundle of the app that contains the plug-in).
 If this method called from an app and not from a plug-in, it just returns the app's main bundle. This method
 returns nil if an error occurred.
 */
+ (NSBundle*)containerBundleForClass:(Class)aClass;

@end

