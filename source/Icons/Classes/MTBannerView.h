/*
     MTBannerView.h
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

#import <Cocoa/Cocoa.h>
#import "MTAttributedString.h"

@interface MTBannerView : NSView

/*!
 @property      isTruncatingText
 @abstract      A boolean value indicating whether the banner's text has been truncated.
 @discussion    Returns YES if the text has been truncated, otherwise returns NO.
*/
@property (assign, readonly) BOOL isTruncatingText;

/*!
 @property      isMirrored
 @abstract      Specifies if the banner should be drawn on the upper left or the upper right corner of the view.
 @discussion    The value of this property is a boolean. If set to NO, the banner is drawn
 on the upper left side of the view, otherwise the banner is drawn on the upper right corner of the view.
*/
@property (nonatomic, assign, readwrite) BOOL isMirrored;

/*!
 @method        setAttributes:
 @abstract      Set the attributes for a banner.
 @param         attributedString A NSAttributedString object containing the attributes for the
 banner. This should be at least the text, font, text color (NSForegroundColorAttributeName) and the
 banner color (NSBackgroundColorAttributeName).
 @discussion    If the NSAttributedString object contains other attributes as the ones described
 above, they are removed from the string to make sure it contains just the needed attributes and to
 avoid misplacement.
 */
- (void)setAttributes:(NSAttributedString*)attributedString;

@end
