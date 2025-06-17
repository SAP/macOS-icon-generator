/*
     MTAttributedString.h
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

#import <Cocoa/Cocoa.h>

/*!
 @abstract This class extends the NSAttributedString class and provides methods to easily deal with
 text color, background color, font and font size.
 */

@interface NSAttributedString (MTAttributedString)

/*!
 @method        initWithString:font:foregroundColor:backgroundColor:
 @abstract      Creates an attributed string with the characters of the specified string,
 the given font, foreground color and background color.
 @param         string The characters for the attributed string.
 @param         font The font for the attributed string. May be nil.
 @param         foregroundColor The text color for the attributed string. May be nil.
 @param         backgroundColor The background color for the attributed string. May be nil.
 @discussion    Returns a NSAttributedString object with the given string and the provided attributes,
 or nil if an error occurred.
 */
- (instancetype)initWithString:(NSString*)string
                          font:(NSFont*)font
               foregroundColor:(NSColor*)foregroundColor
               backgroundColor:(NSColor*)backgroundColor;

/*!
 @method        attributedStringWithTextColor:
 @abstract      Returns an attributed string with the given text color.
 @param         color A NSColor oject representing the string's text color.
 @discussion    Returns a NSAttributedString object with its text color attribute set to
 the given color..
 */
- (NSAttributedString*)attributedStringWithTextColor:(NSColor*)color;

/*!
 @method        attributedStringWithBackgroundColor:
 @abstract      Returns an attributed string with the given background color.
 @param         color A NSColor oject representing the string's background color.
 @discussion    Returns a NSAttributedString object with its background color attribute set to
 the given color..
 */
- (NSAttributedString*)attributedStringWithBackgroundColor:(NSColor*)color;

/*!
 @method        textColor
 @abstract      Returns the text color of the NSAttributedString object.
 @discussion    Returns a NSColor object representing the string's text color. If the text color
 attribute does not exist, the method returns black color.
 */
- (NSColor*)textColor;

/*!
 @method        backgroundColor
 @abstract      Returns the background color of the NSAttributedString object.
 @discussion    Returns a NSColor object representing the string's background color or nil, if the background
 color attribute does not exist.
 */
- (NSColor*)backgroundColor;

/*!
 @method        font
 @abstract      Returns the font of the NSAttributedString object.
 @discussion    Returns a NSFont object representing the string's font or nil, if the font attribute
 does not exist.
 */
- (NSFont*)font;

/*!
 @method        fontSizeToFitInRect:minimumFontSize:maximumFontSize:useImageBounds:
 @abstract      Returns the optimal font size for the attributed string to fit in the given rect.
 @param         rect The rect to draw the attributed sting in.
 @param         minFontSize The minimum font size.
 @param         maxFontSize The maximum font size.
 @param         imageBounds If set to YES, the image bounds will be used to calculate
                the font size, otherwise the typographic bounds are used.
 @discussion    Returns the optimal font size that can be used to draw the string into the given
                rect without truncating the string. If the string should be drawn using the drawInRect:
                method, make sure @c useImageBounds is set to NO. Otherwise the font size might
                be much bigger than expected. If you set @c useImageBounds to YES, please use
                Core Type to draw the string.
 */
- (CGFloat)fontSizeToFitInRect:(NSRect)rect
               minimumFontSize:(CGFloat)minFontSize
               maximumFontSize:(CGFloat)maxFontSize
                useImageBounds:(BOOL)imageBounds;

/*!
 @method        imageBounds
 @abstract      Returns the image bounds for the string.
 @discussion    Returns a rectangle that tightly encloses the paths of the string's glyphs, or, if the string
                or context is invalid, CGRectNull.
 */
- (CGRect)imageBounds;

@end
