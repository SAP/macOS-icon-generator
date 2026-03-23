/*
    MTIconView.m
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

#import "MTIconView.h"
#import "Constants.h"
#import <QuartzCore/CAShapeLayer.h>

@interface MTIconView ()
@property (assign) NSRect boundingRect;
@property (assign) CGFloat cornerRadius;
@end

@implementation MTIconView

- (instancetype)initWithFrame:(NSRect)frameRect
{
    self = [super initWithFrame:frameRect];
    
    if (self) {
        
        [self setWantsLayer:YES];
        [self updateBoundsWithRect:[self bounds]];
    }
    
    return self;
}

- (void)updateBoundsWithRect:(NSRect)bounds
{
    _boundingRect = NSInsetRect(
                                bounds,
                                NSWidth(bounds) * .097,
                                NSHeight(bounds) * .099
                                );
    
    _cornerRadius = (_usesOldIconShape) ? NSWidth(bounds) * .18 : NSWidth(bounds) * .205;
}

- (void)updateLayers
{
    [[[self layer] sublayers] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];

    NSRect bounds = [self bounds];
    [self updateBoundsWithRect:bounds];

    // draw the icon shape
    CALayer *containerLayer = [[CALayer alloc] init];
    [containerLayer setFrame:_boundingRect];
    [containerLayer setBackgroundColor:[NSColor whiteColor].CGColor];
    [containerLayer setCornerRadius:_cornerRadius];
    
    // draw the icon's drop shadow
    [containerLayer setShadowColor:[NSColor blackColor].CGColor];
    [containerLayer setShadowOffset:CGSizeMake(0, -(NSWidth(bounds) * .0095))];
    [containerLayer setShadowRadius:NSWidth(bounds) * .013];
    [containerLayer setShadowOpacity:.3];

    [[self layer] addSublayer:containerLayer];

    // draw the image
    if ([_image isValid]) {

        CGImageRef cgImage = [_image CGImageForProposedRect:NULL context:nil hints:nil];

        CALayer *imageLayer = [[CALayer alloc] init];
        [imageLayer setFrame:[containerLayer bounds]];
        [imageLayer setContents:(__bridge id)cgImage];
        [imageLayer setContentsGravity:kCAGravityResizeAspectFill];

        NSRect imageLayerBounds = [imageLayer bounds];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        [maskLayer setFrame:imageLayerBounds];
        
        CGPathRef roundedPath = CGPathCreateWithRoundedRect(
                                                            imageLayerBounds,
                                                            _cornerRadius,
                                                            _cornerRadius,
                                                            NULL
                                                            );
        [maskLayer setPath:roundedPath];
        CGPathRelease(roundedPath);

        [imageLayer setMask:maskLayer];

        [containerLayer addSublayer:imageLayer];
    }
}

- (void)layout
{
    [super layout];
    [self updateLayers];
}

@end

