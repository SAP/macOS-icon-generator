/*
    MTDropView.h
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
#import "MTIconView.h"

@class MTDropView;

/*!
 @protocol      MTDropViewDelegate
 @abstract      Defines an interface for delegates of MTDropView to be notified if the view's source picture has changed.
*/
@protocol MTDropViewDelegate <NSObject>
@optional

/*!
 @method        view:didChangeImage:applicationBundle:
 @abstract      Called whenever the view's source image has changed.
 @param         view The MTDropView instance whose source image has changed.
 @param         image A reference to the new image object.
 @param         application A boolean specifying if the image came from an app bundle or not.
 @discussion    Delegates receive this message whenever the view's source image has changed.
 */
- (void)view:(MTDropView*)view didChangeImage:(NSImage*)image applicationBundle:(BOOL)application;

/*!
 @method        view:hasBeenClickedAtLocation:
 @abstract      Called whenever the view has been clicked on.
 @param         view The MTDropView instance that has been clicked on.
 @param         location The location of the click.
 @discussion    Delegates receive this message whenever the view has been clicked on.
 */
- (void)view:(MTDropView*)view hasBeenClickedAtLocation:(NSPoint)location;

@end

@interface MTDropView : NSView <NSDraggingDestination>
{
    @protected NSImage *_image;
    @protected NSImage *_unmodifiedImage;
    @protected BOOL _applyIconShape;
    @protected BOOL _usesOldIconShape;
    @protected BOOL _isAppBundle;
}

/*!
 @property      delegate
 @abstract      The receiver's delegate.
 @discussion    The value of this property is an object conforming to the MTDropViewDelegate protocol.
 */
@property (weak) id <MTDropViewDelegate> delegate;

/*!
 @property      image
 @abstract      The current image after applying (e.g. an icon shape).
 @discussion    The value of this property is a NSImage object. May be nil.
 */
@property (nonatomic, strong, readwrite) NSImage *image;

/*!
 @property      unmodifiedImage
 @abstract      The image dropped to the view.
 @discussion    The value of this property is a NSImage object. May be nil.
 */
@property (nonatomic, strong, readwrite) NSImage *unmodifiedImage;

/*!
 @property      applyIconShape
 @abstract      Specifies whether or not to draw the dropped image into an icon shape.
 @discussion    The value of this property is boolean.
 */
@property (nonatomic, assign) BOOL applyIconShape;

/*!
 @property      usesOldIconShape
 @abstract      Specifies whether or not to use the icon shape from before macOS 26.
 @discussion    The value of this property is boolean.
 */
@property (nonatomic, assign) BOOL usesOldIconShape;

/*!
 @property      isAppBundle
 @abstract      Specifies whether or not the icon comes from an app bundle.
 @discussion    The value of this property is boolean.
 */
@property (nonatomic, assign) BOOL isAppBundle;

@end
