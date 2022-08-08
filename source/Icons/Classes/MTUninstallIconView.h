/*
     MTUninstallIconView.h
     Copyright 2022 SAP SE
     
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
#import "MTImage.h"
#import "MTBundle.h"
#import "Constants.h"

@interface MTUninstallIconView : MTDropView

/*!
 @property      imageInset
 @abstract      The inset for the icon image.
 @discussion    The value of this property is a float.
*/
@property (nonatomic, assign) CGFloat imageInset;

/*!
 @property      autoInsetEnabled
 @abstract      A boolean value indicating whether automatic inset calculation is enabled.
 @discussion    Returns YES if auto inset is enabled, otherwise returns NO. If set to YES,
 an image is automatically inset (if needed) whenever setImage: is called.
*/
@property (nonatomic, assign) BOOL autoInsetEnabled;

/*!
 @method        setImage:
 @abstract      Set the view's source image.
 @param         image A NSImage object (may be nil).
 */
- (void)setImage:(NSImage *)image;

/*!
 @method        setCloseBox:
 @abstract      Set the image for the close box.
 @param         closeBox A NSImage object (may be nil).
 */
- (void)setCloseBox:(NSImage *)closeBox;

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
