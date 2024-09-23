/*
     MTOverlayImageView.h
     Copyright 2024 SAP SE
     
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

@class MTOverlayImageView;

/*!
 @protocol      MTOverlayImageViewDelegate
 @abstract      Defines an interface for delegates of MTOverlayImageView to be notified if specific aspects of the view have changed.
*/
@protocol MTOverlayImageViewDelegate <NSObject>
@optional

/*!
 @method        view:didStartDraggingAtPoint:
 @abstract      Called whenever the view is dragged.
 @param         view A reference to the MTOverlayImageView instance that is dragged.
 @param         point The origin of the MTOverlayImageView instance.
 @discussion    Delegates receive this message whenever the view is dragged.
 */
- (void)view:(MTOverlayImageView*)view didStartDraggingAtPoint:(NSPoint)point;

/*!
 @method        view:didMoveToPoint:
 @abstract      Called whenever the view has been moved.
 @param         view A reference to the MTOverlayImageView instance that has moved.
 @param         point The origin of the MTOverlayImageView instance.
 @discussion    Delegates receive this message whenever the view has been moved.
 */
- (void)view:(MTOverlayImageView*)view didMoveToPoint:(NSPoint)point;

/*!
 @method        view:didEndDraggingAtPoint:
 @abstract      Called whenever the view has been dragged.
 @param         view A reference to the MTOverlayImageView instance that ended dragging.
 @param         point The origin of the MTOverlayImageView instance.
 @discussion    Delegates receive this message whenever the view has ended dragging.
 */
- (void)view:(MTOverlayImageView*)view didEndDraggingAtPoint:(NSPoint)point;

/*!
 @method        view:didCancelDraggingAtPoint:
 @abstract      Called whenever the dragging operation has been cancelled.
 @param         view A reference to the MTOverlayImageView instance the dragging operation has been cancelled for.
 @param         point The origin of the MTOverlayImageView instance.
 @discussion    Delegates receive this message whenever the dragging operation has been cancelled.
 */
- (void)view:(MTOverlayImageView*)view didCancelDraggingAtPoint:(NSPoint)point;

/*!
 @method        view:hasBeenRemovedFromSuperView:
 @abstract      Called whenever the view has been dragged out of its superview.
 @param         view A reference to the MTOverlayImageView instance that has been dragged out of its superview.
 @param         superview A reference to the MTOverlayImageView's superview.
 @discussion    Delegates receive this message whenever the view has been dragged out of its superview.
 */
- (void)view:(MTOverlayImageView*)view hasBeenRemovedFromSuperView:(NSView*)superview;

/*!
 @method        viewDidResize:
 @abstract      Called whenever the view has been resized.
 @param         view A reference to the MTOverlayImageView instance that has been resized.
 @discussion    Delegates receive this message whenever the view has been resized.
 */
- (void)viewDidResize:(MTOverlayImageView*)view;

@end

@interface MTOverlayImageView : NSImageView <NSDraggingSource>

/*!
 @property      delegate
 @abstract      The receiver's delegate.
 @discussion    The value of this property is an object conforming to the MTRoundedViewDelegate protocol.
*/
@property (weak) id <MTOverlayImageViewDelegate> delegate;

@end
