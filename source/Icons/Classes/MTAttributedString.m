/*
     MTAttributedString.m
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

#import "MTAttributedString.h"

@implementation NSAttributedString (MTAttributedString)

- (instancetype)initWithString:(NSString*)string
                          font:(NSFont*)font
               foregroundColor:(NSColor*)foregroundColor
               backgroundColor:(NSColor*)backgroundColor
{
    NSMutableAttributedString *attrString = nil;
    
    if (string) {
        
        attrString = [[NSMutableAttributedString alloc] initWithString:string];
    
        NSRange stringRange = NSMakeRange(0,[string length]);
        if (font) { [attrString addAttribute:NSFontAttributeName value:font range:stringRange]; }
        if (foregroundColor) { [attrString addAttribute:NSForegroundColorAttributeName value:foregroundColor range:stringRange]; }
        if (backgroundColor) { [attrString addAttribute:NSBackgroundColorAttributeName value:backgroundColor range:stringRange]; }
    }

    return attrString;
}

- (NSColor*)textColor
{
    NSColor *color = [self attribute:NSForegroundColorAttributeName atIndex:0 effectiveRange:nil];
    if (!color) { color = [NSColor blackColor]; }
    
    return color;
}

- (NSColor*)backgroundColor
{
    return [self attribute:NSBackgroundColorAttributeName atIndex:0 effectiveRange:nil];
}

- (NSFont*)font
{
    return [self attribute:NSFontAttributeName atIndex:0 effectiveRange:nil];
}

- (NSAttributedString*)attributedStringWithTextColor:(NSColor*)color
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithAttributedString:self];
    [attrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, [attrString length])];
    
    return attrString;
}

- (NSAttributedString*)attributedStringWithBackgroundColor:(NSColor*)color
{
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithAttributedString:self];
    [attrString addAttribute:NSBackgroundColorAttributeName value:color range:NSMakeRange(0, [attrString length])];
    
    return attrString;
}

- (CGFloat)fontSizeToFitInRect:(NSRect)rect withMinimumFontSize:(CGFloat)minFontSize
{
    CGFloat fontSize = NSHeight(rect);
    CGFloat textHeight = FLT_MAX;
    CGFloat textWidth = FLT_MAX;
    NSFont *font = ([self font]) ? [self font] : [NSFont systemFontOfSize:13.0];
        
    while ((textHeight > NSHeight(rect) || textWidth > NSWidth(rect)) && fontSize >= minFontSize) {

        font = [[NSFontManager sharedFontManager] convertFont:font toSize:fontSize--];
        
        NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:self];
        NSTextContainer *textContainer = [[NSTextContainer alloc] initWithContainerSize: NSMakeSize(FLT_MAX, FLT_MAX)];
        NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
        [layoutManager addTextContainer:textContainer];
        [textStorage addLayoutManager:layoutManager];
        [textStorage addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, [textStorage length])];
        [textContainer setLineFragmentPadding:0.0];
        [layoutManager glyphRangeForTextContainer:textContainer];
        textHeight = [layoutManager usedRectForTextContainer:textContainer].size.height;
        textWidth = [layoutManager usedRectForTextContainer:textContainer].size.width;
    }
    
    return ++fontSize;
}

@end
