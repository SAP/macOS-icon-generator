/*
     MTOverlayImageView.m
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

#import "MTOverlayImageView.h"

@interface MTOverlayImageView ()
@property (assign) NSPoint cursorPoint;
@property (assign) BOOL shouldBeRemoved;
@end

@implementation MTOverlayImageView

- (void)setImage:(NSImage *)image
{
    [super setImage:image];
    
    _shouldBeRemoved = NO;
    
    [self setHidden:(image) ? NO : YES];
    [self setAllowsExpansionToolTips:(image) ? YES : NO];
}

- (void)mouseDown:(NSEvent*)event
{
    // dragging
    NSBitmapImageRep *colorImageRep = [self bitmapImageRepForCachingDisplayInRect:[self bounds]];
    [colorImageRep setSize:[self bounds].size];
    [self cacheDisplayInRect:[self bounds] toBitmapImageRep:colorImageRep];
    NSImage *dragImage = [[NSImage alloc]initWithSize:[self bounds].size] ;
    [dragImage addRepresentation:colorImageRep];
    
    NSDraggingItem *draggingItem = [[NSDraggingItem alloc] initWithPasteboardWriter:dragImage];
    [draggingItem setDraggingFrame:[self bounds] contents:dragImage];
    NSDraggingSession *session = [self beginDraggingSessionWithItems:[NSArray arrayWithObject:draggingItem] event:event source:self];
    [session setAnimatesToStartingPositionsOnCancelOrFail:NO];
    [session setDraggingFormation:NSDraggingFormationNone];
}

- (NSPoint)originWithScreenPoint:(NSPoint)screenPoint
{
    NSPoint pointInWindow = [[self window] convertPointFromScreen:screenPoint];
    NSPoint pointInView = [[self superview] convertPoint:pointInWindow fromView:nil];
    
    NSPoint viewOrigin = NSMakePoint(
                                     pointInView.x - _cursorPoint.x,
                                     pointInView.y - _cursorPoint.y
                                     );
    return viewOrigin;
}

#pragma mark NSDraggingSession

- (NSDragOperation)draggingSession:(NSDraggingSession *)session sourceOperationMaskForDraggingContext:(NSDraggingContext)context
{
    NSDragOperation dragOperation = (context == NSDraggingContextWithinApplication) ? NSDragOperationMove : NSDragOperationNone;
    return dragOperation;
}

- (void)draggingSession:(NSDraggingSession *)session willBeginAtPoint:(NSPoint)screenPoint
{
    [self setHidden:YES];
    
    _cursorPoint = [self convertPoint:[[self window] convertPointFromScreen:screenPoint] fromView:nil];
    
    if (_delegate && [_delegate respondsToSelector:@selector(view:didStartDraggingAtPoint:)]) {
        [_delegate view:self didStartDraggingAtPoint:[self originWithScreenPoint:screenPoint]];
    }
}

- (void)draggingSession:(NSDraggingSession *)session movedToPoint:(NSPoint)screenPoint
{
    NSPoint pointInWindow = [[self window] convertPointFromScreen:screenPoint];
    NSPoint pointInView = [[self superview] convertPoint:pointInWindow fromView:nil];
    NSPoint frameOrigin = [self originWithScreenPoint:screenPoint];
    
    if (NSMouseInRect(pointInView, NSInsetRect([[self superview] bounds], -20, -20),  NO)) {
        
        [[NSCursor closedHandCursor] set];
        _shouldBeRemoved = NO;
        
    } else {
        
        [[NSCursor disappearingItemCursor] set];
        _shouldBeRemoved = YES;
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(view:didMoveToPoint:)]) {
        [_delegate view:self didMoveToPoint:frameOrigin];
    }
}

- (void)draggingSession:(NSDraggingSession *)session endedAtPoint:(NSPoint)screenPoint operation:(NSDragOperation)operation
{
    if (_shouldBeRemoved) {
        
        [self setImage:nil];
        
        if (_delegate && [_delegate respondsToSelector:@selector(view:hasBeenRemovedFromSuperView:)]) {
            [_delegate view:self hasBeenRemovedFromSuperView:[self superview]];
        }
        
    } else {
        
        NSPoint frameOrigin = NSZeroPoint;
        NSEvent *currentEvent = [[NSApplication sharedApplication] currentEvent];

        if ([currentEvent type] == NSEventTypeLeftMouseUp ||[currentEvent type] == NSEventTypeLeftMouseDragged) {
            
            frameOrigin = [self originWithScreenPoint:screenPoint];
            
            if (frameOrigin.x < 0) {
                
                frameOrigin.x = 0;
                
            } else if ( frameOrigin.x > (NSWidth([[self superview] bounds]) - NSWidth([self bounds]))) {

                frameOrigin.x = NSWidth([[self superview] bounds]) - NSWidth([self bounds]);
            }
            
            if (frameOrigin.y < 0) {
                
                frameOrigin.y = 0;
                
            } else if ( frameOrigin.y > (NSHeight([[self superview] bounds]) - NSHeight([self bounds]))) {
                
                frameOrigin.y = NSHeight([[self superview] bounds]) - NSHeight([self bounds]);
            }
            
            [self setFrameOrigin:frameOrigin];
            
            if (_delegate && [_delegate respondsToSelector:@selector(view:didEndDraggingAtPoint:)]) {
                [_delegate view:self didEndDraggingAtPoint:frameOrigin];
            }
            
        } else {
            
            if (_delegate && [_delegate respondsToSelector:@selector(view:didCancelDraggingAtPoint:)]) {
                [_delegate view:self didCancelDraggingAtPoint:frameOrigin];
            }
        }
        
        [self setHidden:NO];
    }

    _cursorPoint = NSZeroPoint;
}

@end
