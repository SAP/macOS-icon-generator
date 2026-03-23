/*
    MTProcessInfo.h
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

/*!
 @class         MTProcessInfo
 @abstract      A class that provides methods to access the relevant command line arguments.
*/

@interface MTProcessInfo : NSProcessInfo

/*!
 @method        animationDuration
 @abstract      Get the animation duration.
 @discussion    Returns a float.
 */
- (CGFloat)animationDuration;

/*!
 @method        outputSize
 @abstract      Get the output size of the icon.
 @discussion    Returns an unsigned integer.
 */
- (NSUInteger)outputSize;

/*!
 @method        imageInset
 @abstract      Get the image inset of the uninstall icon.
 @discussion    Returns a float.
 */
- (CGFloat)imageInset;

/*!
 @method        bannerText
 @abstract      Get the text of the banner.
 @discussion    Returns a string.
 */
- (NSString*)bannerText;

/*!
 @method        textColor
 @abstract      Get the color of the banner's text.
 @discussion    Returns an unsigned integer.
 */
- (NSUInteger)textColor;

/*!
 @method        bannerColor
 @abstract      Get the color of the banner.
 @discussion    Returns an unsigned integer.
 */
- (NSUInteger)bannerColor;

/*!
 @method        bannerPosition
 @abstract      Get the position of the banner.
 @discussion    Returns a string.
 */
- (NSString*)bannerPosition;

/*!
 @method        inputFilePath
 @abstract      Get the path to the input file.
 @discussion    Returns a string.
 */
- (NSString*)inputFilePath;

/*!
 @method        outputFolderPath
 @abstract      Get the path to the output folder.
 @discussion    Returns a string.
 */
- (NSString*)outputFolderPath;

/*!
 @method        textMargin
 @abstract      Get the minimum margin between the text and the edge of the banner.
 @discussion    Returns a float.
 */
- (CGFloat)textMargin;

/*!
 @method        bannerAngle
 @abstract      Get the banner's angle in degrees.
 @discussion    Returns a float.
 */
- (CGFloat)bannerAngle;

/*!
 @method        bannerHeight
 @abstract      Get the banner's height.
 @discussion    Returns a float.
 */
- (CGFloat)bannerHeight;

/*!
 @method        bannerMargin
 @abstract      Get the margin between the banner and the corner of the icon.
 @discussion    Returns a float.
 */
- (CGFloat)bannerMargin;

/*!
 @method        fileNamePrefix
 @abstract      Get the prefix the should be used for the icon file name.
 @discussion    Returns a string.
 */
- (NSString*)fileNamePrefix;

/*!
 @method        excludeFromCreation
 @abstract      Get the icons that should be excluded from creation.
 @discussion    Returns a string.
 */
- (NSString*)excludeFromCreation;

/*!
 @method        deleteBadgeFilePath
 @abstract      Get the path to the image of the custom delete badge.
 @discussion    Returns a string.
 */
- (NSString*)deleteBadgeFilePath;

/*!
 @method        deleteBadgeSize
 @abstract      Get size of the custom delete badge.
 @discussion    Returns a float.
 */
- (CGFloat)deleteBadgeSize;

/*!
 @method        deleteBadgeMargin
 @abstract      Get margin between the custom delete badge and the edge of the icon.
 @discussion    Returns a float.
 */
- (CGFloat)deleteBadgeMargin;

/*!
 @method        deleteBadgePosition
 @abstract      Get the position of the custom delete badge.
 @discussion    Returns a string.
 */
- (NSString*)deleteBadgePosition;
/*!
 @method        showVersion
 @abstract      Get whether the version should be displayed.
 @discussion    Returns YES if the version should be displayed, otherwise returns NO.
 */
- (BOOL)showVersion;

/*!
 @method        launchURL
 @abstract      Get the launch url of the current process.
 @discussion    Returns an NSURL object or nil, if an error occurred.
 */
- (NSURL*)launchURL;

@end
