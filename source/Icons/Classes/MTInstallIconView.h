/*
     MTInstallIconView.h
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

#import "MTDropView.h"
#import "MTBannerView.h"
#import "MTOverlayImageView.h"

@interface MTInstallIconView : MTDropView <MTOverlayImageViewDelegate>

/*!
 @property      overlayImageScalingFactor
 @abstract      Specifies the scaling factor of the overlay image in percent.
 @discussion    The value of this property is float.
*/
@property (nonatomic, assign) CGFloat overlayImageScalingFactor;

/*!
 @property      overlayImageAspectRatio
 @abstract      Specifies the aspect ratio of the overlay image.
 @discussion    The value of this property is float.
*/
@property (nonatomic, assign) CGFloat overlayImageAspectRatio;

/*!
 @property      overlayPosition
 @abstract      Specifies the position of the overlay image. A value of {0, 0} specifies
                the center of the view. The x/y values of the point can be between -1 and 1.
 @discussion    The value of this property is NSPoint.
*/
@property (nonatomic, assign) NSPoint overlayPosition;

/*!
 @property      bannerAttributes
 @abstract      The attributes for the banner (color, text and text color).
 @discussion    The value of this property is a NSAttributedString object.
*/
@property (nonatomic, strong) NSAttributedString *bannerAttributes;

/*!
 @property      bannerPosition
 @abstract      Specifies the position the banner should be drawn at.
 @discussion    The value of this property is MTBannerPosition.
*/
@property (nonatomic, assign) MTBannerPosition bannerPosition;

/*!
 @property      bannerTextMargin
 @abstract      Specifies the minimum distance between the edge of the
                banner and the text as a percentage.
 @discussion    The value of this property is a float between 0.0 and 0.4. Values below 0.0 are interpreted as 0.0,
                and values above 0.4 are interpreted as 0.4.
*/
@property (nonatomic, assign) CGFloat bannerTextMargin;

/*!
 @method        setImage:
 @abstract      Set the view's source image.
 @param         image A NSImage object (may be nil).
 */
- (void)setImage:(NSImage *)image;

/*!
 @method        setOverlayImage:
 @abstract      Set the view's overlay image.
 @param         image A NSImage object (may be nil).
 */
- (void)setOverlayImage:(NSImage *)image;

/*!
 @method        overlayImage
 @abstract      Returns the view's overlay image.
 */
- (NSImage*)overlayImage;

/*!
 @method        icon
 @abstract      Returns the composed icon of the view.
 */
- (NSView*)icon;

@end
