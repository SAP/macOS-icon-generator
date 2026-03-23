/*
    MTUninstallIconView.h
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

#import "MTDropView.h"
#import <QuartzCore/QuartzCore.h>
#import "MTDeleteBadgeView.h"
#import "MTImage.h"
#import "MTBundle.h"
#import "Constants.h"

@interface MTUninstallIconView : MTDropView <NSCopying>

/*!
 @enum          MTBadgePosition
 @abstract      Specifies the position of the custom delete badge.
 @constant      MTBadgePositionTopLeft Specifies the top left position.
 @constant      MTBadgePositionTopRight Specifies the top right position.
 @constant      MTBadgePositionBottomLeft Specifies the bottom left position.
 @constant      MTBadgePositionBottomRight Specifies the bottom right position.
*/
typedef enum {
    MTBadgePositionTopLeft     = 0,
    MTBadgePositionTopRight    = 1,
    MTBadgePositionBottomLeft  = 2,
    MTBadgePositionBottomRight = 3
} MTBadgePosition;

/*!
 @property      imageInset
 @abstract      The inset for the icon image.
 @discussion    The value of this property is a float.
*/
@property (nonatomic, assign) CGFloat imageInset;

/*!
 @property      badgeSize
 @abstract      The size of the delete badge icon as a percentage of the icon size.
 @discussion    The value of this property is a float.
*/
@property (nonatomic, assign) CGFloat badgeSize;

/*!
 @property      badgeMargin
 @abstract      The margin between the delete badge icon and the corner of the view as a percentage of the icon size.
 @discussion    The value of this property is a float.
*/
@property (nonatomic, assign) CGFloat badgeMargin;

/*!
 @property      badgePosition
 @abstract      Specifies the position the delete badge should be drawn at.
 @discussion    The value of this property is MTBadgePosition.
*/
@property (nonatomic, assign) MTBadgePosition badgePosition;

/*!
 @property      autoInsetEnabled
 @abstract      A boolean value indicating whether automatic inset calculation is enabled.
 @discussion    Returns YES if auto inset is enabled, otherwise returns NO. If set to YES,
                an image is automatically inset (if needed) whenever setImage: is called.
*/
@property (assign) BOOL autoInsetEnabled;

/*!
 @property      deleteBadge
 @abstract      Specifies the icon's delete badge.
 @discussion    The value of this property is MTDeleteBadgeView.
*/
@property (nonatomic, strong, readwrite) MTDeleteBadgeView *deleteBadge;

/*!
 @property      hasCustomDeleteBadge
 @abstract      A boolean value indicating whether a custom delete badge was set by the user.
 @discussion    Returns YES if a custom release badge was set, otherwise returns NO.
*/
@property (assign, readonly) BOOL hasCustomDeleteBadge;

/*!
 @method        setImage:
 @abstract      Set the view's source image.
 @param         image A NSImage object (may be nil).
 */
- (void)setImage:(NSImage *)image;

/*!
 @method        setDeleteBadge:
 @abstract      Set the delete badge.
 @param         deleteBadge An NSImage object (may be nil).
 */
- (void)setDeleteBadge:(MTDeleteBadgeView*)deleteBadge;
           
/*!
 @method        autoInset
 @abstract      Calculate the smallest inset needed to ensure the image is not cropped during animation.
 @discussion    Returns the number of pixels the image needs to be inset.
 */
- (CGFloat)autoInset;

/*!
 @method        animateWithDuration:repeatCount:
 @abstract      Animates the view's uninstall image for the given duration.
 @param         duration The duration for the animation.
 @param         repeatCount The number of times the animation should be repeated.
 */
- (void)animateWithDuration:(CGFloat)duration repeatCount:(NSInteger)repeatCount;

/*!
 @method        icon
 @abstract      Returns the composed icon of the view.
 */
- (NSView*)icon;

@end
