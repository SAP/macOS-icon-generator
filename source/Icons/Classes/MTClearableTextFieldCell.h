/*
    MTClearableTextFieldCell.h
    Copyright 2016-2026 SAP SE

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

@interface MTClearableTextFieldCell : NSTextFieldCell

/*!
 @method        clearButtonRectForBounds:
 @abstract      Returns size and position of the clear button for the given bounds.
 @param         bounds The bounds for which the button position should be returned.
 */
- (NSRect)clearButtonRectForBounds:(NSRect)bounds;

@end
