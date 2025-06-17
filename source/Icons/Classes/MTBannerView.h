/*
     MTBannerView.h
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
#import "MTAttributedString.h"

@interface MTBannerView : NSView

/*!
 @enum          MTBannerPosition
 @abstract      Specifies the position of the banner.
 @constant      MTBannerPositionTopLeft Specifies the top left position.
 @constant      MTBannerPositionTopRight Specifies the top right position.
 @constant      MTBannerPositionBottomLeft Specifies the bottom left position.
 @constant      MTBannerPositionBottomRight Specifies the bottom right position.
 @constant      MTBannerPositionTop Specifies a position at the top.
 @constant      MTBannerPositionBottom Specifies a position at the bottom.
*/
typedef enum {
    MTBannerPositionTopLeft     = 0,
    MTBannerPositionTopRight    = 1,
    MTBannerPositionBottomLeft  = 2,
    MTBannerPositionBottomRight = 3,
    MTBannerPositionTop         = 4,
    MTBannerPositionBottom      = 5
} MTBannerPosition;

/*!
 @property      isTruncatingText
 @abstract      A boolean value indicating whether the banner's text has been truncated.
 @discussion    Returns YES if the text has been truncated, otherwise returns NO.
*/
@property (assign, readonly) BOOL isTruncatingText;

/*!
 @property      bannerPosition
 @abstract      Specifies the position the banner should be drawn at.
 @discussion    The value of this property is MTBannerPosition.
*/
@property (nonatomic, assign) MTBannerPosition bannerPosition;

/*!
 @property      debugDrawingEnabled
 @abstract      If set to YES, enables drawing of the text container and the rectange where the banner
                text is acutally drawn into.
 @discussion    The value of this property is boolen.
*/
@property (assign) BOOL debugDrawingEnabled;

/*!
 @property      minimumTextMargin
 @abstract      Specifies the minimum distance between the edge of the banner and the text as a percentage.
 @discussion    The value of this property is a float between 0.0 and 0.4. Values below 0.0 are interpreted as 0.0,
                and values above 0.4 are interpreted as 0.4.
*/
@property (nonatomic, assign) CGFloat minimumTextMargin;

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
