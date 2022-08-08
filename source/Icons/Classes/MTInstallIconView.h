/*
     MTInstallIconView.h
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
#import "MTBannerView.h"

@interface MTInstallIconView : MTDropView

/*!
 @property      bannerAttributes
 @abstract      The attributes for the banner (color, text and text color).
 @discussion    The value of this property is a NSAttributedString object.
*/
@property (nonatomic, strong, readwrite) NSAttributedString *bannerAttributes;

/*!
 @property      bannerIsMirrored
 @abstract      Specifies if the banner should be drawn on the upper left or the upper right corner of the view.
 @discussion    The value of this property is a boolean. If set to NO, the banner is drawn
 on the upper left side of the view, otherwise the banner is drawn on the upper right corner of the view.
*/
@property (nonatomic, assign, readwrite) BOOL bannerIsMirrored;

/*!
 @method        setImage:
 @abstract      Set the view's source image.
 @param         image A NSImage object (may be nil).
 */
- (void)setImage:(NSImage *)image;

/*!
 @method        icon
 @abstract      Returns the composed icon of the view.
 */
- (NSView*)icon;

@end
