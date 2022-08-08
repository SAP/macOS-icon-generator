/*
     MTDropView.h
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

@class MTDropView;

/*!
 @protocol      MTDropViewDelegate
 @abstract      Defines an interface for delegates of MTDropView to receive to be notified if the view's source picture has changed.
*/
@protocol MTDropViewDelegate <NSObject>

/*!
 @method        view:didChangeImage:
 @abstract      Called whenever the view's source image has changed.
 @param         view The MTDropView instance whose source image has changed.
 @param         image A NSImage object containing the image data of the source image.
 @discussion    Delegates receive this message whenever the view's source image has changed.
 */
- (void)view:(MTDropView*)view didChangeImage:(NSImage*)image;

@end

@interface MTDropView : NSView <NSDraggingDestination>
{
    @protected NSImage *_image;
}

/*!
 @property      delegate
 @abstract      The receiver's delegate.
 @discussion    The value of this property is an object conforming to the MTDropViewDelegate protocol.
*/
@property (weak) id <MTDropViewDelegate> delegate;

/*!
 @property      image
 @abstract      The image dropped to the view.
 @discussion    The value of this property is a NSImage object. May be nil.
*/
@property (nonatomic, strong, readonly) NSImage *image;

@end
