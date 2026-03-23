/*
    MTClearableTextField.m
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

#import "MTClearableTextField.h"
#import "MTClearableTextFieldCell.h"

@interface MTClearableTextField ()
@property (nonatomic, strong, readwrite) NSTrackingArea *trackingArea;
@end

@implementation MTClearableTextField

- (void)updateTrackingAreas
{
    [super updateTrackingAreas];

    if (_trackingArea) { [self removeTrackingArea:_trackingArea]; }

    _trackingArea = [[NSTrackingArea alloc] initWithRect:[self bounds]
                                                 options:NSTrackingMouseEnteredAndExited | NSTrackingMouseMoved | NSTrackingActiveInKeyWindow
                                                   owner:self
                                                userInfo:nil
    ];
    
    [self addTrackingArea:_trackingArea];
}

- (void)mouseMoved:(NSEvent *)event
{
    NSPoint point = [self convertPoint:event.locationInWindow fromView:nil];
    MTClearableTextFieldCell *cell = (MTClearableTextFieldCell*)[self cell];
    NSRect clearRect = [cell clearButtonRectForBounds:[self bounds]];

    (NSPointInRect(point, clearRect)) ? [[NSCursor arrowCursor] set] : [[NSCursor IBeamCursor] set];
}

- (void)mouseExited:(NSEvent *)event
{
    [[NSCursor IBeamCursor] set];
}

- (void)mouseDown:(NSEvent *)event
{
    NSPoint point = [self convertPoint:event.locationInWindow fromView:nil];
    MTClearableTextFieldCell *cell = (MTClearableTextFieldCell*)[self cell];
    NSRect clearRect = [cell clearButtonRectForBounds:[self bounds]];
   
    if (NSPointInRect(point, clearRect)) {

        NSDictionary *info = [self infoForBinding:NSValueBinding];
        id observedObject = [info objectForKey:NSObservedObjectKey];
        NSString *keyPath = [info objectForKey:NSObservedKeyPathKey];
        [observedObject setValue:@"" forKeyPath:keyPath];
        
        [self setStringValue:@""];
        
        [self sendAction:[self action] to:[self target]];
        
    } else {

        [super mouseDown:event];
    }
}

- (NSView *)hitTest:(NSPoint)point
{
    return (NSPointInRect(point, [self frame])) ? self : nil;
}

@end
