/*
     MTColor.h
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
 @abstract This class extends the NSColor class and provides a method to create a NSColor object from an integer value and vice versa. In addition to this, it provides a method that returns the complimentary color of a given NSColor object.
 */

@interface NSColor (MTColor)

/*!
 @method        colorFromInteger:
 @abstract      Creates a NSColor object from a given integer value.
 @param         integerValue The integer value of the color.
 */
+ (NSColor*)colorFromInteger:(NSInteger)integerValue;

/*!
 @method        integerValue
 @abstract      Returns the integer value of the receiver.
 */
- (NSInteger)integerValue;

/*!
 @method        complementaryColor
 @abstract      Returns a NSColor object representing the complementary color of the receiver.
 */
- (NSColor*)complementaryColor;

@end
