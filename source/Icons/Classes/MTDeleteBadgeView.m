/*
    MTDeleteBadgeView.m
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

#import "MTDeleteBadgeView.h"

@implementation MTDeleteBadgeView

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    
    if (self) {
        
        [self setWantsLayer:YES];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    
    if (self) {
        
        [self setWantsLayer:YES];
    }
    
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    MTDeleteBadgeView *copiedView = [[[self class] allocWithZone:zone] initWithFrame:[self frame]];

    if (copiedView) {
        
        [copiedView setImage:[[self image] copyWithZone:zone]];
        [copiedView setShowsShadow:_showsShadow];
        [copiedView setShadowOffset:_shadowOffset];
        [copiedView setShadowAngle:_shadowAngle];
        [copiedView setShadowColor:[_shadowColor copyWithZone:zone]];
        [copiedView setShadowRadius:_shadowRadius];
    }
    
    return copiedView;
}

- (void)layout
{
    [super layout];
    [self updateShadow];
}

- (void)setShowsShadow:(BOOL)show
{
    _showsShadow = show;
    [[self layer] setShadowOpacity:(show) ? 1.0 : 0];
    [self layout];
}

- (void)setShadowAngle:(CGFloat)shadowAngle
{
    _shadowAngle = shadowAngle;
    [self layout];
}

- (void)setShadowOffset:(CGFloat)shadowOffset
{
    _shadowOffset = shadowOffset;
    [self layout];
}

- (void)setShadowRadius:(CGFloat)shadowRadius
{
    _shadowRadius = shadowRadius;
    [self layout];
}

- (void)setShadowColor:(NSColor *)shadowColor
{
    _shadowColor = shadowColor;
    [self layout];
}

- (void)updateShadow
{
    CGFloat viewWidth = NSWidth([self bounds]);

    // correct the angle to match the coordinate system of a circular slider
    CGFloat correctedAngle = _shadowAngle - 90;

    // calculate offset
    CGFloat radians = correctedAngle * M_PI / 180.0;
    CGFloat x = viewWidth * _shadowOffset * cos(radians);
    CGFloat y = viewWidth * _shadowOffset * sin(radians) * -1;
    
    [[self layer] setShadowColor:(_shadowColor) ? [_shadowColor CGColor] : [[NSColor colorWithWhite:0 alpha:.5] CGColor]];
    [[self layer] setShadowOffset:NSMakeSize(x, y)];
    [[self layer] setShadowRadius:viewWidth * _shadowRadius];
}

@end

