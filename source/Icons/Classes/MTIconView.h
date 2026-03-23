/*
    MTIconView.h
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
#import <QuartzCore/CAShapeLayer.h>

@interface MTIconView : NSView

/*!
 @property      image
 @abstract      Specifies the image to draw into an icon shape.
 @discussion    The value of this property is NSImage.
 */
@property (nonatomic, strong, readwrite) NSImage *image;

/*!
 @property      usesOldIconShape
 @abstract      Specifies whether or not to use the icon shape from before macOS 26.
 @discussion    The value of this property is boolean.
 */
@property (assign) BOOL usesOldIconShape;

/*!
 @property      boundingRect
 @abstract      Returns the icon's bounding rect.
 @discussion    The value of this property is NSRect.
 */
@property (assign, readonly) NSRect boundingRect;

/*!
 @property      cornerRadius
 @abstract      Returns the corner radius of the icon.
 @discussion    The value of this property is CGFloat.
 */
@property (assign, readonly) CGFloat cornerRadius;

/*!
 @method        init:
 @discussion    The init method is not available. Please use initWithFrame: instead.
*/
- (instancetype)init NS_UNAVAILABLE;

/*!
 @method        initWithFrame:
 @abstract      Initializes and returns a newly allocated MTIconView object with a specified frame rectangle.
 @param         frameRect The frame rectangle for the created view object.
 @discussion    This method is the designated initializer for the MTIconView class.
*/
- (instancetype)initWithFrame:(NSRect)frameRect NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder*)coder NS_UNAVAILABLE;

@end
