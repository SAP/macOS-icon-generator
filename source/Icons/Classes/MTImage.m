/*
     MTImage.m
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

#import "MTImage.h"

@implementation NSImage (MTImage)

- (NSImage*)imageRotatedByDegrees:(CGFloat)degrees
{
    NSSize imageSize = [self size];
    NSImage *rotatedImage = [NSImage imageWithSize:imageSize
                                           flipped:NO
                                    drawingHandler:^BOOL(NSRect dstRect) {
        // rotate from center
        NSPoint centerPoint = NSMakePoint(imageSize.width / 2.0, imageSize.height / 2.0);

        NSAffineTransform *rotate = [[NSAffineTransform alloc] init];
        [rotate translateXBy:centerPoint.x yBy:centerPoint.y];
        [rotate rotateByDegrees:degrees];
        [rotate translateXBy:-centerPoint.x yBy:-centerPoint.y];
        [rotate concat];
        
        [self drawInRect:dstRect
                fromRect:NSZeroRect
               operation:NSCompositingOperationCopy
                fraction:1.0];
        
        return YES;
    }];
    
    return rotatedImage;
}

- (NSImage*)imageScaledToSize:(CGSize)targetSize maintainAspectRatio:(BOOL)aspectRatio
{
    NSImage *scaledImage = nil;
    
    if ([self isValid]) {
        
        NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithData:[self TIFFRepresentation]];
        NSSize imageSize = NSMakeSize([imageRep pixelsWide], [imageRep pixelsHigh]);
        
        if (!CGSizeEqualToSize(imageSize, targetSize)) {
            
            NSSize rectSize = targetSize;
            CGFloat imageOriginX = 0;
            CGFloat imageOriginY = 0;
        
            if (aspectRatio) {
                                
                if (imageSize.width > imageSize.height) {
                    
                    CGFloat scaleFactor = targetSize.width / imageSize.width;
                    rectSize = NSMakeSize(imageSize.width * scaleFactor, imageSize.height * scaleFactor);
                    imageOriginY = (targetSize.height - rectSize.height) / 2.0;
                    
                } else {
                    
                    CGFloat scaleFactor = targetSize.height / imageSize.height;
                    rectSize = NSMakeSize(imageSize.width * scaleFactor, imageSize.height * scaleFactor);
                    imageOriginX = (targetSize.width - rectSize.width) / 2.0;
                    
                }
            }

            scaledImage = [NSImage imageWithSize:targetSize
                                         flipped:NO
                                  drawingHandler:^BOOL(NSRect dstRect) {
                
                [self drawInRect:NSMakeRect(
                                            imageOriginX,
                                            imageOriginY,
                                            rectSize.width,
                                            rectSize.height
                                            )
                ];
                
                return YES;
            }];
            
        } else {
            scaledImage = self;
        }
    }
    
    return scaledImage;
}

- (BOOL)canBeScaledToSize:(NSSize)scaleSize
{
    BOOL canBeScaled = NO;
        
    if ([self isValid]) {
    
        NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc] initWithData:[self TIFFRepresentation]];
        NSRect sourceImageFrame = NSMakeRect(0, 0, [imageRep pixelsWide], [imageRep pixelsHigh]);
        NSRect targetImageFrame = NSMakeRect(0, 0, scaleSize.width, scaleSize.height);
        
        canBeScaled = NSContainsRect(sourceImageFrame, targetImageFrame);
    }
    
    return canBeScaled;
}

- (NSData*)pngData
{
    NSData *imageData = nil;
    
    NSBitmapImageRep *bitmapData = [[NSBitmapImageRep alloc] initWithData:[self TIFFRepresentation]];
    NSDictionary *imageProps = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:1.0]
                                                               forKey:NSImageCompressionFactor];
    imageData = [bitmapData representationUsingType:NSBitmapImageFileTypePNG
                                         properties:imageProps];
    
    return imageData;
}

+ (NSImage*)imageWithFileAtPath:(NSString*)path
{
    NSImage *returnImage = nil;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        
        NSImage *sourceImage = nil;
        
        id utiValue = nil;
        NSURL *fileURL = [NSURL fileURLWithPath:path];
        [fileURL getResourceValue:&utiValue forKey:NSURLTypeIdentifierKey error:nil];
        
        if ([utiValue isEqualTo:(NSString*)kUTTypeApplicationBundle]) {
            sourceImage = [[NSWorkspace sharedWorkspace] iconForFile:path];
            
            if ([sourceImage isValid]) {
                
                // because NSWorkspace only gives us a icon with 32x32 pixels in size
                // we get the highest available resolution here
                NSImageRep *imageRep = [sourceImage bestRepresentationForRect:CGRectInfinite context:nil hints:nil];
                sourceImage = [[NSImage alloc] initWithSize:[imageRep size]];
                [sourceImage addRepresentation:imageRep];
            }
            
        } else {
            sourceImage = [[NSImage alloc] initWithContentsOfFile:path];
        }
        
        if ([sourceImage isValid]) { returnImage = sourceImage; }
    }
    
    return returnImage;
}

+ (NSImage*)imageWithView:(NSView*)view size:(NSSize)size;
{
    NSData *pdfData = [view dataWithPDFInsideRect:[view bounds]];
    NSPDFImageRep* pdfImageRep = [NSPDFImageRep imageRepWithData:pdfData];
    
    NSImage* scaledImage = [NSImage imageWithSize:size
                                          flipped:NO
                                   drawingHandler:^BOOL(NSRect dstRect) {
            [pdfImageRep drawInRect:dstRect];
            return YES;
        }
    ];

    return scaledImage;
}

@end
