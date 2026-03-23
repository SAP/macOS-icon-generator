/*
    MTClearableTextFieldCell.m
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

#import "MTClearableTextFieldCell.h"

static const CGFloat kClearButtonSize   = 14.0;
static const CGFloat kClearButtonMargin = 6.0;

@implementation MTClearableTextFieldCell

#pragma mark - Button Rect

- (NSRect)clearButtonRectForBounds:(NSRect)bounds
{
    return NSMakeRect(
                      NSMaxX(bounds) - kClearButtonSize - kClearButtonMargin,
                      NSMidY(bounds) - kClearButtonSize / 2.0,
                      kClearButtonSize,
                      kClearButtonSize
                      );
}

#pragma mark - Drawing

- (void)drawWithFrame:(NSRect)cellFrame inView:(NSView *)controlView
{
    [super drawWithFrame:cellFrame inView:controlView];

    if ([[self stringValue] length] > 0) {
        
        NSImage *image = [NSImage imageWithSystemSymbolName:@"xmark.circle.fill" accessibilityDescription:nil];
        NSImageSymbolConfiguration *colorConfig = [NSImageSymbolConfiguration configurationWithPaletteColors:[NSArray arrayWithObjects:
                                                                                                              [NSColor controlBackgroundColor],
                                                                                                              [NSColor secondaryLabelColor],
                                                                                                              nil
                                                                                                             ]
        ];
        image = [image imageWithSymbolConfiguration:colorConfig];

        [[controlView effectiveAppearance] performAsCurrentDrawingAppearance:^{

            [image drawInRect:[self clearButtonRectForBounds:cellFrame]
                     fromRect:NSZeroRect
                    operation:NSCompositingOperationSourceOver
                     fraction:1.0
               respectFlipped:YES
                        hints:nil
             ];
        }];
    }
}

#pragma mark - Text Rect (padding right)

- (NSRect)textRectForBounds:(NSRect)bounds
{
    NSRect rect = [super drawingRectForBounds:bounds];
    rect.size.width -= (kClearButtonSize + kClearButtonMargin);
    return rect;
}

- (NSRect)titleRectForBounds:(NSRect)bounds
{
    return [self textRectForBounds:bounds];
}

- (NSRect)editingRectForBounds:(NSRect)bounds
{
    return [self textRectForBounds:bounds];
}

- (NSRect)drawingRectForBounds:(NSRect)bounds
{
    return [self textRectForBounds:bounds];
}

@end
