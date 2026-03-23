/*
    MTDeleteBadgeView.h
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

@interface MTDeleteBadgeView : NSImageView <NSCopying>

/*!
 @property      showsShadow
 @abstract      Specifies whether or not to draw a drop shadow.
 @discussion    The value of this property is boolean.
 */
@property (nonatomic, assign) BOOL showsShadow;

/*!
 @property      shadowColor
 @abstract      Specifies the color of the drop shadow.
 @discussion    The value of this property is NSColor.
 */
@property (nonatomic, strong, readwrite) NSColor *shadowColor;

/*!
 @property      shadowOffset
 @abstract      Specifies the offset of the drop shadow.
 @discussion    The value of this property is CGFloat.
 */
@property (nonatomic, assign) CGFloat shadowOffset;

/*!
 @property      shadowAngle
 @abstract      Specifies the angle of the drop shadow.
 @discussion    The value of this property is CGFloat.
 */
@property (nonatomic, assign) CGFloat shadowAngle;

/*!
 @property      shadowRadius
 @abstract      Specifies the radius of the drop shadow.
 @discussion    The value of this property is CGFloat.
 */
@property (nonatomic, assign) CGFloat shadowRadius;

/*!
 @method        init:
 @discussion    The init method is not available. Please use initWithFrame: instead.
*/
- (instancetype)init NS_UNAVAILABLE;

/*!
 @method        initWithFrame:
 @abstract      Initializes and returns a newly allocated MTDeleteBadge object with a specified frame rectangle.
 @param         frameRect The frame rectangle for the created view object.
 @discussion    This method is the designated initializer for the MTDeleteBadge class.
*/
- (instancetype)initWithFrame:(NSRect)frameRect NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

@end
