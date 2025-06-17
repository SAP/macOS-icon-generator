/*
     MTImage.h
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
 @abstract This class extends the NSImage class and provides methods for scaling and rotating images.
 */

@interface NSImage (MTImage)

/*!
 @method        imageRotatedByDegrees:
 @abstract      Rotate the image by the given angle (in degrees).
 @param         degrees A float defining the angle the image should be rotated by.
 @discussion    Returns the rotated image or nil if an error occurred.
 */
- (NSImage*)imageRotatedByDegrees:(CGFloat)degrees;

/*!
 @method        imageScaledToSize:maintainAspectRatio:
 @abstract      Scale the image to the given size whith or without maintaining the aspect ratio.
 @param         targetSize The size the image should be scaled to.
 @param         aspectRatio A boolean indicating if the original image's aspect ratio should be maintained or not.
 @discussion    Returns the scaled image or nil if an error occurred.
 */
- (NSImage*)imageScaledToSize:(CGSize)targetSize maintainAspectRatio:(BOOL)aspectRatio;

/*!
 @method        canBeScaledToSize:
 @abstract      Check if the image can be scaled to the given size (without upscaling).
 @param         scaleSize The size the image should be scaled to.
 @discussion    Returns YES if the image can be scaled to the given size, otherwise returns NO.
 */
- (BOOL)canBeScaledToSize:(NSSize)scaleSize;

/*!
 @method        pngData
 @abstract      Get the PNG data of the image, so it could e.g. be written into a file.
 @discussion    Returns the PNG data of the image or nil if an error occurred.
 */
- (NSData*)pngData;

/*!
 @method        imageWithFileAtURL:
 @abstract      Get a NSImage object from the file at the given path.
 @param         url The file url to the image file or app bundle.
 @discussion    Returns an NSImage object of the given file or nil if an error occurred. In contrast to
 NSImage's "initWithContentsOfFile:" method, this method also returns an icon image from a given app bundle.
 */
+ (NSImage*)imageWithFileAtURL:(NSURL*)url;

/*!
 @method        imageWithView:size
 @abstract      Get a NSImage object of the view with the given size.
 @param         view The view to get an image from.
 @param         size The size for the image.
 @discussion    Returns an initialized image object.
 */
+ (NSImage*)imageWithView:(NSView*)view size:(NSSize)size;

@end
