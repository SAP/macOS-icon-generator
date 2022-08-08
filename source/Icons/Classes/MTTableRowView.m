/*
     MTTableRowView.m
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

#import "MTTableRowView.h"

@implementation MTTableRowView

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

- (void)drawSelectionInRect:(NSRect)dirtyRect
{
     if ([self selectionHighlightStyle] != NSTableViewSelectionHighlightStyleNone) {
     
         NSRect selectionRect = NSInsetRect([self bounds], -0.5, -0.5);
         NSBezierPath *selectionPath = [NSBezierPath bezierPathWithRect:selectionRect];
         NSColor *selectionColor = (_highlightColor) ? _highlightColor : [NSColor systemBlueColor];
         [selectionColor setStroke];
         [selectionPath stroke];
     }
}

@end
