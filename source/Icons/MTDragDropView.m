/*
    MTDragDropView.m
    Copyright 2016-2017 SAP SE
 
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

#import "MTDragDropView.h"

@interface MTDragDropView ()
@property (nonatomic, assign) BOOL highlight;
@end

@implementation MTDragDropView

- (id)initWithCoder:(NSCoder*)coder
{
    self = [super initWithCoder:coder];
    
    if (self) {
        [self registerForDraggedTypes:[NSArray arrayWithObject:NSFilenamesPboardType]];
    }
    
    return self;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    _highlight = YES;
    [self setNeedsDisplay: YES];
    return NSDragOperationCopy;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    _highlight = NO;
    [self setNeedsDisplay: YES];
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    _highlight = NO;
    [self setNeedsDisplay: YES];
    return YES;
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender
{
    NSArray *draggedFilenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    NSString *pathExtension = [[draggedFilenames objectAtIndex:0] pathExtension];
    
    if ([pathExtension isEqual:@"app"] || [pathExtension isEqual:@"png"] || [pathExtension isEqual:@"jpg"] || [pathExtension isEqual:@"jpeg"]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
    NSArray *draggedFilenames = [[sender draggingPasteboard] propertyListForType:NSFilenamesPboardType];
    NSString *itemPath = [draggedFilenames firstObject];
    
    if ([[itemPath pathExtension] isEqualToString:@"app"]) {
        NSBundle *appBundle = [NSBundle bundleWithPath:itemPath];
        NSString *iconName = [appBundle objectForInfoDictionaryKey:@"CFBundleIconFile"];
        iconName = [[iconName componentsSeparatedByString:@"."] firstObject];

        if (iconName) { itemPath = [appBundle pathForResource:iconName ofType:@"icns"]; }
    }
    
    if (itemPath) {
                
        NSImage *currentImage = [[NSImage alloc] initWithContentsOfFile:itemPath];
        if (currentImage) { [self setImage:currentImage]; }
    }
}

- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    
    if (_highlight) {
        
        NSRect roundedRect = NSMakeRect(rect.origin.x + 3, rect.origin.y + 3, rect.size.width - 6, rect.size.height - 6);
        [[[NSColor blackColor] colorWithAlphaComponent:0.3] set];
        [NSBezierPath setDefaultLineWidth:5];
        NSBezierPath *roundedPath = [NSBezierPath bezierPathWithRoundedRect:roundedRect xRadius:5 yRadius:5];
        [roundedPath fill];
    }
}

@end
