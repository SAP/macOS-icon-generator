/*
     MTTextColorValueTransformer.h
     Copyright 2022-2024 SAP SE
     
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

/*!
 @abstract A value transformer creates a NSAttributedString from a given NSData object and returns
 a NSColor object containing the attributed string's text color (NSForegroundColorAttributeName). This
 is used to bind our table cell's font attribute to our table view's objectValue (which returns a NSData
 object).
 */

@interface MTTextColorValueTransformer : NSValueTransformer

@end
